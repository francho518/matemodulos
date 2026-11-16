-- ============================================================
--  Mate Dual Brücke · Un solo grupo por estudiante
--
--  A partir de este cambio, un estudiante solo puede pertenecer a un
--  grupo. Al asignarlo a un grupo, ya no aparecerá como disponible en
--  los demás.
--
--  Si en tu base hay estudiantes en varios grupos, este script deja
--  únicamente la membresía MÁS RECIENTE (la última asignación) y
--  elimina las anteriores, porque el índice único no permite
--  duplicados.
--
--  Ejecuta este archivo en el SQL Editor de Supabase.
-- ============================================================

-- 1. Elimina membresías duplicadas dejando la más reciente ----------
delete from public.group_members gm
using public.group_members newer
where gm.user_id = newer.user_id
  and (
    gm.created_at < newer.created_at
    or (gm.created_at = newer.created_at and gm.group_id < newer.group_id)
  );

-- 2. Impide que un estudiante vuelva a estar en dos grupos ----------
create unique index if not exists idx_group_members_one_group
  on public.group_members (user_id);
