import type { Metadata } from "next";
import { createClient } from "@/lib/supabase/server";
import { firstParam, formatDate } from "@/lib/utils";
import { ConfirmButton } from "@/components/confirm-button";
import {
  sendPasswordResetAction,
  setUserActiveAction,
} from "@/app/admin/users/actions";

export const metadata: Metadata = {
  title: "Usuarios",
};

type ProfileWithStatus = {
  id: string;
  full_name: string | null;
  email: string | null;
  role: "student" | "admin";
  active?: boolean;
  created_at: string;
};

type MembershipRow = {
  user_id: string;
  groups: Array<{ name: string }> | null;
};

type Props = {
  searchParams: Promise<{ ok?: string | string[]; error?: string | string[] }>;
};

const okMessages: Record<string, string> = {
  "1": "Operación realizada correctamente.",
  baja: "El usuario se dio de baja y se quitó de su grupo.",
  reactivado: "El usuario se reactivó correctamente.",
  correo:
    "Si la cuenta existe, se envió un enlace para establecer la contraseña.",
};

export default async function AdminUsersPage({ searchParams }: Props) {
  const params = await searchParams;
  const ok = firstParam(params.ok);
  const errorMessage = firstParam(params.error);

  const supabase = await createClient();

  const [usersResult, membershipsResult, currentResult] = await Promise.all([
    supabase
      .from("profiles")
      .select("id, full_name, email, role, active, created_at")
      .order("role", { ascending: true })
      .order("full_name", { ascending: true }),
    supabase.from("group_members").select("user_id, groups(name)"),
    supabase.auth.getUser(),
  ]);

  const users = (usersResult.data ?? []) as ProfileWithStatus[];
  const memberships = (membershipsResult.data ?? []) as MembershipRow[];
  const currentUserId = currentResult.data.user?.id;

  const groupByUser = new Map<string, string>();
  memberships.forEach((membership) => {
    const groupName = membership.groups?.[0]?.name;
    if (groupName) {
      groupByUser.set(membership.user_id, groupName);
    }
  });

  return (
    <div>
      {ok && (
        <p className="mb-4 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          {okMessages[ok] ?? okMessages["1"]}
        </p>
      )}

      {errorMessage && (
        <p className="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {errorMessage}
        </p>
      )}

      <div className="flex flex-col justify-between gap-3 sm:flex-row sm:items-center">
        <div>
          <h2 className="text-xl font-bold text-slate-900">Usuarios</h2>
          <p className="mt-1 text-sm text-slate-500">
            Da de baja a un estudiante para quitarlo de su grupo y evitar que
            siga entrando. Su historial de intentos se conserva.
          </p>
        </div>
        <span className="badge">{users.length} usuarios</span>
      </div>

      <div className="card mt-6 overflow-x-auto p-0">
        <table className="w-full min-w-[860px] text-left text-sm">
          <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
            <tr>
              <th className="px-4 py-3 font-semibold">Usuario</th>
              <th className="px-4 py-3 font-semibold">Correo</th>
              <th className="px-4 py-3 font-semibold">Rol</th>
              <th className="px-4 py-3 font-semibold">Grupo</th>
              <th className="px-4 py-3 font-semibold">Estado</th>
              <th className="px-4 py-3 font-semibold">Acciones</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {users.length === 0 && (
              <tr>
                <td colSpan={6} className="px-4 py-8 text-center text-slate-500">
                  Todavía no hay usuarios registrados.
                </td>
              </tr>
            )}

            {users.map((user) => {
              const isActive = user.active !== false;
              const isSelf = user.id === currentUserId;

              return (
                <tr key={user.id} className="hover:bg-slate-50/60">
                  <td className="px-4 py-3">
                    <p className="font-medium text-slate-900">
                      {user.full_name || "Sin nombre"}
                      {isSelf && (
                        <span className="ml-2 text-xs font-normal text-indigo-600">
                          (tú)
                        </span>
                      )}
                    </p>
                    <p className="text-xs text-slate-400">
                      Desde {formatDate(user.created_at)}
                    </p>
                  </td>
                  <td className="px-4 py-3 text-slate-600">
                    {user.email || "Sin correo"}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`badge ${
                        user.role === "admin"
                          ? "bg-indigo-100 text-indigo-700"
                          : ""
                      }`}
                    >
                      {user.role === "admin" ? "Admin" : "Estudiante"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-600">
                    {groupByUser.get(user.id) ?? "—"}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`badge ${
                        isActive
                          ? "bg-emerald-100 text-emerald-700"
                          : "bg-red-100 text-red-700"
                      }`}
                    >
                      {isActive ? "Activo" : "Dado de baja"}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {isSelf ? (
                      <span className="text-xs text-slate-400">
                        No disponible
                      </span>
                    ) : (
                      <div className="flex flex-wrap gap-2">
                        <form action={sendPasswordResetAction}>
                          <input
                            type="hidden"
                            name="email"
                            value={user.email ?? ""}
                          />
                          <button
                            type="submit"
                            className="btn-secondary px-3 py-1.5 text-xs"
                            disabled={!user.email}
                            title={
                              user.email
                                ? undefined
                                : "Este usuario no tiene correo registrado"
                            }
                          >
                            Enviar enlace
                          </button>
                        </form>

                        <form action={setUserActiveAction}>
                          <input
                            type="hidden"
                            name="user_id"
                            value={user.id}
                          />
                          <input
                            type="hidden"
                            name="active"
                            value={isActive ? "false" : "true"}
                          />
                          <ConfirmButton
                            message={
                              isActive
                                ? `¿Dar de baja a ${user.full_name || user.email}? Se le quitará de su grupo y no podrá entrar hasta que lo reactives.`
                                : `¿Reactivar a ${user.full_name || user.email}? Volverá a poder iniciar sesión, pero habrá que asignarlo a un grupo.`
                            }
                            className={
                              isActive
                                ? "btn-danger px-3 py-1.5 text-xs"
                                : "btn-secondary px-3 py-1.5 text-xs"
                            }
                          >
                            {isActive ? "Dar de baja" : "Reactivar"}
                          </ConfirmButton>
                        </form>
                      </div>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <p className="mt-4 text-xs text-slate-500">
        El botón <strong>Enviar enlace</strong> usa el correo configurado en
        Supabase. El enlace abre una página para elegir una nueva contraseña;
        no se envía ninguna contraseña en texto plano.
      </p>
    </div>
  );
}
