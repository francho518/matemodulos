"use client";

import { useActionState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { submitAttempt } from "@/app/modules/actions";
import { MathText } from "@/components/math-text";
import type { AttemptState } from "@/lib/action-state";
import type { PublicExercise } from "@/lib/types";

type Props = {
  exercise: PublicExercise;
  index: number;
  solved: boolean;
};

const initialState: AttemptState = { status: "idle" };

export function ExerciseCard({ exercise, index, solved }: Props) {
  const router = useRouter();
  const [state, formAction, pending] = useActionState<AttemptState, FormData>(
    submitAttempt,
    initialState,
  );

  useEffect(() => {
    if (state.status === "correct" || state.status === "incorrect") {
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

        {solved && (
          <span className="badge shrink-0 bg-emerald-100 text-emerald-700">
            Resuelto
          </span>
        )}
      </div>

      <form action={formAction} className="mt-6">
        <input type="hidden" name="exercise_id" value={exercise.id} />

        {exercise.type === "multiple_choice" ? (
          <fieldset className="space-y-2">
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
              className="input"
              placeholder="Escribe un número, por ejemplo 3.5"
            />
          </div>
        )}

        <div className="mt-5 flex items-center gap-3">
          <button type="submit" disabled={pending} className="btn-primary">
            {pending ? "Comprobando…" : "Comprobar respuesta"}
          </button>

          <span className="text-xs text-slate-400">
            Puedes intentarlo las veces que quieras.
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

      {state.status === "error" && (
        <div className="mt-5 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-700">
          {state.message}
        </div>
      )}
    </article>
  );
}
