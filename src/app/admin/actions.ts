"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import type { ActionState } from "@/lib/action-state";
import { slugify } from "@/lib/utils";

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

function friendlyDatabaseError(message: string, code?: string) {
  if (code === "23505") {
    return "Ya existe un módulo con ese slug. Prueba con otro.";
  }
  return message || "Ocurrió un error al guardar. Inténtalo de nuevo.";
}

/* ------------------------------------------------------------
 * Módulos
 * ---------------------------------------------------------- */

export async function saveModuleAction(
  _previousState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const { supabase, error: authError } = await getAdminContext();

  if (authError) return { error: authError };

  const id = getString(formData, "id");
  const title = getString(formData, "title");
  const rawSlug = getString(formData, "slug");
  const description = getString(formData, "description");
  const orderRaw = getString(formData, "order_index");
  const isPublished = formData.get("is_published") === "on";

  if (title.length < 3) {
    return { error: "El título debe tener al menos 3 caracteres." };
  }

  const slug = slugify(rawSlug || title);

  if (!slug) {
    return {
      error:
        "El slug no es válido. Usa letras, números y guiones (ejemplo: algebra-basica).",
    };
  }

  const orderIndex = orderRaw === "" ? 0 : Number(orderRaw);

  if (!Number.isInteger(orderIndex) || orderIndex < 0) {
    return { error: "El orden debe ser un número entero mayor o igual a 0." };
  }

  const payload = {
    title,
    slug,
    description: description || null,
    order_index: orderIndex,
    is_published: isPublished,
  };

  if (id) {
    const { error } = await supabase
      .from("modules")
      .update(payload)
      .eq("id", id);

    if (error) {
      return { error: friendlyDatabaseError(error.message, error.code) };
    }

    revalidatePath("/admin");
    revalidatePath("/admin/modules/" + id);
    revalidatePath("/dashboard");
    revalidatePath("/modules/" + slug);

    redirect(`/admin/modules/${id}?ok=1`);
  }

  const { data, error } = await supabase
    .from("modules")
    .insert(payload)
    .select("id")
    .single();

  if (error || !data) {
    return {
      error: friendlyDatabaseError(
        error?.message ?? "No se pudo crear el módulo.",
        error?.code,
      ),
    };
  }

  revalidatePath("/admin");
  revalidatePath("/dashboard");

  redirect(`/admin/modules/${data.id}?ok=1`);
}

export async function deleteModuleAction(formData: FormData) {
  const { supabase, error } = await getAdminContext();

  if (error) {
    redirect("/admin?error=" + encodeURIComponent(error));
  }

  const id = getString(formData, "id");

  if (!id) {
    redirect("/admin?error=" + encodeURIComponent("Módulo no válido."));
  }

  const { error: deleteError } = await supabase
    .from("modules")
    .delete()
    .eq("id", id);

  if (deleteError) {
    redirect(
      "/admin?error=" + encodeURIComponent("No se pudo eliminar el módulo."),
    );
  }

  revalidatePath("/admin");
  revalidatePath("/dashboard");

  redirect("/admin?ok=1");
}

/* ------------------------------------------------------------
 * Ejercicios
 * ---------------------------------------------------------- */

export async function createExerciseAction(
  _previousState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const { supabase, error: authError } = await getAdminContext();

  if (authError) return { error: authError };

  const moduleId = getString(formData, "module_id");
  const prompt = getString(formData, "prompt");
  const type = getString(formData, "type");
  const explanation = getString(formData, "explanation");
  const orderRaw = getString(formData, "order_index");

  if (!moduleId) {
    return { error: "No se recibió el módulo." };
  }

  if (prompt.length < 3) {
    return { error: "El enunciado debe tener al menos 3 caracteres." };
  }

  if (type !== "multiple_choice" && type !== "numeric") {
    return { error: "Selecciona un tipo de ejercicio válido." };
  }

  const orderIndex = orderRaw === "" ? 0 : Number(orderRaw);

  if (!Number.isInteger(orderIndex) || orderIndex < 0) {
    return { error: "El orden debe ser un número entero mayor o igual a 0." };
  }

  let options: string[] | null = null;
  let correctOption: number | null = null;
  let correctAnswer: number | null = null;
  let tolerance = 0.000001;

  if (type === "multiple_choice") {
    options = getString(formData, "options")
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean);

    if (options.length < 2) {
      return {
        error: "Agrega al menos dos opciones, una por línea.",
      };
    }

    const selected = Number(getString(formData, "correct_option"));

    if (
      !Number.isInteger(selected) ||
      selected < 1 ||
      selected > options.length
    ) {
      return {
        error: `La opción correcta debe ser un número entre 1 y ${options.length}.`,
      };
    }

    correctOption = selected - 1;
  } else {
    const answerRaw = getString(formData, "correct_answer").replace(",", ".");
    const answer = Number(answerRaw);

    if (!answerRaw || !Number.isFinite(answer)) {
      return { error: "Escribe una respuesta numérica correcta válida." };
    }

    correctAnswer = answer;

    const toleranceRaw = getString(formData, "tolerance").replace(",", ".");

    if (toleranceRaw !== "") {
      const parsedTolerance = Number(toleranceRaw);

      if (!Number.isFinite(parsedTolerance) || parsedTolerance < 0) {
        return { error: "La tolerancia debe ser un número mayor o igual a 0." };
      }

      tolerance = parsedTolerance;
    }
  }

  const { error } = await supabase.from("exercises").insert({
    module_id: moduleId,
    prompt,
    type,
    options,
    correct_option: correctOption,
    correct_answer: correctAnswer,
    tolerance,
    explanation: explanation || null,
    order_index: orderIndex,
  });

  if (error) {
    return { error: friendlyDatabaseError(error.message, error.code) };
  }

  revalidatePath("/admin/modules/" + moduleId);
  revalidatePath("/dashboard");

  redirect(`/admin/modules/${moduleId}?ok=1`);
}

export async function deleteExerciseAction(formData: FormData) {
  const { supabase, error } = await getAdminContext();

  if (error) {
    redirect("/admin?error=" + encodeURIComponent(error));
  }

  const id = getString(formData, "id");
  const moduleId = getString(formData, "module_id");

  if (!id || !moduleId) {
    redirect("/admin?error=" + encodeURIComponent("Ejercicio no válido."));
  }

  const { error: deleteError } = await supabase
    .from("exercises")
    .delete()
    .eq("id", id);

  if (deleteError) {
    redirect(
      "/admin/modules/" +
        moduleId +
        "?error=" +
        encodeURIComponent("No se pudo eliminar el ejercicio."),
    );
  }

  revalidatePath("/admin/modules/" + moduleId);
  revalidatePath("/dashboard");

  redirect(`/admin/modules/${moduleId}?ok=1`);
}
