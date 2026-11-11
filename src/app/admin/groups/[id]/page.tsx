import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { firstParam, percentage } from "@/lib/utils";
import { formatScore } from "@/lib/scoring";
import {
  bestGradedRound,
  buildRoundPlans,
  currentRoundPlan,
  statsForPlan,
  type StoredRound,
} from "@/lib/progress";
import type { GroupRow, ModuleRow, ProfileRow } from "@/lib/types";
import { GroupForm } from "@/components/admin/group-form";
import { ConfirmButton } from "@/components/confirm-button";
import {
  addGroupMemberAction,
  deleteGroupAction,
  reassignModuleAction,
  removeGroupMemberAction,
  setGroupModulesAction,
} from "@/app/admin/groups/actions";

type Props = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{
    ok?: string | string[];
    error?: string | string[];
    nuevos?: string | string[];
    total?: string | string[];
  }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  const supabase = await createClient();
  const { data } = await supabase
    .from("groups")
    .select("name")
    .eq("id", id)
    .maybeSingle();

  return { title: data?.name ? `Grupo: ${data.name}` : "Grupo" };
}

export default async function GroupDetailPage({ params, searchParams }: Props) {
  const { id } = await params;
  const query = await searchParams;
  const ok = firstParam(query.ok);
  const errorMessage = firstParam(query.error);
  const newExercises = Number(firstParam(query.nuevos) ?? 0) || 0;
  const totalExercises = Number(firstParam(query.total) ?? 0) || 0;

  const supabase = await createClient();

  const { data: groupData } = await supabase
    .from("groups")
    .select("id, name, description, created_at")
    .eq("id", id)
    .maybeSingle();

  if (!groupData) {
    notFound();
  }

  const group = groupData as GroupRow;

  const [memberRowsResult, allStudentsResult, modulesResult, assignedResult] =
    await Promise.all([
      supabase
        .from("group_members")
        .select("user_id, created_at")
        .eq("group_id", group.id)
        .order("created_at", { ascending: true }),
      supabase
        .from("profiles")
        .select("id, full_name, email, role")
        .eq("role", "student")
        .order("full_name", { ascending: true }),
      supabase
        .from("modules")
        .select(
          "id, title, slug, order_index, is_published, randomize_exercises, exercises_per_student",
        )
        .order("order_index", { ascending: true })
        .order("created_at", { ascending: true }),
      supabase
        .from("group_modules")
        .select("module_id")
        .eq("group_id", group.id),
    ]);

  const memberIds = (memberRowsResult.data ?? []).map((row) => row.user_id);
  const memberIdSet = new Set(memberIds);

  let memberProfiles: ProfileRow[] = [];

  if (memberIds.length > 0) {
    const { data } = await supabase
      .from("profiles")
      .select("id, full_name, email, role")
      .in("id", memberIds);

    memberProfiles = (data ?? []) as ProfileRow[];
  }

  const profileById = new Map(
    memberProfiles.map((profile) => [profile.id, profile]),
  );

  const members = memberIds.map((memberId) => {
    const profile = profileById.get(memberId);
    return {
      id: memberId,
      name: profile?.full_name ?? "Estudiante sin nombre",
      email: profile?.email ?? "Sin correo",
    };
  });

  const allStudents = (allStudentsResult.data ?? []) as ProfileRow[];
  const availableStudents = allStudents.filter(
    (student) => !memberIdSet.has(student.id),
  );

  const modules = (modulesResult.data ?? []) as Array<
    Pick<
      ModuleRow,
      | "id"
      | "title"
      | "slug"
      | "order_index"
      | "is_published"
      | "randomize_exercises"
      | "exercises_per_student"
    >
  >;
  const assignedModuleIds = new Set(
    (assignedResult.data ?? []).map((row) => row.module_id),
  );

  const assignedModules = modules.filter((module) =>
    assignedModuleIds.has(module.id),
  );

  // Progreso por estudiante y módulo, con la ronda actual y la mejor
  // nota entre la asignación original y sus reasignaciones.
  const progressByStudentModule = new Map<
    string,
    {
      total: number;
      solved: number;
      completed: boolean;
      timeExpired: boolean;
      grade: number;
      bestGrade: number;
      round: number;
    }
  >();

  if (memberIds.length > 0 && assignedModules.length > 0) {
    const assignedModuleIdList = assignedModules.map((module) => module.id);

    const [exercisesResult, progressAttemptsResult, roundsResult, sessionsResult] =
      await Promise.all([
        supabase
          .from("exercises")
          .select("id, module_id, order_index")
          .in("module_id", assignedModuleIdList),
        supabase
          .from("attempts")
          .select("user_id, module_id, exercise_id, is_correct, created_at, round")
          .in("user_id", memberIds)
          .in("module_id", assignedModuleIdList),
        supabase
          .from("module_rounds")
          .select("user_id, module_id, round, exercise_ids")
          .in("user_id", memberIds)
          .in("module_id", assignedModuleIdList),
        supabase
          .from("module_sessions")
          .select("user_id, module_id, expires_at")
          .in("user_id", memberIds)
          .in("module_id", assignedModuleIdList),
      ]);

    const expiredSessionKeys = new Set<string>();

    for (const session of sessionsResult.data ?? []) {
      if (
        session.expires_at &&
        new Date(session.expires_at).getTime() <= Date.now()
      ) {
        expiredSessionKeys.add(`${session.user_id}:${session.module_id}`);
      }
    }

    const exercisesByModule = new Map<
      string,
      Array<{ id: string; order_index: number }>
    >();

    for (const exercise of exercisesResult.data ?? []) {
      const list = exercisesByModule.get(exercise.module_id) ?? [];
      list.push({ id: exercise.id, order_index: exercise.order_index });
      exercisesByModule.set(exercise.module_id, list);
    }

    const attemptsByStudentModule = new Map<
      string,
      Array<{
        exercise_id: string;
        is_correct: boolean;
        created_at: string;
        round: number | null;
      }>
    >();

    for (const attempt of progressAttemptsResult.data ?? []) {
      const key = `${attempt.user_id}:${attempt.module_id}`;
      const list = attemptsByStudentModule.get(key) ?? [];
      list.push({
        exercise_id: attempt.exercise_id,
        is_correct: attempt.is_correct,
        created_at: attempt.created_at,
        round: attempt.round,
      });
      attemptsByStudentModule.set(key, list);
    }

    const roundsByStudentModule = new Map<string, StoredRound[]>();

    for (const row of roundsResult.data ?? []) {
      const key = `${row.user_id}:${row.module_id}`;
      const list = roundsByStudentModule.get(key) ?? [];
      list.push({ round: row.round, exercise_ids: row.exercise_ids });
      roundsByStudentModule.set(key, list);
    }

    for (const memberId of memberIds) {
      for (const module of assignedModules) {
        const key = `${memberId}:${module.id}`;

        const plans = buildRoundPlans({
          exercises: exercisesByModule.get(module.id) ?? [],
          userId: memberId,
          moduleId: module.id,
          randomize: Boolean(module.randomize_exercises),
          exercisesPerStudent: Number(module.exercises_per_student) || 0,
          rounds: roundsByStudentModule.get(key) ?? [],
        });

        const attempts = attemptsByStudentModule.get(key) ?? [];

        const roundStats = plans.map((plan) => statsForPlan(plan, attempts));
        const current = currentRoundPlan(plans);
        const stats = roundStats[roundStats.length - 1];
        const best = bestGradedRound(roundStats);

        progressByStudentModule.set(key, {
          total: stats.total,
          solved: stats.solved,
          completed: stats.completed,
          timeExpired: expiredSessionKeys.has(key),
          grade: stats.grade,
          bestGrade: best?.grade ?? stats.grade,
          round: current.round,
        });
      }
    }
  }

  return (
    <div className="space-y-8">
      {ok && (
        <p className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          {ok === "reasignado"
            ? `Reasignación creada con ${newExercises} de ${totalExercises} ejercicios nuevos. Se conservará la mejor nota del estudiante.`
            : "Cambios guardados correctamente."}
        </p>
      )}

      {errorMessage && (
        <p className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {errorMessage}
        </p>
      )}

      <div>
        <Link
          href="/admin/groups"
          className="text-sm font-medium text-slate-500 transition hover:text-indigo-600"
        >
          ← Volver a grupos
        </Link>

        <div className="mt-4 flex flex-col justify-between gap-4 sm:flex-row sm:items-start">
          <div>
            <h2 className="text-2xl font-bold text-slate-900">{group.name}</h2>
            <p className="mt-1 text-sm text-slate-500">
              {group.description ?? "Sin descripción."}
            </p>
            <p className="mt-2 text-sm text-slate-500">
              {members.length} estudiante{members.length === 1 ? "" : "s"} ·{" "}
              {assignedModuleIds.size} módulo
              {assignedModuleIds.size === 1 ? "" : "s"} asignado
              {assignedModuleIds.size === 1 ? "" : "s"}
            </p>
          </div>

          <div className="flex shrink-0 flex-col gap-2 sm:flex-row">
            <a
              href={`/admin/groups/${group.id}/export`}
              className="btn-secondary"
            >
              ⬇ Planilla de notas (CSV)
            </a>
            <a
              href={`/admin/groups/${group.id}/export?formato=detalle`}
              className="btn-secondary"
            >
              Detalle por módulo (CSV)
            </a>
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="card p-6">
          <h3 className="text-lg font-bold text-slate-900">Datos del grupo</h3>
          <div className="mt-5">
            <GroupForm group={group} />
          </div>
        </div>

        <div className="card p-6">
          <h3 className="text-lg font-bold text-slate-900">
            Estudiantes del grupo
          </h3>
          <p className="mt-1 text-sm text-slate-500">
            Solo los estudiantes agregados aquí verán los módulos asignados a
            este grupo.
          </p>

          {members.length === 0 ? (
            <p className="mt-5 rounded-xl bg-slate-50 p-4 text-sm text-slate-500">
              Todavía no hay estudiantes en este grupo.
            </p>
          ) : (
            <ul className="mt-5 divide-y divide-slate-100">
              {members.map((member) => (
                <li
                  key={member.id}
                  className="flex items-center justify-between gap-3 py-3"
                >
                  <div className="min-w-0">
                    <p className="truncate text-sm font-medium text-slate-800">
                      {member.name}
                    </p>
                    <p className="truncate text-xs text-slate-500">
                      {member.email}
                    </p>
                  </div>

                  <form action={removeGroupMemberAction} className="shrink-0">
                    <input type="hidden" name="group_id" value={group.id} />
                    <input type="hidden" name="user_id" value={member.id} />
                    <ConfirmButton
                      message={`¿Quitar a ${member.name} del grupo?`}
                      className="text-xs font-semibold text-red-600 transition hover:text-red-700"
                    >
                      Quitar
                    </ConfirmButton>
                  </form>
                </li>
              ))}
            </ul>
          )}

          <form
            action={addGroupMemberAction}
            className="mt-6 flex flex-col gap-2 border-t border-slate-100 pt-5 sm:flex-row"
          >
            <input type="hidden" name="group_id" value={group.id} />
            <select
              name="user_id"
              required
              defaultValue=""
              className="input flex-1"
              aria-label="Estudiante para agregar"
            >
              <option value="" disabled>
                {availableStudents.length === 0
                  ? "No hay estudiantes disponibles"
                  : "Selecciona un estudiante…"}
              </option>
              {availableStudents.map((student) => (
                <option key={student.id} value={student.id}>
                  {student.full_name ?? "Sin nombre"}
                  {student.email ? ` · ${student.email}` : ""}
                </option>
              ))}
            </select>
            <button
              type="submit"
              disabled={availableStudents.length === 0}
              className="btn-primary shrink-0 disabled:cursor-not-allowed disabled:opacity-50"
            >
              Agregar
            </button>
          </form>
        </div>
      </div>

      <div className="card p-6">
        <h3 className="text-lg font-bold text-slate-900">
          Módulos asignados al grupo
        </h3>
        <p className="mt-1 max-w-3xl text-sm text-slate-500">
          Marca los módulos que puede ver este grupo. Un módulo solo es visible
          para los estudiantes de los grupos donde esté asignado: si no lo
          asignas a ningún grupo, ningún estudiante lo verá.
        </p>

        <form action={setGroupModulesAction} className="mt-5">
          <input type="hidden" name="group_id" value={group.id} />

          {modules.length === 0 ? (
            <p className="rounded-xl bg-slate-50 p-4 text-sm text-slate-500">
              Todavía no hay módulos creados.
            </p>
          ) : (
            <div className="grid gap-2 sm:grid-cols-2">
              {modules.map((module) => (
                <label
                  key={module.id}
                  className="flex items-start gap-3 rounded-xl border border-slate-200 p-3.5 transition hover:border-indigo-200 hover:bg-indigo-50/40"
                >
                  <input
                    type="checkbox"
                    name="module_id"
                    value={module.id}
                    defaultChecked={assignedModuleIds.has(module.id)}
                    className="mt-0.5 h-4 w-4 shrink-0 accent-indigo-600"
                  />
                  <span className="min-w-0">
                    <span className="block text-sm font-medium text-slate-800">
                      {module.title}
                    </span>
                    <span className="mt-1 flex flex-wrap gap-1.5">
                      <span
                        className={`badge ${
                          module.is_published
                            ? "bg-emerald-100 text-emerald-700"
                            : "bg-amber-100 text-amber-700"
                        }`}
                      >
                        {module.is_published ? "Publicado" : "Borrador"}
                      </span>
                      <span className="badge bg-slate-100 text-slate-600">
                        /modules/{module.slug}
                      </span>
                    </span>
                  </span>
                </label>
              ))}
            </div>
          )}

          <button type="submit" className="btn-primary mt-5">
            Guardar módulos asignados
          </button>
        </form>
      </div>

      <div className="card p-6">
        <h3 className="text-lg font-bold text-slate-900">
          Progreso y reasignaciones
        </h3>
        <p className="mt-1 max-w-3xl text-sm text-slate-500">
          Cuando un estudiante termina un módulo puedes reasignarlo con
          ejercicios diferentes. Los intentos anteriores se conservan y se deja
          la mejor nota entre la primera vuelta y la reasignación.
        </p>

        {members.length === 0 ? (
          <p className="mt-5 rounded-xl bg-slate-50 p-4 text-sm text-slate-500">
            Agrega estudiantes al grupo para ver su progreso.
          </p>
        ) : assignedModules.length === 0 ? (
          <p className="mt-5 rounded-xl bg-slate-50 p-4 text-sm text-slate-500">
            Asigna al menos un módulo al grupo para ver el progreso.
          </p>
        ) : (
          <div className="mt-5 overflow-x-auto">
            <table className="w-full min-w-[720px] border-collapse text-left text-sm">
              <thead>
                <tr className="border-b border-slate-200 text-xs uppercase tracking-wide text-slate-500">
                  <th className="py-3 pr-4 font-semibold">Estudiante</th>
                  {assignedModules.map((module) => (
                    <th
                      key={module.id}
                      className="px-3 py-3 font-semibold align-bottom"
                    >
                      {module.title}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {members.map((member) => (
                  <tr
                    key={member.id}
                    className="border-b border-slate-100 align-top last:border-0"
                  >
                    <td className="py-4 pr-4">
                      <p className="font-medium text-slate-800">{member.name}</p>
                      <p className="text-xs text-slate-500">{member.email}</p>
                    </td>

                    {assignedModules.map((module) => {
                      const status = progressByStudentModule.get(
                        `${member.id}:${module.id}`,
                      );

                      if (!status || status.total === 0) {
                        return (
                          <td
                            key={module.id}
                            className="px-3 py-4 text-xs text-slate-400"
                          >
                            Sin ejercicios
                          </td>
                        );
                      }

                      const finished = status.completed || status.timeExpired;

                      return (
                        <td key={module.id} className="px-3 py-4">
                          <p className="text-xs font-semibold text-slate-600">
                            {status.round > 1
                              ? `Reasignación ${status.round}`
                              : "Primera vuelta"}
                          </p>
                          <p className="mt-0.5 text-xs text-slate-500">
                            {status.solved} de {status.total} resueltos ·{" "}
                            {percentage(status.solved, status.total)}%
                          </p>
                          <p className="mt-0.5 text-xs text-slate-500">
                            {status.completed
                              ? `Nota ${formatScore(status.grade)} / 10`
                              : status.timeExpired
                                ? `Tiempo agotado · Nota ${formatScore(status.grade)} / 10`
                                : "En curso"}
                          </p>
                          {status.round > 1 && (
                            <p className="mt-0.5 text-xs font-medium text-violet-700">
                              Mejor nota: {formatScore(status.bestGrade)} / 10
                            </p>
                          )}

                          {finished ? (
                            <form action={reassignModuleAction} className="mt-2">
                              <input
                                type="hidden"
                                name="group_id"
                                value={group.id}
                              />
                              <input
                                type="hidden"
                                name="user_id"
                                value={member.id}
                              />
                              <input
                                type="hidden"
                                name="module_id"
                                value={module.id}
                              />
                              <ConfirmButton
                                message={`¿Reasignar "${module.title}" a ${member.name} con ejercicios diferentes? Se conservará la mejor nota.`}
                                className="rounded-lg bg-violet-600 px-3 py-1.5 text-xs font-semibold text-white transition hover:bg-violet-500"
                              >
                                ↻ Reasignar
                              </ConfirmButton>
                            </form>
                          ) : (
                            <span className="mt-2 inline-block text-xs text-slate-400">
                              Se habilita al terminar
                            </span>
                          )}
                        </td>
                      );
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <p className="mt-4 text-xs text-slate-400">
          Para que una reasignación tenga ejercicios realmente distintos, el
          módulo debe entregar menos ejercicios que el total de su banco
          (configúralo en “Ejercicios por estudiante”). Si entrega todo el
          banco, se repetirán los mismos ejercicios en una ronda nueva.
        </p>
      </div>

      <div className="card border-red-200 p-6">
        <h3 className="text-lg font-bold text-red-700">Eliminar grupo</h3>
        <p className="mt-1 text-sm text-slate-500">
          Se elimina el grupo y sus asignaciones. Los estudiantes y los módulos
          no se borran.
        </p>

        <form action={deleteGroupAction} className="mt-4">
          <input type="hidden" name="id" value={group.id} />
          <ConfirmButton
            message={`¿Eliminar el grupo "${group.name}"? Esta acción no se puede deshacer.`}
            className="btn-danger"
          >
            Eliminar grupo
          </ConfirmButton>
        </form>
      </div>
    </div>
  );
}
