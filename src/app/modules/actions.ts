"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import type {
  AttemptState,
  ExpireQuestionResult,
  StartSessionResult,
} from "@/lib/action-state";
import { pointsLabel, scoreForAttempt } from "@/lib/scoring";
import type {
  ModuleSessionRow,
  QuestionSessionRow,
} from "@/lib/types";

type SupabaseServerClient = Awaited<ReturnType<typeof createClient>>;

const moduleSessionColumns =
  "id, user_id, module_id, started_at, expires_at, completed_at";

const questionSessionColumns =
  "id, module_session_id, exercise_id, started_at, expires_at, submitted_at";

/** Después del cuarto intento el ejercicio ya no suma puntos. */
const MAX_ATTEMPTS = 4;

type ModuleTiming = {
  id: string;
  module_time_limit_minutes: number | null;
  question_time_limit_seconds: number | null;
};

function nowIso() {
  return new Date().toISOString();
}

function positiveLimit(value: number | null | undefined) {
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : null;
}

function sessionExpired(expiresAt: string | null) {
  return Boolean(expiresAt && new Date(expiresAt).getTime() <= Date.now());
}

async function getModuleTiming(
  supabase: SupabaseServerClient,
  moduleId: string,
): Promise<ModuleTiming | null> {
  const { data } = await supabase
    .from("modules")
    .select("id, module_time_limit_minutes, question_time_limit_seconds")
    .eq("id", moduleId)
    .maybeSingle();

  return (data as ModuleTiming | null) ?? null;
}

async function ensureModuleSession(
  supabase: SupabaseServerClient,
  userId: string,
  moduleId: string,
  moduleLimitMinutes: number | null,
): Promise<ModuleSessionRow | null> {
  const { data: existing } = await supabase
    .from("module_sessions")
    .select(moduleSessionColumns)
    .eq("user_id", userId)
    .eq("module_id", moduleId)
    .maybeSingle();

  const minutes = positiveLimit(moduleLimitMinutes);

  if (existing) {
    const session = existing as ModuleSessionRow;

    // Si el administrador acaba de activar o quitar el límite del
    // módulo, ajustamos la sesión existente.
    if (minutes && !session.expires_at) {
      const { data: updated } = await supabase
        .from("module_sessions")
        .update({
          expires_at: new Date(
            Date.now() + minutes * 60_000,
          ).toISOString(),
        })
        .eq("id", session.id)
        .select(moduleSessionColumns)
        .single();

      return (updated as ModuleSessionRow | null) ?? session;
    }

    if (!minutes && session.expires_at) {
      const { data: updated } = await supabase
        .from("module_sessions")
        .update({ expires_at: null })
        .eq("id", session.id)
        .select(moduleSessionColumns)
        .single();

      return (updated as ModuleSessionRow | null) ?? session;
    }

    return session;
  }

  const expiresAt = minutes
    ? new Date(Date.now() + minutes * 60_000).toISOString()
    : null;

  const { data, error } = await supabase
    .from("module_sessions")
    .insert({
      user_id: userId,
      module_id: moduleId,
      expires_at: expiresAt,
    })
    .select(moduleSessionColumns)
    .single();

  if (!error && data) return data as ModuleSessionRow;

  // Si dos peticiones intentaron crear la sesión a la vez, leemos la ganadora.
  const { data: retry } = await supabase
    .from("module_sessions")
    .select(moduleSessionColumns)
    .eq("user_id", userId)
    .eq("module_id", moduleId)
    .maybeSingle();

  return (retry as ModuleSessionRow | null) ?? null;
}

async function ensureQuestionSession(
  supabase: SupabaseServerClient,
  moduleSessionId: string,
  exerciseId: string,
  limitSeconds: number | null,
): Promise<QuestionSessionRow | null> {
  const { data: existing } = await supabase
    .from("question_sessions")
    .select(questionSessionColumns)
    .eq("module_session_id", moduleSessionId)
    .eq("exercise_id", exerciseId)
    .maybeSingle();

  const seconds = positiveLimit(limitSeconds);

  if (existing) {
    const session = existing as QuestionSessionRow;

    // Si el administrador activa o quita el límite por pregunta
    // mientras la pregunta está abierta, ajustamos su sesión.
    if (seconds && !session.expires_at && !session.submitted_at) {
      const { data: updated } = await supabase
        .from("question_sessions")
        .update({
          expires_at: new Date(
            Date.now() + seconds * 1_000,
          ).toISOString(),
        })
        .eq("id", session.id)
        .select(questionSessionColumns)
        .single();

      return (updated as QuestionSessionRow | null) ?? session;
    }

    if (!seconds && session.expires_at) {
      const { data: updated } = await supabase
        .from("question_sessions")
        .update({ expires_at: null })
        .eq("id", session.id)
        .select(questionSessionColumns)
        .single();

      return (updated as QuestionSessionRow | null) ?? session;
    }

    return session;
  }

  const expiresAt = seconds
    ? new Date(Date.now() + seconds * 1_000).toISOString()
    : null;

  const { data, error } = await supabase
    .from("question_sessions")
    .insert({
      module_session_id: moduleSessionId,
      exercise_id: exerciseId,
      expires_at: expiresAt,
    })
    .select(questionSessionColumns)
    .single();

  if (!error && data) return data as QuestionSessionRow;

  const { data: retry } = await supabase
    .from("question_sessions")
    .select(questionSessionColumns)
    .eq("module_session_id", moduleSessionId)
    .eq("exercise_id", exerciseId)
    .maybeSingle();

  return (retry as QuestionSessionRow | null) ?? null;
}

async function closeQuestionWithTimeout(
  supabase: SupabaseServerClient,
  userId: string,
  moduleId: string,
  exerciseId: string,
  questionSessionId: string,
) {
  const { data: updated } = await supabase
    .from("question_sessions")
    .update({ submitted_at: nowIso() })
    .eq("id", questionSessionId)
    .is("submitted_at", null)
    .select("id");

  if (!updated || updated.length === 0) return;

  await supabase.from("attempts").insert({
    user_id: userId,
    module_id: moduleId,
    exercise_id: exerciseId,
    answer: { timeout: true },
    is_correct: false,
  });

  revalidatePath("/dashboard");
}

/* ------------------------------------------------------------
 * Temporizadores
 * ---------------------------------------------------------- */

export async function startModuleSession(
  moduleId: string,
): Promise<StartSessionResult> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return {
      ok: false,
      reason: "auth",
      message: "Tu sesión expiró. Vuelve a iniciar sesión.",
      serverNow: nowIso(),
    };
  }

  if (!moduleId) {
    return {
      ok: false,
      reason: "not_found",
      message: "No se recibió el módulo.",
      serverNow: nowIso(),
    };
  }

  const module = await getModuleTiming(supabase, moduleId);

  if (!module) {
    return {
      ok: false,
      reason: "not_found",
      message: "No se encontró el módulo o no tienes acceso.",
      serverNow: nowIso(),
    };
  }

  const session = await ensureModuleSession(
    supabase,
    user.id,
    module.id,
    module.module_time_limit_minutes,
  );

  if (!session) {
    return {
      ok: false,
      reason: "error",
      message: "No se pudo iniciar la sesión del módulo.",
      serverNow: nowIso(),
    };
  }

  return {
    ok: true,
    serverNow: nowIso(),
    moduleExpiresAt: session.expires_at,
    questionExpiresAt: null,
    questionSubmittedAt: null,
  };
}

export async function startQuestion(
  exerciseId: string,
): Promise<StartSessionResult> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return {
      ok: false,
      reason: "auth",
      message: "Tu sesión expiró. Vuelve a iniciar sesión.",
      serverNow: nowIso(),
    };
  }

  const { data: exercise } = await supabase
    .from("exercises")
    .select("id, module_id")
    .eq("id", exerciseId)
    .maybeSingle();

  if (!exercise) {
    return {
      ok: false,
      reason: "not_found",
      message: "No se encontró el ejercicio.",
      serverNow: nowIso(),
    };
  }

  const module = await getModuleTiming(supabase, exercise.module_id);

  if (!module) {
    return {
      ok: false,
      reason: "not_found",
      message: "No se encontró el módulo o no tienes acceso.",
      serverNow: nowIso(),
    };
  }

  const session = await ensureModuleSession(
    supabase,
    user.id,
    module.id,
    module.module_time_limit_minutes,
  );

  if (!session) {
    return {
      ok: false,
      reason: "error",
      message: "No se pudo iniciar la sesión del módulo.",
      serverNow: nowIso(),
    };
  }

  if (sessionExpired(session.expires_at)) {
    return {
      ok: false,
      reason: "module_expired",
      message: "El tiempo del módulo terminó.",
      serverNow: nowIso(),
    };
  }

  const questionSession = await ensureQuestionSession(
    supabase,
    session.id,
    exercise.id,
    module.question_time_limit_seconds,
  );

  if (!questionSession) {
    return {
      ok: false,
      reason: "error",
      message: "No se pudo iniciar el tiempo de la pregunta.",
      serverNow: nowIso(),
    };
  }

  return {
    ok: true,
    serverNow: nowIso(),
    moduleExpiresAt: session.expires_at,
    questionExpiresAt: questionSession.expires_at,
    questionSubmittedAt: questionSession.submitted_at,
  };
}

export async function expireQuestion(
  exerciseId: string,
): Promise<ExpireQuestionResult> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return {
      ok: false,
      reason: "auth",
      message: "Tu sesión expiró. Vuelve a iniciar sesión.",
      serverNow: nowIso(),
    };
  }

  const { data: exercise } = await supabase
    .from("exercises")
    .select("id, module_id")
    .eq("id", exerciseId)
    .maybeSingle();

  if (!exercise) {
    return {
      ok: false,
      reason: "not_found",
      message: "No se encontró el ejercicio.",
      serverNow: nowIso(),
    };
  }

  const module = await getModuleTiming(supabase, exercise.module_id);

  if (!module) {
    return {
      ok: false,
      reason: "not_found",
      message: "No se encontró el módulo.",
      serverNow: nowIso(),
    };
  }

  const session = await ensureModuleSession(
    supabase,
    user.id,
    module.id,
    module.module_time_limit_minutes,
  );

  if (!session) {
    return {
      ok: false,
      reason: "error",
      message: "No se pudo leer la sesión del módulo.",
      serverNow: nowIso(),
    };
  }

  if (sessionExpired(session.expires_at)) {
    return {
      ok: false,
      reason: "module_expired",
      message: "El tiempo del módulo terminó.",
      serverNow: nowIso(),
    };
  }

  const questionSession = await ensureQuestionSession(
    supabase,
    session.id,
    exercise.id,
    module.question_time_limit_seconds,
  );

  if (!questionSession) {
    return {
      ok: false,
      reason: "error",
      message: "No se pudo leer el tiempo de la pregunta.",
      serverNow: nowIso(),
    };
  }

  if (questionSession.submitted_at) {
    return {
      ok: true,
      serverNow: nowIso(),
      expired: true,
      alreadySubmitted: true,
    };
  }

  if (!sessionExpired(questionSession.expires_at)) {
    return {
      ok: true,
      serverNow: nowIso(),
      expired: false,
      alreadySubmitted: false,
    };
  }

  await closeQuestionWithTimeout(
    supabase,
    user.id,
    module.id,
    exercise.id,
    questionSession.id,
  );

  return {
    ok: true,
    serverNow: nowIso(),
    expired: true,
    alreadySubmitted: false,
  };
}

/* ------------------------------------------------------------
 * Corrección de intentos
 * ---------------------------------------------------------- */

/**
 * Corrige un intento en el servidor. El cliente nunca recibe las
 * respuestas correctas antes de responder.
 *
 * Si el módulo o la pregunta tienen límite de tiempo, el servidor
 * comprueba el plazo antes de aceptar la respuesta.
 */
export async function submitAttempt(
  _previousState: AttemptState,
  formData: FormData,
): Promise<AttemptState> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return {
      status: "error",
      message: "Tu sesión expiró. Vuelve a iniciar sesión.",
    };
  }

  const exerciseId = String(formData.get("exercise_id") ?? "");

  if (!exerciseId) {
    return { status: "error", message: "No se recibió el ejercicio." };
  }

  const { data: exercise, error: exerciseError } = await supabase
    .from("exercises")
    .select(
      "id, module_id, type, correct_option, correct_answer, tolerance, explanation",
    )
    .eq("id", exerciseId)
    .maybeSingle();

  if (exerciseError || !exercise) {
    return {
      status: "error",
      message: "No se encontró el ejercicio o no está disponible.",
    };
  }

  const module = await getModuleTiming(supabase, exercise.module_id);
  const moduleLimit = positiveLimit(module?.module_time_limit_minutes ?? null);
  const questionLimit = positiveLimit(
    module?.question_time_limit_seconds ?? null,
  );

  let questionSession: QuestionSessionRow | null = null;

  if (module && (moduleLimit || questionLimit)) {
    const session = await ensureModuleSession(
      supabase,
      user.id,
      module.id,
      moduleLimit,
    );

    if (!session) {
      return {
        status: "error",
        message: "No se pudo leer la sesión del módulo.",
      };
    }

    if (sessionExpired(session.expires_at)) {
      return {
        status: "expired",
        message: "El tiempo del módulo terminó. Ya no puedes responder.",
      };
    }

    if (questionLimit) {
      questionSession = await ensureQuestionSession(
        supabase,
        session.id,
        exercise.id,
        questionLimit,
      );

      if (!questionSession) {
        return {
          status: "error",
          message: "No se pudo leer el tiempo de la pregunta.",
        };
      }

      if (questionSession.submitted_at) {
        return {
          status: "expired",
          message: "Esta pregunta ya se cerró.",
        };
      }

      if (sessionExpired(questionSession.expires_at)) {
        await closeQuestionWithTimeout(
          supabase,
          user.id,
          module.id,
          exercise.id,
          questionSession.id,
        );

        return {
          status: "expired",
          message: "Se acabó el tiempo de esta pregunta.",
        };
      }
    }
  }

  let answer: Record<string, unknown>;
  let isCorrect = false;

  // Un ejercicio ya resuelto o con los 4 intentos usados queda cerrado:
  // no se aceptan más respuestas.
  const { data: previousAttemptRows } = await supabase
    .from("attempts")
    .select("id, is_correct, created_at")
    .eq("user_id", user.id)
    .eq("exercise_id", exercise.id)
    .order("created_at", { ascending: true });

  const previousAttempts = previousAttemptRows ?? [];
  const alreadyCorrect = previousAttempts.some((attempt) => attempt.is_correct);

  if (alreadyCorrect) {
    return {
      status: "locked",
      message:
        "Ya respondiste correctamente este ejercicio. No se aceptan más respuestas.",
    };
  }

  if (previousAttempts.length >= MAX_ATTEMPTS) {
    return {
      status: "locked",
      message:
        "Agotaste los 4 intentos de este ejercicio. No se aceptan más respuestas.",
    };
  }

  const attemptNumber = previousAttempts.length + 1;

  if (exercise.type === "multiple_choice") {
    const optionRaw = formData.get("option");
    const selected =
      typeof optionRaw === "string" && optionRaw !== ""
        ? Number(optionRaw)
        : Number.NaN;

    if (!Number.isInteger(selected)) {
      return {
        status: "error",
        message: "Selecciona una opción antes de enviar.",
      };
    }

    answer = { option: selected };
    isCorrect = selected === Number(exercise.correct_option);
  } else {
    const raw = String(formData.get("answer") ?? "")
      .trim()
      .replace(",", ".");

    const value = Number(raw);

    if (!raw || !Number.isFinite(value)) {
      return {
        status: "error",
        message: "Escribe una respuesta numérica válida.",
      };
    }

    answer = { value };

    const tolerance = Number(exercise.tolerance ?? 0);
    const correct = Number(exercise.correct_answer);
    const margin = Number.isFinite(tolerance) && tolerance > 0 ? tolerance : 1e-9;

    isCorrect = Math.abs(value - correct) <= margin;
  }

  // Guardamos el intento; su número define el puntaje del acierto.
  const { error: insertError } = await supabase.from("attempts").insert({
    user_id: user.id,
    module_id: exercise.module_id,
    exercise_id: exercise.id,
    answer,
    is_correct: isCorrect,
  });

  if (insertError) {
    return {
      status: "error",
      message: "No se pudo guardar tu intento. Inténtalo de nuevo.",
    };
  }

  // Una respuesta correcta cierra la pregunta. También se cierra al
  // agotar los 4 intentos; no se aceptan respuestas posteriores.
  if ((isCorrect || attemptNumber >= MAX_ATTEMPTS) && questionSession) {
    await supabase
      .from("question_sessions")
      .update({ submitted_at: nowIso() })
      .eq("id", questionSession.id)
      .is("submitted_at", null);
  }

  revalidatePath("/dashboard");

  if (isCorrect) {
    const points = scoreForAttempt(attemptNumber);

    return {
      status: "correct",
      message:
        points > 0
          ? `¡Correcto! Ganaste ${pointsLabel(points)}.`
          : "¡Correcto! Pero como fue tu cuarto intento o posterior, este ejercicio suma 0 puntos.",
      explanation: exercise.explanation ?? null,
      points,
      attemptNumber,
    };
  }

  if (attemptNumber >= MAX_ATTEMPTS) {
    return {
      status: "locked",
      message:
        "Se agotaron los 4 intentos de este ejercicio. Ya no puedes enviar más respuestas.",
      explanation: exercise.explanation ?? null,
    };
  }

  const nextPoints = scoreForAttempt(attemptNumber + 1);

  return {
    status: "incorrect",
    message: `Todavía no es correcto. Si aciertas en el siguiente intento ganas ${pointsLabel(nextPoints)}.`,
    explanation: exercise.explanation ?? null,
    attemptNumber,
    nextPoints,
  };
}
