import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login?redirectTo=/admin");
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  if (profile?.role !== "admin") {
    return (
      <div className="mx-auto max-w-2xl px-4 py-24 text-center">
        <p className="text-6xl">🔒</p>
        <h1 className="mt-4 text-2xl font-bold text-slate-900">
          Acceso restringido
        </h1>
        <p className="mt-2 text-slate-600">
          Esta sección es solo para administradores. Si necesitas permisos, pide
          a otra persona del equipo que te asigne el rol.
        </p>
        <Link href="/dashboard" className="btn-primary mt-8">
          Volver a mis módulos
        </Link>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-6xl px-4 py-10">
      <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
        <div>
          <p className="text-sm font-medium text-indigo-600">Administración</p>
          <h1 className="mt-1 text-3xl font-bold tracking-tight text-slate-900">
            Gestión de contenido
          </h1>
        </div>

        <Link href="/dashboard" className="btn-secondary">
          Ver como estudiante
        </Link>
      </div>

      <nav className="mt-6 flex gap-1 border-b border-slate-200">
        <Link
          href="/admin"
          className="border-b-2 border-indigo-600 px-4 py-2 text-sm font-semibold text-indigo-600"
        >
          Módulos
        </Link>
        <Link
          href="/admin/modules/new"
          className="border-b-2 border-transparent px-4 py-2 text-sm font-medium text-slate-500 transition hover:text-slate-800"
        >
          Nuevo módulo
        </Link>
      </nav>

      <div className="mt-8">{children}</div>
    </div>
  );
}
