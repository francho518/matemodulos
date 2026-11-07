import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { percentage } from "@/lib/utils";
import { selectExercisesForStudent } from "@/lib/exercise-selection";
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

  const [exercisesResult, attemptsResult] = await Promise.all([
    supabase
      .from("exercises")
      .select("id, prompt, type, options, order_index")
      .eq("module_id", module.id)
      .order("order_index", { ascending: true })
      .order("created_at", { ascending: true }),
    supabase
      .from("attempts")
      .select("exercise_id, module_id, is_correct")
      .eq("user_id", user.id)
      .eq("module_id", module.id),
  ]);

  const allExercises = (exercisesResult.data ?? []) as PublicExercise[];

  // Selección estable por estudiante: misma combinación en cada visita,
  // distinta a la de los demás alumnos.
  const exercises = selectExercisesForStudent(
    allExercises,
    user.id,
    module.id,
    Boolean(module.randomize_exercises),
    Number(module.exercises_per_student) || 0,
  );

  const assignedIds = new Set(exercises.map((exercise) => exercise.id));

  const attempts = ((attemptsResult.data ?? []) as AttemptRow[]).filter(
    (attempt) => assignedIds.has(attempt.exercise_id),
  );

  const solvedIds = new Set(
    attempts
      .filter((attempt) => attempt.is_correct)
      .map((attempt) => attempt.exercise_id),
  );

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

          <span
            className={`badge shrink-0 ${
              progress === 100
                ? "bg-emerald-100 text-emerald-700"
                : "bg-indigo-50 text-indigo-700"
            }`}
          >
            {solvedIds.size} de {exercises.length} resueltos
          </span>
        </div>

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
        ) : (
          exercises.map((exercise, index) => (
            <ExerciseCard
              key={exercise.id}
              exercise={exercise}
              index={index}
              solved={solvedIds.has(exercise.id)}
            />
          ))
        )}
      </div>

      {!hasTimeLimit && progress === 100 && exercises.length > 0 && (
        <div className="mt-6 rounded-2xl border border-emerald-200 bg-emerald-50 p-6 text-center">
          <p className="text-lg font-bold text-emerald-800">
            ¡Módulo completado! 🎉
          </p>
          <p className="mt-1 text-sm text-emerald-700">
            Resolviste todos los ejercicios. Puedes repasarlos o volver al panel
            para elegir otro tema.
          </p>
          <Link href="/dashboard" className="btn-primary mt-4">
            Elegir otro módulo
          </Link>
        </div>
      )}
    </div>
  );
}
