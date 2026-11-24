import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import {
  buildEvaluationSheets,
  parseBoundedInt,
  selectEvaluationExercises,
} from "@/lib/evaluation";
import { buildPracticeSheetsPdf } from "@/lib/practice-sheet-pdf";
import type { AdminExercise } from "@/lib/types";
import { slugify } from "@/lib/utils";

export const dynamic = "force-dynamic";

function jsonError(message: string, status: number) {
  return NextResponse.json({ error: message }, { status });
}

export async function GET(request: Request) {
  const params = new URL(request.url).searchParams;
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return jsonError("No autenticado.", 401);

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  if (profile?.role !== "admin") return jsonError("No autorizado.", 403);

  const mode = params.get("modo") === "grupo" ? "grupo" : "modulo";
  const exercisesPerTest = parseBoundedInt(
    params.get("ejercicios"),
    10,
    1,
    100,
  );
  const versions = parseBoundedInt(params.get("versiones"), 2, 1, 10);
  const solutionMode = params.get("solucionario") === "1";
  const title = (params.get("titulo") ?? "Evaluación").slice(0, 120);

  let moduleIds: string[] = [];
  let scopeLabel = "varios-modulos";

  if (mode === "modulo") {
    moduleIds = [
      ...new Set(params.getAll("module_id").filter((id) => id.length > 0)),
    ];

    if (moduleIds.length === 0) {
      return jsonError("Selecciona al menos un módulo.", 400);
    }
  } else {
    const groupId = params.get("group_id");

    if (!groupId) {
      return jsonError("Selecciona un grupo.", 400);
    }

    const [groupResult, groupModulesResult] = await Promise.all([
      supabase.from("groups").select("name").eq("id", groupId).maybeSingle(),
      supabase
        .from("group_modules")
        .select("module_id")
        .eq("group_id", groupId),
    ]);

    if (!groupResult.data) {
      return jsonError("No se encontró el grupo.", 404);
    }

    scopeLabel = slugify(groupResult.data.name ?? "grupo");
    moduleIds = [
      ...new Set(
        (groupModulesResult.data ?? [])
          .map((row) => row.module_id)
          .filter((id) => id.length > 0),
      ),
    ];

    if (moduleIds.length === 0) {
      return jsonError("Ese grupo todavía no tiene módulos asignados.", 409);
    }
  }

  const [modulesResult, exercisesResult] = await Promise.all([
    supabase.from("modules").select("id, title").in("id", moduleIds),
    supabase
      .from("exercises")
      .select(
        "id, module_id, prompt, type, options, order_index, correct_option, correct_answer, tolerance, explanation",
      )
      .in("module_id", moduleIds),
  ]);

  if (modulesResult.error || !modulesResult.data) {
    return jsonError(
      modulesResult.error?.message ?? "No se pudieron cargar los módulos.",
      500,
    );
  }

  if (exercisesResult.error || !exercisesResult.data) {
    return jsonError(
      exercisesResult.error?.message ?? "No se pudieron cargar los ejercicios.",
      500,
    );
  }

  const modulesById = new Map(
    modulesResult.data.map((module) => [module.id, module.title]),
  );
  const modules = moduleIds.map((id) => ({
    id,
    title: modulesById.get(id) ?? "Módulo",
  }));

  if (mode === "modulo" && modules.length === 1) {
    scopeLabel = slugify(modules[0].title);
  }

  const exercises = exercisesResult.data as unknown as AdminExercise[];

  for (let version = 1; version <= versions; version++) {
    const selected = selectEvaluationExercises(
      exercises,
      moduleIds,
      exercisesPerTest,
      version,
    );

    if (selected.length < exercisesPerTest) {
      return jsonError(
        `El banco no alcanza para ${exercisesPerTest} ejercicios en la versión ${version}. Añade ejercicios o reduce la cantidad.`,
        409,
      );
    }
  }

  const sheets = buildEvaluationSheets({
    modules,
    exercises,
    config: {
      title,
      exercisesPerTest,
      versions,
    },
    solutionMode,
  });

  const pdfBytes = await buildPracticeSheetsPdf(sheets);
  const kind = solutionMode ? "solucionario" : "evaluacion";
  const filename = `${kind}-${scopeLabel}-${versions}versiones.pdf`;

  return new NextResponse(Buffer.from(pdfBytes), {
    headers: {
      "content-type": "application/pdf",
      "content-disposition": `attachment; filename="${filename}"`,
      "cache-control": "no-store",
    },
  });
}
