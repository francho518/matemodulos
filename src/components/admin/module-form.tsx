"use client";

import { useActionState } from "react";
import { saveModuleAction } from "@/app/admin/actions";
import type { ActionState } from "@/lib/action-state";
import type { ModuleRow } from "@/lib/types";

type Props = {
  module?: ModuleRow;
};

export function ModuleForm({ module }: Props) {
  const [state, formAction, pending] = useActionState<ActionState, FormData>(
    saveModuleAction,
    {},
  );

  return (
    <form action={formAction} className="space-y-5">
      {module && <input type="hidden" name="id" value={module.id} />}

      <div className="grid gap-5 sm:grid-cols-2">
        <div className="sm:col-span-2">
          <label htmlFor="title" className="label">
            Título del módulo *
          </label>
          <input
            id="title"
            name="title"
            type="text"
            required
            minLength={3}
            defaultValue={module?.title ?? ""}
            className="input"
            placeholder="Álgebra básica"
          />
        </div>

        <div>
          <label htmlFor="slug" className="label">
            Slug (URL)
          </label>
          <input
            id="slug"
            name="slug"
            type="text"
            defaultValue={module?.slug ?? ""}
            className="input"
            placeholder="algebra-basica"
          />
          <p className="mt-1 text-xs text-slate-500">
            Déjalo vacío para generarlo automáticamente desde el título.
          </p>
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
            defaultValue={module?.order_index ?? 0}
            className="input"
          />
          <p className="mt-1 text-xs text-slate-500">
            Los números menores aparecen primero.
          </p>
        </div>

        <div>
          <label htmlFor="exercises_per_student" className="label">
            Ejercicios por estudiante
          </label>
          <input
            id="exercises_per_student"
            name="exercises_per_student"
            type="number"
            min={0}
            step={1}
            defaultValue={module?.exercises_per_student ?? 0}
            className="input"
          />
          <p className="mt-1 text-xs text-slate-500">
            0 = todos los ejercicios. Si hay más en el banco, se seleccionan al
            azar para cada estudiante.
          </p>
        </div>

        <div>
          <label htmlFor="module_time_limit_minutes" className="label">
            Tiempo máximo del módulo (minutos)
          </label>
          <input
            id="module_time_limit_minutes"
            name="module_time_limit_minutes"
            type="number"
            min={1}
            step={1}
            defaultValue={module?.module_time_limit_minutes ?? ""}
            className="input"
            placeholder="Sin límite"
          />
          <p className="mt-1 text-xs text-slate-500">
            El reloj empieza la primera vez que el estudiante abre el módulo.
            Déjalo vacío para no limitar el tiempo.
          </p>
        </div>

        <div>
          <label htmlFor="question_time_limit_seconds" className="label">
            Tiempo máximo por pregunta (segundos)
          </label>
          <input
            id="question_time_limit_seconds"
            name="question_time_limit_seconds"
            type="number"
            min={1}
            step={1}
            defaultValue={module?.question_time_limit_seconds ?? ""}
            className="input"
            placeholder="Sin límite"
          />
          <p className="mt-1 text-xs text-slate-500">
            Cada pregunta se cierra al agotarse su tiempo. Déjalo vacío para no
            limitar cada pregunta.
          </p>
        </div>

        <div className="flex items-center">
          <label className="flex w-full items-center gap-3 rounded-xl border border-slate-200 p-4">
            <input
              type="checkbox"
              name="randomize_exercises"
              defaultChecked={module?.randomize_exercises ?? false}
              className="h-4 w-4 shrink-0 accent-indigo-600"
            />
            <span className="text-sm text-slate-700">
              <span className="font-semibold text-slate-900">
                Variantes por estudiante
              </span>{" "}
              · cada alumno recibe una combinación y orden distintos
            </span>
          </label>
        </div>

        <div className="sm:col-span-2">
          <label htmlFor="description" className="label">
            Descripción
          </label>
          <textarea
            id="description"
            name="description"
            rows={3}
            defaultValue={module?.description ?? ""}
            className="input"
            placeholder="Ecuaciones lineales, cuadráticas y factorización."
          />
        </div>

        <div className="sm:col-span-2">
          <label className="flex items-center gap-3 rounded-xl border border-slate-200 p-4">
            <input
              type="checkbox"
              name="is_published"
              defaultChecked={module?.is_published ?? true}
              className="h-4 w-4 accent-indigo-600"
            />
            <span className="text-sm text-slate-700">
              <span className="font-semibold text-slate-900">Publicado</span> ·
              visible para los estudiantes
            </span>
          </label>
        </div>
      </div>

      {state.error && (
        <p className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {state.error}
        </p>
      )}

      <button type="submit" disabled={pending} className="btn-primary">
        {pending
          ? "Guardando…"
          : module
            ? "Guardar cambios"
            : "Crear módulo"}
      </button>
    </form>
  );
}
