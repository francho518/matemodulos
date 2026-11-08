import Link from "next/link";
import { redirect } from "next/navigation";
import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { percentage } from "@/lib/utils";
import { selectExercisesForStudent } from "@/lib/exercise-selection";
import { formatScore, scoreByExercise } from "@/lib/scoring";
import type { AttemptRow, ModuleRow, ProfileRow } from "@/lib/types";

export const metadata: Metadata = {
  title: "Mis módulos",
};

export default async function DashboardPage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login?redirectTo=/dashboard");
  }

  const [profileResult, modulesResult, exercisesResult, attemptsResult] =
    await Promise.all([
      supabase
        .from("profiles")
        .select("id, full_name, email, role")
        .eq("id", user.id)
        .single(),
      supabase
        .from("modules")
        .select("*")
        .eq("is_published", true)
        .order("order_index", { ascending: true })
        .order("created_at", { ascending: true }),
      supabase.from("exercises").select("id, module_id, order_index"),
      supabase
        .from("attempts")
        .select("exercise_id, module_id, is_correct, created_at")
        .eq("user_id", user.id),
    ]);

  const profile = profileResult.data as ProfileRow | null;
  const modules = (modulesResult.data ?? []) as ModuleRow[];
  const publishedModuleIds = new Set(modules.map((module) => module.id));

  const exercises = ((exercisesResult.data ?? []) as Array<{
    id: string;
    module_id: string;
    order_index: number;
  }>).filter((exercise) => publishedModuleIds.has(exercise.module_id));

  const attempts = ((attemptsResult.data ?? []) as AttemptRow[]).filter(
    (attempt) => publishedModuleIds.has(attempt.module_id),
  );

  const exercisesByModule = new Map<
    string,
    Array<{ id: string; order_index: number }>
  >();

  for (const exercise of exercises) {
    if (!exercisesByModule.has(exercise.module_id)) {
      exercisesByModule.set(exercise.module_id, []);
    }
    exercisesByModule.get(exercise.module_id)!.push(exercise);
  }

  const totalByModule = new Map<string, number>();
  const assignedIdsByModule = new Map<string, Set<string>>();
  let totalExercises = 0;

  for (const module of modules) {
    const assigned = selectExercisesForStudent(
      exercisesByModule.get(module.id) ?? [],
      user.id,
      module.id,
      Boolean(module.randomize_exercises),
      Number(module.exercises_per_student) || 0,
    );

    assignedIdsByModule.set(
      module.id,
      new Set(assigned.map((exercise) => exercise.id)),
    );
    totalByModule.set(module.id, assigned.length);
    totalExercises += assigned.length;
  }

  const relevantAttempts = attempts.filter((attempt) =>
    assignedIdsByModule.get(attempt.module_id)?.has(attempt.exercise_id),
  );

  const solvedByModule = new Map<string, Set<string>>();
  const solvedExercises = new Set<string>();

  for (const attempt of relevantAttempts) {
    if (!attempt.is_correct) continue;

    solvedExercises.add(attempt.exercise_id);

    if (!solvedByModule.has(attempt.module_id)) {
      solvedByModule.set(attempt.module_id, new Set());
    }
    solvedByModule.get(attempt.module_id)!.add(attempt.exercise_id);
  }

  const totalSolved = solvedExercises.size;

  const scores = scoreByExercise(relevantAttempts);

  const moduleIdByExercise = new Map(
    exercises.map((exercise) => [exercise.id, exercise.module_id]),
  );

  const pointsByModule = new Map<string, number>();

  for (const [exerciseId, score] of scores) {
    const moduleId = moduleIdByExercise.get(exerciseId);
    if (!moduleId) continue;

    pointsByModule.set(moduleId, (pointsByModule.get(moduleId) ?? 0) + score);
  }

  const totalPoints = Array.from(pointsByModule.values()).reduce(
    (sum, points) => sum + points,
    0,
  );
  const overallGrade =
    totalExercises > 0 ? (totalPoints / totalExercises) * 10 : 0;

  const correctAttempts = relevantAttempts.filter(
    (attempt) => attempt.is_correct,
  ).length;
  const accuracy =
    relevantAttempts.length > 0
      ? Math.round((correctAttempts / relevantAttempts.length) * 100)
      : 0;

  const displayName =
    profile?.full_name ?? user.email?.split("@")[0] ?? "estudiante";

  return (
    <div className="mx-auto max-w-6xl px-4 py-10">
      <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
        <div>
          <p className="text-sm font-medium text-indigo-600">Panel del estudiante</p>
          <h1 className="mt-1 text-3xl font-bold tracking-tight text-slate-900">
            Hola, {displayName}
          </h1>
          <p className="mt-2 text-slate-600">
            Elige un módulo y continúa donde lo dejaste.
          </p>
        </div>

        {profile?.role === "admin" && (
          <Link href="/admin" className="btn-secondary">
            Ir al panel de administración
          </Link>
        )}
      </div>

      {/* Estadísticas */}
      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div className="card p-5">
          <p className="text-sm font-medium text-slate-500">Módulos disponibles</p>
          <p className="mt-2 text-3xl font-bold text-slate-900">
            {modules.length}
          </p>
        </div>

        <div className="card p-5">
          <p className="text-sm font-medium text-slate-500">Ejercicios resueltos</p>
          <p className="mt-2 text-3xl font-bold text-slate-900">
            {totalSolved}
            <span className="text-base font-medium text-slate-400">
              {" "}
              / {totalExercises}
            </span>
          </p>
        </div>

        <div className="card p-5">
          <p className="text-sm font-medium text-slate-500">Puntaje</p>
          <p className="mt-2 text-3xl font-bold text-slate-900">
            {formatScore(totalPoints)}
            <span className="text-base font-medium text-slate-400">
              {" "}
              / {totalExercises}
            </span>
          </p>
          <p className="mt-1 text-xs text-slate-400">
            Nota global: {formatScore(overallGrade)} / 10
          </p>
        </div>

        <div className="card p-5">
          <p className="text-sm font-medium text-slate-500">Precisión</p>
          <p className="mt-2 text-3xl font-bold text-slate-900">{accuracy}%</p>
          <p className="mt-1 text-xs text-slate-400">
            {relevantAttempts.length} intento
            {relevantAttempts.length === 1 ? "" : "s"} en total
          </p>
        </div>
      </div>

      {/* Lista de módulos */}
      <h2 className="mt-10 text-xl font-bold text-slate-900">Módulos</h2>

      {modules.length === 0 ? (
        <div className="card mt-4 p-10 text-center">
          <p className="text-lg font-semibold text-slate-700">
            Todavía no tienes módulos asignados
          </p>
          <p className="mt-2 text-sm text-slate-500">
            Los módulos solo son visibles para los estudiantes que pertenecen a
            un grupo con módulos asignados. Pide a tu profesor que te agregue a
            un grupo.
          </p>
          {profile?.role === "admin" && (
            <Link href="/admin/modules/new" className="btn-primary mt-6">
              Crear un módulo
            </Link>
          )}
        </div>
      ) : (
        <div className="mt-4 grid gap-5 md:grid-cols-2">
          {modules.map((module) => {
            const total = totalByModule.get(module.id) ?? 0;
            const solved = solvedByModule.get(module.id)?.size ?? 0;
            const points = pointsByModule.get(module.id) ?? 0;
            const moduleGrade = total > 0 ? (points / total) * 10 : 0;
            const progress = percentage(solved, total);

            return (
              <Link
                key={module.id}
                href={`/modules/${module.slug}`}
                className="card group flex flex-col p-6 transition hover:-translate-y-0.5 hover:border-indigo-200 hover:shadow-md"
              >
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <h3 className="text-lg font-bold text-slate-900 group-hover:text-indigo-700">
                      {module.title}
                    </h3>
                    <p className="mt-1 line-clamp-2 text-sm text-slate-600">
                      {module.description ?? "Sin descripción."}
                    </p>

                    {(module.module_time_limit_minutes ||
                      module.question_time_limit_seconds) && (
                      <div className="mt-2 flex flex-wrap gap-1.5">
                        {module.module_time_limit_minutes ? (
                          <span className="badge bg-amber-50 text-amber-700">
                            ⏱ {module.module_time_limit_minutes} min
                          </span>
                        ) : null}
                        {module.question_time_limit_seconds ? (
                          <span className="badge bg-amber-50 text-amber-700">
                            ⏱ {module.question_time_limit_seconds} s/pregunta
                          </span>
                        ) : null}
                      </div>
                    )}
                  </div>

                  <span
                    className={`badge shrink-0 ${
                      progress === 100
                        ? "bg-emerald-100 text-emerald-700"
                        : "bg-slate-100 text-slate-600"
                    }`}
                  >
                    {solved}/{total}
                  </span>
                </div>

                <div className="mt-5">
                  <div className="flex items-center justify-between text-xs text-slate-500">
                    <span>{progress}% completado</span>
                    <span>Nota {formatScore(moduleGrade)} / 10</span>
                  </div>
                  <div className="mt-2 h-2 overflow-hidden rounded-full bg-slate-100">
                    <div
                      className="h-full rounded-full bg-indigo-600 transition-all"
                      style={{ width: `${progress}%` }}
                    />
                  </div>
                  <p className="mt-1.5 text-xs text-slate-400">
                    {formatScore(points)} de {total} puntos · {total} ejercicios
                  </p>
                </div>

                <span className="mt-5 text-sm font-semibold text-indigo-600">
                  Entrar al módulo →
                </span>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
