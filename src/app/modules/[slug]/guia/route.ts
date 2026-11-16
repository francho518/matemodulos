import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { selectPracticeExercises } from "@/lib/exercise-selection";
import { buildRoundPlans, currentRoundPlan } from "@/lib/progress";
import { buildPracticeSheetPdf } from "@/lib/practice-sheet-pdf";
import type { ModuleRow, PublicExercise } from "@/lib/types";

export const dynamic = "force-dynamic";

type Props = {
  params: Promise<{ slug: string }>;
};

/**
 * Descarga la guía de práctica en PDF: la misma cantidad de ejercicios
 * que asignará el módulo, pero tomados de los que el estudiante no verá
 * en su ronda actual.
 */
export async function GET(request: Request, { params }: Props) {
  const { slug } = await params;
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.redirect(
      new URL(`/login?redirectTo=/modules/${slug}`, request.url),
    );
  }

  const { data: moduleData } = await supabase
    .from("modules")
    .select("*")
    .eq("slug", slug)
    .eq("is_published", true)
    .maybeSingle();

  if (!moduleData) {
    return new NextResponse("Módulo no encontrado.", {
      status: 404,
      headers: { "content-type": "text/plain; charset=utf-8" },
    });
  }

  const module = moduleData as ModuleRow;

  const [exercisesResult, roundsResult, profileResult] = await Promise.all([
    supabase
      .from("exercises")
      .select("id, prompt, type, options, order_index")
      .eq("module_id", module.id)
      .order("order_index", { ascending: true })
      .order("created_at", { ascending: true }),
    supabase
      .from("module_rounds")
      .select("round, exercise_ids")
      .eq("user_id", user.id)
      .eq("module_id", module.id)
      .order("round", { ascending: true }),
    supabase
      .from("profiles")
      .select("full_name")
      .eq("id", user.id)
      .maybeSingle(),
  ]);

  const allExercises = (exercisesResult.data ?? []) as PublicExercise[];

  const plans = buildRoundPlans({
    exercises: allExercises,
    userId: user.id,
    moduleId: module.id,
    randomize: Boolean(module.randomize_exercises),
    exercisesPerStudent: Number(module.exercises_per_student) || 0,
    rounds: (roundsResult.data ?? []) as Array<{
      round: number;
      exercise_ids: string[];
    }>,
  });

  const current = currentRoundPlan(plans);
  const assignedIds = current.exercises.map((exercise) => exercise.id);

  const selected = selectPracticeExercises(
    allExercises,
    user.id,
    module.id,
    current.round,
    assignedIds.length,
    assignedIds,
  );

  if (assignedIds.length === 0) {
    return new NextResponse("Este módulo todavía no tiene ejercicios.", {
      status: 404,
      headers: { "content-type": "text/plain; charset=utf-8" },
    });
  }

  if (selected.length < assignedIds.length) {
    return new NextResponse(
      "No hay suficientes ejercicios distintos en el banco para armar la guía con la misma cantidad que asigna el módulo. Pide a tu docente que amplíe el banco o configure menos ejercicios por estudiante.",
      {
        status: 409,
        headers: { "content-type": "text/plain; charset=utf-8" },
      },
    );
  }

  const pdfBytes = await buildPracticeSheetPdf({
    moduleTitle: module.title,
    moduleDescription: module.description,
    studentName: profileResult.data?.full_name ?? null,
    exercises: selected.map((exercise) => ({
      prompt: exercise.prompt,
      type: exercise.type,
      options: exercise.options,
    })),
  });

  return new NextResponse(Buffer.from(pdfBytes), {
    headers: {
      "content-type": "application/pdf",
      "content-disposition": `attachment; filename="guia-practica-${module.slug}.pdf"`,
      "cache-control": "no-store",
    },
  });
}
