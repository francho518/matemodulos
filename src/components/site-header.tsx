import Link from "next/link";
import Image from "next/image";
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
    <header className="sticky top-0 z-40 border-b border-slate-200 bg-white">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between gap-4 px-4">
        <Link
          href="/"
          className="flex items-center gap-3"
          aria-label="Mate Dual Brücke"
        >
          <Image
            src="/images/crisfe-logo.png"
            alt="Colegios CRISFE"
            width={150}
            height={42}
            className="h-9 w-auto"
            priority
          />
          <span className="hidden h-7 w-px bg-slate-200 md:block" />
          <span className="hidden text-sm font-bold tracking-tight text-brand-navy md:block">
            Mate <span className="text-brand-teal">Dual Brücke</span>
          </span>
        </Link>

        <nav className="flex items-center gap-1 text-sm sm:gap-2">
          <Link
            href="/"
            className="hidden rounded-lg px-3 py-2 font-semibold text-brand-orange transition hover:bg-orange-50 sm:inline-flex"
          >
            Inicio
          </Link>

          {user ? (
            <>
              <Link
                href="/dashboard"
                className="rounded-lg px-3 py-2 font-medium text-slate-600 transition hover:bg-slate-100 hover:text-brand-navy"
              >
                Mis módulos
              </Link>

              {role === "admin" && (
                <Link
                  href="/admin"
                  className="rounded-lg px-3 py-2 font-medium text-slate-600 transition hover:bg-slate-100 hover:text-brand-navy"
                >
                  Administración
                </Link>
              )}

              <span className="hidden max-w-[10rem] truncate px-2 text-slate-400 lg:inline">
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
                href="/#como-funciona"
                className="hidden rounded-lg px-3 py-2 font-medium text-slate-600 transition hover:bg-slate-100 hover:text-brand-navy md:inline-flex"
              >
                Cómo funciona
              </Link>

              <Link
                href="/login"
                className="hidden rounded-lg px-3 py-2 font-medium text-slate-600 transition hover:bg-slate-100 hover:text-brand-navy sm:inline-flex"
              >
                Ingresar
              </Link>

              <Link href="/register" className="btn-brand">
                Crear cuenta
              </Link>
            </>
          )}
        </nav>
      </div>
    </header>
  );
}
