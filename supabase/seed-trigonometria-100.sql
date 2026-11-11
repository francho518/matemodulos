-- ============================================================
--  Mate Dual Brucke · Trigonometría · 100 ejercicios
--
--  Requisitos:
--    1. Haber ejecutado schema.sql
--    2. Haber ejecutado migration-student-variants.sql
--       (o tener ya las columnas nuevas en public.modules)
--
--  Este archivo REEMPLAZA el banco anterior del módulo
--  'trigonometria-100'. Contiene:
--    - 1 ejercicio de teorema de Pitágoras.
--    - 99 aplicaciones con triángulos rectángulos.
--
--  Las respuestas son numéricas y los enunciados indican el redondeo:
--    - Longitudes: 2 decimales (tolerancia 0.01).
--    - Ángulos: 1 decimal (tolerancia 0.1).
--
--  ATENCIÓN: al eliminar los ejercicios anteriores se borran en cascada
--  los intentos y el progreso de los estudiantes en este módulo.
--
--  IMPORTANTE: con la visibilidad estricta por grupos, este módulo solo
--  lo verán los estudiantes de los grupos a los que se asigne.
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
  'Trigonometría · 100 ejercicios',
  'trigonometria-100',
  '100 ejercicios de aplicaciones con triángulos rectángulos: alturas, sombras, cables, distancias y ángulos. Incluye un ejercicio de Pitágoras.',
  4,
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

-- Limpia reasignaciones y relojes abiertos del módulo: si no se hace,
-- las rondas guardadas apuntarían a ejercicios que se eliminan a
-- continuación y los estudiantes quedarían con un reloj viejo.
do $$
declare
  v_module_id uuid;
begin
  select id into v_module_id
  from public.modules
  where slug = 'trigonometria-100';

  if v_module_id is null then
    return;
  end if;

  if to_regclass('public.module_rounds') is not null then
    delete from public.module_rounds where module_id = v_module_id;
  end if;

  if to_regclass('public.module_sessions') is not null then
    delete from public.module_sessions where module_id = v_module_id;
  end if;
end;
$$;

-- Reemplaza el banco anterior de este módulo.
delete from public.exercises
where module_id = (
  select id from public.modules where slug = 'trigonometria-100'
);

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
      'Una escalera de $13$ m se apoya en una pared. La base de la escalera está a $5$ m de la pared. ¿A qué altura de la pared llega la escalera? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.01::numeric,
      'La escalera forma un triángulo rectángulo con la pared y el suelo. Por Pitágoras: $h^2=13^2-5^2=144$, así que $h=12$ m.',
      1
    ),
    (
      'Desde un punto situado a $12$ m de la base de un árbol, el ángulo de elevación hasta su parte superior es $35^\circ$. ¿Cuál es la altura del árbol? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      8.4::numeric,
      0.01::numeric,
      '$\tan 35^\circ=\frac{h}{12}$, así que $h=12\cdot\tan 35^\circ\approx 8.40$ m.',
      2
    ),
    (
      'Desde un punto situado a $30$ m de la base de un edificio, el ángulo de elevación hasta su parte superior es $50^\circ$. ¿Cuál es la altura del edificio? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      35.75::numeric,
      0.01::numeric,
      '$\tan 50^\circ=\frac{h}{30}$, así que $h=30\cdot\tan 50^\circ\approx 35.75$ m.',
      3
    ),
    (
      'Desde un punto situado a $18$ m de la base de una torre, el ángulo de elevación hasta su parte superior es $60^\circ$. ¿Cuál es la altura de la torre? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      31.18::numeric,
      0.01::numeric,
      '$\tan 60^\circ=\frac{h}{18}$, así que $h=18\cdot\tan 60^\circ\approx 31.18$ m.',
      4
    ),
    (
      'Desde un punto situado a $15$ m de la base de un poste, el ángulo de elevación hasta su parte superior es $40^\circ$. ¿Cuál es la altura del poste? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      12.59::numeric,
      0.01::numeric,
      '$\tan 40^\circ=\frac{h}{15}$, así que $h=15\cdot\tan 40^\circ\approx 12.59$ m.',
      5
    ),
    (
      'Desde un punto situado a $25$ m de la base de un faro, el ángulo de elevación hasta su parte superior es $55^\circ$. ¿Cuál es la altura del faro? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      35.7::numeric,
      0.01::numeric,
      '$\tan 55^\circ=\frac{h}{25}$, así que $h=25\cdot\tan 55^\circ\approx 35.70$ m.',
      6
    ),
    (
      'Desde un punto situado a $22$ m de la base de un monumento, el ángulo de elevación hasta su parte superior es $48^\circ$. ¿Cuál es la altura del monumento? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      24.43::numeric,
      0.01::numeric,
      '$\tan 48^\circ=\frac{h}{22}$, así que $h=22\cdot\tan 48^\circ\approx 24.43$ m.',
      7
    ),
    (
      'Desde un punto situado a $9$ m de la base de una estatua, el ángulo de elevación hasta su parte superior es $52^\circ$. ¿Cuál es la altura de la estatua? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      11.52::numeric,
      0.01::numeric,
      '$\tan 52^\circ=\frac{h}{9}$, así que $h=9\cdot\tan 52^\circ\approx 11.52$ m.',
      8
    ),
    (
      'Desde un punto situado a $14$ m de la base de una antena, el ángulo de elevación hasta su parte superior es $63^\circ$. ¿Cuál es la altura de la antena? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      27.48::numeric,
      0.01::numeric,
      '$\tan 63^\circ=\frac{h}{14}$, así que $h=14\cdot\tan 63^\circ\approx 27.48$ m.',
      9
    ),
    (
      'Desde un punto situado a $20$ m de la base de un mástil, el ángulo de elevación hasta su parte superior es $42^\circ$. ¿Cuál es la altura del mástil? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      18.01::numeric,
      0.01::numeric,
      '$\tan 42^\circ=\frac{h}{20}$, así que $h=20\cdot\tan 42^\circ\approx 18.01$ m.',
      10
    ),
    (
      'Desde un punto situado a $16$ m de la base de una chimenea, el ángulo de elevación hasta su parte superior es $58^\circ$. ¿Cuál es la altura de la chimenea? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      25.61::numeric,
      0.01::numeric,
      '$\tan 58^\circ=\frac{h}{16}$, así que $h=16\cdot\tan 58^\circ\approx 25.61$ m.',
      11
    ),
    (
      'Desde un punto situado a $40$ m de la base de un castillo, el ángulo de elevación hasta su parte superior es $38^\circ$. ¿Cuál es la altura del castillo? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      31.25::numeric,
      0.01::numeric,
      '$\tan 38^\circ=\frac{h}{40}$, así que $h=40\cdot\tan 38^\circ\approx 31.25$ m.',
      12
    ),
    (
      'Desde un punto situado a $28$ m de la base de un templo, el ángulo de elevación hasta su parte superior es $47^\circ$. ¿Cuál es la altura del templo? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      30.03::numeric,
      0.01::numeric,
      '$\tan 47^\circ=\frac{h}{28}$, así que $h=28\cdot\tan 47^\circ\approx 30.03$ m.',
      13
    ),
    (
      'Desde un punto situado a $35$ m de la base de un puente, el ángulo de elevación hasta su parte superior es $33^\circ$. ¿Cuál es la altura del puente? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      22.73::numeric,
      0.01::numeric,
      '$\tan 33^\circ=\frac{h}{35}$, así que $h=35\cdot\tan 33^\circ\approx 22.73$ m.',
      14
    ),
    (
      'Desde un punto situado a $24$ m de la base de una grúa, el ángulo de elevación hasta su parte superior es $65^\circ$. ¿Cuál es la altura de la grúa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      51.47::numeric,
      0.01::numeric,
      '$\tan 65^\circ=\frac{h}{24}$, así que $h=24\cdot\tan 65^\circ\approx 51.47$ m.',
      15
    ),
    (
      'Desde un punto situado a $19$ m de la base de un silo, el ángulo de elevación hasta su parte superior es $44^\circ$. ¿Cuál es la altura del silo? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      18.35::numeric,
      0.01::numeric,
      '$\tan 44^\circ=\frac{h}{19}$, así que $h=19\cdot\tan 44^\circ\approx 18.35$ m.',
      16
    ),
    (
      'Desde un punto situado a $11$ m de la base de un tanque de agua, el ángulo de elevación hasta su parte superior es $61^\circ$. ¿Cuál es la altura del tanque de agua? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      19.84::numeric,
      0.01::numeric,
      '$\tan 61^\circ=\frac{h}{11}$, así que $h=11\cdot\tan 61^\circ\approx 19.84$ m.',
      17
    ),
    (
      'Desde un punto situado a $8$ m de la base de una columna, el ángulo de elevación hasta su parte superior es $54^\circ$. ¿Cuál es la altura de la columna? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      11.01::numeric,
      0.01::numeric,
      '$\tan 54^\circ=\frac{h}{8}$, así que $h=8\cdot\tan 54^\circ\approx 11.01$ m.',
      18
    ),
    (
      'Desde un punto situado a $26$ m de la base de un obelisco, el ángulo de elevación hasta su parte superior es $49^\circ$. ¿Cuál es la altura del obelisco? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      29.91::numeric,
      0.01::numeric,
      '$\tan 49^\circ=\frac{h}{26}$, así que $h=26\cdot\tan 49^\circ\approx 29.91$ m.',
      19
    ),
    (
      'Un árbol proyecta una sombra de $12$ m cuando el ángulo de elevación del sol es $35^\circ$. ¿Cuál es la altura del árbol? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      8.4::numeric,
      0.01::numeric,
      '$\tan 35^\circ=\frac{h}{12}$, así que $h=12\cdot\tan 35^\circ\approx 8.40$ m.',
      20
    ),
    (
      'Un poste proyecta una sombra de $15$ m cuando el ángulo de elevación del sol es $40^\circ$. ¿Cuál es la altura del poste? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      12.59::numeric,
      0.01::numeric,
      '$\tan 40^\circ=\frac{h}{15}$, así que $h=15\cdot\tan 40^\circ\approx 12.59$ m.',
      21
    ),
    (
      'Un edificio proyecta una sombra de $30$ m cuando el ángulo de elevación del sol es $50^\circ$. ¿Cuál es la altura del edificio? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      35.75::numeric,
      0.01::numeric,
      '$\tan 50^\circ=\frac{h}{30}$, así que $h=30\cdot\tan 50^\circ\approx 35.75$ m.',
      22
    ),
    (
      'Una torre proyecta una sombra de $18$ m cuando el ángulo de elevación del sol es $60^\circ$. ¿Cuál es la altura de la torre? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      31.18::numeric,
      0.01::numeric,
      '$\tan 60^\circ=\frac{h}{18}$, así que $h=18\cdot\tan 60^\circ\approx 31.18$ m.',
      23
    ),
    (
      'Una estatua proyecta una sombra de $9$ m cuando el ángulo de elevación del sol es $52^\circ$. ¿Cuál es la altura de la estatua? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      11.52::numeric,
      0.01::numeric,
      '$\tan 52^\circ=\frac{h}{9}$, así que $h=9\cdot\tan 52^\circ\approx 11.52$ m.',
      24
    ),
    (
      'Un faro proyecta una sombra de $25$ m cuando el ángulo de elevación del sol es $55^\circ$. ¿Cuál es la altura del faro? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      35.7::numeric,
      0.01::numeric,
      '$\tan 55^\circ=\frac{h}{25}$, así que $h=25\cdot\tan 55^\circ\approx 35.70$ m.',
      25
    ),
    (
      'Un mástil proyecta una sombra de $20$ m cuando el ángulo de elevación del sol es $42^\circ$. ¿Cuál es la altura del mástil? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      18.01::numeric,
      0.01::numeric,
      '$\tan 42^\circ=\frac{h}{20}$, así que $h=20\cdot\tan 42^\circ\approx 18.01$ m.',
      26
    ),
    (
      'Una antena proyecta una sombra de $14$ m cuando el ángulo de elevación del sol es $63^\circ$. ¿Cuál es la altura de la antena? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      27.48::numeric,
      0.01::numeric,
      '$\tan 63^\circ=\frac{h}{14}$, así que $h=14\cdot\tan 63^\circ\approx 27.48$ m.',
      27
    ),
    (
      'Un obelisco proyecta una sombra de $26$ m cuando el ángulo de elevación del sol es $49^\circ$. ¿Cuál es la altura del obelisco? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      29.91::numeric,
      0.01::numeric,
      '$\tan 49^\circ=\frac{h}{26}$, así que $h=26\cdot\tan 49^\circ\approx 29.91$ m.',
      28
    ),
    (
      'Una columna proyecta una sombra de $8$ m cuando el ángulo de elevación del sol es $54^\circ$. ¿Cuál es la altura de la columna? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      11.01::numeric,
      0.01::numeric,
      '$\tan 54^\circ=\frac{h}{8}$, así que $h=8\cdot\tan 54^\circ\approx 11.01$ m.',
      29
    ),
    (
      'Un cable sujeta un poste de $18$ m de altura y forma un ángulo de $65^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      19.86::numeric,
      0.01::numeric,
      '$\operatorname{sen}65^\circ=\frac{18}{L}$, así que $L=\frac{18}{\operatorname{sen}65^\circ}\approx 19.86$ m.',
      30
    ),
    (
      'Un cable sujeta una torre de $30$ m de altura y forma un ángulo de $55^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      36.62::numeric,
      0.01::numeric,
      '$\operatorname{sen}55^\circ=\frac{30}{L}$, así que $L=\frac{30}{\operatorname{sen}55^\circ}\approx 36.62$ m.',
      31
    ),
    (
      'Un cable sujeta una antena de $15$ m de altura y forma un ángulo de $50^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      19.58::numeric,
      0.01::numeric,
      '$\operatorname{sen}50^\circ=\frac{15}{L}$, así que $L=\frac{15}{\operatorname{sen}50^\circ}\approx 19.58$ m.',
      32
    ),
    (
      'Un cable sujeta un mástil de $22$ m de altura y forma un ángulo de $60^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      25.4::numeric,
      0.01::numeric,
      '$\operatorname{sen}60^\circ=\frac{22}{L}$, así que $L=\frac{22}{\operatorname{sen}60^\circ}\approx 25.40$ m.',
      33
    ),
    (
      'Un cable sujeta un faro de $40$ m de altura y forma un ángulo de $70^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      42.57::numeric,
      0.01::numeric,
      '$\operatorname{sen}70^\circ=\frac{40}{L}$, así que $L=\frac{40}{\operatorname{sen}70^\circ}\approx 42.57$ m.',
      34
    ),
    (
      'Un cable sujeta un edificio de $25$ m de altura y forma un ángulo de $45^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      35.36::numeric,
      0.01::numeric,
      '$\operatorname{sen}45^\circ=\frac{25}{L}$, así que $L=\frac{25}{\operatorname{sen}45^\circ}\approx 35.36$ m.',
      35
    ),
    (
      'Un cable sujeta una grúa de $35$ m de altura y forma un ángulo de $58^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      41.27::numeric,
      0.01::numeric,
      '$\operatorname{sen}58^\circ=\frac{35}{L}$, así que $L=\frac{35}{\operatorname{sen}58^\circ}\approx 41.27$ m.',
      36
    ),
    (
      'Un cable sujeta una columna de $12$ m de altura y forma un ángulo de $62^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      13.59::numeric,
      0.01::numeric,
      '$\operatorname{sen}62^\circ=\frac{12}{L}$, así que $L=\frac{12}{\operatorname{sen}62^\circ}\approx 13.59$ m.',
      37
    ),
    (
      'Un cable sujeta un poste de luz de $11$ m de altura y forma un ángulo de $67^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      11.95::numeric,
      0.01::numeric,
      '$\operatorname{sen}67^\circ=\frac{11}{L}$, así que $L=\frac{11}{\operatorname{sen}67^\circ}\approx 11.95$ m.',
      38
    ),
    (
      'Un cable sujeta un monumento de $28$ m de altura y forma un ángulo de $52^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      35.53::numeric,
      0.01::numeric,
      '$\operatorname{sen}52^\circ=\frac{28}{L}$, así que $L=\frac{28}{\operatorname{sen}52^\circ}\approx 35.53$ m.',
      39
    ),
    (
      'Un cable sujeta un silo de $20$ m de altura y forma un ángulo de $66^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      21.89::numeric,
      0.01::numeric,
      '$\operatorname{sen}66^\circ=\frac{20}{L}$, así que $L=\frac{20}{\operatorname{sen}66^\circ}\approx 21.89$ m.',
      40
    ),
    (
      'Un cable sujeta un tanque de agua de $14$ m de altura y forma un ángulo de $54^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      17.3::numeric,
      0.01::numeric,
      '$\operatorname{sen}54^\circ=\frac{14}{L}$, así que $L=\frac{14}{\operatorname{sen}54^\circ}\approx 17.30$ m.',
      41
    ),
    (
      'Un cable sujeta una chimenea de $32$ m de altura y forma un ángulo de $57^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      38.16::numeric,
      0.01::numeric,
      '$\operatorname{sen}57^\circ=\frac{32}{L}$, así que $L=\frac{32}{\operatorname{sen}57^\circ}\approx 38.16$ m.',
      42
    ),
    (
      'Un cable sujeta un obelisco de $26$ m de altura y forma un ángulo de $63^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      29.18::numeric,
      0.01::numeric,
      '$\operatorname{sen}63^\circ=\frac{26}{L}$, así que $L=\frac{26}{\operatorname{sen}63^\circ}\approx 29.18$ m.',
      43
    ),
    (
      'Un cable sujeta un árbol de $10$ m de altura y forma un ángulo de $42^\circ$ con el suelo. ¿Cuánto mide el cable? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      14.94::numeric,
      0.01::numeric,
      '$\operatorname{sen}42^\circ=\frac{10}{L}$, así que $L=\frac{10}{\operatorname{sen}42^\circ}\approx 14.94$ m.',
      44
    ),
    (
      'Desde un avión que vuela a $800$ m de altura, el ángulo de depresión hacia un punto en el suelo es $30^\circ$. ¿Cuál es la distancia horizontal entre el avión y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      1385.64::numeric,
      0.01::numeric,
      '$\tan 30^\circ=\frac{800}{d}$, así que $d=\frac{800}{\tan 30^\circ}\approx 1385.64$ m.',
      45
    ),
    (
      'Desde un dron que vuela a $90$ m de altura, el ángulo de depresión hacia un punto en el suelo es $40^\circ$. ¿Cuál es la distancia horizontal entre el dron y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      107.26::numeric,
      0.01::numeric,
      '$\tan 40^\circ=\frac{90}{d}$, así que $d=\frac{90}{\tan 40^\circ}\approx 107.26$ m.',
      46
    ),
    (
      'Desde un globo que vuela a $150$ m de altura, el ángulo de depresión hacia un punto en el suelo es $20^\circ$. ¿Cuál es la distancia horizontal entre el globo y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      412.12::numeric,
      0.01::numeric,
      '$\tan 20^\circ=\frac{150}{d}$, así que $d=\frac{150}{\tan 20^\circ}\approx 412.12$ m.',
      47
    ),
    (
      'Desde un helicóptero que vuela a $250$ m de altura, el ángulo de depresión hacia un punto en el suelo es $15^\circ$. ¿Cuál es la distancia horizontal entre el helicóptero y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      933.01::numeric,
      0.01::numeric,
      '$\tan 15^\circ=\frac{250}{d}$, así que $d=\frac{250}{\tan 15^\circ}\approx 933.01$ m.',
      48
    ),
    (
      'Desde una avioneta que vuela a $600$ m de altura, el ángulo de depresión hacia un punto en el suelo es $40^\circ$. ¿Cuál es la distancia horizontal entre la avioneta y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      715.05::numeric,
      0.01::numeric,
      '$\tan 40^\circ=\frac{600}{d}$, así que $d=\frac{600}{\tan 40^\circ}\approx 715.05$ m.',
      49
    ),
    (
      'Desde un parapente que vuela a $320$ m de altura, el ángulo de depresión hacia un punto en el suelo es $27^\circ$. ¿Cuál es la distancia horizontal entre el parapente y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      628.04::numeric,
      0.01::numeric,
      '$\tan 27^\circ=\frac{320}{d}$, así que $d=\frac{320}{\tan 27^\circ}\approx 628.04$ m.',
      50
    ),
    (
      'Desde un globo aerostático que vuela a $180$ m de altura, el ángulo de depresión hacia un punto en el suelo es $24^\circ$. ¿Cuál es la distancia horizontal entre el globo aerostático y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      404.29::numeric,
      0.01::numeric,
      '$\tan 24^\circ=\frac{180}{d}$, así que $d=\frac{180}{\tan 24^\circ}\approx 404.29$ m.',
      51
    ),
    (
      'Desde un avión de carga que vuela a $1000$ m de altura, el ángulo de depresión hacia un punto en el suelo es $35^\circ$. ¿Cuál es la distancia horizontal entre el avión de carga y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      1428.15::numeric,
      0.01::numeric,
      '$\tan 35^\circ=\frac{1000}{d}$, así que $d=\frac{1000}{\tan 35^\circ}\approx 1428.15$ m.',
      52
    ),
    (
      'Desde un dron de vigilancia que vuela a $120$ m de altura, el ángulo de depresión hacia un punto en el suelo es $32^\circ$. ¿Cuál es la distancia horizontal entre el dron de vigilancia y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      192.04::numeric,
      0.01::numeric,
      '$\tan 32^\circ=\frac{120}{d}$, así que $d=\frac{120}{\tan 32^\circ}\approx 192.04$ m.',
      53
    ),
    (
      'Desde un helicóptero de rescate que vuela a $300$ m de altura, el ángulo de depresión hacia un punto en el suelo es $22^\circ$. ¿Cuál es la distancia horizontal entre el helicóptero de rescate y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      742.53::numeric,
      0.01::numeric,
      '$\tan 22^\circ=\frac{300}{d}$, así que $d=\frac{300}{\tan 22^\circ}\approx 742.53$ m.',
      54
    ),
    (
      'Desde una avioneta de turismo que vuela a $450$ m de altura, el ángulo de depresión hacia un punto en el suelo es $28^\circ$. ¿Cuál es la distancia horizontal entre la avioneta de turismo y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      846.33::numeric,
      0.01::numeric,
      '$\tan 28^\circ=\frac{450}{d}$, así que $d=\frac{450}{\tan 28^\circ}\approx 846.33$ m.',
      55
    ),
    (
      'Desde un globo de observación que vuela a $220$ m de altura, el ángulo de depresión hacia un punto en el suelo es $18^\circ$. ¿Cuál es la distancia horizontal entre el globo de observación y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      677.09::numeric,
      0.01::numeric,
      '$\tan 18^\circ=\frac{220}{d}$, así que $d=\frac{220}{\tan 18^\circ}\approx 677.09$ m.',
      56
    ),
    (
      'Desde un planeador que vuela a $380$ m de altura, el ángulo de depresión hacia un punto en el suelo es $26^\circ$. ¿Cuál es la distancia horizontal entre el planeador y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      779.12::numeric,
      0.01::numeric,
      '$\tan 26^\circ=\frac{380}{d}$, así que $d=\frac{380}{\tan 26^\circ}\approx 779.12$ m.',
      57
    ),
    (
      'Desde un dirigible que vuela a $260$ m de altura, el ángulo de depresión hacia un punto en el suelo es $21^\circ$. ¿Cuál es la distancia horizontal entre el dirigible y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      677.32::numeric,
      0.01::numeric,
      '$\tan 21^\circ=\frac{260}{d}$, así que $d=\frac{260}{\tan 21^\circ}\approx 677.32$ m.',
      58
    ),
    (
      'Desde un dron agrícola que vuela a $75$ m de altura, el ángulo de depresión hacia un punto en el suelo es $38^\circ$. ¿Cuál es la distancia horizontal entre el dron agrícola y ese punto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      96::numeric,
      0.01::numeric,
      '$\tan 38^\circ=\frac{75}{d}$, así que $d=\frac{75}{\tan 38^\circ}\approx 96.00$ m.',
      59
    ),
    (
      'Una rampa sube $2$ m en una distancia horizontal de $8$ m. ¿Qué ángulo forma con la horizontal? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      14::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{2}{8}\approx 0.2500$, así que $\theta=\arctan(0.2500)\approx 14.0^\circ$.',
      60
    ),
    (
      'Una carretera sube $150$ m en una distancia horizontal de $1000$ m. ¿Qué ángulo forma con la horizontal? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      8.5::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{150}{1000}\approx 0.1500$, así que $\theta=\arctan(0.1500)\approx 8.5^\circ$.',
      61
    ),
    (
      'Un camino sube $40$ m en una distancia horizontal de $300$ m. ¿Qué ángulo forma con la horizontal? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      7.6::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{40}{300}\approx 0.1333$, así que $\theta=\arctan(0.1333)\approx 7.6^\circ$.',
      62
    ),
    (
      'Una cuesta sube $75$ m en una distancia horizontal de $600$ m. ¿Qué ángulo forma con la horizontal? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      7.1::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{75}{600}\approx 0.1250$, así que $\theta=\arctan(0.1250)\approx 7.1^\circ$.',
      63
    ),
    (
      'Una pista sube $20$ m en una distancia horizontal de $250$ m. ¿Qué ángulo forma con la horizontal? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      4.6::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{20}{250}\approx 0.0800$, así que $\theta=\arctan(0.0800)\approx 4.6^\circ$.',
      64
    ),
    (
      'Una pendiente sube $12$ m en una distancia horizontal de $90$ m. ¿Qué ángulo forma con la horizontal? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      7.6::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{12}{90}\approx 0.1333$, así que $\theta=\arctan(0.1333)\approx 7.6^\circ$.',
      65
    ),
    (
      'Una escalera de $6$ m alcanza una altura de $4.5$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      48.6::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{4.5}{6}\approx 0.7500$, así que $\theta=\arcsin(0.7500)\approx 48.6^\circ$.',
      66
    ),
    (
      'Un cable de $20$ m alcanza una altura de $18$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      64.2::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{18}{20}\approx 0.9000$, así que $\theta=\arcsin(0.9000)\approx 64.2^\circ$.',
      67
    ),
    (
      'Una rampa de $12$ m alcanza una altura de $3$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      14.5::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{3}{12}\approx 0.2500$, así que $\theta=\arcsin(0.2500)\approx 14.5^\circ$.',
      68
    ),
    (
      'Un teleférico de $100$ m alcanza una altura de $65$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      40.5::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{65}{100}\approx 0.6500$, así que $\theta=\arcsin(0.6500)\approx 40.5^\circ$.',
      69
    ),
    (
      'Una tirolesa de $80$ m alcanza una altura de $25$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      18.2::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{25}{80}\approx 0.3125$, así que $\theta=\arcsin(0.3125)\approx 18.2^\circ$.',
      70
    ),
    (
      'Una cuerda de $50$ m alcanza una altura de $35$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      44.4::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{35}{50}\approx 0.7000$, así que $\theta=\arcsin(0.7000)\approx 44.4^\circ$.',
      71
    ),
    (
      'Una escalera de $15$ m alcanza una altura de $12$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      53.1::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{12}{15}\approx 0.8000$, así que $\theta=\arcsin(0.8000)\approx 53.1^\circ$.',
      72
    ),
    (
      'Una escalera de $10$ m se apoya en una pared y su base está a $6$ m de la pared. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      53.1::numeric,
      0.1::numeric,
      '$\cos\theta=\frac{6}{10}\approx 0.6000$, así que $\theta=\arccos(0.6000)\approx 53.1^\circ$.',
      73
    ),
    (
      'Un cable de $50$ m va desde lo alto de una torre hasta un punto a $38$ m de la base. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      40.5::numeric,
      0.1::numeric,
      '$\cos\theta=\frac{38}{50}\approx 0.7600$, así que $\theta=\arccos(0.7600)\approx 40.5^\circ$.',
      74
    ),
    (
      'Una rampa de $30$ m de longitud cubre una distancia horizontal de $27$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      25.8::numeric,
      0.1::numeric,
      '$\cos\theta=\frac{27}{30}\approx 0.9000$, así que $\theta=\arccos(0.9000)\approx 25.8^\circ$.',
      75
    ),
    (
      'Una cuerda de $45$ m sujeta una cometa y la distancia horizontal desde el anclaje hasta la cometa es $30$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      48.2::numeric,
      0.1::numeric,
      '$\cos\theta=\frac{30}{45}\approx 0.6667$, así que $\theta=\arccos(0.6667)\approx 48.2^\circ$.',
      76
    ),
    (
      'Una escalera de $8$ m se apoya en una pared y su base está a $5$ m de la pared. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      51.3::numeric,
      0.1::numeric,
      '$\cos\theta=\frac{5}{8}\approx 0.6250$, así que $\theta=\arccos(0.6250)\approx 51.3^\circ$.',
      77
    ),
    (
      'Un cable de $60$ m va desde lo alto de un poste hasta un punto a $45$ m de la base. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      41.4::numeric,
      0.1::numeric,
      '$\cos\theta=\frac{45}{60}\approx 0.7500$, así que $\theta=\arccos(0.7500)\approx 41.4^\circ$.',
      78
    ),
    (
      'Una rampa de $25$ m de longitud cubre una distancia horizontal de $21$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      32.9::numeric,
      0.1::numeric,
      '$\cos\theta=\frac{21}{25}\approx 0.8400$, así que $\theta=\arccos(0.8400)\approx 32.9^\circ$.',
      79
    ),
    (
      'Una rampa de $12$ m de longitud forma un ángulo de $15^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      3.11::numeric,
      0.01::numeric,
      '$\operatorname{sen}15^\circ=\frac{h}{12}$, así que $h=12\cdot\operatorname{sen}15^\circ\approx 3.11$ m.',
      80
    ),
    (
      'Una carretera de $500$ m de longitud forma un ángulo de $8^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      69.59::numeric,
      0.01::numeric,
      '$\operatorname{sen}8^\circ=\frac{h}{500}$, así que $h=500\cdot\operatorname{sen}8^\circ\approx 69.59$ m.',
      81
    ),
    (
      'Un camino de $80$ m de longitud forma un ángulo de $12^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      16.63::numeric,
      0.01::numeric,
      '$\operatorname{sen}12^\circ=\frac{h}{80}$, así que $h=80\cdot\operatorname{sen}12^\circ\approx 16.63$ m.',
      82
    ),
    (
      'Una escalera mecánica de $25$ m de longitud forma un ángulo de $30^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      12.5::numeric,
      0.01::numeric,
      '$\operatorname{sen}30^\circ=\frac{h}{25}$, así que $h=25\cdot\operatorname{sen}30^\circ\approx 12.50$ m.',
      83
    ),
    (
      'Una pista de $300$ m de longitud forma un ángulo de $6^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      31.36::numeric,
      0.01::numeric,
      '$\operatorname{sen}6^\circ=\frac{h}{300}$, así que $h=300\cdot\operatorname{sen}6^\circ\approx 31.36$ m.',
      84
    ),
    (
      'Una cuesta de $150$ m de longitud forma un ángulo de $10^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      26.05::numeric,
      0.01::numeric,
      '$\operatorname{sen}10^\circ=\frac{h}{150}$, así que $h=150\cdot\operatorname{sen}10^\circ\approx 26.05$ m.',
      85
    ),
    (
      'Una rampa de $20$ m de longitud forma un ángulo de $18^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      6.18::numeric,
      0.01::numeric,
      '$\operatorname{sen}18^\circ=\frac{h}{20}$, así que $h=20\cdot\operatorname{sen}18^\circ\approx 6.18$ m.',
      86
    ),
    (
      'Una carretera de $1200$ m de longitud forma un ángulo de $5^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      104.59::numeric,
      0.01::numeric,
      '$\operatorname{sen}5^\circ=\frac{h}{1200}$, así que $h=1200\cdot\operatorname{sen}5^\circ\approx 104.59$ m.',
      87
    ),
    (
      'Un camino de $60$ m de longitud forma un ángulo de $14^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      14.52::numeric,
      0.01::numeric,
      '$\operatorname{sen}14^\circ=\frac{h}{60}$, así que $h=60\cdot\operatorname{sen}14^\circ\approx 14.52$ m.',
      88
    ),
    (
      'Una rampa de $8$ m de longitud forma un ángulo de $20^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      2.74::numeric,
      0.01::numeric,
      '$\operatorname{sen}20^\circ=\frac{h}{8}$, así que $h=8\cdot\operatorname{sen}20^\circ\approx 2.74$ m.',
      89
    ),
    (
      'Una carretera de $900$ m de longitud forma un ángulo de $7^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      109.68::numeric,
      0.01::numeric,
      '$\operatorname{sen}7^\circ=\frac{h}{900}$, así que $h=900\cdot\operatorname{sen}7^\circ\approx 109.68$ m.',
      90
    ),
    (
      'Una cuesta de $250$ m de longitud forma un ángulo de $11^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      47.7::numeric,
      0.01::numeric,
      '$\operatorname{sen}11^\circ=\frac{h}{250}$, así que $h=250\cdot\operatorname{sen}11^\circ\approx 47.70$ m.',
      91
    ),
    (
      'Para medir el ancho de un río, una persona camina $30$ m a lo largo de una orilla y observa un punto de la otra orilla con un ángulo de $60^\circ$ respecto a la orilla. ¿Cuál es el ancho del río? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      51.96::numeric,
      0.01::numeric,
      '$\tan 60^\circ=\frac{a}{30}$, así que $a=30\cdot\tan 60^\circ\approx 51.96$ m.',
      92
    ),
    (
      'El ángulo de elevación de una nube es $30^\circ$ desde un punto situado a $200$ m de su proyección sobre el suelo. ¿A qué altura está la nube? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      115.47::numeric,
      0.01::numeric,
      '$\tan 30^\circ=\frac{h}{200}$, así que $h=200\cdot\tan 30^\circ\approx 115.47$ m.',
      93
    ),
    (
      'Desde un faro de $100$ m de altura, el ángulo de depresión hacia un barco es $20^\circ$. ¿A qué distancia de la base del faro está el barco? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      274.75::numeric,
      0.01::numeric,
      '$\tan 20^\circ=\frac{100}{d}$, así que $d=\frac{100}{\tan 20^\circ}\approx 274.75$ m.',
      94
    ),
    (
      'Un globo está sujeto por una cuerda de $80$ m que forma un ángulo de $55^\circ$ con el suelo. ¿A qué altura está el globo? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      65.53::numeric,
      0.01::numeric,
      '$\operatorname{sen}55^\circ=\frac{h}{80}$, así que $h=80\cdot\operatorname{sen}55^\circ\approx 65.53$ m.',
      95
    ),
    (
      'Un edificio de $18$ m de altura proyecta una sombra cuando el sol tiene una elevación de $60^\circ$. ¿Cuánto mide la sombra? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      10.39::numeric,
      0.01::numeric,
      '$\tan 60^\circ=\frac{18}{s}$, así que $s=\frac{18}{\tan 60^\circ}\approx 10.39$ m.',
      96
    ),
    (
      'Una cometa está sujeta por una cuerda de $60$ m que forma un ángulo de $35^\circ$ con el suelo. ¿A qué distancia horizontal del anclaje está la cometa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      49.15::numeric,
      0.01::numeric,
      '$\cos 35^\circ=\frac{d}{60}$, así que $d=60\cdot\cos 35^\circ\approx 49.15$ m.',
      97
    ),
    (
      'Un árbol proyecta una sombra de $14$ m cuando el sol tiene una elevación de $48^\circ$. ¿Cuánto mide el árbol? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      15.55::numeric,
      0.01::numeric,
      '$\tan 48^\circ=\frac{h}{14}$, así que $h=14\cdot\tan 48^\circ\approx 15.55$ m.',
      98
    ),
    (
      'Una rampa debe salvar una altura de $2.5$ m con un ángulo de $9^\circ$. ¿Cuánto mide la rampa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      15.98::numeric,
      0.01::numeric,
      '$\operatorname{sen}9^\circ=\frac{2.5}{L}$, así que $L=\frac{2.5}{\operatorname{sen}9^\circ}\approx 15.98$ m.',
      99
    ),
    (
      'Un avión vuela a $700$ m de altura y el ángulo de depresión hacia el aeropuerto es $25^\circ$. ¿Cuál es la distancia horizontal entre el avión y el aeropuerto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      1501.15::numeric,
      0.01::numeric,
      '$\tan 25^\circ=\frac{700}{d}$, así que $d=\frac{700}{\tan 25^\circ}\approx 1501.15$ m.',
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
  select id from public.modules where slug = 'trigonometria-100'
) as m;
