"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
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
