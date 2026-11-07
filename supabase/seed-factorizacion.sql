-- ============================================================
--  Matemódulos · Módulo de Factorización
--
--  Requisitos:
--    1. Haber ejecutado schema.sql
--    2. Haber ejecutado migration-student-variants.sql
--       (o tener ya las columnas nuevas en public.modules)
--
--  Este módulo tiene 14 ejercicios y entrega 6 distintos a cada
--  estudiante. La selección es estable: el mismo alumno ve siempre
--  la misma combinación, pero distinta a la de los demás.
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
  'Factorización',
  'factorizacion',
  'Factor común, diferencia de cuadrados, trinomios, cubos y agrupación.',
  2,
  true,
  true,
  6
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
      'Factoriza $6x^2 + 9x$.',
      'multiple_choice',
      '["$3x(2x + 3)$", "$3(2x^2 + 3x)$", "$x(6x + 9)$", "$3x(2x + 9)$"]'::jsonb,
      0,
      null::numeric,
      0.000001::numeric,
      'El factor común es $3x$: $6x^2 + 9x = 3x(2x + 3)$.',
      1
    ),
    (
      'Factoriza $x^2 - 16$.',
      'multiple_choice',
      '["$(x - 4)(x + 4)$", "$(x - 8)(x + 2)$", "$(x - 4)^2$", "$(x + 4)^2$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Es una diferencia de cuadrados: $x^2 - 4^2 = (x - 4)(x + 4)$.',
      2
    ),
    (
      'Factoriza $x^2 + 10x + 25$.',
      'multiple_choice',
      '["$(x + 5)^2$", "$(x + 5)(x - 5)$", "$(x + 25)(x + 1)$", "$(x + 10)(x + 1)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Es un trinomio cuadrado perfecto: $x^2 + 2 \cdot 5x + 5^2 = (x + 5)^2$.',
      3
    ),
    (
      'Factoriza $x^2 - 7x + 12$.',
      'multiple_choice',
      '["$(x - 3)(x - 4)$", "$(x + 3)(x + 4)$", "$(x - 6)(x - 2)$", "$(x - 12)(x + 1)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Buscamos dos números que multipliquen $12$ y sumen $-7$: $-3$ y $-4$. Por eso, $(x - 3)(x - 4)$.',
      4
    ),
    (
      'Factoriza $9x^2 - 25$.',
      'multiple_choice',
      '["$(3x - 5)(3x + 5)$", "$(9x - 5)(x + 5)$", "$(3x - 5)^2$", "$(3x + 5)^2$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Diferencia de cuadrados: $9x^2 - 25 = (3x)^2 - 5^2 = (3x - 5)(3x + 5)$.',
      5
    ),
    (
      'Factoriza por agrupación $x^3 + 2x^2 + 3x + 6$.',
      'multiple_choice',
      '["$(x + 2)(x^2 + 3)$", "$(x + 3)(x^2 + 2)$", "$(x + 2)(x^2 + 6)$", "$(x + 6)(x^2 + 1)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Agrupamos: $x^2(x + 2) + 3(x + 2) = (x + 2)(x^2 + 3)$.',
      6
    ),
    (
      'Factoriza $4x^2 - 12x + 9$.',
      'multiple_choice',
      '["$(2x - 3)^2$", "$(2x + 3)^2$", "$(4x - 3)(x - 3)$", "$(2x - 9)(2x - 1)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Es un trinomio cuadrado perfecto: $(2x)^2 - 2 \cdot 2x \cdot 3 + 3^2 = (2x - 3)^2$.',
      7
    ),
    (
      'Factoriza $x^3 + 8$.',
      'multiple_choice',
      '["$(x + 2)(x^2 - 2x + 4)$", "$(x + 2)(x^2 + 2x + 4)$", "$(x - 2)(x^2 + 2x + 4)$", "$(x + 8)(x^2 - 8x + 64)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Suma de cubos: $a^3 + b^3 = (a + b)(a^2 - ab + b^2)$, con $a = x$ y $b = 2$.',
      8
    ),
    (
      'Factoriza $x^3 - 27$.',
      'multiple_choice',
      '["$(x - 3)(x^2 + 3x + 9)$", "$(x - 3)(x^2 - 3x + 9)$", "$(x + 3)(x^2 - 3x + 9)$", "$(x - 27)(x^2 + 27x + 729)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Diferencia de cubos: $a^3 - b^3 = (a - b)(a^2 + ab + b^2)$, con $a = x$ y $b = 3$.',
      9
    ),
    (
      'Factoriza $2x^2 + 7x + 3$.',
      'multiple_choice',
      '["$(2x + 1)(x + 3)$", "$(2x + 3)(x + 1)$", "$(2x - 1)(x - 3)$", "$(2x + 7)(x + 3)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Reescribimos $7x = 6x + x$: $2x^2 + 6x + x + 3 = 2x(x + 3) + 1(x + 3) = (2x + 1)(x + 3)$.',
      10
    ),
    (
      'Factoriza $5a^2b - 15ab^2$.',
      'multiple_choice',
      '["$5ab(a - 3b)$", "$5ab(a - 15b)$", "$5a(ab - 3b^2)$", "$ab(5a - 15b)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'El factor común es $5ab$: $5a^2b - 15ab^2 = 5ab(a - 3b)$.',
      11
    ),
    (
      'Factoriza $x^2 - 2x - 15$.',
      'multiple_choice',
      '["$(x - 5)(x + 3)$", "$(x + 5)(x - 3)$", "$(x - 15)(x + 1)$", "$(x - 5)(x - 3)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Buscamos dos números que multipliquen $-15$ y sumen $-2$: $-5$ y $3$. Entonces, $(x - 5)(x + 3)$.',
      12
    ),
    (
      '¿Cuál es la mayor raíz de $x^2 + 2x - 8 = 0$?',
      'numeric',
      null::jsonb,
      null::integer,
      2,
      0.000001,
      'Factorizamos: $(x + 4)(x - 2) = 0$. Las raíces son $-4$ y $2$; la mayor es $2$.',
      13
    ),
    (
      'Escribe la raíz positiva de $x^2 - 9 = 0$.',
      'numeric',
      null::jsonb,
      null::integer,
      3,
      0.000001,
      'Diferencia de cuadrados: $(x - 3)(x + 3) = 0$. Las raíces son $3$ y $-3$; la positiva es $3$.',
      14
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
  select id from public.modules where slug = 'factorizacion'
) as m
where not exists (
  select 1
  from public.exercises e
  where e.module_id = m.id
);
