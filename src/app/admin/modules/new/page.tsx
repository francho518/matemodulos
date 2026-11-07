import Link from "next/link";
import type { Metadata } from "next";
import { ModuleForm } from "@/components/admin/module-form";

export const metadata: Metadata = {
  title: "Nuevo módulo",
};

export default function NewModulePage() {
  return (
    <div className="mx-auto max-w-2xl">
      <Link
        href="/admin"
        className="text-sm font-medium text-slate-500 transition hover:text-indigo-600"
      >
        ← Volver a módulos
      </Link>

      <div className="card mt-4 p-6 sm:p-8">
        <h2 className="text-xl font-bold text-slate-900">Nuevo módulo</h2>
        <p className="mt-1 text-sm text-slate-500">
          Crea un tema. Después podrás agregarle ejercicios desde su página de
          edición.
        </p>

        <div className="mt-6">
          <ModuleForm />
        </div>
      </div>
    </div>
  );
}
