-- ============================================================
--  Mate Dual Brücke · Reasignación de módulos
--
--  Permite que un estudiante que ya terminó un módulo reciba una
--  reasignación con ejercicios diferentes (otra ronda) y que se
--  conserve la mejor nota entre todas las rondas.
--
--  Cambios:
--    1. public.attempts.round  -> ronda a la que pertenece el intento.
--    2. public.module_rounds   -> ejercicios asignados en cada
--       reasignación (ronda 2, 3, …).
--
--  La ronda 1 es la asignación original y no se guarda en la tabla:
--  se calcula igual que siempre con selectExercisesForStudent.
--
--  Ejecuta este archivo en el SQL Editor de Supabase.
-- ============================================================

-- 1. Ronda de cada intento ------------------------------------
alter table public.attempts
  add column if not exists round integer not null default 1;

alter table public.attempts
  drop constraint if exists attempts_round_check;

alter table public.attempts
  add constraint attempts_round_check check (round >= 1);

create index if not exists idx_attempts_round
  on public.attempts (user_id, module_id, round);

-- 2. Rondas de reasignación ----------------------------------
create table if not exists public.module_rounds (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  module_id uuid not null references public.modules (id) on delete cascade,
  round integer not null,
  exercise_ids uuid[] not null default '{}',
  assigned_by uuid default auth.uid() references auth.users (id) on delete set null,
  assigned_at timestamptz not null default now(),
  constraint module_rounds_round_check check (round >= 2),
  constraint module_rounds_unique unique (user_id, module_id, round)
);

alter table public.module_rounds enable row level security;

drop policy if exists "module_rounds_select" on public.module_rounds;
create policy "module_rounds_select"
  on public.module_rounds for select
  to authenticated
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists "module_rounds_admin_insert" on public.module_rounds;
create policy "module_rounds_admin_insert"
  on public.module_rounds for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists "module_rounds_admin_delete" on public.module_rounds;
create policy "module_rounds_admin_delete"
  on public.module_rounds for delete
  to authenticated
  using (public.is_admin());

create index if not exists idx_module_rounds_student
  on public.module_rounds (user_id, module_id, round);
