"use client";

import { useActionState, useState } from "react";
import { prepareEvaluacionesAction } from "@/app/admin/evaluaciones/actions";
import type { EvaluationMode, EvaluationState } from "@/lib/evaluation";

type ModuleOption = {
  id: string;
  title: string;
  isPublished: boolean;
  exerciseCount: number;
};

type GroupOption = {
  id: string;
  name: string;
  moduleCount: number;
};

type Props = {
  modules: ModuleOption[];
  groups: GroupOption[];
};

function toggleValue(values: Set<string>, value: string): Set<string> {
  const next = new Set(values);
  if (next.has(value)) next.delete(value);
  else next.add(value);
  return next;
}

export function EvaluationForm({ modules, groups }: Props) {
  const [state, formAction, pending] = useActionState<
    EvaluationState,
    FormData
  >(prepareEvaluacionesAction, {});

  const [mode, setMode] = useState<EvaluationMode>("modulo");
  const [title, setTitle] = useState("Evaluación");
  const [exercises, setExercises] = useState(10);
  const [versions, setVersions] = useState(2);
  const [includeSolutions, setIncludeSolutions] = useState(false);
  const [selectedModules, setSelectedModules] = useState<Set<string>>(
    new Set(),
  );
  const [selectedGroups, setSelectedGroups] = useState<Set<string>>(new Set());

  return (
    <>
      <form action={formAction} className="card mt-6 space-y-6 p-6">
        <fieldset>
          <legend className="label">Generar evaluación</legend>
          <div className="mt-2 flex flex-wrap gap-4">
            <label className="flex cursor-pointer items-center gap-2 text-sm text-slate-700">
              <input
                type="radio"
                name="modo"
                value="modulo"
                checked={mode === "modulo"}
                onChange={() => setMode("modulo")}
                className="accent-indigo-600"
              />
              Por módulo
            </label>
            <label className="flex cursor-pointer items-center gap-2 text-sm text-slate-700">
              <input
                type="radio"
                name="modo"
                value="grupo"
                checked={mode === "grupo"}
                onChange={() => setMode("grupo")}
                className="accent-indigo-600"
              />
              Por grupo
            </label>
          </div>
          <p className="mt-2 text-xs text-slate-500">
            {mode === "modulo"
              ? "Selecciona uno o varios módulos. Los ejercicios se reparten entre ellos."
              : "Se genera un PDF por grupo usando los módulos ya asignados a cada grupo."}
          </p>
        </fieldset>

        <div>
          <label htmlFor="titulo" className="label">
            Título de la evaluación
          </label>
          <input
            id="titulo"
            name="titulo"
            className="input"
            value={title}
            onChange={(event) => setTitle(event.target.value)}
            placeholder="Evaluación de cálculo"
          />
        </div>

        <div className="grid gap-4 sm:grid-cols-2">
          <div>
            <label htmlFor="ejercicios" className="label">
              Ejercicios por prueba
            </label>
            <input
              id="ejercicios"
              name="ejercicios"
              type="number"
              min={1}
              max={100}
              className="input"
              value={exercises}
              onChange={(event) => setExercises(Number(event.target.value))}
            />
          </div>
          <div>
            <label htmlFor="versiones" className="label">
              Versiones diferentes
            </label>
            <input
              id="versiones"
              name="versiones"
              type="number"
              min={1}
              max={10}
              className="input"
              value={versions}
              onChange={(event) => setVersions(Number(event.target.value))}
            />
            <p className="mt-1 text-xs text-slate-500">
              Todas las versiones van en el mismo PDF.
            </p>
          </div>
        </div>

        {mode === "modulo" ? (
          <div>
            <p className="label">Módulos</p>
            {modules.length === 0 ? (
              <p className="text-sm text-slate-500">No hay módulos creados.</p>
            ) : (
              <div className="mt-2 grid gap-2 sm:grid-cols-2">
                {modules.map((module) => (
                  <label
                    key={module.id}
                    className="flex cursor-pointer items-start gap-2 rounded-lg border border-slate-200 p-3 text-sm has-[:checked]:border-indigo-400 has-[:checked]:bg-indigo-50"
                  >
                    <input
                      type="checkbox"
                      name="module_id"
                      value={module.id}
                      checked={selectedModules.has(module.id)}
                      onChange={() =>
                        setSelectedModules((current) =>
                          toggleValue(current, module.id),
                        )
                      }
                      className="mt-0.5 accent-indigo-600"
                    />
                    <span>
                      <span className="font-medium text-slate-800">
                        {module.title}
                      </span>
                      <span className="block text-xs text-slate-500">
                        {module.exerciseCount} ejercicios
                        {module.isPublished ? "" : " · sin publicar"}
                      </span>
                    </span>
                  </label>
                ))}
              </div>
            )}
          </div>
        ) : (
          <div>
            <p className="label">Grupos</p>
            {groups.length === 0 ? (
              <p className="text-sm text-slate-500">No hay grupos creados.</p>
            ) : (
              <div className="mt-2 grid gap-2 sm:grid-cols-2">
                {groups.map((group) => (
                  <label
                    key={group.id}
                    className="flex cursor-pointer items-start gap-2 rounded-lg border border-slate-200 p-3 text-sm has-[:checked]:border-indigo-400 has-[:checked]:bg-indigo-50"
                  >
                    <input
                      type="checkbox"
                      name="group_id"
                      value={group.id}
                      checked={selectedGroups.has(group.id)}
                      onChange={() =>
                        setSelectedGroups((current) =>
                          toggleValue(current, group.id),
                        )
                      }
                      className="mt-0.5 accent-indigo-600"
                    />
                    <span>
                      <span className="font-medium text-slate-800">
                        {group.name}
                      </span>
                      <span className="block text-xs text-slate-500">
                        {group.moduleCount} módulos asignados
                      </span>
                    </span>
                  </label>
                ))}
              </div>
            )}
          </div>
        )}

        <label className="flex cursor-pointer items-center gap-2 text-sm text-slate-700">
          <input
            type="checkbox"
            name="solucionario"
            value="1"
            checked={includeSolutions}
            onChange={(event) => setIncludeSolutions(event.target.checked)}
            className="accent-indigo-600"
          />
          Generar también el solucionario en un PDF separado
        </label>

        {state.error && (
          <p className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            {state.error}
          </p>
        )}

        <button type="submit" className="btn-primary" disabled={pending}>
          {pending ? "Preparando enlaces…" : "Generar enlaces de descarga"}
        </button>
      </form>

      {state.links && state.links.length > 0 && (
        <div className="card mt-6 p-6">
          <h3 className="text-lg font-bold text-slate-900">
            Enlaces listos
          </h3>
          <p className="mt-1 text-sm text-slate-500">
            Cada PDF contiene {versions}{" "}
            {versions === 1 ? "versión" : "versiones"} de {exercises}{" "}
            {exercises === 1 ? "ejercicio" : "ejercicios"}.
          </p>

          <ul className="mt-4 space-y-3">
            {state.links.map((link) => (
              <li
                key={link.url}
                className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-slate-200 p-4"
              >
                <span className="font-medium text-slate-800">{link.label}</span>
                <span className="flex flex-wrap gap-2">
                  <a
                    href={link.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="btn-primary px-3 py-1.5 text-xs"
                  >
                    Descargar PDF
                  </a>
                  {link.solutionUrl && (
                    <a
                      href={link.solutionUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="btn-secondary px-3 py-1.5 text-xs"
                    >
                      Descargar solucionario
                    </a>
                  )}
                </span>
              </li>
            ))}
          </ul>
        </div>
      )}
    </>
  );
}
