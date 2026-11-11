import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { percentage } from "@/lib/utils";
import {
  MAX_ROUND_ATTEMPTS,
  bestGradedRound,
  buildRoundPlans,
  currentRoundPlan,
  statsForPlan,
} from "@/lib/progress";
import { formatScore } from "@/lib/scoring";
import type {
  AttemptRow,
  ModuleRow,
  ModuleSessionRow,
  PublicExercise,
  QuestionSessionRow,
} from "@/lib/types";
import { ExerciseCard } from "@/components/exercise-card";
import { TimedRunner } from "@/components/timed-runner";

type Props = {
  params: Promise<{ slug: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const supabase = await createClient();
  const { data } = await supabase
    .from("modules")
    .select("title")
    .eq("slug", slug)
    .maybeSingle();

  return { title: data?.title ?? "Módulo" };
}

export default async function ModulePage({ params }: Props) {
  const { slug } = await params;
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect(`/login?redirectTo=/modules/${slug}`);
  }

  const { data: moduleData } = await supabase
    .from("modules")
    .select("*")
    .eq("slug", slug)
    .eq("is_published", true)
    .maybeSingle();

  if (!moduleData) {
    notFound();
  }

  const module = moduleData as ModuleRow;

  const [exercisesResult, attemptsResult, roundsResult] = await Promise.all([
    supabase
      .from("exercises")
      .select("id, prompt, type, options, order_index")
      .eq("module_id", module.id)
      .order("order_index", { ascending: true })
      .order("created_at", { ascending: true }),
    supabase
      .from("attempts")
      .select("exercise_id, module_id, is_correct, created_at, round")
      .eq("user_id", user.id)
      .eq("module_id", module.id),
    supabase
      .from("module_rounds")
      .select("round, exercise_ids")
      .eq("user_id", user.id)
      .eq("module_id", module.id)
      .order("round", { ascending: true }),
  ]);

  const allExercises = (exercisesResult.data ?? []) as PublicExercise[];
  const attempts = (attemptsResult.data ?? []) as AttemptRow[];

  // Ronda 1 = asignación original; 2+ = reasignaciones hechas por el
  // docente con ejercicios diferentes.
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

  const currentPlan = currentRoundPlan(plans);
  const exercises = currentPlan.exercises;

  const roundsStats = plans.map((plan) => statsForPlan(plan, attempts));
  const bestStats = bestGradedRound(roundsStats);
  const stats = roundsStats[roundsStats.length - 1];

  const solvedIds = stats.solvedIds;
  const lockedIds = stats.lockedIds;
  const scores = stats.scores;
  const attemptsUsed = stats.attemptsUsed;

  const totalPoints = stats.points;
  const maxPoints = stats.total;
  const grade = stats.grade;
  const moduleCompleted = stats.completed;
  const isReassignment = currentPlan.round > 1;
  const bestGrade = bestStats?.grade ?? 0;
  const bestRound = bestStats?.round ?? 1;

  // En los módulos sin tiempo se muestra un único ejercicio: el primero
  // que todavía no está cerrado (ni resuelto ni con los 4 intentos usados).
  const currentIndex = exercises.findIndex(
    (exercise) => !lockedIds.has(exercise.id),
  );
  const currentExercise = currentIndex === -1 ? null : exercises[currentIndex];

  const attemptsExhaustedIds = exercises
    .filter(
      (exercise) =>
        (attemptsUsed.get(exercise.id) ?? 0) >= MAX_ROUND_ATTEMPTS,
    )
    .map((exercise) => exercise.id);

  const progress = percentage(solvedIds.size, exercises.length);

  const hasTimeLimit =
    Number(module.module_time_limit_minutes) > 0 ||
    Number(module.question_time_limit_seconds) > 0;

  let moduleSession: ModuleSessionRow | null = null;
  let questionSessions: QuestionSessionRow[] = [];

  if (hasTimeLimit) {
    const { data: sessionData } = await supabase
      .from("module_sessions")
      .select("id, user_id, module_id, started_at, expires_at, completed_at")
      .eq("user_id", user.id)
      .eq("module_id", module.id)
      .maybeSingle();

    moduleSession = (sessionData as ModuleSessionRow | null) ?? null;

    if (moduleSession) {
      const { data: questionData } = await supabase
        .from("question_sessions")
        .select(
          "id, module_session_id, exercise_id, started_at, expires_at, submitted_at",
        )
        .eq("module_session_id", moduleSession.id);

      questionSessions = (questionData ?? []) as QuestionSessionRow[];
    }
  }

  const serverNow = new Date().toISOString();

  return (
    <div className="mx-auto max-w-4xl px-4 py-10">
      <Link
        href="/dashboard"
        className="text-sm font-medium text-slate-500 transition hover:text-indigo-600"
      >
        ← Volver a mis módulos
      </Link>

      <div className="card mt-4 p-6 sm:p-8">
        <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-start">
          <div>
            <p className="text-xs font-semibold uppercase tracking-wider text-indigo-600">
              Módulo
            </p>
            <h1 className="mt-1 text-3xl font-bold tracking-tight text-slate-900">
              {module.title}
            </h1>
            <p className="mt-2 max-w-2xl text-slate-600">
              {module.description ?? "Sin descripción."}
            </p>

            {module.randomize_exercises && (
              <p className="mt-3 inline-flex items-center gap-2 rounded-full bg-indigo-50 px-3 py-1 text-xs font-medium text-indigo-700">
                <span aria-hidden="true">🎲</span>
                {exercises.length < allExercises.length
                  ? `Tu selección personalizada: ${exercises.length} de ${allExercises.length} ejercicios`
                  : "Orden personalizado para ti"}
              </p>
            )}

            {isReassignment && (
              <p className="mt-3 inline-flex items-center gap-2 rounded-full bg-violet-50 px-3 py-1 text-xs font-semibold text-violet-700">
                <span aria-hidden="true">↻</span>
                Reasignación {currentPlan.round} · ejercicios nuevos
              </p>
            )}

            {hasTimeLimit && (
              <div className="mt-3 flex flex-wrap items-center gap-2">
                {Number(module.module_time_limit_minutes) > 0 && (
                  <span className="badge bg-amber-50 text-amber-700">
                    ⏱ Módulo: {module.module_time_limit_minutes} min
                  </span>
                )}
                {Number(module.question_time_limit_seconds) > 0 && (
                  <span className="badge bg-amber-50 text-amber-700">
                    ⏱ Por pregunta: {module.question_time_limit_seconds} s
                  </span>
                )}
              </div>
            )}
          </div>

          <div className="flex shrink-0 flex-col items-start gap-2 sm:items-end">
            <span
              className={`badge ${
                progress === 100
                  ? "bg-emerald-100 text-emerald-700"
                  : "bg-indigo-50 text-indigo-700"
              }`}
            >
              {solvedIds.size} de {exercises.length} resueltos
            </span>
            <span className="badge bg-slate-100 text-slate-700">
              Puntaje: {formatScore(totalPoints)} / {maxPoints}
            </span>
            {plans.length > 1 && (
              <span className="badge bg-violet-100 text-violet-700">
                Mejor nota: {formatScore(bestGrade)} / 10
              </span>
            )}
          </div>
        </div>

        <p className="mt-4 rounded-xl bg-slate-50 px-4 py-3 text-xs text-slate-600">
          <span className="font-semibold text-slate-700">Modo de resolución:</span>{" "}
          verás los ejercicios de uno en uno. Al acertar o al agotar los 4
          intentos pasarás al siguiente.
          <br />
          <span className="font-semibold text-slate-700">Cómo se puntúa:</span>{" "}
          acierto al 1.er intento = 1,0 · 2.º intento = 0,8 · 3.er intento = 0,5
          · 4.º intento o más = 0. Cada ejercicio se cierra al acertar o al
          agotar los 4 intentos.
        </p>

        <div className="mt-6">
          <div className="flex items-center justify-between text-xs text-slate-500">
            <span>Tu progreso</span>
            <span>{progress}%</span>
          </div>
          <div className="mt-2 h-2 overflow-hidden rounded-full bg-slate-100">
            <div
              className="h-full rounded-full bg-indigo-600 transition-all"
              style={{ width: `${progress}%` }}
            />
          </div>
          <p className="mt-2 text-xs text-slate-500">
            {isReassignment ? "Nota de esta reasignación:" : "Nota actual:"}{" "}
            <span className="font-semibold text-slate-700">
              {formatScore(grade)} / 10
            </span>{" "}
            ({formatScore(totalPoints)} de {maxPoints} puntos posibles)
          </p>
          {plans.length > 1 && (
            <p className="mt-1 text-xs text-violet-700">
              Se conserva tu mejor nota entre todas las rondas:{" "}
              <span className="font-semibold">
                {formatScore(bestGrade)} / 10
              </span>{" "}
              (ronda {bestRound}).
            </p>
          )}
        </div>
      </div>

      <div className="mt-6 space-y-4">
        {exercises.length === 0 ? (
          <div className="card p-10 text-center text-slate-500">
            Este módulo todavía no tiene ejercicios.
          </div>
        ) : hasTimeLimit ? (
          <TimedRunner
            moduleId={module.id}
            exercises={exercises}
            solvedIds={Array.from(solvedIds)}
            lockedByAttemptsIds={attemptsExhaustedIds}
            initialEarnedPoints={totalPoints}
            moduleTimeLimitMinutes={module.module_time_limit_minutes}
            questionTimeLimitSeconds={module.question_time_limit_seconds}
            initialModuleExpiresAt={moduleSession?.expires_at ?? null}
            initialQuestionSessions={questionSessions.map((session) => ({
              exerciseId: session.exercise_id,
              expiresAt: session.expires_at,
              submittedAt: session.submitted_at,
            }))}
            serverNow={serverNow}
          />
        ) : currentExercise ? (
          <>
            <div className="flex flex-wrap items-center justify-between gap-2 px-1 text-xs font-medium text-slate-500">
              <span>
                Ejercicio {currentIndex + 1} de {exercises.length}
              </span>
              <span>
                {lockedIds.size} de {exercises.length} cerrados
              </span>
            </div>

            <ExerciseCard
              key={currentExercise.id}
              exercise={currentExercise}
              index={currentIndex}
              solved={solvedIds.has(currentExercise.id)}
              score={scores.get(currentExercise.id) ?? 0}
              attemptsUsed={attemptsUsed.get(currentExercise.id) ?? 0}
              locked={lockedIds.has(currentExercise.id)}
              isLast={currentIndex === exercises.length - 1}
            />

            <p className="px-1 text-xs text-slate-400">
              Este es el único ejercicio visible. Para avanzar, acierta o agota
              los 4 intentos.
            </p>
          </>
        ) : null}
      </div>

      {!hasTimeLimit && moduleCompleted && (
        <div
          className={`mt-6 rounded-2xl border p-6 text-center ${
            progress === 100
              ? "border-emerald-200 bg-emerald-50"
              : "border-amber-200 bg-amber-50"
          }`}
        >
          <p
            className={`text-lg font-bold ${
              progress === 100 ? "text-emerald-800" : "text-amber-900"
            }`}
          >
            {isReassignment
              ? `Reasignación ${currentPlan.round} completada`
              : progress === 100
                ? "¡Módulo completado! 🎉"
                : "Módulo finalizado"}
          </p>
          <p
            className={`mt-1 text-sm ${
              progress === 100 ? "text-emerald-700" : "text-amber-800"
            }`}
          >
            Resolviste {solvedIds.size} de {exercises.length} ejercicios. Nota
            de esta ronda: {formatScore(grade)} / 10.
            {plans.length > 1 && (
              <>
                {" "}
                Tu mejor nota se conserva:{" "}
                <span className="font-semibold">
                  {formatScore(bestGrade)} / 10
                </span>
                .
              </>
            )}{" "}
            Los ejercicios quedaron cerrados y no se aceptan más respuestas.
          </p>
          <p className="mt-2 text-xs text-slate-500">
            Si tu docente te reasigna el módulo, recibirás ejercicios diferentes
            y podrás mejorar tu nota.
          </p>
          <Link href="/dashboard" className="btn-primary mt-4">
            Volver a mis módulos
          </Link>
        </div>
      )}
    </div>
  );
}
