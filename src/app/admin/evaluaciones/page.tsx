import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { EvaluationForm } from "@/components/admin/evaluation-form";

export const metadata: Metadata = {
  title: "Evaluaciones PDF",
};

type ModuleOption = {
  id: string;
  title: string;
  is_published: boolean;
  order_index: number;
  exercises: Array<{ count: number }>;
};

type GroupOption = {
  id: string;
  name: string;
  group_modules: Array<{ count: number }>;
};

export default async function AdminEvaluacionesPage() {
  const supabase = await createClient();

  const [modulesResult, groupsResult] = await Promise.all([
    supabase
      .from("modules")
      .select("id, title, is_published, order_index, exercises(count)")
      .order("order_index", { ascending: true })
      .order("created_at", { ascending: true }),
    supabase
      .from("groups")
      .select("id, name, group_modules(count)")
      .order("name", { ascending: true }),
  ]);

  const modules = (modulesResult.data ?? []) as ModuleOption[];
  const groups = (groupsResult.data ?? []) as GroupOption[];

  return (
    <div>
      <h2 className="text-xl font-bold text-slate-900">Evaluaciones PDF</h2>
      <p className="mt-1 text-sm text-slate-500">
        Genera pruebas con el mismo formato de las guías de práctica. Puedes
        crear varias versiones diferentes en un mismo PDF y descargar el
        solucionario por separado.
      </p>

      <EvaluationForm
        modules={modules.map((module) => ({
          id: module.id,
          title: module.title,
          isPublished: module.is_published,
          exerciseCount: module.exercises[0]?.count ?? 0,
        }))}
        groups={groups.map((group) => ({
          id: group.id,
          name: group.name,
          moduleCount: group.group_modules[0]?.count ?? 0,
        }))}
      />
    </div>
  );
}
