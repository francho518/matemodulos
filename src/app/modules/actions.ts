"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import type { AttemptState } from "@/lib/action-state";

/**
 * Corrige un intento en el servidor. El cliente nunca recibe las
 * respuestas correctas antes de responder.
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

  let answer: Record<string, number>;
  let isCorrect = false;

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

  revalidatePath("/dashboard");

  return {
    status: isCorrect ? "correct" : "incorrect",
    message: isCorrect
      ? "¡Correcto! Buen trabajo."
      : "Todavía no es correcto. Revísalo e inténtalo de nuevo.",
    explanation: exercise.explanation ?? null,
  };
}
