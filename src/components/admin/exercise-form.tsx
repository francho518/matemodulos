"use client";

import { useActionState, useState } from "react";
import { createExerciseAction } from "@/app/admin/actions";
import type { ActionState } from "@/lib/action-state";
import type { ExerciseType } from "@/lib/types";

type Props = {
  moduleId: string;
  nextOrder: number;
};

export function ExerciseForm({ moduleId, nextOrder }: Props) {
  const [type, setType] = useState<ExerciseType>("multiple_choice");

  const [state, formAction, pending] = useActionState<ActionState, FormData>(
    createExerciseAction,
    {},
  );

  return (
    <form action={formAction} className="space-y-5">
      <input type="hidden" name="module_id" value={moduleId} />

      <div>
        <label htmlFor="prompt" className="label">
          Enunciado *
        </label>
        <textarea
          id="prompt"
          name="prompt"
          rows={3}
          required
          className="input"
          placeholder="Resuelve $2x + 5 = 13$."
        />
        <p className="mt-1 text-xs text-slate-500">
          Puedes usar LaTeX entre signos de dólar:{" "}
          <code className="rounded bg-slate-100 px-1">$x^2 + 1$</code>.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <label htmlFor="type" className="label">
            Tipo de ejercicio *
          </label>
          <select
            id="type"
            name="type"
            value={type}
            onChange={(event) =>
              setType(event.target.value as ExerciseType)
            }
            className="input"
          >
            <option value="multiple_choice">Opción múltiple</option>
            <option value="numeric">Respuesta numérica</option>
          </select>
        </div>

        <div>
          <label htmlFor="order_index" className="label">
            Orden
          </label>
          <input
            id="order_index"
            name="order_index"
            type="number"
            min={0}
            step={1}
            defaultValue={nextOrder}
            className="input"
          />
        </div>
      </div>

      {type === "multiple_choice" ? (
        <div className="grid gap-4 sm:grid-cols-2">
          <div>
            <label htmlFor="options" className="label">
              Opciones * <span className="font-normal">(una por línea)</span>
            </label>
            <textarea
              id="options"
              name="options"
              rows={5}
              required
              className="input font-mono text-xs"
              placeholder={"$3$\n$4$\n$5$\n$9$"}
            />
          </div>

          <div>
            <label htmlFor="correct_option" className="label">
              Número de la opción correcta *
            </label>
            <input
              id="correct_option"
              name="correct_option"
              type="number"
              min={1}
              step={1}
              required
              defaultValue={1}
              className="input"
            />
            <p className="mt-1 text-xs text-slate-500">
              La primera opción es la 1, la segunda es la 2, etc.
            </p>
          </div>
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2">
          <div>
            <label htmlFor="correct_answer" className="label">
              Respuesta correcta *
            </label>
            <input
              id="correct_answer"
              name="correct_answer"
              type="text"
              inputMode="decimal"
              required
              className="input"
              placeholder="4"
            />
          </div>

          <div>
            <label htmlFor="tolerance" className="label">
              Tolerancia
            </label>
            <input
              id="tolerance"
              name="tolerance"
              type="text"
              inputMode="decimal"
              defaultValue="0.000001"
              className="input"
            />
            <p className="mt-1 text-xs text-slate-500">
              Margen aceptado alrededor de la respuesta correcta.
            </p>
          </div>
        </div>
      )}

      <div>
        <label htmlFor="explanation" className="label">
          Explicación (se muestra al acertar)
        </label>
        <textarea
          id="explanation"
          name="explanation"
          rows={3}
          className="input"
          placeholder="Restamos 5 en ambos lados: $2x = 8$, entonces $x = 4$."
        />
      </div>

      {state.error && (
        <p className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {state.error}
        </p>
      )}

      <button type="submit" disabled={pending} className="btn-primary">
        {pending ? "Agregando…" : "Agregar ejercicio"}
      </button>
    </form>
  );
}
