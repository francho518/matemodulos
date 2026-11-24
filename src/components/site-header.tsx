import Link from "next/link";
import Image from "next/image";
import type { User } from "@supabase/supabase-js";
import { createClient } from "@/lib/supabase/server";
import { logout } from "@/app/(auth)/actions";
import { SiteNavLinks } from "@/components/site-nav-links";

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
          <SiteNavLinks
            isAuthenticated={Boolean(user)}
            role={role}
            fullName={fullName}
          />

          {user && (
            <form action={logout}>
              <button type="submit" className="btn-secondary">
                Salir
              </button>
            </form>
          )}
        </nav>
      </div>
    </header>
  );
}
