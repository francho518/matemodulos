"use server";

import { headers } from "next/headers";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

function getString(formData: FormData, key: string) {
  const value = formData.get(key);
  return typeof value === "string" ? value.trim() : "";
}

async function getAdminContext() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { supabase, error: "Debes iniciar sesión." as string };
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  if (profile?.role !== "admin") {
    return { supabase, error: "No tienes permisos de administrador." };
  }

  return { supabase, error: null };
}

async function getOrigin() {
  const headersList = await headers();
  const forwardedHost = headersList.get("x-forwarded-host");
  const forwardedProto = headersList.get("x-forwarded-proto") ?? "https";

  return (
    headersList.get("origin") ??
    (forwardedHost
      ? `${forwardedProto}://${forwardedHost}`
      : process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000")
  );
}

function usersError(message: string): never {
  redirect("/admin/users?error=" + encodeURIComponent(message));
}

/**
 * Da de baja o reactiva a un usuario mediante la RPC `set_user_active`.
 * Al darlo de baja se elimina su membresía en grupos, por lo que deja
 * de ver módulos. El perfil y el historial se conservan.
 */
export async function setUserActiveAction(formData: FormData) {
  const { supabase, error: authError } = await getAdminContext();

  if (authError) usersError(authError);

  const userId = getString(formData, "user_id");
  const active = getString(formData, "active") === "true";

  if (!userId) {
    usersError("No se recibió el usuario.");
  }

  const { error } = await supabase.rpc("set_user_active", {
    target_user: userId,
    is_active: active,
  });

  if (error) {
    usersError(
      error.message || "No se pudo cambiar el estado del usuario.",
    );
  }

  revalidatePath("/admin/users");
  revalidatePath("/admin/groups");
  revalidatePath("/dashboard");

  redirect(`/admin/users?ok=${active ? "reactivado" : "baja"}`);
}

/**
 * Envía un enlace de recuperación usando el SMTP configurado en Supabase.
 * No revelamos si el correo existe: Supabase responde igual en ambos casos.
 */
export async function sendPasswordResetAction(formData: FormData) {
  const { supabase, error: authError } = await getAdminContext();

  if (authError) usersError(authError);

  const email = getString(formData, "email");

  if (!email) {
    usersError("No se recibió el correo del usuario.");
  }

  const origin = await getOrigin();

  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${origin}/auth/callback?next=/update-password`,
  });

  if (error) {
    usersError(
      error.message || "No se pudo enviar el enlace de recuperación.",
    );
  }

  redirect("/admin/users?ok=correo");
}
