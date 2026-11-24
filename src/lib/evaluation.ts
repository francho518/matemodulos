import { shuffleWithSeed } from "./exercise-selection";
import { latexToPlainText } from "./latex-plain";
import type {
  PracticeSheetExercise,
  PracticeSheetInput,
} from "./practice-sheet-pdf";
import type { AdminExercise } from "./types";

export type EvaluationMode = "modulo" | "grupo";

export type EvaluationLink = {
  label: string;
  url: string;
  solutionUrl: string | null;
};

export type EvaluationState = {
  error?: string;
  links?: EvaluationLink[];
};

export type EvaluationTarget = {
  key: string;
  label: string;
  moduleIds: string[];
};

export type EvaluationConfig = {
  title: string;
  exercisesPerTest: number;
  versions: number;
};

export function parseBoundedInt(
  value: string | null,
  fallback: number,
  min: number,
  max: number,
): number {
  const parsed = Number.parseInt(value ?? "", 10);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.min(max, Math.max(min, parsed));
}

export function versionLabel(version: number): string {
  return String.fromCharCode(64 + version);
}

/**
 * Reparte `count` ejercicios entre los módulos seleccionados de forma
 * determinista: cada versión usa una semilla distinta, por lo que las pruebas
 * no se repiten. Se aplica round-robin para que todos los módulos aporten
 * ejercicios cuando el banco lo permite.
 */
export function selectEvaluationExercises(
  exercises: AdminExercise[],
  moduleIds: string[],
  count: number,
  version: number,
): AdminExercise[] {
  const pools = new Map<string, AdminExercise[]>();

  moduleIds.forEach((moduleId) => {
    const pool = exercises
      .filter((exercise) => exercise.module_id === moduleId)
      .sort(
        (a, b) => a.order_index - b.order_index || a.id.localeCompare(b.id),
      );

    pools.set(moduleId, shuffleWithSeed(pool, `eval:${version}:${moduleId}`));
  });

  const selected: AdminExercise[] = [];

  for (let index = 0; selected.length < count; index++) {
    let added = false;

    for (const moduleId of moduleIds) {
      const pool = pools.get(moduleId) ?? [];
      if (index >= pool.length) continue;

      selected.push(pool[index]);
      added = true;
      if (selected.length === count) break;
    }

    if (!added) break;
  }

  return selected;
}

function answerText(exercise: AdminExercise): string {
  if (exercise.type === "multiple_choice") {
    const index = exercise.correct_option ?? -1;
    const option = exercise.options?.[index];
    return option ? latexToPlainText(option) : "—";
  }

  if (exercise.correct_answer === null) return "—";

  const value = String(exercise.correct_answer);
  const tolerance = Number(exercise.tolerance) || 0;
  return tolerance > 0 ? `${value} (± ${tolerance})` : value;
}

function toSheetExercise(
  exercise: AdminExercise,
  tag: string,
  includeAnswers: boolean,
): PracticeSheetExercise {
  return {
    prompt: exercise.prompt,
    type: exercise.type,
    options: exercise.options,
    tag,
    answer: includeAnswers ? answerText(exercise) : undefined,
    explanation: includeAnswers ? exercise.explanation : undefined,
  };
}

/**
 * Convierte cada versión de la evaluación en un bloque con el formato de la
 * guía de práctica. Si `solutionMode` es true, dibuja respuestas en lugar de
 * la línea en blanco.
 */
export function buildEvaluationSheets({
  modules,
  exercises,
  config,
  solutionMode,
}: {
  modules: Array<{ id: string; title: string }>;
  exercises: AdminExercise[];
  config: EvaluationConfig;
  solutionMode: boolean;
}): PracticeSheetInput[] {
  const moduleIds = modules.map((module) => module.id);
  const tags = new Map(modules.map((module) => [module.id, module.title]));
  const combinedTitle = modules.map((module) => module.title).join(" · ");
  const kind = solutionMode ? "Solucionario" : "Evaluación";

  const instructions = solutionMode
    ? [
        "Este solucionario corresponde a las mismas versiones de la evaluación.",
        "Compara tu procedimiento con la explicación de cada ejercicio.",
      ]
    : [
        "Resuelve cada ejercicio en el espacio disponible y escribe tu respuesta en la línea indicada.",
        "Cada versión tiene una selección diferente de ejercicios. No compartas tu versión.",
        "Justifica el procedimiento cuando sea posible.",
      ];

  const sheets: PracticeSheetInput[] = [];

  for (let version = 1; version <= config.versions; version++) {
    const label = versionLabel(version);
    const selected = selectEvaluationExercises(
      exercises,
      moduleIds,
      config.exercisesPerTest,
      version,
    );

    sheets.push({
      moduleTitle: combinedTitle,
      moduleDescription: config.title,
      studentName: null,
      documentLabel: `${kind} · Versión ${label}`,
      title: `${kind} · Versión ${label}`,
      metaLine: `Nombre: ________________________________ · Fecha: ______________ · Versión: ${label}`,
      objective: `Resolver ${config.exercisesPerTest} ${
        config.exercisesPerTest === 1 ? "ejercicio" : "ejercicios"
      } de ${modules.length === 1 ? "el módulo" : "los módulos"} ${combinedTitle}.`,
      instructions,
      exerciseHeading: solutionMode ? "Soluciones" : "Ejercicios",
      solutionMode,
      exercises: selected.map((exercise) =>
        toSheetExercise(
          exercise,
          tags.get(exercise.module_id) ?? "Ejercicio",
          solutionMode,
        ),
      ),
    });
  }

  return sheets;
}

/** URL del handler que genera el PDF de una evaluación o su solucionario. */
export function evaluationUrl({
  mode,
  moduleIds = [],
  groupId,
  exercises,
  versions,
  title,
  solutionMode,
}: {
  mode: EvaluationMode;
  moduleIds?: string[];
  groupId?: string;
  exercises: number;
  versions: number;
  title: string;
  solutionMode: boolean;
}): string {
  const params = new URLSearchParams();
  params.set("modo", mode);

  if (mode === "modulo") {
    moduleIds.forEach((id) => params.append("module_id", id));
  } else if (groupId) {
    params.set("group_id", groupId);
  }

  params.set("ejercicios", String(exercises));
  params.set("versiones", String(versions));
  params.set("titulo", title);

  if (solutionMode) params.set("solucionario", "1");

  return `/admin/evaluaciones/pdf?${params.toString()}`;
}
