"use client";

import { useActionState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { submitAttempt } from "@/app/modules/actions";
import { MathText } from "@/components/math-text";
import { formatScore } from "@/lib/scoring";
import type { AttemptState } from "@/lib/action-state";
import type { PublicExercise } from "@/lib/types";

type Props = {
  exercise: PublicExercise;
  index: number;
  solved: boolean;
  score: number;
  attemptsUsed: number;
  locked: boolean;
};

const initialState: AttemptState = { status: "idle" };

export function ExerciseCard({
  exercise,
  index,
  solved,
  score,
  attemptsUsed,
  locked,
}: Props) {
  const router = useRouter();
  const [state, formAction, pending] = useActionState<AttemptState, FormData>(
    submitAttempt,
    initialState,
  );

  useEffect(() => {
    if (
      state.status === "correct" ||
      state.status === "incorrect" ||
      state.status === "locked"
    ) {
      router.refresh();
    }
  }, [state, router]);

  return (
    <article className="card p-6">
      <div className="flex items-start justify-between gap-4">
        <div className="flex items-start gap-3">
          <span className="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-indigo-50 text-sm font-bold text-indigo-700">
            {index + 1}
          </span>
          <div className="pt-1.5 text-base leading-relaxed text-slate-800">
            <MathText>{exercise.prompt}</MathText>
          </div>
        </div>

        {solved ? (
          <span className="badge shrink-0 bg-emerald-100 text-emerald-700">
            Resuelto · {formatScore(score)} pt
          </span>
        ) : locked ? (
          <span className="badge shrink-0 bg-slate-200 text-slate-600">
            Cerrado · 0 pt
          </span>
        ) : null}
      </div>

      <form action={formAction} className="mt-6">
        <input type="hidden" name="exercise_id" value={exercise.id} />

        {exercise.type === "multiple_choice" ? (
          <fieldset disabled={locked || pending} className="space-y-2">
            <legend className="sr-only">Selecciona una opción</legend>

            {(exercise.options ?? []).map((option, optionIndex) => (
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
            ))}
          </fieldset>
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
              disabled={locked || pending}
              className="input"
              placeholder="Escribe un número, por ejemplo 3.5"
            />
          </div>
        )}

        <div className="mt-5 flex flex-col gap-2 sm:flex-row sm:items-center sm:gap-3">
          <button
            type="submit"
            disabled={pending || locked}
            className="btn-primary disabled:cursor-not-allowed disabled:opacity-50"
          >
            {pending ? "Comprobando…" : locked ? "Ejercicio cerrado" : "Comprobar respuesta"}
          </button>

          <span className="text-xs text-slate-400">
            {solved
              ? "Ya acertaste este ejercicio."
              : locked
                ? "No se aceptan más respuestas en este ejercicio."
                : `Intentos usados: ${attemptsUsed} de 4. Puntaje: 1.er intento 1,0 · 2.º 0,8 · 3.er 0,5 · 4.º 0.`}
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
        </div>
      )}

      {state.status === "incorrect" && (
        <div className="mt-5 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800">
          <p className="font-semibold">{state.message}</p>
        </div>
      )}

      {state.status === "expired" && (
        <div className="mt-5 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800">
          {state.message}
        </div>
      )}

      {state.status === "locked" && (
        <div className="mt-5 rounded-xl border border-slate-300 bg-slate-50 p-4 text-sm text-slate-700">
          <p className="font-semibold">{state.message}</p>
          {state.explanation && (
            <p className="mt-2 leading-relaxed">
              <MathText>{state.explanation}</MathText>
            </p>
          )}
        </div>
      )}

      {state.status === "error" && (
        <div className="mt-5 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-700">
          {state.message}
        </div>
      )}
    </article>
  );
}
