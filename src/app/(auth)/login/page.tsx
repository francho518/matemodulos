import Link from "next/link";
import type { Metadata } from "next";
import { login } from "@/app/(auth)/actions";

export const metadata: Metadata = {
  title: "Ingresar",
};

type Props = {
  searchParams: Promise<{
    error?: string | string[];
    message?: string | string[];
    redirectTo?: string | string[];
  }>;
};

export default async function LoginPage({ searchParams }: Props) {
  const params = await searchParams;

  const error = typeof params.error === "string" ? params.error : undefined;
  const message =
    typeof params.message === "string" ? params.message : undefined;
  const redirectTo =
    typeof params.redirectTo === "string" &&
    params.redirectTo.startsWith("/") &&
    !params.redirectTo.startsWith("//")
      ? params.redirectTo
      : "/dashboard";

  return (
    <div className="flex min-h-[calc(100vh-10rem)] items-center justify-center px-4 py-16">
      <div className="w-full max-w-md">
        <div className="card p-8">
          <div className="text-center">
            <span className="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-indigo-600 text-xl font-bold text-white">
              ∑
            </span>
            <h1 className="mt-4 text-2xl font-bold text-slate-900">
              Bienvenido de nuevo
            </h1>
            <p className="mt-1 text-sm text-slate-500">
              Inicia sesión para continuar practicando.
            </p>
          </div>

          {error && (
            <p className="mt-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {error}
            </p>
          )}

          {message && (
            <p className="mt-6 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
              {message}
            </p>
          )}

          <form action={login} className="mt-6 space-y-4">
            <input type="hidden" name="redirectTo" value={redirectTo} />

            <div>
              <label htmlFor="email" className="label">
                Correo electrónico
              </label>
              <input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                required
                className="input"
                placeholder="tu@correo.com"
              />
            </div>

            <div>
              <label htmlFor="password" className="label">
                Contraseña
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                required
                className="input"
                placeholder="••••••••"
              />
            </div>

            <button type="submit" className="btn-primary w-full py-2.5">
              Ingresar
            </button>
          </form>

          <p className="mt-6 text-center text-sm text-slate-500">
            ¿No tienes cuenta?{" "}
            <Link
              href="/register"
              className="font-semibold text-indigo-600 hover:text-indigo-500"
            >
              Crear una gratis
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
