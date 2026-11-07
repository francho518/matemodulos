-- ============================================================
--  Matemódulos · Esquema de base de datos (Supabase / PostgreSQL)
--
--  Cómo usar:
--    1. Crea un proyecto gratuito en https://supabase.com
--    2. Abre SQL Editor > New query
--    3. Pega todo este archivo y pulsa "Run"
--
--  El script es seguro de volver a ejecutar en su mayor parte
--  (usa IF NOT EXISTS / OR REPLACE / DROP POLICY IF EXISTS).
-- ============================================================

create extension if not exists pgcrypto;

-- ------------------------------------------------------------
-- 1. PERFILES
-- ------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  email text,
  role text not null default 'student' check (role in ('student', 'admin')),
  created_at timestamptz not null default now()
);

-- Migración para bases de datos creadas antes de los grupos.
alter table public.profiles add column if not exists email text;

-- Rellena el correo de los perfiles que ya existían.
update public.profiles p
set email = u.email
from auth.users u
where p.id = u.id
  and (p.email is null or p.email = '');

alter table public.profiles enable row level security;

-- Devuelve true si el usuario autenticado es administrador.
-- SECURITY DEFINER evita recursión en las políticas RLS de profiles.
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'
  );
$$;

grant execute on function public.is_admin() to authenticated;

drop policy if exists "profiles_select" on public.profiles;
create policy "profiles_select"
  on public.profiles for select
  to authenticated
  using (id = auth.uid() or public.is_admin());

drop policy if exists "profiles_update" on public.profiles;
create policy "profiles_update"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- Crea automáticamente el perfil cuando se registra un usuario.
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

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Evita que un alumno se asigne el rol de administrador.
-- auth.uid() es null cuando se ejecuta desde el SQL Editor o service_role,
-- lo que permite promover administradores manualmente.
create or replace function public.protect_profile_role()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role is distinct from old.role
     and auth.uid() is not null
     and not public.is_admin() then
    raise exception 'Solo un administrador puede cambiar el rol.';
  end if;

  return new;
end;
$$;

drop trigger if exists protect_profile_role on public.profiles;
create trigger protect_profile_role
  before update on public.profiles
  for each row execute function public.protect_profile_role();

-- El correo se usa para exportar notas. Un estudiante no puede cambiarlo
-- desde la aplicación; un administrador o el SQL Editor sí pueden.
create or replace function public.protect_profile_email()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.email is distinct from old.email
     and auth.uid() is not null
     and not public.is_admin() then
    new.email := old.email;
  end if;

  return new;
end;
$$;

drop trigger if exists protect_profile_email on public.profiles;
create trigger protect_profile_email
  before update on public.profiles
  for each row execute function public.protect_profile_email();

-- ------------------------------------------------------------
-- 2. MÓDULOS (temas)
-- ------------------------------------------------------------
create table if not exists public.modules (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  description text,
  order_index integer not null default 0,
  is_published boolean not null default false,
  randomize_exercises boolean not null default false,
  exercises_per_student integer not null default 0,
  module_time_limit_minutes integer,
  question_time_limit_seconds integer,
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Migración para bases de datos creadas antes de las variantes por estudiante.
alter table public.modules
  add column if not exists randomize_exercises boolean not null default false,
  add column if not exists exercises_per_student integer not null default 0;

-- Migración para bases de datos creadas antes de los límites de tiempo.
alter table public.modules
  add column if not exists module_time_limit_minutes integer,
  add column if not exists question_time_limit_seconds integer;

alter table public.modules
  drop constraint if exists modules_exercises_per_student_check;

alter table public.modules
  add constraint modules_exercises_per_student_check
  check (exercises_per_student >= 0);

alter table public.modules
  drop constraint if exists modules_timing_check;

alter table public.modules
  add constraint modules_timing_check
  check (
    (module_time_limit_minutes is null or module_time_limit_minutes > 0)
    and
    (question_time_limit_seconds is null or question_time_limit_seconds > 0)
  );

alter table public.modules enable row level security;

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

-- Los estudiantes solo ven los grupos a los que pertenecen.
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
-- Un módulo publicado es visible para todos si no tiene grupos
-- asignados. Si tiene al menos un grupo, solo lo ven sus miembros.
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

drop policy if exists "modules_admin_insert" on public.modules;
create policy "modules_admin_insert"
  on public.modules for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists "modules_admin_update" on public.modules;
create policy "modules_admin_update"
  on public.modules for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "modules_admin_delete" on public.modules;
create policy "modules_admin_delete"
  on public.modules for delete
  to authenticated
  using (public.is_admin());

-- ------------------------------------------------------------
-- 5. EJERCICIOS
-- ------------------------------------------------------------
create table if not exists public.exercises (
  id uuid primary key default gen_random_uuid(),
  module_id uuid not null references public.modules (id) on delete cascade,
  prompt text not null,
  type text not null check (type in ('multiple_choice', 'numeric')),
  options jsonb,               -- arreglo JSON de textos para opción múltiple
  correct_option integer,      -- índice base 0 de la opción correcta
  correct_answer numeric,      -- respuesta correcta para tipo numérico
  tolerance numeric not null default 0.000001,
  explanation text,
  order_index integer not null default 0,
  created_at timestamptz not null default now(),
  constraint exercises_answer_check check (
    (type = 'multiple_choice' and options is not null and correct_option is not null)
    or
    (type = 'numeric' and correct_answer is not null)
  ),
  constraint exercises_options_array check (
    options is null or jsonb_typeof(options) = 'array'
  )
);

alter table public.exercises enable row level security;

drop policy if exists "exercises_select" on public.exercises;
create policy "exercises_select"
  on public.exercises for select
  to authenticated
  using (public.is_admin() or public.can_access_module(module_id));

drop policy if exists "exercises_admin_insert" on public.exercises;
create policy "exercises_admin_insert"
  on public.exercises for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists "exercises_admin_update" on public.exercises;
create policy "exercises_admin_update"
  on public.exercises for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "exercises_admin_delete" on public.exercises;
create policy "exercises_admin_delete"
  on public.exercises for delete
  to authenticated
  using (public.is_admin());

-- ------------------------------------------------------------
-- 6. INTENTOS / PROGRESO
-- ------------------------------------------------------------
create table if not exists public.attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  module_id uuid not null references public.modules (id) on delete cascade,
  exercise_id uuid not null references public.exercises (id) on delete cascade,
  answer jsonb not null,
  is_correct boolean not null,
  created_at timestamptz not null default now()
);

alter table public.attempts enable row level security;

drop policy if exists "attempts_select" on public.attempts;
create policy "attempts_select"
  on public.attempts for select
  to authenticated
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists "attempts_insert" on public.attempts;
create policy "attempts_insert"
  on public.attempts for insert
  to authenticated
  with check (
    user_id = auth.uid()
    and (public.is_admin() or public.can_access_module(module_id))
  );

-- ------------------------------------------------------------
-- 7. SESIONES CON TIEMPO LIMITADO
-- ------------------------------------------------------------
-- Una sesión por estudiante y módulo. El reloj del módulo empieza
-- la primera vez que el estudiante abre el módulo.
create table if not exists public.module_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  module_id uuid not null references public.modules (id) on delete cascade,
  started_at timestamptz not null default now(),
  expires_at timestamptz,
  completed_at timestamptz,
  unique (user_id, module_id)
);

-- Una sesión por pregunta dentro de la sesión del módulo.
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
-- 8. ÍNDICES Y TRIGGERS DE ACTUALIZACIÓN
-- ------------------------------------------------------------
create index if not exists idx_exercises_module
  on public.exercises (module_id, order_index);

create index if not exists idx_attempts_user_module
  on public.attempts (user_id, module_id);

create index if not exists idx_attempts_exercise
  on public.attempts (exercise_id);

create index if not exists idx_group_members_user
  on public.group_members (user_id);

create index if not exists idx_group_modules_module
  on public.group_modules (module_id);

create index if not exists idx_module_sessions_user
  on public.module_sessions (user_id, module_id);

create index if not exists idx_question_sessions_module
  on public.question_sessions (module_session_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists modules_set_updated_at on public.modules;
create trigger modules_set_updated_at
  before update on public.modules
  for each row execute function public.set_updated_at();

drop trigger if exists groups_set_updated_at on public.groups;
create trigger groups_set_updated_at
  before update on public.groups
  for each row execute function public.set_updated_at();

-- ------------------------------------------------------------
-- 9. PERMISOS
-- ------------------------------------------------------------
grant select, insert, update, delete
  on public.profiles, public.modules, public.exercises, public.attempts,
     public.groups, public.group_members, public.group_modules,
     public.module_sessions, public.question_sessions
  to authenticated;

grant select on public.modules, public.exercises to anon;
