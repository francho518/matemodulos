"use client";

import { useActionState } from "react";
import {
  createGroupAction,
  updateGroupAction,
} from "@/app/admin/groups/actions";
import type { ActionState } from "@/lib/action-state";
import type { GroupRow } from "@/lib/types";

type Props = {
  group?: GroupRow;
};

export function GroupForm({ group }: Props) {
  const [state, formAction, pending] = useActionState<ActionState, FormData>(
    group ? updateGroupAction : createGroupAction,
    {},
  );

  return (
    <form action={formAction} className="space-y-4">
      {group && <input type="hidden" name="id" value={group.id} />}

      <div>
        <label htmlFor={`group-name-${group?.id ?? "new"}`} className="label">
          Nombre del grupo *
        </label>
        <input
          id={`group-name-${group?.id ?? "new"}`}
          name="name"
          type="text"
          required
          minLength={2}
          defaultValue={group?.name ?? ""}
          className="input"
          placeholder="3.º A · Matemáticas"
        />
      </div>

      <div>
        <label
          htmlFor={`group-description-${group?.id ?? "new"}`}
          className="label"
        >
          Descripción
        </label>
        <textarea
          id={`group-description-${group?.id ?? "new"}`}
          name="description"
          rows={2}
          defaultValue={group?.description ?? ""}
          className="input"
          placeholder="Grupo de la mañana, ciclo 2026."
        />
      </div>

      {state.error && (
        <p className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {state.error}
        </p>
      )}

      <button type="submit" disabled={pending} className="btn-primary">
        {pending
          ? "Guardando…"
          : group
            ? "Guardar cambios"
            : "Crear grupo"}
      </button>
    </form>
  );
}
