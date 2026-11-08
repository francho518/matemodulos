-- ============================================================
--  Matemódulos · Migración: visibilidad estricta por grupos
--
--  Regla nueva:
--    Un módulo publicado SOLO es visible para los estudiantes que
--    pertenecen a algún grupo al que ese módulo esté asignado.
--    Un módulo sin grupos asignados no lo ve ningún estudiante
--    (los administradores sí lo ven siempre desde el panel).
--
--  Ejecuta este archivo una vez en el SQL Editor de Supabase.
--  Es seguro volver a ejecutarlo.
-- ============================================================

create or replace function public.can_access_module(p_module_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.modules m
    where m.id = p_module_id
      and m.is_published = true
      and exists (
        select 1
        from public.group_modules gm
        join public.group_members gmem on gmem.group_id = gm.group_id
        where gm.module_id = m.id
          and gmem.user_id = auth.uid()
      )
  );
$$;

grant execute on function public.can_access_module(uuid) to authenticated;

-- Acelera el cálculo del puntaje por intento.
create index if not exists idx_attempts_user_exercise
  on public.attempts (user_id, exercise_id, created_at);
