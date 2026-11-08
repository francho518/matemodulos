import Link from "next/link";
import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { firstParam } from "@/lib/utils";
import { GroupForm } from "@/components/admin/group-form";

export const metadata: Metadata = {
  title: "Grupos",
};

type GroupWithCounts = {
  id: string;
  name: string;
  description: string | null;
  created_at: string;
  group_members?: Array<{ count: number }>;
  group_modules?: Array<{ count: number }>;
};

type Props = {
  searchParams: Promise<{ ok?: string | string[]; error?: string | string[] }>;
};

export default async function GroupsPage({ searchParams }: Props) {
  const query = await searchParams;
  const ok = firstParam(query.ok);
  const errorMessage = firstParam(query.error);

  const supabase = await createClient();
  const { data } = await supabase
    .from("groups")
    .select(
      "id, name, description, created_at, group_members(count), group_modules(count)",
    )
    .order("name", { ascending: true });

  const groups = (data ?? []) as GroupWithCounts[];

  return (
    <div className="space-y-8">
      {ok && (
        <p className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Operación realizada correctamente.
        </p>
      )}

      {errorMessage && (
        <p className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {errorMessage}
        </p>
      )}

      <div>
        <h2 className="text-xl font-bold text-slate-900">Grupos</h2>
        <p className="mt-1 max-w-3xl text-sm text-slate-500">
          Agrupa estudiantes y asigna módulos. Un módulo solo es visible para los
          estudiantes que pertenecen a algún grupo al que esté asignado. Los
          módulos sin grupos asignados no los ve ningún estudiante.
        </p>
      </div>

      {groups.length === 0 ? (
        <div className="card p-8 text-center text-slate-500">
          Todavía no hay grupos. Crea el primero con el formulario de abajo.
        </div>
      ) : (
        <div className="space-y-3">
          {groups.map((group) => {
            const memberCount = group.group_members?.[0]?.count ?? 0;
            const moduleCount = group.group_modules?.[0]?.count ?? 0;

            return (
              <Link
                key={group.id}
                href={`/admin/groups/${group.id}`}
                className="card flex flex-col justify-between gap-4 p-5 transition hover:border-indigo-200 hover:shadow-md sm:flex-row sm:items-center"
              >
                <div className="min-w-0">
                  <h3 className="truncate font-semibold text-slate-900">
                    {group.name}
                  </h3>
                  <p className="mt-1 truncate text-sm text-slate-500">
                    {group.description ?? "Sin descripción."}
                  </p>
                </div>

                <div className="flex shrink-0 flex-wrap items-center gap-2">
                  <span className="badge bg-indigo-50 text-indigo-700">
                    {memberCount} estudiante{memberCount === 1 ? "" : "s"}
                  </span>
                  <span className="badge bg-slate-100 text-slate-600">
                    {moduleCount} módulo{moduleCount === 1 ? "" : "s"}
                  </span>
                  <span className="text-sm font-semibold text-indigo-600">
                    Abrir →
                  </span>
                </div>
              </Link>
            );
          })}
        </div>
      )}

      <div className="card p-6 sm:p-8">
        <h3 className="text-lg font-bold text-slate-900">Nuevo grupo</h3>
        <p className="mt-1 text-sm text-slate-500">
          Después de crearlo podrás agregar estudiantes, asignar módulos y
          exportar sus notas.
        </p>

        <div className="mt-6 max-w-xl">
          <GroupForm />
        </div>
      </div>
    </div>
  );
}
