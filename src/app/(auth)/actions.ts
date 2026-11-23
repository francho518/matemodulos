"use server";

import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

function safeRedirect(value: FormDataEntryValue | null) {
  if (
    typeof value === "string" &&
    value.startsWith("/") &&
    !value.startsWith("//")
  ) {
    return value;
  }
  return "/dashboard";
}

export async function login(formData: FormData) {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");
  const redirectTo = safeRedirect(formData.get("redirectTo"));

  if (!email || !password) {
    redirect("/login?error=" + encodeURIComponent("Completa todos los campos."));
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    redirect("/login?error=" + encodeURIComponent(error.message));
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("active")
    .eq("id", data.user.id)
    .maybeSingle();

  if (profile?.active === false) {
    await supabase.auth.signOut();
    redirect(
      "/login?error=" +
        encodeURIComponent(
          "Esta cuenta está dada de baja. Contacta con el administrador.",
        ),
    );
  }

  redirect(redirectTo);
}

export async function signup(formData: FormData) {
  const fullName = String(formData.get("full_name") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  if (!email || password.length < 6) {
    redirect(
      "/register?error=" +
        encodeURIComponent(
          "Ingresa un correo válido y una contraseña de al menos 6 caracteres.",
        ),
    );
  }

  const supabase = await createClient();

  const headersList = await headers();
  const forwardedHost = headersList.get("x-forwarded-host");
  const forwardedProto = headersList.get("x-forwarded-proto") ?? "https";
  const origin =
    headersList.get("origin") ??
    (forwardedHost
      ? `${forwardedProto}://${forwardedHost}`
      : process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000");

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { full_name: fullName || email.split("@")[0] },
      emailRedirectTo: `${origin}/auth/callback`,
    },
  });

  if (error) {
    redirect("/register?error=" + encodeURIComponent(error.message));
  }

  // Si Supabase exige confirmar el correo, no hay sesión todavía.
  if (!data.session) {
    redirect(
      "/login?message=" +
        encodeURIComponent(
          "Cuenta creada. Revisa tu correo para confirmarla y luego inicia sesión.",
        ),
    );
  }

  redirect("/dashboard");
}

export async function logout() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/");
}

export async function updatePassword(formData: FormData) {
  const password = String(formData.get("password") ?? "");
  const repeatPassword = String(formData.get("repeat_password") ?? "");

  if (password.length < 6) {
    redirect(
      "/update-password?error=" +
        encodeURIComponent("La contraseña debe tener al menos 6 caracteres."),
    );
  }

  if (password !== repeatPassword) {
    redirect(
      "/update-password?error=" +
        encodeURIComponent("Las contraseñas no coinciden."),
    );
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect(
      "/login?error=" +
        encodeURIComponent("La sesión caducó. Pide un nuevo enlace."),
    );
  }

  const { error } = await supabase.auth.updateUser({ password });

  if (error) {
    redirect("/update-password?error=" + encodeURIComponent(error.message));
  }

  redirect("/update-password?ok=1");
}
