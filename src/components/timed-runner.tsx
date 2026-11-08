"use client";

import Link from "next/link";
import { useActionState, useEffect, useState } from "react";
import {
  expireQuestion,
  startModuleSession,
  startQuestion,
  submitAttempt,
} from "@/app/modules/actions";
import { MathText } from "@/components/math-text";
import { formatScore } from "@/lib/scoring";
import type { AttemptState } from "@/lib/action-state";
import type { PublicExercise } from "@/lib/types";

export type QuestionSessionInfo = {
  exerciseId: string;
  expiresAt: string | null;
  submittedAt: string | null;
};

type Props = {
  moduleId: string;
  exercises: PublicExercise[];
  solvedIds: string[];
  lockedByAttemptsIds: string[];
  initialEarnedPoints: number;
  moduleTimeLimitMinutes: number | null;
  questionTimeLimitSeconds: number | null;
  initialModuleExpiresAt: string | null;
  initialQuestionSessions: QuestionSessionInfo[];
  serverNow: string;
};

function formatClock(milliseconds: number) {
  const totalSeconds = Math.max(0, Math.ceil(milliseconds / 1000));
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  if (hours > 0) {
    return `${hours}:${String(minutes).padStart(2, "0")}:${String(
      seconds,
    ).padStart(2, "0")}`;
  }

  return `${minutes}:${String(seconds).padStart(2, "0")}`;
}

function useRemainingMs(
  expiresAt: string | null,
  serverNow: string | null,
) {
  const [remaining, setRemaining] = useState<number | null>(null);

  useEffect(() => {
    if (!expiresAt || !serverNow) {
      setRemaining(null);
      return;
    }

    // Corrige la diferencia entre el reloj del servidor y el del navegador.
    const skew = new Date(serverNow).getTime() - Date.now();
    const deadline = new Date(expiresAt).getTime() - skew;

    const update = () => setRemaining(Math.max(0, deadline - Date.now()));
    update();

    const timer = window.setInterval(update, 1000);
    return () => window.clearInterval(timer);
  }, [expiresAt, serverNow]);

  return remaining;
}

function initialDoneIds(
  solvedIds: string[],
  sessions: QuestionSessionInfo[],
  lockedByAttemptsIds: string[],
) {
  const done = new Set<string>([...solvedIds, ...lockedByAttemptsIds]);

  for (const session of sessions) {
    if (session.submittedAt) done.add(session.exerciseId);
  }

  return done;
}

export function TimedRunner({
  moduleId,
  exercises,
  solvedIds,
  lockedByAttemptsIds,
  initialEarnedPoints,
  moduleTimeLimitMinutes,
  questionTimeLimitSeconds,
  initialModuleExpiresAt,
  initialQuestionSessions,
  serverNow: initialServerNow,
}: Props) {
  const [solved, setSolved] = useState(() => new Set(solvedIds));
  const [earned, setEarned] = useState(initialEarnedPoints);
  const [done, setDone] = useState(() =>
    initialDoneIds(solvedIds, initialQuestionSessions, lockedByAttemptsIds),
  );
  const [index, setIndex] = useState(() => {
    const finished = initialDoneIds(
      solvedIds,
      initialQuestionSessions,
      lockedByAttemptsIds,
    );
    const next = exercises.findIndex((exercise) => !finished.has(exercise.id));
    return next === -1 ? exercises.length : next;
  });

  const [moduleExpiresAt, setModuleExpiresAt] = useState(
    initialModuleExpiresAt,
  );
  const [serverNow, setServerNow] = useState(initialServerNow);
  const [startError, setStartError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    startModuleSession(moduleId)
      .then((result) => {
        if (cancelled) return;

        if (result.ok) {
          setModuleExpiresAt(result.moduleExpiresAt);
          setServerNow(result.serverNow);
          return;
        }

        setServerNow(result.serverNow);

        if (result.reason === "module_expired") {
          setModuleExpiresAt(new Date(0).toISOString());
          return;
        }

        setStartError(result.message);
      })
      .catch(() => {
        if (!cancelled) {
          setStartError("No se pudo iniciar el módulo. Recarga la página.");
        }
      });

    return () => {
      cancelled = true;
    };
  }, [moduleId]);

  const moduleRemaining = useRemainingMs(moduleExpiresAt, serverNow);
  const moduleExpired =
    moduleRemaining !== null && moduleRemaining <= 0;

  const handleDone = (
    exerciseId: string,
    outcome: "correct" | "timeout" | "locked",
    points = 0,
  ) => {
    if (done.has(exerciseId)) return;

    const nextDone = new Set(done);
    nextDone.add(exerciseId);
    setDone(nextDone);

    if (outcome === "correct") {
      const nextSolved = new Set(solved);
      nextSolved.add(exerciseId);
      setSolved(nextSolved);
      setEarned((previous) => previous + points);
    }

    const nextIndex = exercises.findIndex(
      (exercise) => !nextDone.has(exercise.id),
    );
    setIndex(nextIndex === -1 ? exercises.length : nextIndex);
  };

  const current = index < exercises.length ? exercises[index] : null;
  const allSolved = exercises.length > 0 && solved.size === exercises.length;

  return (
    <div className="mt-6">
      {startError && (
        <p className="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {startError}
        </p>
      )}

      <div className="card p-5 sm:p-6">
        <div className="flex flex-col justify-between gap-3 sm:flex-row sm:items-center">
          <div>
            <p className="text-xs font-semibold uppercase tracking-wider text-indigo-600">
              {moduleTimeLimitMinutes || questionTimeLimitSeconds
                ? "Módulo con tiempo limitado"
                : "Módulo"}
            </p>
            <p className="mt-1 text-sm text-slate-600">
              {solved.size} de {exercises.length} ejercicios resueltos · Puntaje:{" "}
              {formatScore(earned)} / {exercises.length}
              {current ? ` · pregunta ${index + 1} de ${exercises.length}` : ""}
            </p>
          </div>

          {moduleRemaining !== null && (
            <span
              className={`badge shrink-0 ${
                moduleRemaining <= 60_000
                  ? "bg-red-100 text-red-700"
                  : "bg-amber-50 text-amber-700"
              }`}
            >
              ⏱ Módulo: {formatClock(moduleRemaining)}
            </span>
          )}
        </div>

        <div className="mt-4 h-2 overflow-hidden rounded-full bg-slate-100">
          <div
            className="h-full rounded-full bg-indigo-600 transition-all"
            style={{
              width: `${
                exercises.length > 0
                  ? Math.round((earned / exercises.length) * 100)
                  : 0
              }%`,
            }}
          />
        </div>
      </div>

      {index >= exercises.length ? (
        <div
          className={`card mt-6 p-8 text-center ${
            allSolved
              ? "border-emerald-200 bg-emerald-50"
              : "border-amber-200 bg-amber-50"
          }`}
        >
          <p className="text-4xl">{allSolved ? "🎉" : "✅"}</p>
          <h2
            className={`mt-3 text-xl font-bold ${
              allSolved ? "text-emerald-900" : "text-amber-900"
            }`}
          >
            {allSolved ? "¡Módulo completado!" : "Módulo finalizado"}
          </h2>
          <p
            className={`mt-2 text-sm ${
              allSolved ? "text-emerald-800" : "text-amber-800"
            }`}
          >
            Resolviste {solved.size} de {exercises.length} ejercicios · Puntaje:{" "}
            {formatScore(earned)} / {exercises.length} · Nota:{" "}
            {formatScore(
              exercises.length > 0 ? (earned / exercises.length) * 10 : 0,
            )}{" "}
            / 10
          </p>
          <Link href="/dashboard" className="btn-primary mt-6">
            Elegir otro módulo
          </Link>
        </div>
      ) : moduleExpired ? (
        <div className="card mt-6 border-amber-200 bg-amber-50 p-8 text-center">
          <p className="text-4xl">⏰</p>
          <h2 className="mt-3 text-xl font-bold text-amber-900">
            El tiempo del módulo terminó
          </h2>
          <p className="mt-2 text-sm text-amber-800">
            Resolviste {solved.size} de {exercises.length} ejercicios · Puntaje:{" "}
            {formatScore(earned)} / {exercises.length}. Tus respuestas quedaron
            guardadas.
          </p>
          <Link href="/dashboard" className="btn-primary mt-6">
            Volver a mis módulos
          </Link>
        </div>
      ) : current ? (
        <TimedQuestion
          key={current.id}
          exercise={current}
          number={index + 1}
          total={exercises.length}
          questionTimeLimitSeconds={questionTimeLimitSeconds}
          moduleExpired={moduleExpired}
          onDone={handleDone}
        />
      ) : null}
    </div>
  );
}

type QuestionProps = {
  exercise: PublicExercise;
  number: number;
  total: number;
  questionTimeLimitSeconds: number | null;
  moduleExpired: boolean;
  onDone: (
    exerciseId: string,
    outcome: "correct" | "timeout" | "locked",
    points?: number,
  ) => void;
};

function TimedQuestion({
  exercise,
  number,
  total,
  questionTimeLimitSeconds,
  moduleExpired,
  onDone,
}: QuestionProps) {
  const [session, setSession] = useState<{
    expiresAt: string | null;
    serverNow: string;
  } | null>(null);
  const [sessionError, setSessionError] = useState<string | null>(null);
  const [timedOut, setTimedOut] = useState(false);
  const [closeRequested, setCloseRequested] = useState(false);

  const [state, formAction, pending] = useActionState<AttemptState, FormData>(
    submitAttempt,
    { status: "idle" },
  );

  useEffect(() => {
    let cancelled = false;

    startQuestion(exercise.id)
      .then((result) => {
        if (cancelled) return;

        if (result.ok) {
          setSession({
            expiresAt: result.questionExpiresAt,
            serverNow: result.serverNow,
          });

          if (result.questionSubmittedAt) setTimedOut(true);
          return;
        }

        if (result.reason === "module_expired") {
          setTimedOut(true);
          return;
        }

        setSessionError(result.message);
      })
      .catch(() => {
        if (!cancelled) {
          setSessionError("No se pudo iniciar el tiempo de la pregunta.");
        }
      });

    return () => {
      cancelled = true;
    };
  }, [exercise.id]);

  const remaining = useRemainingMs(
    session?.expiresAt ?? null,
    session?.serverNow ?? null,
  );

  useEffect(() => {
    if (remaining === null || remaining > 0 || timedOut || closeRequested) {
      return;
    }

    setCloseRequested(true);

    expireQuestion(exercise.id)
      .then((result) => {
        if (result.ok) {
          if (result.expired || result.alreadySubmitted) {
            setTimedOut(true);
            return;
          }

          // El reloj del navegador se adelantó al del servidor:
          // reintentamos en un segundo.
          window.setTimeout(() => setCloseRequested(false), 1000);
          return;
        }

        if (result.reason === "module_expired") {
          setTimedOut(true);
          return;
        }

        window.setTimeout(() => setCloseRequested(false), 2000);
      })
      .catch(() => {
        // Si falla la red, reintentamos; el servidor seguirá
        // rechazando respuestas enviadas tarde.
        window.setTimeout(() => setCloseRequested(false), 2000);
      });
  }, [remaining, timedOut, closeRequested, exercise.id]);

  useEffect(() => {
    if (state.status === "expired" || state.status === "locked") {
      setTimedOut(true);
    }

    if (state.status === "correct") {
      setSession((previous) =>
        previous ? { ...previous, expiresAt: null } : previous,
      );
    }
  }, [state.status]);

  const answeredCorrectly = state.status === "correct";
  const locked = moduleExpired || timedOut || answeredCorrectly;

  return (
    <article className="card mt-6 p-6">
      <div className="flex items-start justify-between gap-4">
        <div className="flex items-start gap-3">
          <span className="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-indigo-50 text-sm font-bold text-indigo-700">
            {number}
          </span>
          <div className="pt-1.5 text-base leading-relaxed text-slate-800">
            <MathText>{exercise.prompt}</MathText>
          </div>
        </div>

        {remaining !== null && !answeredCorrectly && (
          <span
            className={`badge shrink-0 ${
              remaining <= 10_000
                ? "bg-red-100 text-red-700"
                : "bg-amber-50 text-amber-700"
            }`}
          >
            ⏱ {formatClock(remaining)}
          </span>
        )}
      </div>

      {questionTimeLimitSeconds !== null && !answeredCorrectly && (
        <p className="mt-4 text-xs text-slate-500">
          Tiempo máximo para esta pregunta: {questionTimeLimitSeconds} s. La
          pregunta se cierra al agotarse el tiempo.
        </p>
      )}

      <form action={formAction} className="mt-6">
        <input type="hidden" name="exercise_id" value={exercise.id} />

        <fieldset disabled={locked || pending} className="space-y-2">
          <legend className="sr-only">Selecciona una opción</legend>

          {exercise.type === "multiple_choice" ? (
            (exercise.options ?? []).map((option, optionIndex) => (
              <label
                key={optionIndex}
                className="flex cursor-pointer items-start gap-3 rounded-xl border border-slate-200 p-3.5 transition hover:border-indigo-200 hover:bg-indigo-50/40 has-[:checked]:border-indigo-400 has-[:checked]:bg-indigo-50"
              >
                <input
                  type="radio"
                  name="option"
                  value={optionIndex}
                  required
                  className="mt-1 h-4 w-4 accent-indigo-600"
                />
                <span className="text-sm text-slate-800">
                  <MathText>{option}</MathText>
                </span>
              </label>
            ))
          ) : (
            <div className="max-w-sm">
              <label htmlFor={`answer-${exercise.id}`} className="label">
                Tu respuesta
              </label>
              <input
                id={`answer-${exercise.id}`}
                name="answer"
                type="text"
                inputMode="decimal"
                required
                autoComplete="off"
                className="input"
                placeholder="Escribe un número, por ejemplo 3.5"
              />
            </div>
          )}
        </fieldset>

        <div className="mt-5 flex items-center gap-3">
          <button
            type="submit"
            disabled={pending || locked}
            className="btn-primary"
          >
            {pending ? "Comprobando…" : "Comprobar respuesta"}
          </button>

          <span className="text-xs text-slate-400">
            {locked
              ? "Esta pregunta ya está cerrada."
              : "Puedes reintentar mientras quede tiempo."}
          </span>
        </div>
      </form>

      {state.status === "correct" && (
        <div className="mt-5 rounded-xl border border-emerald-200 bg-emerald-50 p-4 text-sm text-emerald-800">
          <p className="font-semibold">{state.message}</p>
          {state.explanation && (
            <p className="mt-2 leading-relaxed">
              <MathText>{state.explanation}</MathText>
            </p>
          )}
          <button
            type="button"
            className="btn-primary mt-4"
            onClick={() => onDone(exercise.id, "correct", state.points)}
          >
            {number < total ? "Siguiente pregunta →" : "Finalizar módulo"}
          </button>
        </div>
      )}

      {(timedOut || state.status === "expired") && (
        <div className="mt-5 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800">
          <p className="font-semibold">
            {state.status === "expired" || state.status === "locked"
              ? state.message
              : "Se acabó el tiempo de esta pregunta."}
          </p>
          <p className="mt-2 text-amber-700">
            {state.status === "locked"
              ? "Ya no puedes enviar más respuestas para este ejercicio."
              : "La respuesta no se contó como correcta."}
          </p>
          <button
            type="button"
            className="btn-primary mt-4"
            onClick={() =>
              onDone(
                exercise.id,
                state.status === "locked" ? "locked" : "timeout",
              )
            }
          >
            {number < total ? "Siguiente pregunta →" : "Finalizar módulo"}
          </button>
        </div>
      )}

      {state.status === "incorrect" && !locked && (
        <div className="mt-5 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800">
          <p className="font-semibold">{state.message}</p>
        </div>
      )}

      {state.status === "error" && (
        <div className="mt-5 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-700">
          {state.message}
        </div>
      )}

      {sessionError && (
        <div className="mt-5 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-700">
          {sessionError}
        </div>
      )}
    </article>
  );
}
