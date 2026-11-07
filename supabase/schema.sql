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
  role text not null default 'student' check (role in ('student', 'admin')),
  created_at timestamptz not null default now()
);

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
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'full_name', ''),
      split_part(coalesce(new.email, 'usuario'), '@', 1)
    )
  )
  on conflict (id) do nothing;

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
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.modules enable row level security;

drop policy if exists "modules_select" on public.modules;
create policy "modules_select"
  on public.modules for select
  to authenticated
  using (is_published or public.is_admin());

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
-- 3. EJERCICIOS
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

-- Permite saber si un módulo está publicado sin chocar con su RLS.
create or replace function public.module_is_published(p_module_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.modules
    where id = p_module_id
      and is_published = true
  );
$$;

grant execute on function public.module_is_published(uuid) to authenticated;

drop policy if exists "exercises_select" on public.exercises;
create policy "exercises_select"
  on public.exercises for select
  to authenticated
  using (public.is_admin() or public.module_is_published(module_id));

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
-- 4. INTENTOS / PROGRESO
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
  with check (user_id = auth.uid());

-- ------------------------------------------------------------
-- 5. ÍNDICES Y TRIGGERS DE ACTUALIZACIÓN
-- ------------------------------------------------------------
create index if not exists idx_exercises_module
  on public.exercises (module_id, order_index);

create index if not exists idx_attempts_user_module
  on public.attempts (user_id, module_id);

create index if not exists idx_attempts_exercise
  on public.attempts (exercise_id);

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

-- ------------------------------------------------------------
-- 6. PERMISOS
-- ------------------------------------------------------------
grant select, insert, update, delete
  on public.profiles, public.modules, public.exercises, public.attempts
  to authenticated;

grant select on public.modules, public.exercises to anon;
