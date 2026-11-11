"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { selectExercisesForRound } from "@/lib/exercise-selection";
import {
  buildRoundPlans,
  currentRoundPlan,
  statsForPlan,
  type StoredRound,
} from "@/lib/progress";
import type { ActionState } from "@/lib/action-state";

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

function friendlyGroupError(message: string, code?: string) {
  if (code === "23505") {
    return "Ya existe un grupo con ese nombre. Prueba con otro.";
  }
  return message || "No se pudo guardar el grupo. Inténtalo de nuevo.";
}

function groupErrorRedirect(groupId: string, message: string): never {
  redirect(`/admin/groups/${groupId}?error=${encodeURIComponent(message)}`);
}

export async function createGroupAction(
  _previousState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const { supabase, error: authError } = await getAdminContext();

  if (authError) return { error: authError };

  const name = getString(formData, "name");
  const description = getString(formData, "description");

  if (name.length < 2) {
    return { error: "El nombre del grupo debe tener al menos 2 caracteres." };
  }

  const { data, error } = await supabase
    .from("groups")
    .insert({
      name,
      description: description || null,
    })
    .select("id")
    .single();

  if (error || !data) {
    return {
      error: friendlyGroupError(
        error?.message ?? "No se pudo crear el grupo.",
        error?.code,
      ),
    };
  }

  revalidatePath("/admin/groups");
  redirect(`/admin/groups/${data.id}?ok=1`);
}

export async function updateGroupAction(
  _previousState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const { supabase, error: authError } = await getAdminContext();

  if (authError) return { error: authError };

  const id = getString(formData, "id");
  const name = getString(formData, "name");
  const description = getString(formData, "description");

  if (!id) return { error: "No se recibió el grupo." };

  if (name.length < 2) {
    return { error: "El nombre del grupo debe tener al menos 2 caracteres." };
  }

  const { error } = await supabase
    .from("groups")
    .update({
      name,
      description: description || null,
    })
    .eq("id", id);

  if (error) {
    return { error: friendlyGroupError(error.message, error.code) };
  }

  revalidatePath("/admin/groups");
  revalidatePath(`/admin/groups/${id}`);
  redirect(`/admin/groups/${id}?ok=1`);
}

export async function deleteGroupAction(formData: FormData) {
  const { supabase, error } = await getAdminContext();

  if (error) {
    redirect("/admin/groups?error=" + encodeURIComponent(error));
  }

  const id = getString(formData, "id");

  if (!id) {
    redirect(
      "/admin/groups?error=" + encodeURIComponent("Grupo no válido."),
    );
  }

  const { error: deleteError } = await supabase
    .from("groups")
    .delete()
    .eq("id", id);

  if (deleteError) {
    redirect(
      "/admin/groups?error=" +
        encodeURIComponent("No se pudo eliminar el grupo."),
    );
  }

  revalidatePath("/admin/groups");
  revalidatePath("/dashboard");

  redirect("/admin/groups?ok=1");
}

export async function addGroupMemberAction(formData: FormData) {
  const { supabase, error } = await getAdminContext();
  const groupId = getString(formData, "group_id");

  if (error) {
    if (groupId) groupErrorRedirect(groupId, error);
    redirect("/admin/groups?error=" + encodeURIComponent(error));
  }

  const userId = getString(formData, "user_id");

  if (!groupId || !userId) {
    groupErrorRedirect(groupId || "", "Selecciona un estudiante.");
  }

  const { error: insertError } = await supabase
    .from("group_members")
    .upsert(
      { group_id: groupId, user_id: userId },
      { onConflict: "group_id,user_id", ignoreDuplicates: true },
    );

  if (insertError) {
    groupErrorRedirect(groupId, "No se pudo agregar al estudiante.");
  }

  revalidatePath(`/admin/groups/${groupId}`);
  revalidatePath("/dashboard");

  redirect(`/admin/groups/${groupId}?ok=1`);
}

export async function removeGroupMemberAction(formData: FormData) {
  const { supabase, error } = await getAdminContext();
  const groupId = getString(formData, "group_id");

  if (error) {
    if (groupId) groupErrorRedirect(groupId, error);
    redirect("/admin/groups?error=" + encodeURIComponent(error));
  }

  const userId = getString(formData, "user_id");

  if (!groupId || !userId) {
    groupErrorRedirect(groupId || "", "No se recibió el estudiante.");
  }

  const { error: deleteError } = await supabase
    .from("group_members")
    .delete()
    .eq("group_id", groupId)
    .eq("user_id", userId);

  if (deleteError) {
    groupErrorRedirect(groupId, "No se pudo quitar al estudiante.");
  }

  revalidatePath(`/admin/groups/${groupId}`);
  revalidatePath("/dashboard");

  redirect(`/admin/groups/${groupId}?ok=1`);
}

export async function setGroupModulesAction(formData: FormData) {
  const { supabase, error } = await getAdminContext();
  const groupId = getString(formData, "group_id");

  if (error) {
    if (groupId) groupErrorRedirect(groupId, error);
    redirect("/admin/groups?error=" + encodeURIComponent(error));
  }

  if (!groupId) {
    redirect(
      "/admin/groups?error=" + encodeURIComponent("Grupo no válido."),
    );
  }

  const moduleIds = formData
    .getAll("module_id")
    .filter((value): value is string => typeof value === "string" && value !== "");

  const { error: deleteError } = await supabase
    .from("group_modules")
    .delete()
    .eq("group_id", groupId);

  if (deleteError) {
    groupErrorRedirect(groupId, "No se pudieron actualizar los módulos.");
  }

  if (moduleIds.length > 0) {
    const { error: insertError } = await supabase
      .from("group_modules")
      .insert(
        moduleIds.map((moduleId) => ({
          group_id: groupId,
          module_id: moduleId,
        })),
      );

    if (insertError) {
      groupErrorRedirect(groupId, "No se pudieron asignar los módulos.");
    }
  }

  revalidatePath(`/admin/groups/${groupId}`);
  revalidatePath("/dashboard");

  redirect(`/admin/groups/${groupId}?ok=1`);
}

/**
 * Reasigna un módulo a un estudiante que ya lo terminó.
 *
 * Crea una ronda nueva (2, 3, …) con ejercicios que el estudiante no
 * había visto en las rondas anteriores. Los intentos de la ronda
 * anterior se conservan, así que la mejor nota no se pierde.
 */
export async function reassignModuleAction(formData: FormData) {
  const { supabase, error } = await getAdminContext();
  const groupId = getString(formData, "group_id");

  if (error) {
    if (groupId) groupErrorRedirect(groupId, error);
    redirect("/admin/groups?error=" + encodeURIComponent(error));
  }

  const userId = getString(formData, "user_id");
  const moduleId = getString(formData, "module_id");

  if (!groupId || !userId || !moduleId) {
    groupErrorRedirect(groupId || "", "Faltan datos para reasignar.");
  }

  const { data: membership } = await supabase
    .from("group_members")
    .select("user_id")
    .eq("group_id", groupId)
    .eq("user_id", userId)
    .maybeSingle();

  if (!membership) {
    groupErrorRedirect(groupId, "El estudiante no pertenece a este grupo.");
  }

  const { data: moduleData } = await supabase
    .from("modules")
    .select("id, slug, randomize_exercises, exercises_per_student")
    .eq("id", moduleId)
    .maybeSingle();

  if (!moduleData) {
    groupErrorRedirect(groupId, "No se encontró el módulo.");
  }

  const [exercisesResult, roundsResult, attemptsResult, sessionResult] =
    await Promise.all([
      supabase
        .from("exercises")
        .select("id, order_index")
        .eq("module_id", moduleId)
        .order("order_index", { ascending: true }),
      supabase
        .from("module_rounds")
        .select("round, exercise_ids")
        .eq("user_id", userId)
        .eq("module_id", moduleId)
        .order("round", { ascending: true }),
      supabase
        .from("attempts")
        .select("exercise_id, is_correct, created_at, round")
        .eq("user_id", userId)
        .eq("module_id", moduleId),
      supabase
        .from("module_sessions")
        .select("expires_at")
        .eq("user_id", userId)
        .eq("module_id", moduleId)
        .maybeSingle(),
    ]);

  const exercises = (exercisesResult.data ?? []) as Array<{
    id: string;
    order_index: number;
  }>;

  if (exercises.length === 0) {
    groupErrorRedirect(groupId, "El módulo no tiene ejercicios.");
  }

  const rounds = (roundsResult.data ?? []) as StoredRound[];

  const plans = buildRoundPlans({
    exercises,
    userId,
    moduleId,
    randomize: Boolean(moduleData.randomize_exercises),
    exercisesPerStudent: Number(moduleData.exercises_per_student) || 0,
    rounds,
  });

  const current = currentRoundPlan(plans);
  const stats = statsForPlan(current, attemptsResult.data ?? []);

  // Un módulo con tiempo también se considera terminado cuando el reloj
  // venció, aunque el estudiante no haya cerrado todos los ejercicios.
  const expiresAt = sessionResult.data?.expires_at ?? null;
  const timeExpired = Boolean(
    expiresAt && new Date(expiresAt).getTime() <= Date.now(),
  );

  if (!stats.completed && !timeExpired) {
    groupErrorRedirect(
      groupId,
      "El estudiante todavía no ha terminado ese módulo. Solo puedes reasignarlo cuando haya cerrado todos los ejercicios o se haya agotado el tiempo.",
    );
  }

  const nextRound =
    rounds.reduce((max, item) => Math.max(max, item.round), 1) + 1;

  const previousIds = plans.flatMap((plan) =>
    plan.exercises.map((exercise) => exercise.id),
  );

  const selected = selectExercisesForRound(
    exercises,
    userId,
    moduleId,
    Boolean(moduleData.randomize_exercises),
    Number(moduleData.exercises_per_student) || 0,
    nextRound,
    previousIds,
  );

  if (selected.length === 0) {
    groupErrorRedirect(
      groupId,
      "No hay ejercicios disponibles para la reasignación.",
    );
  }

  const previousSet = new Set(previousIds);
  const newCount = selected.filter(
    (exercise) => !previousSet.has(exercise.id),
  ).length;

  const { error: insertError } = await supabase
    .from("module_rounds")
    .insert({
      user_id: userId,
      module_id: moduleId,
      round: nextRound,
      exercise_ids: selected.map((exercise) => exercise.id),
    });

  if (insertError) {
    groupErrorRedirect(
      groupId,
      insertError.code === "23505"
        ? "Ese estudiante ya tiene una reasignación pendiente en este módulo."
        : "No se pudo crear la reasignación.",
    );
  }

  // En módulos con tiempo, la reasignación arranca con un reloj nuevo.
  await supabase
    .from("module_sessions")
    .delete()
    .eq("user_id", userId)
    .eq("module_id", moduleId);

  revalidatePath(`/admin/groups/${groupId}`);
  revalidatePath("/dashboard");
  revalidatePath(`/modules/${moduleData.slug}`);

  redirect(
    `/admin/groups/${groupId}?ok=reasignado&nuevos=${newCount}&total=${selected.length}`,
  );
}
