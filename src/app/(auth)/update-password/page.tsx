import Link from "next/link";
import { redirect } from "next/navigation";
import type { Metadata } from "next";
import { updatePassword } from "@/app/(auth)/actions";
import { createClient } from "@/lib/supabase/server";
import { firstParam } from "@/lib/utils";

export const metadata: Metadata = {
  title: "Nueva contraseña",
};

type Props = {
  searchParams: Promise<{
    ok?: string | string[];
    error?: string | string[];
  }>;
};

export default async function UpdatePasswordPage({ searchParams }: Props) {
  const params = await searchParams;
  const ok = firstParam(params.ok);
  const errorMessage = firstParam(params.error);

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect(
      "/login?error=" +
        encodeURIComponent(
          "Necesitas un enlace válido para cambiar la contraseña.",
        ),
    );
  }

  return (
    <div className="flex min-h-[calc(100vh-10rem)] items-center justify-center px-4 py-16">
      <div className="w-full max-w-md">
        <div className="card p-8">
          <div className="text-center">
            <span className="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-indigo-600 text-xl font-bold text-white">
              🔑
            </span>
            <h1 className="mt-4 text-2xl font-bold text-slate-900">
              Nueva contraseña
            </h1>
            <p className="mt-1 text-sm text-slate-500">
              Elige una contraseña para acceder a Matemódulos.
            </p>
          </div>

          {ok && (
            <p className="mt-6 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
              Contraseña actualizada correctamente.
            </p>
          )}

          {errorMessage && (
            <p className="mt-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {errorMessage}
            </p>
          )}

          <form action={updatePassword} className="mt-6 space-y-4">
            <div>
              <label htmlFor="password" className="label">
                Nueva contraseña
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="new-password"
                minLength={6}
                required
                className="input"
                placeholder="Al menos 6 caracteres"
              />
            </div>

            <div>
              <label htmlFor="repeat_password" className="label">
                Repite la contraseña
              </label>
              <input
                id="repeat_password"
                name="repeat_password"
                type="password"
                autoComplete="new-password"
                minLength={6}
                required
                className="input"
                placeholder="Repite la contraseña"
              />
            </div>

            <button type="submit" className="btn-primary w-full py-2.5">
              Guardar contraseña
            </button>
          </form>

          <p className="mt-6 text-center text-sm text-slate-500">
            <Link href="/dashboard" className="font-semibold text-indigo-600">
              Volver a mis módulos
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
