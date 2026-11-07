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
  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    redirect("/login?error=" + encodeURIComponent(error.message));
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
