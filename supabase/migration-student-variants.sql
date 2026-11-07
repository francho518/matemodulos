-- ============================================================
--  Matemódulos · Migración: variantes de ejercicios por estudiante
--
--  Ejecuta este archivo SOLO si ya habías creado las tablas con
--  una versión anterior de schema.sql.
--
--  Agrega dos columnas a public.modules:
--    randomize_exercises    -> selección/orden distinto por estudiante
--    exercises_per_student  -> cuántos ejercicios ve cada estudiante (0 = todos)
-- ============================================================

alter table public.modules
  add column if not exists randomize_exercises boolean not null default false,
  add column if not exists exercises_per_student integer not null default 0;

alter table public.modules
  drop constraint if exists modules_exercises_per_student_check;

alter table public.modules
  add constraint modules_exercises_per_student_check
  check (exercises_per_student >= 0);
