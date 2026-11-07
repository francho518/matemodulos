import Link from "next/link";
import type { Metadata } from "next";
import { signup } from "@/app/(auth)/actions";

export const metadata: Metadata = {
  title: "Crear cuenta",
};

type Props = {
  searchParams: Promise<{
    error?: string | string[];
  }>;
};

export default async function RegisterPage({ searchParams }: Props) {
  const params = await searchParams;
  const error = typeof params.error === "string" ? params.error : undefined;

  return (
    <div className="flex min-h-[calc(100vh-10rem)] items-center justify-center px-4 py-16">
      <div className="w-full max-w-md">
        <div className="card p-8">
          <div className="text-center">
            <span className="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-indigo-600 text-xl font-bold text-white">
              ∑
            </span>
            <h1 className="mt-4 text-2xl font-bold text-slate-900">
              Crea tu cuenta
            </h1>
            <p className="mt-1 text-sm text-slate-500">
              Empieza a resolver ejercicios en menos de un minuto.
            </p>
          </div>

          {error && (
            <p className="mt-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {error}
            </p>
          )}

          <form action={signup} className="mt-6 space-y-4">
            <div>
              <label htmlFor="full_name" className="label">
                Nombre completo
              </label>
              <input
                id="full_name"
                name="full_name"
                type="text"
                autoComplete="name"
                className="input"
                placeholder="Ana Pérez"
              />
            </div>

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
                autoComplete="new-password"
                required
                minLength={6}
                className="input"
                placeholder="Mínimo 6 caracteres"
              />
            </div>

            <button type="submit" className="btn-primary w-full py-2.5">
              Crear cuenta
            </button>
          </form>

          <p className="mt-6 text-center text-sm text-slate-500">
            ¿Ya tienes cuenta?{" "}
            <Link
              href="/login"
              className="font-semibold text-indigo-600 hover:text-indigo-500"
            >
              Iniciar sesión
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
