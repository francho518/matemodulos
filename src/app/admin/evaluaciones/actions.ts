"use server";

import { createClient } from "@/lib/supabase/server";
import {
  evaluationUrl,
  parseBoundedInt,
  type EvaluationLink,
  type EvaluationMode,
  type EvaluationState,
  type EvaluationTarget,
} from "@/lib/evaluation";

function getString(formData: FormData, key: string) {
  const value = formData.get(key);
  return typeof value === "string" ? value.trim() : "";
}

function getAllStrings(formData: FormData, key: string): string[] {
  const values = formData
    .getAll(key)
    .filter((value): value is string => typeof value === "string" && value !== "");
  return [...new Set(values)];
}

async function getAdminContext() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { supabase, error: "Debes iniciar sesión." as string };
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  if (profile?.role !== "admin") {
    return { supabase, error: "No tienes permisos de administrador." };
  }

  return { supabase, error: null };
}

/**
 * Valida la selección y devuelve enlaces de descarga. El PDF se genera en el
 * route handler para que cada enlace pueda abrirse o descargarse por separado.
 */
export async function prepareEvaluacionesAction(
  _previousState: EvaluationState,
  formData: FormData,
): Promise<EvaluationState> {
  const { supabase, error: authError } = await getAdminContext();

  if (authError) return { error: authError };

  const mode: EvaluationMode =
    getString(formData, "modo") === "grupo" ? "grupo" : "modulo";
  const exercises = parseBoundedInt(
    getString(formData, "ejercicios"),
    10,
    1,
    100,
  );
  const versions = parseBoundedInt(getString(formData, "versiones"), 2, 1, 10);
  const title = getString(formData, "titulo") || "Evaluación";
  const includeSolutions = getString(formData, "solucionario") === "1";

  let targets: EvaluationTarget[] = [];

  if (mode === "modulo") {
    const moduleIds = getAllStrings(formData, "module_id");

    if (moduleIds.length === 0) {
      return { error: "Selecciona al menos un módulo." };
    }

    const { data, error } = await supabase
      .from("modules")
      .select("id, title")
      .in("id", moduleIds);

    if (error || !data) {
      return { error: error?.message ?? "No se pudieron cargar los módulos." };
    }

    const modulesById = new Map(data.map((module) => [module.id, module.title]));
    const orderedIds = moduleIds.filter((id) => modulesById.has(id));

    if (orderedIds.length === 0) {
      return { error: "Ninguno de los módulos seleccionados existe." };
    }

    targets = [
      {
        key: "modulo",
        label: orderedIds.map((id) => modulesById.get(id) ?? "").join(" · "),
        moduleIds: orderedIds,
      },
    ];
  } else {
    const groupIds = getAllStrings(formData, "group_id");

    if (groupIds.length === 0) {
      return { error: "Selecciona al menos un grupo." };
    }

    const [groupsResult, groupModulesResult] = await Promise.all([
      supabase.from("groups").select("id, name").in("id", groupIds),
      supabase
        .from("group_modules")
        .select("group_id, module_id")
        .in("group_id", groupIds),
    ]);

    if (groupsResult.error || !groupsResult.data) {
      return {
        error: groupsResult.error?.message ?? "No se pudieron cargar los grupos.",
      };
    }

    if (groupModulesResult.error || !groupModulesResult.data) {
      return {
        error:
          groupModulesResult.error?.message ??
          "No se pudieron cargar los módulos de los grupos.",
      };
    }

    targets = groupsResult.data.map((group) => ({
      key: group.id,
      label: `Grupo ${group.name}`,
      moduleIds: groupModulesResult.data!
        .filter((row) => row.group_id === group.id)
        .map((row) => row.module_id),
    }));

    const emptyTarget = targets.find((target) => target.moduleIds.length === 0);

    if (emptyTarget) {
      return {
        error: `${emptyTarget.label} no tiene módulos asignados. Asígnale módulos antes de generar la evaluación.`,
      };
    }
  }

  const allModuleIds = [
    ...new Set(targets.flatMap((target) => target.moduleIds)),
  ];

  const { data: exerciseRows, error: exercisesError } = await supabase
    .from("exercises")
    .select("id, module_id")
    .in("module_id", allModuleIds);

  if (exercisesError || !exerciseRows) {
    return {
      error: exercisesError?.message ?? "No se pudieron contar los ejercicios.",
    };
  }

  const counts = new Map<string, number>();
  exerciseRows.forEach((row) => {
    counts.set(row.module_id, (counts.get(row.module_id) ?? 0) + 1);
  });

  for (const target of targets) {
    const available = target.moduleIds.reduce(
      (total, id) => total + (counts.get(id) ?? 0),
      0,
    );

    if (available < exercises) {
      return {
        error: `El banco de ${target.label} tiene ${available} ${
          available === 1 ? "ejercicio" : "ejercicios"
        } y has pedido ${exercises} por prueba. Reduce la cantidad o añade ejercicios.`,
      };
    }
  }

  const links: EvaluationLink[] = targets.map((target) => {
    const common = {
      mode,
      moduleIds: mode === "modulo" ? target.moduleIds : [],
      groupId: mode === "grupo" ? target.key : undefined,
      exercises,
      versions,
      title,
    };

    return {
      label: `${target.label} · Evaluación`,
      url: evaluationUrl({ ...common, solutionMode: false }),
      solutionUrl: includeSolutions
        ? evaluationUrl({ ...common, solutionMode: true })
        : null,
    };
  });

  return { links };
}
