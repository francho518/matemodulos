import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { firstParam } from "@/lib/utils";
import type { AdminExercise, ModuleRow } from "@/lib/types";
import { ModuleForm } from "@/components/admin/module-form";
import { ExerciseForm } from "@/components/admin/exercise-form";
import { MathText } from "@/components/math-text";
import { ConfirmButton } from "@/components/confirm-button";
import { deleteExerciseAction } from "@/app/admin/actions";

type Props = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ ok?: string | string[]; error?: string | string[] }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  const supabase = await createClient();
  const { data } = await supabase
    .from("modules")
    .select("title")
    .eq("id", id)
    .maybeSingle();

  return { title: data?.title ? `Editar: ${data.title}` : "Editar módulo" };
}

export default async function EditModulePage({ params, searchParams }: Props) {
  const { id } = await params;
  const query = await searchParams;
  const ok = firstParam(query.ok);
  const errorMessage = firstParam(query.error);

  const supabase = await createClient();

  const { data: moduleData } = await supabase
    .from("modules")
    .select("*")
    .eq("id", id)
    .maybeSingle();

  if (!moduleData) {
    notFound();
  }

  const module = moduleData as ModuleRow;

  const { data: exercisesData } = await supabase
    .from("exercises")
    .select(
      "id, module_id, prompt, type, options, correct_option, correct_answer, tolerance, explanation, order_index",
    )
    .eq("module_id", module.id)
    .order("order_index", { ascending: true })
    .order("created_at", { ascending: true });

  const exercises = (exercisesData ?? []) as AdminExercise[];

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
          href="/admin"
          className="text-sm font-medium text-slate-500 transition hover:text-indigo-600"
        >
          ← Volver a módulos
        </Link>

        <div className="card mt-4 p-6 sm:p-8">
          <div className="flex flex-col justify-between gap-3 sm:flex-row sm:items-start">
            <div>
              <h2 className="text-xl font-bold text-slate-900">
                Editar módulo
              </h2>
              <p className="mt-1 text-sm text-slate-500">
                {module.is_published
                  ? "Este módulo está publicado y visible para los estudiantes."
                  : "Este módulo está en borrador y no es visible para los estudiantes."}
              </p>
            </div>

            {module.is_published && (
              <Link
                href={`/modules/${module.slug}`}
                className="btn-secondary shrink-0"
              >
                Ver módulo
              </Link>
            )}
          </div>

          <div className="mt-6">
            <ModuleForm module={module} />
          </div>
        </div>
      </div>

      <div>
        <div className="flex flex-col justify-between gap-2 sm:flex-row sm:items-center">
          <div>
            <h2 className="text-xl font-bold text-slate-900">Ejercicios</h2>
            <p className="mt-1 text-sm text-slate-500">
              {exercises.length} ejercicio
              {exercises.length === 1 ? "" : "s"} en este módulo.
            </p>
          </div>
        </div>

        {exercises.length > 0 && (
          <div className="mt-4 space-y-3">
            {exercises.map((exercise, index) => {
              const options = exercise.options ?? [];
              const correctText =
                exercise.type === "multiple_choice"
                  ? (options[exercise.correct_option ?? -1] ?? "—")
                  : String(exercise.correct_answer ?? "—");

              return (
                <div key={exercise.id} className="card p-5">
                  <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-start">
                    <div className="flex min-w-0 items-start gap-3">
                      <span className="grid h-8 w-8 shrink-0 place-items-center rounded-full bg-slate-100 text-sm font-semibold text-slate-600">
                        {index + 1}
                      </span>

                      <div className="min-w-0">
                        <div className="text-sm leading-relaxed text-slate-800">
                          <MathText>{exercise.prompt}</MathText>
                        </div>

                        <div className="mt-2 flex flex-wrap items-center gap-2 text-xs text-slate-500">
                          <span className="badge bg-slate-100 text-slate-600">
                            {exercise.type === "multiple_choice"
                              ? "Opción múltiple"
                              : "Numérica"}
                          </span>
                          <span>
                            Correcta:{" "}
                            <span className="font-medium text-slate-700">
                              <MathText>{String(correctText)}</MathText>
                            </span>
                          </span>
                          <span>· Orden {exercise.order_index}</span>
                        </div>

                        {exercise.explanation && (
                          <p className="mt-2 text-xs text-slate-500">
                            <MathText>{exercise.explanation}</MathText>
                          </p>
                        )}
                      </div>
                    </div>

                    <form action={deleteExerciseAction} className="shrink-0">
                      <input type="hidden" name="id" value={exercise.id} />
                      <input
                        type="hidden"
                        name="module_id"
                        value={module.id}
                      />
                      <ConfirmButton
                        message="¿Eliminar este ejercicio? Esta acción no se puede deshacer."
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

        <div className="card mt-6 p-6 sm:p-8">
          <h3 className="text-lg font-bold text-slate-900">
            Agregar ejercicio
          </h3>
          <p className="mt-1 text-sm text-slate-500">
            El ejercicio se agrega al final; puedes cambiar el orden con el
            campo correspondiente.
          </p>

          <div className="mt-6">
            <ExerciseForm
              moduleId={module.id}
              nextOrder={exercises.length + 1}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
