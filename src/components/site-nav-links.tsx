"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

type Props = {
  isAuthenticated: boolean;
  role: string | null;
  fullName: string | null;
};

function linkClass(active: boolean, extra = "") {
  const state = active
    ? "border-b-2 border-indigo-600 bg-indigo-50 font-semibold text-indigo-700"
    : "font-medium text-slate-600 hover:bg-slate-100 hover:text-brand-navy";

  return `rounded-lg px-3 py-2 transition ${state} ${extra}`.trim();
}

export function SiteNavLinks({ isAuthenticated, role, fullName }: Props) {
  const pathname = usePathname();

  const homeActive = pathname === "/";
  const dashboardActive =
    pathname === "/dashboard" || pathname.startsWith("/modules/");
  const adminActive = pathname.startsWith("/admin");

  return (
    <>
      <Link
        href="/"
        aria-current={homeActive ? "page" : undefined}
        className={linkClass(
          homeActive,
          "hidden font-semibold text-brand-orange sm:inline-flex",
        )}
      >
        Inicio
      </Link>

      {isAuthenticated ? (
        <>
          <Link
            href="/dashboard"
            aria-current={dashboardActive ? "page" : undefined}
            className={linkClass(dashboardActive)}
          >
            Mis módulos
          </Link>

          {role === "admin" && (
            <Link
              href="/admin"
              aria-current={adminActive ? "page" : undefined}
              className={linkClass(adminActive)}
            >
              Administración
            </Link>
          )}

          <span className="hidden max-w-[10rem] truncate px-2 text-slate-400 lg:inline">
            {fullName}
          </span>
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
            aria-current={pathname === "/login" ? "page" : undefined}
            className={linkClass(
              pathname === "/login",
              "hidden sm:inline-flex",
            )}
          >
            Ingresar
          </Link>

          <Link
            href="/register"
            aria-current={pathname === "/register" ? "page" : undefined}
            className={`btn-brand ${
              pathname === "/register" ? "border-b-2 border-indigo-600" : ""
            }`}
          >
            Crear cuenta
          </Link>
        </>
      )}
    </>
  );
}
