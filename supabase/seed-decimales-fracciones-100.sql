-- ============================================================
--  Mate Dual Brucke · Decimales a fracciones · 100 ejercicios
--
--  Requisitos:
--    1. Haber ejecutado schema.sql
--    2. Haber ejecutado migration-student-variants.sql
--       (o tener ya las columnas nuevas en public.modules)
--
--  Contenido: conversión de decimales simples (finitos) a fracciones
--  irreducibles. Incluye décimas, centésimas, milésimas y valores
--  mayores que 1.
--
--  Cada ejercicio es de opción múltiple con 4 fracciones distintas.
--  El módulo entrega los 100 ejercicios completos a cada estudiante
--  y se resuelven de uno en uno.
--
--  IMPORTANTE: con la visibilidad estricta por grupos, este módulo solo
--  lo verán los estudiantes de los grupos a los que se asigne.
--  Después de ejecutar este archivo, asígnalo en Administración → Grupos.
-- ============================================================

-- Asegura las columnas aunque no se haya ejecutado la migración.
alter table public.modules
  add column if not exists randomize_exercises boolean not null default false,
  add column if not exists exercises_per_student integer not null default 0;

insert into public.modules (
  title,
  slug,
  description,
  order_index,
  is_published,
  randomize_exercises,
  exercises_per_student
)
values (
  'Decimales a fracciones · 100 ejercicios',
  'decimales-fracciones-100',
  '100 ejercicios para convertir decimales simples (décimas, centésimas y milésimas) a fracciones irreducibles.',
  5,
  true,
  false,
  0
)
on conflict (slug) do update
set title = excluded.title,
    description = excluded.description,
    order_index = excluded.order_index,
    is_published = excluded.is_published,
    randomize_exercises = excluded.randomize_exercises,
    exercises_per_student = excluded.exercises_per_student;

-- Solo inserta el banco si el módulo todavía no tiene ejercicios.
insert into public.exercises (
  module_id,
  prompt,
  type,
  options,
  correct_option,
  correct_answer,
  tolerance,
  explanation,
  order_index
)
select
  m.id,
  v.prompt,
  v.type,
  v.options,
  v.correct_option,
  v.correct_answer,
  v.tolerance,
  v.explanation,
  v.order_index
from (
  values
    (
      'Convierte el decimal $0.1$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{1}{10}$', '$\frac{2}{10}$', '$\frac{1}{11}$', '$\frac{3}{10}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.1$ tiene una cifra decimal, así que se escribe como $\frac{1}{10}$. La fracción ya es irreducible: $\frac{1}{10}$.',
      1
    ),
    (
      'Convierte el decimal $0.2$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{2}{5}$', '$\frac{1}{5}$', '$\frac{1}{6}$', '$\frac{3}{5}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.2$ tiene una cifra decimal, así que se escribe como $\frac{2}{10}$. Al simplificar entre $2$ se obtiene $\frac{1}{5}$.',
      2
    ),
    (
      'Convierte el decimal $0.3$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{4}{10}$', '$\frac{3}{11}$', '$\frac{3}{10}$', '$\frac{5}{10}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.3$ tiene una cifra decimal, así que se escribe como $\frac{3}{10}$. La fracción ya es irreducible: $\frac{3}{10}$.',
      3
    ),
    (
      'Convierte el decimal $0.4$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{3}{5}$', '$\frac{2}{6}$', '$\frac{4}{5}$', '$\frac{2}{5}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.4$ tiene una cifra decimal, así que se escribe como $\frac{4}{10}$. Al simplificar entre $2$ se obtiene $\frac{2}{5}$.',
      4
    ),
    (
      'Convierte el decimal $0.5$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{1}{2}$', '$\frac{2}{2}$', '$\frac{1}{3}$', '$\frac{3}{2}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.5$ tiene una cifra decimal, así que se escribe como $\frac{5}{10}$. Al simplificar entre $5$ se obtiene $\frac{1}{2}$.',
      5
    ),
    (
      'Convierte el decimal $0.6$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{4}{5}$', '$\frac{3}{5}$', '$\frac{3}{6}$', '$\frac{5}{5}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.6$ tiene una cifra decimal, así que se escribe como $\frac{6}{10}$. Al simplificar entre $2$ se obtiene $\frac{3}{5}$.',
      6
    ),
    (
      'Convierte el decimal $0.7$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{8}{10}$', '$\frac{7}{11}$', '$\frac{7}{10}$', '$\frac{9}{10}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.7$ tiene una cifra decimal, así que se escribe como $\frac{7}{10}$. La fracción ya es irreducible: $\frac{7}{10}$.',
      7
    ),
    (
      'Convierte el decimal $0.8$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{5}{5}$', '$\frac{4}{6}$', '$\frac{6}{5}$', '$\frac{4}{5}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.8$ tiene una cifra decimal, así que se escribe como $\frac{8}{10}$. Al simplificar entre $2$ se obtiene $\frac{4}{5}$.',
      8
    ),
    (
      'Convierte el decimal $0.9$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{9}{10}$', '$\frac{10}{10}$', '$\frac{9}{11}$', '$\frac{11}{10}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.9$ tiene una cifra decimal, así que se escribe como $\frac{9}{10}$. La fracción ya es irreducible: $\frac{9}{10}$.',
      9
    ),
    (
      'Convierte el decimal $1.1$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{12}{10}$', '$\frac{11}{10}$', '$\frac{11}{11}$', '$\frac{13}{10}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $1.1$ tiene una cifra decimal, así que se escribe como $\frac{11}{10}$. La fracción ya es irreducible: $\frac{11}{10}$.',
      10
    ),
    (
      'Convierte el decimal $1.2$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{7}{5}$', '$\frac{6}{6}$', '$\frac{6}{5}$', '$\frac{8}{5}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $1.2$ tiene una cifra decimal, así que se escribe como $\frac{12}{10}$. Al simplificar entre $2$ se obtiene $\frac{6}{5}$.',
      11
    ),
    (
      'Convierte el decimal $1.3$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{14}{10}$', '$\frac{13}{11}$', '$\frac{15}{10}$', '$\frac{13}{10}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $1.3$ tiene una cifra decimal, así que se escribe como $\frac{13}{10}$. La fracción ya es irreducible: $\frac{13}{10}$.',
      12
    ),
    (
      'Convierte el decimal $1.4$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{7}{5}$', '$\frac{8}{5}$', '$\frac{7}{6}$', '$\frac{9}{5}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $1.4$ tiene una cifra decimal, así que se escribe como $\frac{14}{10}$. Al simplificar entre $2$ se obtiene $\frac{7}{5}$.',
      13
    ),
    (
      'Convierte el decimal $1.5$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{4}{2}$', '$\frac{3}{2}$', '$\frac{3}{3}$', '$\frac{5}{2}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $1.5$ tiene una cifra decimal, así que se escribe como $\frac{15}{10}$. Al simplificar entre $5$ se obtiene $\frac{3}{2}$.',
      14
    ),
    (
      'Convierte el decimal $1.6$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{9}{5}$', '$\frac{8}{6}$', '$\frac{8}{5}$', '$\frac{10}{5}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $1.6$ tiene una cifra decimal, así que se escribe como $\frac{16}{10}$. Al simplificar entre $2$ se obtiene $\frac{8}{5}$.',
      15
    ),
    (
      'Convierte el decimal $1.7$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{18}{10}$', '$\frac{17}{11}$', '$\frac{19}{10}$', '$\frac{17}{10}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $1.7$ tiene una cifra decimal, así que se escribe como $\frac{17}{10}$. La fracción ya es irreducible: $\frac{17}{10}$.',
      16
    ),
    (
      'Convierte el decimal $1.8$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{9}{5}$', '$\frac{10}{5}$', '$\frac{9}{6}$', '$\frac{11}{5}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $1.8$ tiene una cifra decimal, así que se escribe como $\frac{18}{10}$. Al simplificar entre $2$ se obtiene $\frac{9}{5}$.',
      17
    ),
    (
      'Convierte el decimal $1.9$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{20}{10}$', '$\frac{19}{10}$', '$\frac{19}{11}$', '$\frac{21}{10}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $1.9$ tiene una cifra decimal, así que se escribe como $\frac{19}{10}$. La fracción ya es irreducible: $\frac{19}{10}$.',
      18
    ),
    (
      'Convierte el decimal $2.5$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{6}{2}$', '$\frac{5}{3}$', '$\frac{5}{2}$', '$\frac{7}{2}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $2.5$ tiene una cifra decimal, así que se escribe como $\frac{25}{10}$. Al simplificar entre $5$ se obtiene $\frac{5}{2}$.',
      19
    ),
    (
      'Convierte el decimal $7.5$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{16}{2}$', '$\frac{15}{3}$', '$\frac{17}{2}$', '$\frac{15}{2}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $7.5$ tiene una cifra decimal, así que se escribe como $\frac{75}{10}$. Al simplificar entre $5$ se obtiene $\frac{15}{2}$.',
      20
    ),
    (
      'Convierte el decimal $0.05$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{1}{20}$', '$\frac{2}{20}$', '$\frac{1}{21}$', '$\frac{3}{20}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.05$ tiene dos cifras decimales, así que se escribe como $\frac{5}{100}$. Al simplificar entre $5$ se obtiene $\frac{1}{20}$.',
      21
    ),
    (
      'Convierte el decimal $0.12$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{4}{25}$', '$\frac{3}{25}$', '$\frac{3}{26}$', '$\frac{5}{25}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.12$ tiene dos cifras decimales, así que se escribe como $\frac{12}{100}$. Al simplificar entre $4$ se obtiene $\frac{3}{25}$.',
      22
    ),
    (
      'Convierte el decimal $0.15$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{4}{20}$', '$\frac{3}{21}$', '$\frac{3}{20}$', '$\frac{5}{20}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.15$ tiene dos cifras decimales, así que se escribe como $\frac{15}{100}$. Al simplificar entre $5$ se obtiene $\frac{3}{20}$.',
      23
    ),
    (
      'Convierte el decimal $0.18$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{10}{50}$', '$\frac{9}{51}$', '$\frac{11}{50}$', '$\frac{9}{50}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.18$ tiene dos cifras decimales, así que se escribe como $\frac{18}{100}$. Al simplificar entre $2$ se obtiene $\frac{9}{50}$.',
      24
    ),
    (
      'Convierte el decimal $0.24$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{6}{25}$', '$\frac{7}{25}$', '$\frac{6}{26}$', '$\frac{8}{25}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.24$ tiene dos cifras decimales, así que se escribe como $\frac{24}{100}$. Al simplificar entre $4$ se obtiene $\frac{6}{25}$.',
      25
    ),
    (
      'Convierte el decimal $0.25$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{2}{4}$', '$\frac{1}{4}$', '$\frac{1}{5}$', '$\frac{3}{4}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.25$ tiene dos cifras decimales, así que se escribe como $\frac{25}{100}$. Al simplificar entre $25$ se obtiene $\frac{1}{4}$.',
      26
    ),
    (
      'Convierte el decimal $0.28$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{8}{25}$', '$\frac{7}{26}$', '$\frac{7}{25}$', '$\frac{9}{25}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.28$ tiene dos cifras decimales, así que se escribe como $\frac{28}{100}$. Al simplificar entre $4$ se obtiene $\frac{7}{25}$.',
      27
    ),
    (
      'Convierte el decimal $0.32$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{9}{25}$', '$\frac{8}{26}$', '$\frac{10}{25}$', '$\frac{8}{25}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.32$ tiene dos cifras decimales, así que se escribe como $\frac{32}{100}$. Al simplificar entre $4$ se obtiene $\frac{8}{25}$.',
      28
    ),
    (
      'Convierte el decimal $0.35$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{7}{20}$', '$\frac{8}{20}$', '$\frac{7}{21}$', '$\frac{9}{20}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.35$ tiene dos cifras decimales, así que se escribe como $\frac{35}{100}$. Al simplificar entre $5$ se obtiene $\frac{7}{20}$.',
      29
    ),
    (
      'Convierte el decimal $0.36$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{10}{25}$', '$\frac{9}{25}$', '$\frac{9}{26}$', '$\frac{11}{25}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.36$ tiene dos cifras decimales, así que se escribe como $\frac{36}{100}$. Al simplificar entre $4$ se obtiene $\frac{9}{25}$.',
      30
    ),
    (
      'Convierte el decimal $0.42$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{22}{50}$', '$\frac{21}{51}$', '$\frac{21}{50}$', '$\frac{23}{50}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.42$ tiene dos cifras decimales, así que se escribe como $\frac{42}{100}$. Al simplificar entre $2$ se obtiene $\frac{21}{50}$.',
      31
    ),
    (
      'Convierte el decimal $0.44$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{12}{25}$', '$\frac{11}{26}$', '$\frac{13}{25}$', '$\frac{11}{25}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.44$ tiene dos cifras decimales, así que se escribe como $\frac{44}{100}$. Al simplificar entre $4$ se obtiene $\frac{11}{25}$.',
      32
    ),
    (
      'Convierte el decimal $0.45$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{9}{20}$', '$\frac{10}{20}$', '$\frac{9}{21}$', '$\frac{11}{20}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.45$ tiene dos cifras decimales, así que se escribe como $\frac{45}{100}$. Al simplificar entre $5$ se obtiene $\frac{9}{20}$.',
      33
    ),
    (
      'Convierte el decimal $0.48$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{13}{25}$', '$\frac{12}{25}$', '$\frac{12}{26}$', '$\frac{14}{25}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.48$ tiene dos cifras decimales, así que se escribe como $\frac{48}{100}$. Al simplificar entre $4$ se obtiene $\frac{12}{25}$.',
      34
    ),
    (
      'Convierte el decimal $0.52$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{14}{25}$', '$\frac{13}{26}$', '$\frac{13}{25}$', '$\frac{15}{25}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.52$ tiene dos cifras decimales, así que se escribe como $\frac{52}{100}$. Al simplificar entre $4$ se obtiene $\frac{13}{25}$.',
      35
    ),
    (
      'Convierte el decimal $0.55$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{12}{20}$', '$\frac{11}{21}$', '$\frac{13}{20}$', '$\frac{11}{20}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.55$ tiene dos cifras decimales, así que se escribe como $\frac{55}{100}$. Al simplificar entre $5$ se obtiene $\frac{11}{20}$.',
      36
    ),
    (
      'Convierte el decimal $0.56$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{14}{25}$', '$\frac{15}{25}$', '$\frac{14}{26}$', '$\frac{16}{25}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.56$ tiene dos cifras decimales, así que se escribe como $\frac{56}{100}$. Al simplificar entre $4$ se obtiene $\frac{14}{25}$.',
      37
    ),
    (
      'Convierte el decimal $0.62$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{32}{50}$', '$\frac{31}{50}$', '$\frac{31}{51}$', '$\frac{33}{50}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.62$ tiene dos cifras decimales, así que se escribe como $\frac{62}{100}$. Al simplificar entre $2$ se obtiene $\frac{31}{50}$.',
      38
    ),
    (
      'Convierte el decimal $0.64$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{17}{25}$', '$\frac{16}{26}$', '$\frac{16}{25}$', '$\frac{18}{25}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.64$ tiene dos cifras decimales, así que se escribe como $\frac{64}{100}$. Al simplificar entre $4$ se obtiene $\frac{16}{25}$.',
      39
    ),
    (
      'Convierte el decimal $0.65$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{14}{20}$', '$\frac{13}{21}$', '$\frac{15}{20}$', '$\frac{13}{20}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.65$ tiene dos cifras decimales, así que se escribe como $\frac{65}{100}$. Al simplificar entre $5$ se obtiene $\frac{13}{20}$.',
      40
    ),
    (
      'Convierte el decimal $0.68$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{17}{25}$', '$\frac{18}{25}$', '$\frac{17}{26}$', '$\frac{19}{25}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.68$ tiene dos cifras decimales, así que se escribe como $\frac{68}{100}$. Al simplificar entre $4$ se obtiene $\frac{17}{25}$.',
      41
    ),
    (
      'Convierte el decimal $0.72$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{19}{25}$', '$\frac{18}{25}$', '$\frac{18}{26}$', '$\frac{20}{25}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.72$ tiene dos cifras decimales, así que se escribe como $\frac{72}{100}$. Al simplificar entre $4$ se obtiene $\frac{18}{25}$.',
      42
    ),
    (
      'Convierte el decimal $0.75$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{4}{4}$', '$\frac{3}{5}$', '$\frac{3}{4}$', '$\frac{5}{4}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.75$ tiene dos cifras decimales, así que se escribe como $\frac{75}{100}$. Al simplificar entre $25$ se obtiene $\frac{3}{4}$.',
      43
    ),
    (
      'Convierte el decimal $0.76$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{20}{25}$', '$\frac{19}{26}$', '$\frac{21}{25}$', '$\frac{19}{25}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.76$ tiene dos cifras decimales, así que se escribe como $\frac{76}{100}$. Al simplificar entre $4$ se obtiene $\frac{19}{25}$.',
      44
    ),
    (
      'Convierte el decimal $0.78$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{39}{50}$', '$\frac{40}{50}$', '$\frac{39}{51}$', '$\frac{41}{50}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.78$ tiene dos cifras decimales, así que se escribe como $\frac{78}{100}$. Al simplificar entre $2$ se obtiene $\frac{39}{50}$.',
      45
    ),
    (
      'Convierte el decimal $0.82$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{42}{50}$', '$\frac{41}{50}$', '$\frac{41}{51}$', '$\frac{43}{50}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.82$ tiene dos cifras decimales, así que se escribe como $\frac{82}{100}$. Al simplificar entre $2$ se obtiene $\frac{41}{50}$.',
      46
    ),
    (
      'Convierte el decimal $0.84$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{22}{25}$', '$\frac{21}{26}$', '$\frac{21}{25}$', '$\frac{23}{25}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.84$ tiene dos cifras decimales, así que se escribe como $\frac{84}{100}$. Al simplificar entre $4$ se obtiene $\frac{21}{25}$.',
      47
    ),
    (
      'Convierte el decimal $0.85$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{18}{20}$', '$\frac{17}{21}$', '$\frac{19}{20}$', '$\frac{17}{20}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.85$ tiene dos cifras decimales, así que se escribe como $\frac{85}{100}$. Al simplificar entre $5$ se obtiene $\frac{17}{20}$.',
      48
    ),
    (
      'Convierte el decimal $0.88$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{22}{25}$', '$\frac{23}{25}$', '$\frac{22}{26}$', '$\frac{24}{25}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.88$ tiene dos cifras decimales, así que se escribe como $\frac{88}{100}$. Al simplificar entre $4$ se obtiene $\frac{22}{25}$.',
      49
    ),
    (
      'Convierte el decimal $0.92$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{24}{25}$', '$\frac{23}{25}$', '$\frac{23}{26}$', '$\frac{25}{25}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.92$ tiene dos cifras decimales, así que se escribe como $\frac{92}{100}$. Al simplificar entre $4$ se obtiene $\frac{23}{25}$.',
      50
    ),
    (
      'Convierte el decimal $0.95$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{20}{20}$', '$\frac{19}{21}$', '$\frac{19}{20}$', '$\frac{21}{20}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.95$ tiene dos cifras decimales, así que se escribe como $\frac{95}{100}$. Al simplificar entre $5$ se obtiene $\frac{19}{20}$.',
      51
    ),
    (
      'Convierte el decimal $0.96$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{25}{25}$', '$\frac{24}{26}$', '$\frac{26}{25}$', '$\frac{24}{25}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.96$ tiene dos cifras decimales, así que se escribe como $\frac{96}{100}$. Al simplificar entre $4$ se obtiene $\frac{24}{25}$.',
      52
    ),
    (
      'Convierte el decimal $0.98$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{49}{50}$', '$\frac{50}{50}$', '$\frac{49}{51}$', '$\frac{51}{50}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.98$ tiene dos cifras decimales, así que se escribe como $\frac{98}{100}$. Al simplificar entre $2$ se obtiene $\frac{49}{50}$.',
      53
    ),
    (
      'Convierte el decimal $0.99$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{100}{100}$', '$\frac{99}{100}$', '$\frac{99}{101}$', '$\frac{101}{100}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.99$ tiene dos cifras decimales, así que se escribe como $\frac{99}{100}$. La fracción ya es irreducible: $\frac{99}{100}$.',
      54
    ),
    (
      'Convierte el decimal $0.04$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{2}{25}$', '$\frac{1}{26}$', '$\frac{1}{25}$', '$\frac{3}{25}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.04$ tiene dos cifras decimales, así que se escribe como $\frac{4}{100}$. Al simplificar entre $4$ se obtiene $\frac{1}{25}$.',
      55
    ),
    (
      'Convierte el decimal $0.125$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{2}{8}$', '$\frac{1}{9}$', '$\frac{3}{8}$', '$\frac{1}{8}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.125$ tiene tres cifras decimales, así que se escribe como $\frac{125}{1000}$. Al simplificar entre $125$ se obtiene $\frac{1}{8}$.',
      56
    ),
    (
      'Convierte el decimal $0.375$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{3}{8}$', '$\frac{4}{8}$', '$\frac{3}{9}$', '$\frac{5}{8}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.375$ tiene tres cifras decimales, así que se escribe como $\frac{375}{1000}$. Al simplificar entre $125$ se obtiene $\frac{3}{8}$.',
      57
    ),
    (
      'Convierte el decimal $0.625$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{6}{8}$', '$\frac{5}{8}$', '$\frac{5}{9}$', '$\frac{7}{8}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.625$ tiene tres cifras decimales, así que se escribe como $\frac{625}{1000}$. Al simplificar entre $125$ se obtiene $\frac{5}{8}$.',
      58
    ),
    (
      'Convierte el decimal $0.875$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{8}{8}$', '$\frac{7}{9}$', '$\frac{7}{8}$', '$\frac{9}{8}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.875$ tiene tres cifras decimales, así que se escribe como $\frac{875}{1000}$. Al simplificar entre $125$ se obtiene $\frac{7}{8}$.',
      59
    ),
    (
      'Convierte el decimal $0.005$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{2}{200}$', '$\frac{1}{201}$', '$\frac{3}{200}$', '$\frac{1}{200}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.005$ tiene tres cifras decimales, así que se escribe como $\frac{5}{1000}$. Al simplificar entre $5$ se obtiene $\frac{1}{200}$.',
      60
    ),
    (
      'Convierte el decimal $0.012$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{3}{250}$', '$\frac{4}{250}$', '$\frac{3}{251}$', '$\frac{5}{250}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.012$ tiene tres cifras decimales, así que se escribe como $\frac{12}{1000}$. Al simplificar entre $4$ se obtiene $\frac{3}{250}$.',
      61
    ),
    (
      'Convierte el decimal $0.024$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{4}{125}$', '$\frac{3}{125}$', '$\frac{3}{126}$', '$\frac{5}{125}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.024$ tiene tres cifras decimales, así que se escribe como $\frac{24}{1000}$. Al simplificar entre $8$ se obtiene $\frac{3}{125}$.',
      62
    ),
    (
      'Convierte el decimal $0.036$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{10}{250}$', '$\frac{9}{251}$', '$\frac{9}{250}$', '$\frac{11}{250}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.036$ tiene tres cifras decimales, así que se escribe como $\frac{36}{1000}$. Al simplificar entre $4$ se obtiene $\frac{9}{250}$.',
      63
    ),
    (
      'Convierte el decimal $0.048$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{7}{125}$', '$\frac{6}{126}$', '$\frac{8}{125}$', '$\frac{6}{125}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.048$ tiene tres cifras decimales, así que se escribe como $\frac{48}{1000}$. Al simplificar entre $8$ se obtiene $\frac{6}{125}$.',
      64
    ),
    (
      'Convierte el decimal $0.064$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{8}{125}$', '$\frac{9}{125}$', '$\frac{8}{126}$', '$\frac{10}{125}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.064$ tiene tres cifras decimales, así que se escribe como $\frac{64}{1000}$. Al simplificar entre $8$ se obtiene $\frac{8}{125}$.',
      65
    ),
    (
      'Convierte el decimal $0.075$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{4}{40}$', '$\frac{3}{40}$', '$\frac{3}{41}$', '$\frac{5}{40}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.075$ tiene tres cifras decimales, así que se escribe como $\frac{75}{1000}$. Al simplificar entre $25$ se obtiene $\frac{3}{40}$.',
      66
    ),
    (
      'Convierte el decimal $0.088$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{12}{125}$', '$\frac{11}{126}$', '$\frac{11}{125}$', '$\frac{13}{125}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.088$ tiene tres cifras decimales, así que se escribe como $\frac{88}{1000}$. Al simplificar entre $8$ se obtiene $\frac{11}{125}$.',
      67
    ),
    (
      'Convierte el decimal $0.104$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{14}{125}$', '$\frac{13}{126}$', '$\frac{15}{125}$', '$\frac{13}{125}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.104$ tiene tres cifras decimales, así que se escribe como $\frac{104}{1000}$. Al simplificar entre $8$ se obtiene $\frac{13}{125}$.',
      68
    ),
    (
      'Convierte el decimal $0.112$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{14}{125}$', '$\frac{15}{125}$', '$\frac{14}{126}$', '$\frac{16}{125}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.112$ tiene tres cifras decimales, así que se escribe como $\frac{112}{1000}$. Al simplificar entre $8$ se obtiene $\frac{14}{125}$.',
      69
    ),
    (
      'Convierte el decimal $0.136$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{18}{125}$', '$\frac{17}{125}$', '$\frac{17}{126}$', '$\frac{19}{125}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.136$ tiene tres cifras decimales, así que se escribe como $\frac{136}{1000}$. Al simplificar entre $8$ se obtiene $\frac{17}{125}$.',
      70
    ),
    (
      'Convierte el decimal $0.144$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{19}{125}$', '$\frac{18}{126}$', '$\frac{18}{125}$', '$\frac{20}{125}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.144$ tiene tres cifras decimales, así que se escribe como $\frac{144}{1000}$. Al simplificar entre $8$ se obtiene $\frac{18}{125}$.',
      71
    ),
    (
      'Convierte el decimal $0.152$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{20}{125}$', '$\frac{19}{126}$', '$\frac{21}{125}$', '$\frac{19}{125}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.152$ tiene tres cifras decimales, así que se escribe como $\frac{152}{1000}$. Al simplificar entre $8$ se obtiene $\frac{19}{125}$.',
      72
    ),
    (
      'Convierte el decimal $0.168$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{21}{125}$', '$\frac{22}{125}$', '$\frac{21}{126}$', '$\frac{23}{125}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.168$ tiene tres cifras decimales, así que se escribe como $\frac{168}{1000}$. Al simplificar entre $8$ se obtiene $\frac{21}{125}$.',
      73
    ),
    (
      'Convierte el decimal $0.175$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{8}{40}$', '$\frac{7}{40}$', '$\frac{7}{41}$', '$\frac{9}{40}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.175$ tiene tres cifras decimales, así que se escribe como $\frac{175}{1000}$. Al simplificar entre $25$ se obtiene $\frac{7}{40}$.',
      74
    ),
    (
      'Convierte el decimal $0.192$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{25}{125}$', '$\frac{24}{126}$', '$\frac{24}{125}$', '$\frac{26}{125}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.192$ tiene tres cifras decimales, así que se escribe como $\frac{192}{1000}$. Al simplificar entre $8$ se obtiene $\frac{24}{125}$.',
      75
    ),
    (
      'Convierte el decimal $0.208$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{27}{125}$', '$\frac{26}{126}$', '$\frac{28}{125}$', '$\frac{26}{125}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.208$ tiene tres cifras decimales, así que se escribe como $\frac{208}{1000}$. Al simplificar entre $8$ se obtiene $\frac{26}{125}$.',
      76
    ),
    (
      'Convierte el decimal $0.225$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{9}{40}$', '$\frac{10}{40}$', '$\frac{9}{41}$', '$\frac{11}{40}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.225$ tiene tres cifras decimales, así que se escribe como $\frac{225}{1000}$. Al simplificar entre $25$ se obtiene $\frac{9}{40}$.',
      77
    ),
    (
      'Convierte el decimal $0.256$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{33}{125}$', '$\frac{32}{125}$', '$\frac{32}{126}$', '$\frac{34}{125}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.256$ tiene tres cifras decimales, así que se escribe como $\frac{256}{1000}$. Al simplificar entre $8$ se obtiene $\frac{32}{125}$.',
      78
    ),
    (
      'Convierte el decimal $0.275$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{12}{40}$', '$\frac{11}{41}$', '$\frac{11}{40}$', '$\frac{13}{40}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.275$ tiene tres cifras decimales, así que se escribe como $\frac{275}{1000}$. Al simplificar entre $25$ se obtiene $\frac{11}{40}$.',
      79
    ),
    (
      'Convierte el decimal $0.304$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{39}{125}$', '$\frac{38}{126}$', '$\frac{40}{125}$', '$\frac{38}{125}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.304$ tiene tres cifras decimales, así que se escribe como $\frac{304}{1000}$. Al simplificar entre $8$ se obtiene $\frac{38}{125}$.',
      80
    ),
    (
      'Convierte el decimal $0.325$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{13}{40}$', '$\frac{14}{40}$', '$\frac{13}{41}$', '$\frac{15}{40}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.325$ tiene tres cifras decimales, así que se escribe como $\frac{325}{1000}$. Al simplificar entre $25$ se obtiene $\frac{13}{40}$.',
      81
    ),
    (
      'Convierte el decimal $0.336$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{43}{125}$', '$\frac{42}{125}$', '$\frac{42}{126}$', '$\frac{44}{125}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $0.336$ tiene tres cifras decimales, así que se escribe como $\frac{336}{1000}$. Al simplificar entre $8$ se obtiene $\frac{42}{125}$.',
      82
    ),
    (
      'Convierte el decimal $0.408$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{52}{125}$', '$\frac{51}{126}$', '$\frac{51}{125}$', '$\frac{53}{125}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $0.408$ tiene tres cifras decimales, así que se escribe como $\frac{408}{1000}$. Al simplificar entre $8$ se obtiene $\frac{51}{125}$.',
      83
    ),
    (
      'Convierte el decimal $0.425$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{18}{40}$', '$\frac{17}{41}$', '$\frac{19}{40}$', '$\frac{17}{40}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $0.425$ tiene tres cifras decimales, así que se escribe como $\frac{425}{1000}$. Al simplificar entre $25$ se obtiene $\frac{17}{40}$.',
      84
    ),
    (
      'Convierte el decimal $0.456$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{57}{125}$', '$\frac{58}{125}$', '$\frac{57}{126}$', '$\frac{59}{125}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $0.456$ tiene tres cifras decimales, así que se escribe como $\frac{456}{1000}$. Al simplificar entre $8$ se obtiene $\frac{57}{125}$.',
      85
    ),
    (
      'Convierte el decimal $1.25$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{6}{4}$', '$\frac{5}{4}$', '$\frac{5}{5}$', '$\frac{7}{4}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $1.25$ tiene dos cifras decimales, así que se escribe como $\frac{125}{100}$. Al simplificar entre $25$ se obtiene $\frac{5}{4}$.',
      86
    ),
    (
      'Convierte el decimal $2.75$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{12}{4}$', '$\frac{11}{5}$', '$\frac{11}{4}$', '$\frac{13}{4}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $2.75$ tiene dos cifras decimales, así que se escribe como $\frac{275}{100}$. Al simplificar entre $25$ se obtiene $\frac{11}{4}$.',
      87
    ),
    (
      'Convierte el decimal $3.5$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{8}{2}$', '$\frac{7}{3}$', '$\frac{9}{2}$', '$\frac{7}{2}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $3.5$ tiene una cifra decimal, así que se escribe como $\frac{35}{10}$. Al simplificar entre $5$ se obtiene $\frac{7}{2}$.',
      88
    ),
    (
      'Convierte el decimal $4.25$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{17}{4}$', '$\frac{18}{4}$', '$\frac{17}{5}$', '$\frac{19}{4}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $4.25$ tiene dos cifras decimales, así que se escribe como $\frac{425}{100}$. Al simplificar entre $25$ se obtiene $\frac{17}{4}$.',
      89
    ),
    (
      'Convierte el decimal $5.75$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{24}{4}$', '$\frac{23}{4}$', '$\frac{23}{5}$', '$\frac{25}{4}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $5.75$ tiene dos cifras decimales, así que se escribe como $\frac{575}{100}$. Al simplificar entre $25$ se obtiene $\frac{23}{4}$.',
      90
    ),
    (
      'Convierte el decimal $6.5$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{14}{2}$', '$\frac{13}{3}$', '$\frac{13}{2}$', '$\frac{15}{2}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $6.5$ tiene una cifra decimal, así que se escribe como $\frac{65}{10}$. Al simplificar entre $5$ se obtiene $\frac{13}{2}$.',
      91
    ),
    (
      'Convierte el decimal $7.05$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{142}{20}$', '$\frac{141}{21}$', '$\frac{143}{20}$', '$\frac{141}{20}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $7.05$ tiene dos cifras decimales, así que se escribe como $\frac{705}{100}$. Al simplificar entre $5$ se obtiene $\frac{141}{20}$.',
      92
    ),
    (
      'Convierte el decimal $8.125$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{65}{8}$', '$\frac{66}{8}$', '$\frac{65}{9}$', '$\frac{67}{8}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $8.125$ tiene tres cifras decimales, así que se escribe como $\frac{8125}{1000}$. Al simplificar entre $125$ se obtiene $\frac{65}{8}$.',
      93
    ),
    (
      'Convierte el decimal $9.6$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{49}{5}$', '$\frac{48}{5}$', '$\frac{48}{6}$', '$\frac{50}{5}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $9.6$ tiene una cifra decimal, así que se escribe como $\frac{96}{10}$. Al simplificar entre $2$ se obtiene $\frac{48}{5}$.',
      94
    ),
    (
      'Convierte el decimal $10.75$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{44}{4}$', '$\frac{43}{5}$', '$\frac{43}{4}$', '$\frac{45}{4}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $10.75$ tiene dos cifras decimales, así que se escribe como $\frac{1075}{100}$. Al simplificar entre $25$ se obtiene $\frac{43}{4}$.',
      95
    ),
    (
      'Convierte el decimal $12.5$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{26}{2}$', '$\frac{25}{3}$', '$\frac{27}{2}$', '$\frac{25}{2}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $12.5$ tiene una cifra decimal, así que se escribe como $\frac{125}{10}$. Al simplificar entre $5$ se obtiene $\frac{25}{2}$.',
      96
    ),
    (
      'Convierte el decimal $15.25$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{61}{4}$', '$\frac{62}{4}$', '$\frac{61}{5}$', '$\frac{63}{4}$'),
      0,
      null::numeric,
      0.001::numeric,
      'El decimal $15.25$ tiene dos cifras decimales, así que se escribe como $\frac{1525}{100}$. Al simplificar entre $25$ se obtiene $\frac{61}{4}$.',
      97
    ),
    (
      'Convierte el decimal $20.8$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{105}{5}$', '$\frac{104}{5}$', '$\frac{104}{6}$', '$\frac{106}{5}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El decimal $20.8$ tiene una cifra decimal, así que se escribe como $\frac{208}{10}$. Al simplificar entre $2$ se obtiene $\frac{104}{5}$.',
      98
    ),
    (
      'Convierte el decimal $25.5$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{52}{2}$', '$\frac{51}{3}$', '$\frac{51}{2}$', '$\frac{53}{2}$'),
      2,
      null::numeric,
      0.001::numeric,
      'El decimal $25.5$ tiene una cifra decimal, así que se escribe como $\frac{255}{10}$. Al simplificar entre $5$ se obtiene $\frac{51}{2}$.',
      99
    ),
    (
      'Convierte el decimal $100.25$ a una fracción irreducible.',
      'multiple_choice',
      jsonb_build_array('$\frac{402}{4}$', '$\frac{401}{5}$', '$\frac{403}{4}$', '$\frac{401}{4}$'),
      3,
      null::numeric,
      0.001::numeric,
      'El decimal $100.25$ tiene dos cifras decimales, así que se escribe como $\frac{10025}{100}$. Al simplificar entre $25$ se obtiene $\frac{401}{4}$.',
      100
    )
) as v (
  prompt,
  type,
  options,
  correct_option,
  correct_answer,
  tolerance,
  explanation,
  order_index
)
cross join (
  select id from public.modules where slug = 'decimales-fracciones-100'
) as m
where not exists (
  select 1
  from public.exercises e
  where e.module_id = m.id
);
