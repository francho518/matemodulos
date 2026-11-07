-- ============================================================
--  Matemódulos · Migración: grupos, notas y límites de tiempo
--
--  Ejecuta este archivo SOLO si ya habías creado las tablas con
--  una versión anterior de schema.sql.
--
--  Agrega:
--    - Correo en los perfiles (para exportar notas).
--    - Grupos de estudiantes y asignación de módulos a grupos.
--    - Límite de tiempo por módulo y por pregunta.
--    - Sesiones de módulo/pregunta para controlar los tiempos.
--    - Políticas de acceso: los módulos asignados a un grupo solo
--      son visibles para sus miembros.
--
--  Es seguro volver a ejecutarlo.
-- ============================================================

-- ------------------------------------------------------------
-- 1. PERFILES CON CORREO
-- ------------------------------------------------------------
alter table public.profiles add column if not exists email text;

update public.profiles p
set email = u.email
from auth.users u
where p.id = u.id
  and (p.email is null or p.email = '');

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'full_name', ''),
      split_part(coalesce(new.email, 'usuario'), '@', 1)
    ),
    new.email
  )
  on conflict (id) do update
    set email = coalesce(excluded.email, public.profiles.email);

  return new;
end;
$$;

-- ------------------------------------------------------------
-- 2. LÍMITES DE TIEMPO EN LOS MÓDULOS
-- ------------------------------------------------------------
alter table public.modules
  add column if not exists module_time_limit_minutes integer,
  add column if not exists question_time_limit_seconds integer;

alter table public.modules
  drop constraint if exists modules_timing_check;

alter table public.modules
  add constraint modules_timing_check
  check (
    (module_time_limit_minutes is null or module_time_limit_minutes > 0)
    and
    (question_time_limit_seconds is null or question_time_limit_seconds > 0)
  );

-- ------------------------------------------------------------
-- 3. GRUPOS Y ASIGNACIONES
-- ------------------------------------------------------------
create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.group_members (
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

create table if not exists public.group_modules (
  group_id uuid not null references public.groups (id) on delete cascade,
  module_id uuid not null references public.modules (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (group_id, module_id)
);

alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.group_modules enable row level security;

drop policy if exists "groups_select" on public.groups;
create policy "groups_select"
  on public.groups for select
  to authenticated
  using (
    public.is_admin()
    or exists (
      select 1
      from public.group_members gm
      where gm.group_id = groups.id
        and gm.user_id = auth.uid()
    )
  );

drop policy if exists "groups_admin_insert" on public.groups;
create policy "groups_admin_insert"
  on public.groups for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists "groups_admin_update" on public.groups;
create policy "groups_admin_update"
  on public.groups for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "groups_admin_delete" on public.groups;
create policy "groups_admin_delete"
  on public.groups for delete
  to authenticated
  using (public.is_admin());

drop policy if exists "group_members_select" on public.group_members;
create policy "group_members_select"
  on public.group_members for select
  to authenticated
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists "group_members_admin_insert" on public.group_members;
create policy "group_members_admin_insert"
  on public.group_members for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists "group_members_admin_update" on public.group_members;
create policy "group_members_admin_update"
  on public.group_members for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "group_members_admin_delete" on public.group_members;
create policy "group_members_admin_delete"
  on public.group_members for delete
  to authenticated
  using (public.is_admin());

drop policy if exists "group_modules_select" on public.group_modules;
create policy "group_modules_select"
  on public.group_modules for select
  to authenticated
  using (
    public.is_admin()
    or exists (
      select 1
      from public.group_members gm
      where gm.group_id = group_modules.group_id
        and gm.user_id = auth.uid()
    )
  );

drop policy if exists "group_modules_admin_insert" on public.group_modules;
create policy "group_modules_admin_insert"
  on public.group_modules for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists "group_modules_admin_update" on public.group_modules;
create policy "group_modules_admin_update"
  on public.group_modules for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "group_modules_admin_delete" on public.group_modules;
create policy "group_modules_admin_delete"
  on public.group_modules for delete
  to authenticated
  using (public.is_admin());

-- ------------------------------------------------------------
-- 4. ACCESO A MÓDULOS SEGÚN GRUPOS
-- ------------------------------------------------------------
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
      and (
        not exists (
          select 1
          from public.group_modules gm
          where gm.module_id = m.id
        )
        or exists (
          select 1
          from public.group_modules gm
          join public.group_members gmem on gmem.group_id = gm.group_id
          where gm.module_id = m.id
            and gmem.user_id = auth.uid()
        )
      )
  );
$$;

grant execute on function public.can_access_module(uuid) to authenticated;

drop policy if exists "modules_select" on public.modules;
create policy "modules_select"
  on public.modules for select
  to authenticated
  using (public.is_admin() or public.can_access_module(id));

drop policy if exists "exercises_select" on public.exercises;
create policy "exercises_select"
  on public.exercises for select
  to authenticated
  using (public.is_admin() or public.can_access_module(module_id));

drop policy if exists "attempts_insert" on public.attempts;
create policy "attempts_insert"
  on public.attempts for insert
  to authenticated
  with check (
    user_id = auth.uid()
    and (public.is_admin() or public.can_access_module(module_id))
  );

-- ------------------------------------------------------------
-- 5. SESIONES CON TIEMPO LIMITADO
-- ------------------------------------------------------------
create table if not exists public.module_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  module_id uuid not null references public.modules (id) on delete cascade,
  started_at timestamptz not null default now(),
  expires_at timestamptz,
  completed_at timestamptz,
  unique (user_id, module_id)
);

create table if not exists public.question_sessions (
  id uuid primary key default gen_random_uuid(),
  module_session_id uuid not null references public.module_sessions (id) on delete cascade,
  exercise_id uuid not null references public.exercises (id) on delete cascade,
  started_at timestamptz not null default now(),
  expires_at timestamptz,
  submitted_at timestamptz,
  unique (module_session_id, exercise_id)
);

alter table public.module_sessions enable row level security;
alter table public.question_sessions enable row level security;

drop policy if exists "module_sessions_select" on public.module_sessions;
create policy "module_sessions_select"
  on public.module_sessions for select
  to authenticated
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists "module_sessions_insert" on public.module_sessions;
create policy "module_sessions_insert"
  on public.module_sessions for insert
  to authenticated
  with check (user_id = auth.uid());

drop policy if exists "module_sessions_update" on public.module_sessions;
create policy "module_sessions_update"
  on public.module_sessions for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "module_sessions_admin_delete" on public.module_sessions;
create policy "module_sessions_admin_delete"
  on public.module_sessions for delete
  to authenticated
  using (public.is_admin());

drop policy if exists "question_sessions_select" on public.question_sessions;
create policy "question_sessions_select"
  on public.question_sessions for select
  to authenticated
  using (
    public.is_admin()
    or exists (
      select 1
      from public.module_sessions ms
      where ms.id = question_sessions.module_session_id
        and ms.user_id = auth.uid()
    )
  );

drop policy if exists "question_sessions_insert" on public.question_sessions;
create policy "question_sessions_insert"
  on public.question_sessions for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.module_sessions ms
      where ms.id = question_sessions.module_session_id
        and ms.user_id = auth.uid()
    )
  );

drop policy if exists "question_sessions_update" on public.question_sessions;
create policy "question_sessions_update"
  on public.question_sessions for update
  to authenticated
  using (
    exists (
      select 1
      from public.module_sessions ms
      where ms.id = question_sessions.module_session_id
        and ms.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1
      from public.module_sessions ms
      where ms.id = question_sessions.module_session_id
        and ms.user_id = auth.uid()
    )
  );

drop policy if exists "question_sessions_admin_delete" on public.question_sessions;
create policy "question_sessions_admin_delete"
  on public.question_sessions for delete
  to authenticated
  using (public.is_admin());

-- ------------------------------------------------------------
-- 6. ÍNDICES Y TRIGGERS
-- ------------------------------------------------------------
create index if not exists idx_group_members_user
  on public.group_members (user_id);

create index if not exists idx_group_modules_module
  on public.group_modules (module_id);

create index if not exists idx_module_sessions_user
  on public.module_sessions (user_id, module_id);

create index if not exists idx_question_sessions_module
  on public.question_sessions (module_session_id);

drop trigger if exists groups_set_updated_at on public.groups;
create trigger groups_set_updated_at
  before update on public.groups
  for each row execute function public.set_updated_at();

-- ------------------------------------------------------------
-- 7. PERMISOS
-- ------------------------------------------------------------
grant select, insert, update, delete
  on public.groups, public.group_members, public.group_modules,
     public.module_sessions, public.question_sessions
  to authenticated;
