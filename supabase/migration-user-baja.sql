-- ============================================================
--  Matemódulos · Baja de usuarios y recuperación de contraseña
--
--  Añade el campo `active` a los perfiles y la función RPC que
--  permite al administrador dar de baja o reactivar estudiantes
--  sin necesidad de usar la clave service_role.
--
--  Ejecuta este archivo en el SQL Editor de Supabase.
--  (Si ya ejecutaste `schema.sql` actualizado, no hace falta.)
-- ============================================================

alter table public.profiles
  add column if not exists active boolean not null default true;

create or replace function public.set_user_active(
  target_user uuid,
  is_active boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Solo un administrador puede cambiar el estado de los usuarios.';
  end if;

  if target_user = auth.uid() then
    raise exception 'No puedes cambiar tu propio estado.';
  end if;

  update public.profiles
  set active = is_active
  where id = target_user;

  if not is_active then
    delete from public.group_members where user_id = target_user;
  end if;
end;
$$;

revoke all on function public.set_user_active(uuid, boolean) from public;
grant execute on function public.set_user_active(uuid, boolean) to authenticated;
