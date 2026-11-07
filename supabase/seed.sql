-- ============================================================
--  Matemódulos · Datos de ejemplo
--  Ejecutar DESPUÉS de schema.sql
-- ============================================================

insert into public.modules (title, slug, description, order_index, is_published)
values (
  'Álgebra básica',
  'algebra-basica',
  'Ecuaciones lineales, ecuaciones cuadráticas y factorización.',
  1,
  true
)
on conflict (slug) do update
set title = excluded.title,
    description = excluded.description,
    order_index = excluded.order_index;

-- Agrega los ejercicios solo si el módulo todavía no tiene ninguno.
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
      'Resuelve $2x + 5 = 13$.',
      'multiple_choice',
      '["$3$", "$4$", "$5$", "$9$"]'::jsonb,
      1,
      null::numeric,
      0.000001::numeric,
      'Restamos 5 en ambos lados: $2x = 8$. Luego dividimos entre 2: $x = 4$.',
      1
    ),
    (
      'Escribe la mayor solución de $x^2 - 5x + 6 = 0$.',
      'numeric',
      null::jsonb,
      null::integer,
      3,
      0.000001,
      'Factorizamos: $(x - 2)(x - 3) = 0$. Las soluciones son 2 y 3; la mayor es 3.',
      2
    ),
    (
      '¿Cuál es la factorización de $x^2 - 9$?',
      'multiple_choice',
      '["$(x - 3)(x + 3)$", "$(x - 9)(x + 1)$", "$(x - 3)^2$", "$(x + 9)(x - 9)$"]'::jsonb,
      0,
      null::numeric,
      0.000001,
      'Es una diferencia de cuadrados: $a^2 - b^2 = (a - b)(a + b)$, con $a = x$ y $b = 3$.',
      3
    ),
    (
      'Resuelve $3x - 7 = 2x + 5$.',
      'numeric',
      null::jsonb,
      null::integer,
      12,
      0.000001,
      'Pasamos las $x$ a un lado: $3x - 2x = 5 + 7$. Por tanto, $x = 12$.',
      4
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
  select id from public.modules where slug = 'algebra-basica'
) as m
where not exists (
  select 1
  from public.exercises e
  where e.module_id = m.id
);
