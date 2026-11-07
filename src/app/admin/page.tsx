import Link from "next/link";
import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { firstParam, formatDate } from "@/lib/utils";
import type { ModuleRow } from "@/lib/types";
import { ConfirmButton } from "@/components/confirm-button";
import { deleteModuleAction } from "@/app/admin/actions";

export const metadata: Metadata = {
  title: "Administración",
};

type ModuleWithCount = ModuleRow & {
  exercises: Array<{ count: number }>;
};

type Props = {
  searchParams: Promise<{ ok?: string | string[]; error?: string | string[] }>;
};

export default async function AdminPage({ searchParams }: Props) {
  const params = await searchParams;
  const ok = firstParam(params.ok);
  const errorMessage = firstParam(params.error);

  const supabase = await createClient();
  const { data } = await supabase
    .from("modules")
    .select(
      "id, title, slug, description, order_index, is_published, created_at, exercises(count)",
    )
    .order("order_index", { ascending: true })
    .order("created_at", { ascending: true });

  const modules = (data ?? []) as ModuleWithCount[];

  return (
    <div>
      {ok && (
        <p className="mb-4 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          Operación realizada correctamente.
        </p>
      )}

      {errorMessage && (
        <p className="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {errorMessage}
        </p>
      )}

      <div className="flex flex-col justify-between gap-3 sm:flex-row sm:items-center">
        <div>
          <h2 className="text-xl font-bold text-slate-900">Módulos</h2>
          <p className="mt-1 text-sm text-slate-500">
            Publica o despublica temas. Los módulos publicados aparecen en el
            panel de los estudiantes.
          </p>
        </div>

        <Link href="/admin/modules/new" className="btn-primary">
          + Nuevo módulo
        </Link>
      </div>

      {modules.length === 0 ? (
        <div className="card mt-4 p-10 text-center">
          <p className="text-lg font-semibold text-slate-700">
            Todavía no hay módulos
          </p>
          <p className="mt-2 text-sm text-slate-500">
            Crea el primer tema para que tus estudiantes puedan practicar.
          </p>
          <Link href="/admin/modules/new" className="btn-primary mt-6">
            Crear mi primer módulo
          </Link>
        </div>
      ) : (
        <div className="mt-4 space-y-3">
          {modules.map((module) => {
            const exerciseCount = module.exercises?.[0]?.count ?? 0;

            return (
              <div
                key={module.id}
                className="card flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between"
              >
                <div className="min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <h3 className="truncate font-semibold text-slate-900">
                      {module.title}
                    </h3>

                    <span
                      className={`badge ${
                        module.is_published
                          ? "bg-emerald-100 text-emerald-700"
                          : "bg-amber-100 text-amber-700"
                      }`}
                    >
                      {module.is_published ? "Publicado" : "Borrador"}
                    </span>
                  </div>

                  <p className="mt-1 truncate text-sm text-slate-500">
                    /modules/{module.slug} · {exerciseCount} ejercicio
                    {exerciseCount === 1 ? "" : "s"} · orden {module.order_index}{" "}
                    · {formatDate(module.created_at)}
                  </p>
                </div>

                <div className="flex shrink-0 flex-wrap items-center gap-2">
                  <Link
                    href={`/admin/modules/${module.id}`}
                    className="btn-secondary"
                  >
                    Editar
                  </Link>

                  {module.is_published && (
                    <Link
                      href={`/modules/${module.slug}`}
                      className="rounded-lg px-3 py-2 text-sm font-semibold text-slate-500 transition hover:bg-slate-100 hover:text-slate-800"
                    >
                      Ver
                    </Link>
                  )}

                  <form action={deleteModuleAction}>
                    <input type="hidden" name="id" value={module.id} />
                    <ConfirmButton
                      message={`¿Eliminar "${module.title}" y todos sus ejercicios? Esta acción no se puede deshacer.`}
                      className="btn-danger"
                    >
                      Eliminar
                    </ConfirmButton>
                  </form>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
