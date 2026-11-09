import Link from "next/link";
import type { User } from "@supabase/supabase-js";
import { createClient } from "@/lib/supabase/server";
import { logout } from "@/app/(auth)/actions";

export async function SiteHeader() {
  let user: User | null = null;
  let fullName: string | null = null;
  let role: string | null = null;

  try {
    const supabase = await createClient();
    const {
      data: { user: currentUser },
    } = await supabase.auth.getUser();

    user = currentUser;

    if (currentUser) {
      const { data: profile } = await supabase
        .from("profiles")
        .select("full_name, role")
        .eq("id", currentUser.id)
        .single();

      fullName = profile?.full_name ?? currentUser.email ?? null;
      role = profile?.role ?? "student";
    }
  } catch {
    // Sin configuración de Supabase la landing sigue siendo visible.
  }

  return (
    <header className="sticky top-0 z-40 border-b border-slate-200 bg-white/80 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between gap-4 px-4">
        <Link href="/" className="flex items-center gap-2.5">
          <span className="grid h-9 w-9 place-items-center rounded-xl bg-indigo-600 text-lg font-bold text-white">
            ∑
          </span>
          <span className="text-lg font-bold tracking-tight text-slate-900">
            Mate <span className="text-indigo-600">Dual Brucke</span>
          </span>
        </Link>

        <nav className="flex items-center gap-2 text-sm">
          {user ? (
            <>
              <Link
                href="/dashboard"
                className="rounded-lg px-3 py-2 font-medium text-slate-600 transition hover:bg-slate-100 hover:text-slate-900"
              >
                Mis módulos
              </Link>

              {role === "admin" && (
                <Link
                  href="/admin"
                  className="rounded-lg px-3 py-2 font-medium text-slate-600 transition hover:bg-slate-100 hover:text-slate-900"
                >
                  Administración
                </Link>
              )}

              <span className="hidden max-w-[12rem] truncate px-2 text-slate-400 sm:inline">
                {fullName}
              </span>

              <form action={logout}>
                <button type="submit" className="btn-secondary">
                  Salir
                </button>
              </form>
            </>
          ) : (
            <>
              <Link
                href="/login"
                className="rounded-lg px-3 py-2 font-medium text-slate-600 transition hover:bg-slate-100 hover:text-slate-900"
              >
                Ingresar
              </Link>
              <Link href="/register" className="btn-primary">
                Crear cuenta
              </Link>
            </>
          )}
        </nav>
      </div>
    </header>
  );
}
