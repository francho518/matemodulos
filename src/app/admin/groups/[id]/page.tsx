import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { firstParam } from "@/lib/utils";
import type { GroupRow, ModuleRow, ProfileRow } from "@/lib/types";
import { GroupForm } from "@/components/admin/group-form";
import { ConfirmButton } from "@/components/confirm-button";
import {
  addGroupMemberAction,
  deleteGroupAction,
  removeGroupMemberAction,
  setGroupModulesAction,
} from "@/app/admin/groups/actions";

type Props = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ ok?: string | string[]; error?: string | string[] }>;
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
        .select("id, title, slug, order_index, is_published")
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
    Pick<ModuleRow, "id" | "title" | "slug" | "order_index" | "is_published">
  >;
  const assignedModuleIds = new Set(
    (assignedResult.data ?? []).map((row) => row.module_id),
  );

  return (
    <div className="space-y-8">
      {ok && (
        <p className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Cambios guardados correctamente.
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
          Marca los módulos que puede ver este grupo. Si un módulo no tiene
          ningún grupo asignado, seguirá siendo visible para todos los
          estudiantes. Si marcas un módulo aquí, solo lo verán los miembros de
          este grupo.
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
