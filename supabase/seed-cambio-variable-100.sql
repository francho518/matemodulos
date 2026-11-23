-- ============================================================
--  Matemódulos · Integrales por cambio de variable · 100 ejercicios
--
--  Requisitos:
--    1. Haber ejecutado schema.sql
--    2. Haber ejecutado migration-student-variants.sql
--
--  100 ejercicios con respuesta numérica. El módulo entrega
--  el banco completo a cada estudiante (randomize_exercises =
--  false y exercises_per_student = 0).
--
--  IMPORTANTE: asígnalo a un grupo en Administración → Grupos
--  para que los estudiantes puedan verlo.
-- ============================================================

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
  'Integrales por cambio de variable · 100 ejercicios',
  'cambio-variable-100',
  '100 integrales que se resuelven con una sustitución u = g(x): potencias, raíces y funciones racionales, con respuesta numérica.',
  9,
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
      'Calcula $\int_{0}^{1} 2x(x^2+6)^{3}\,dx$ usando el cambio de variable $u=x^2+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      276.25::numeric,
      0.001::numeric,
      'Con $u=x^2+6$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+6)^{3}\,dx=\left[\frac{(x^2+6)^{4}}{4}\right]_{0}^{1}=\frac{1105}{4} \approx 276.25$.',
      1
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+3)^{2}\,dx$ usando el cambio de variable $u=x^2+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      12.3333::numeric,
      0.001::numeric,
      'Con $u=x^2+3$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+3)^{2}\,dx=\left[\frac{(x^2+3)^{3}}{3}\right]_{0}^{1}=\frac{37}{3} \approx 12.3333$.',
      2
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+1)^{3}\,dx$ usando el cambio de variable $u=x^2+1$.',
      'numeric',
      null::jsonb,
      null::integer,
      3.75::numeric,
      0.001::numeric,
      'Con $u=x^2+1$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+1)^{3}\,dx=\left[\frac{(x^2+1)^{4}}{4}\right]_{0}^{1}=\frac{15}{4} \approx 3.75$.',
      3
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+3)^{4}\,dx$ usando el cambio de variable $u=x^2+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      156.2::numeric,
      0.001::numeric,
      'Con $u=x^2+3$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+3)^{4}\,dx=\left[\frac{(x^2+3)^{5}}{5}\right]_{0}^{1}=\frac{781}{5} \approx 156.2$.',
      4
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+2)^{4}\,dx$ usando el cambio de variable $u=x^2+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      42.2::numeric,
      0.001::numeric,
      'Con $u=x^2+2$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+2)^{4}\,dx=\left[\frac{(x^2+2)^{5}}{5}\right]_{0}^{1}=\frac{211}{5} \approx 42.2$.',
      5
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+3)^{3}\,dx$ usando el cambio de variable $u=x^2+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      43.75::numeric,
      0.001::numeric,
      'Con $u=x^2+3$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+3)^{3}\,dx=\left[\frac{(x^2+3)^{4}}{4}\right]_{0}^{1}=\frac{175}{4} \approx 43.75$.',
      6
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+2)^{3}\,dx$ usando el cambio de variable $u=x^2+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      16.25::numeric,
      0.001::numeric,
      'Con $u=x^2+2$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+2)^{3}\,dx=\left[\frac{(x^2+2)^{4}}{4}\right]_{0}^{1}=\frac{65}{4} \approx 16.25$.',
      7
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+6)^{4}\,dx$ usando el cambio de variable $u=x^2+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      1806.2::numeric,
      0.001::numeric,
      'Con $u=x^2+6$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+6)^{4}\,dx=\left[\frac{(x^2+6)^{5}}{5}\right]_{0}^{1}=\frac{9031}{5} \approx 1806.2$.',
      8
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+4)^{3}\,dx$ usando el cambio de variable $u=x^2+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      92.25::numeric,
      0.001::numeric,
      'Con $u=x^2+4$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+4)^{3}\,dx=\left[\frac{(x^2+4)^{4}}{4}\right]_{0}^{1}=\frac{369}{4} \approx 92.25$.',
      9
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+2)^{2}\,dx$ usando el cambio de variable $u=x^2+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      6.3333::numeric,
      0.001::numeric,
      'Con $u=x^2+2$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+2)^{2}\,dx=\left[\frac{(x^2+2)^{3}}{3}\right]_{0}^{1}=\frac{19}{3} \approx 6.3333$.',
      10
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+1)^{4}\,dx$ usando el cambio de variable $u=x^2+1$.',
      'numeric',
      null::jsonb,
      null::integer,
      6.2::numeric,
      0.001::numeric,
      'Con $u=x^2+1$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+1)^{4}\,dx=\left[\frac{(x^2+1)^{5}}{5}\right]_{0}^{1}=\frac{31}{5} \approx 6.2$.',
      11
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+4)^{2}\,dx$ usando el cambio de variable $u=x^2+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      20.3333::numeric,
      0.001::numeric,
      'Con $u=x^2+4$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+4)^{2}\,dx=\left[\frac{(x^2+4)^{3}}{3}\right]_{0}^{1}=\frac{61}{3} \approx 20.3333$.',
      12
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+4)\,dx$ usando el cambio de variable $u=x^2+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      4.5::numeric,
      0.001::numeric,
      'Con $u=x^2+4$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+4)\,dx=\left[\frac{(x^2+4)^{2}}{2}\right]_{0}^{1}=\frac{9}{2} \approx 4.5$.',
      13
    ),
    (
      'Calcula $\int_{0}^{1} 2x(x^2+5)^{4}\,dx$ usando el cambio de variable $u=x^2+5$.',
      'numeric',
      null::jsonb,
      null::integer,
      930.2::numeric,
      0.001::numeric,
      'Con $u=x^2+5$, $du=2x\,dx$. Entonces $\int_{0}^{1} 2x(x^2+5)^{4}\,dx=\left[\frac{(x^2+5)^{5}}{5}\right]_{0}^{1}=\frac{4651}{5} \approx 930.2$.',
      14
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+3)^{4}\,dx$ con el cambio $u=x^2+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      78.1::numeric,
      0.001::numeric,
      'Con $u=x^2+3$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+3)^{5}}{2\cdot 5}\right]_{0}^{1}=\frac{781}{10} \approx 78.1$.',
      15
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+8)^{2}\,dx$ con el cambio $u=x^2+8$.',
      'numeric',
      null::jsonb,
      null::integer,
      36.1667::numeric,
      0.001::numeric,
      'Con $u=x^2+8$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+8)^{3}}{2\cdot 3}\right]_{0}^{1}=\frac{217}{6} \approx 36.1667$.',
      16
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+3)^{3}\,dx$ con el cambio $u=x^2+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      21.875::numeric,
      0.001::numeric,
      'Con $u=x^2+3$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+3)^{4}}{2\cdot 4}\right]_{0}^{1}=\frac{175}{8} \approx 21.875$.',
      17
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+1)^{2}\,dx$ con el cambio $u=x^2+1$.',
      'numeric',
      null::jsonb,
      null::integer,
      1.1667::numeric,
      0.001::numeric,
      'Con $u=x^2+1$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+1)^{3}}{2\cdot 3}\right]_{0}^{1}=\frac{7}{6} \approx 1.1667$.',
      18
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+4)^{4}\,dx$ con el cambio $u=x^2+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      210.1::numeric,
      0.001::numeric,
      'Con $u=x^2+4$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+4)^{5}}{2\cdot 5}\right]_{0}^{1}=\frac{2101}{10} \approx 210.1$.',
      19
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+6)\,dx$ con el cambio $u=x^2+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      3.25::numeric,
      0.001::numeric,
      'Con $u=x^2+6$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+6)^{2}}{2\cdot 2}\right]_{0}^{1}=\frac{13}{4} \approx 3.25$.',
      20
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+8)\,dx$ con el cambio $u=x^2+8$.',
      'numeric',
      null::jsonb,
      null::integer,
      4.25::numeric,
      0.001::numeric,
      'Con $u=x^2+8$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+8)^{2}}{2\cdot 2}\right]_{0}^{1}=\frac{17}{4} \approx 4.25$.',
      21
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+4)\,dx$ con el cambio $u=x^2+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      2.25::numeric,
      0.001::numeric,
      'Con $u=x^2+4$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+4)^{2}}{2\cdot 2}\right]_{0}^{1}=\frac{9}{4} \approx 2.25$.',
      22
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+2)^{3}\,dx$ con el cambio $u=x^2+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      8.125::numeric,
      0.001::numeric,
      'Con $u=x^2+2$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+2)^{4}}{2\cdot 4}\right]_{0}^{1}=\frac{65}{8} \approx 8.125$.',
      23
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+5)^{2}\,dx$ con el cambio $u=x^2+5$.',
      'numeric',
      null::jsonb,
      null::integer,
      15.1667::numeric,
      0.001::numeric,
      'Con $u=x^2+5$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+5)^{3}}{2\cdot 3}\right]_{0}^{1}=\frac{91}{6} \approx 15.1667$.',
      24
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+7)^{3}\,dx$ con el cambio $u=x^2+7$.',
      'numeric',
      null::jsonb,
      null::integer,
      211.875::numeric,
      0.001::numeric,
      'Con $u=x^2+7$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+7)^{4}}{2\cdot 4}\right]_{0}^{1}=\frac{1695}{8} \approx 211.875$.',
      25
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+6)^{2}\,dx$ con el cambio $u=x^2+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      21.1667::numeric,
      0.001::numeric,
      'Con $u=x^2+6$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+6)^{3}}{2\cdot 3}\right]_{0}^{1}=\frac{127}{6} \approx 21.1667$.',
      26
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+6)^{3}\,dx$ con el cambio $u=x^2+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      138.125::numeric,
      0.001::numeric,
      'Con $u=x^2+6$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+6)^{4}}{2\cdot 4}\right]_{0}^{1}=\frac{1105}{8} \approx 138.125$.',
      27
    ),
    (
      'Calcula $\int_{0}^{1} x(x^2+8)^{4}\,dx$ con el cambio $u=x^2+8$.',
      'numeric',
      null::jsonb,
      null::integer,
      2628.1::numeric,
      0.001::numeric,
      'Con $u=x^2+8$, $du=2x\,dx$, así que $x\,dx=\frac{du}{2}$. El resultado es $\left[\frac{(x^2+8)^{5}}{2\cdot 5}\right]_{0}^{1}=\frac{26281}{10} \approx 2628.1$.',
      28
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+6)\,dx$ con $u=x^3+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      2.1667::numeric,
      0.001::numeric,
      'Con $u=x^3+6$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+6)\,dx=\left[\frac{(x^3+6)^{2}}{3\cdot 2}\right]_{0}^{1}=\frac{13}{6} \approx 2.1667$.',
      29
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+1)^{3}\,dx$ con $u=x^3+1$.',
      'numeric',
      null::jsonb,
      null::integer,
      1.25::numeric,
      0.001::numeric,
      'Con $u=x^3+1$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+1)^{3}\,dx=\left[\frac{(x^3+1)^{4}}{3\cdot 4}\right]_{0}^{1}=\frac{5}{4} \approx 1.25$.',
      30
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+2)^{3}\,dx$ con $u=x^3+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      5.4167::numeric,
      0.001::numeric,
      'Con $u=x^3+2$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+2)^{3}\,dx=\left[\frac{(x^3+2)^{4}}{3\cdot 4}\right]_{0}^{1}=\frac{65}{12} \approx 5.4167$.',
      31
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+4)\,dx$ con $u=x^3+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      1.5::numeric,
      0.001::numeric,
      'Con $u=x^3+4$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+4)\,dx=\left[\frac{(x^3+4)^{2}}{3\cdot 2}\right]_{0}^{1}=\frac{3}{2} \approx 1.5$.',
      32
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+3)^{3}\,dx$ con $u=x^3+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      14.5833::numeric,
      0.001::numeric,
      'Con $u=x^3+3$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+3)^{3}\,dx=\left[\frac{(x^3+3)^{4}}{3\cdot 4}\right]_{0}^{1}=\frac{175}{12} \approx 14.5833$.',
      33
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+1)\,dx$ con $u=x^3+1$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.5::numeric,
      0.001::numeric,
      'Con $u=x^3+1$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+1)\,dx=\left[\frac{(x^3+1)^{2}}{3\cdot 2}\right]_{0}^{1}=\frac{1}{2} \approx 0.5$.',
      34
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+5)^{2}\,dx$ con $u=x^3+5$.',
      'numeric',
      null::jsonb,
      null::integer,
      10.1111::numeric,
      0.001::numeric,
      'Con $u=x^3+5$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+5)^{2}\,dx=\left[\frac{(x^3+5)^{3}}{3\cdot 3}\right]_{0}^{1}=\frac{91}{9} \approx 10.1111$.',
      35
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+4)^{3}\,dx$ con $u=x^3+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      30.75::numeric,
      0.001::numeric,
      'Con $u=x^3+4$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+4)^{3}\,dx=\left[\frac{(x^3+4)^{4}}{3\cdot 4}\right]_{0}^{1}=\frac{123}{4} \approx 30.75$.',
      36
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+3)\,dx$ con $u=x^3+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      1.1667::numeric,
      0.001::numeric,
      'Con $u=x^3+3$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+3)\,dx=\left[\frac{(x^3+3)^{2}}{3\cdot 2}\right]_{0}^{1}=\frac{7}{6} \approx 1.1667$.',
      37
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+2)^{2}\,dx$ con $u=x^3+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      2.1111::numeric,
      0.001::numeric,
      'Con $u=x^3+2$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+2)^{2}\,dx=\left[\frac{(x^3+2)^{3}}{3\cdot 3}\right]_{0}^{1}=\frac{19}{9} \approx 2.1111$.',
      38
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+6)^{3}\,dx$ con $u=x^3+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      92.0833::numeric,
      0.001::numeric,
      'Con $u=x^3+6$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+6)^{3}\,dx=\left[\frac{(x^3+6)^{4}}{3\cdot 4}\right]_{0}^{1}=\frac{1105}{12} \approx 92.0833$.',
      39
    ),
    (
      'Calcula $\int_{0}^{1} x^2(x^3+5)\,dx$ con $u=x^3+5$.',
      'numeric',
      null::jsonb,
      null::integer,
      1.8333::numeric,
      0.001::numeric,
      'Con $u=x^3+5$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} x^2(x^3+5)\,dx=\left[\frac{(x^3+5)^{2}}{3\cdot 2}\right]_{0}^{1}=\frac{11}{6} \approx 1.8333$.',
      40
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+6)^{3}\,dx$ con $u=x^2+x+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      700::numeric,
      0.000001::numeric,
      'Con $u=x^2+x+6$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+6)^{4}}{4}\right]_{0}^{1}=700$.',
      41
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+1)\,dx$ con $u=x^2+x+1$.',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'Con $u=x^2+x+1$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+1)^{2}}{2}\right]_{0}^{1}=4$.',
      42
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+4)^{3}\,dx$ con $u=x^2+x+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      260::numeric,
      0.000001::numeric,
      'Con $u=x^2+x+4$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+4)^{4}}{4}\right]_{0}^{1}=260$.',
      43
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+2)^{3}\,dx$ con $u=x^2+x+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      60::numeric,
      0.000001::numeric,
      'Con $u=x^2+x+2$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+2)^{4}}{4}\right]_{0}^{1}=60$.',
      44
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+3)^{2}\,dx$ con $u=x^2+x+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      32.6667::numeric,
      0.001::numeric,
      'Con $u=x^2+x+3$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+3)^{3}}{3}\right]_{0}^{1}=\frac{98}{3} \approx 32.6667$.',
      45
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+5)\,dx$ con $u=x^2+x+5$.',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.000001::numeric,
      'Con $u=x^2+x+5$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+5)^{2}}{2}\right]_{0}^{1}=12$.',
      46
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+2)^{2}\,dx$ con $u=x^2+x+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      18.6667::numeric,
      0.001::numeric,
      'Con $u=x^2+x+2$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+2)^{3}}{3}\right]_{0}^{1}=\frac{56}{3} \approx 18.6667$.',
      47
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+1)^{2}\,dx$ con $u=x^2+x+1$.',
      'numeric',
      null::jsonb,
      null::integer,
      8.6667::numeric,
      0.001::numeric,
      'Con $u=x^2+x+1$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+1)^{3}}{3}\right]_{0}^{1}=\frac{26}{3} \approx 8.6667$.',
      48
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+4)^{2}\,dx$ con $u=x^2+x+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      50.6667::numeric,
      0.001::numeric,
      'Con $u=x^2+x+4$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+4)^{3}}{3}\right]_{0}^{1}=\frac{152}{3} \approx 50.6667$.',
      49
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+4)\,dx$ con $u=x^2+x+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.000001::numeric,
      'Con $u=x^2+x+4$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+4)^{2}}{2}\right]_{0}^{1}=10$.',
      50
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+5)^{2}\,dx$ con $u=x^2+x+5$.',
      'numeric',
      null::jsonb,
      null::integer,
      72.6667::numeric,
      0.001::numeric,
      'Con $u=x^2+x+5$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+5)^{3}}{3}\right]_{0}^{1}=\frac{218}{3} \approx 72.6667$.',
      51
    ),
    (
      'Calcula $\int_{0}^{1} (2x+1)(x^2+x+1)^{3}\,dx$ con $u=x^2+x+1$.',
      'numeric',
      null::jsonb,
      null::integer,
      20::numeric,
      0.000001::numeric,
      'Con $u=x^2+x+1$, $du=(2x+1)\,dx$. El resultado es $\left[\frac{(x^2+x+1)^{4}}{4}\right]_{0}^{1}=20$.',
      52
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+8)^2}\,dx$ con $u=x^2+8$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0069::numeric,
      0.001::numeric,
      'Con $u=x^2+8$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+8)^2}\,dx=\left[-\frac{1}{2(x^2+8)}\right]_{0}^{1}=\frac{1}{144} \approx 0.0069$.',
      53
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+16)^2}\,dx$ con $u=x^2+16$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0018::numeric,
      0.001::numeric,
      'Con $u=x^2+16$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+16)^2}\,dx=\left[-\frac{1}{2(x^2+16)}\right]_{0}^{1}=\frac{1}{544} \approx 0.0018$.',
      54
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+9)^2}\,dx$ con $u=x^2+9$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0056::numeric,
      0.001::numeric,
      'Con $u=x^2+9$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+9)^2}\,dx=\left[-\frac{1}{2(x^2+9)}\right]_{0}^{1}=\frac{1}{180} \approx 0.0056$.',
      55
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+4)^2}\,dx$ con $u=x^2+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.025::numeric,
      0.001::numeric,
      'Con $u=x^2+4$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+4)^2}\,dx=\left[-\frac{1}{2(x^2+4)}\right]_{0}^{1}=\frac{1}{40} \approx 0.025$.',
      56
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+11)^2}\,dx$ con $u=x^2+11$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0038::numeric,
      0.001::numeric,
      'Con $u=x^2+11$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+11)^2}\,dx=\left[-\frac{1}{2(x^2+11)}\right]_{0}^{1}=\frac{1}{264} \approx 0.0038$.',
      57
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+3)^2}\,dx$ con $u=x^2+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0417::numeric,
      0.001::numeric,
      'Con $u=x^2+3$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+3)^2}\,dx=\left[-\frac{1}{2(x^2+3)}\right]_{0}^{1}=\frac{1}{24} \approx 0.0417$.',
      58
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+5)^2}\,dx$ con $u=x^2+5$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0167::numeric,
      0.001::numeric,
      'Con $u=x^2+5$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+5)^2}\,dx=\left[-\frac{1}{2(x^2+5)}\right]_{0}^{1}=\frac{1}{60} \approx 0.0167$.',
      59
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+14)^2}\,dx$ con $u=x^2+14$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0024::numeric,
      0.001::numeric,
      'Con $u=x^2+14$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+14)^2}\,dx=\left[-\frac{1}{2(x^2+14)}\right]_{0}^{1}=\frac{1}{420} \approx 0.0024$.',
      60
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+6)^2}\,dx$ con $u=x^2+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0119::numeric,
      0.001::numeric,
      'Con $u=x^2+6$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+6)^2}\,dx=\left[-\frac{1}{2(x^2+6)}\right]_{0}^{1}=\frac{1}{84} \approx 0.0119$.',
      61
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+13)^2}\,dx$ con $u=x^2+13$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0027::numeric,
      0.001::numeric,
      'Con $u=x^2+13$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+13)^2}\,dx=\left[-\frac{1}{2(x^2+13)}\right]_{0}^{1}=\frac{1}{364} \approx 0.0027$.',
      62
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+10)^2}\,dx$ con $u=x^2+10$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0045::numeric,
      0.001::numeric,
      'Con $u=x^2+10$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+10)^2}\,dx=\left[-\frac{1}{2(x^2+10)}\right]_{0}^{1}=\frac{1}{220} \approx 0.0045$.',
      63
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x}{(x^2+12)^2}\,dx$ con $u=x^2+12$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0032::numeric,
      0.001::numeric,
      'Con $u=x^2+12$, $du=2x\,dx$. Entonces $\int_{0}^{1} \frac{x}{(x^2+12)^2}\,dx=\left[-\frac{1}{2(x^2+12)}\right]_{0}^{1}=\frac{1}{312} \approx 0.0032$.',
      64
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+16)^2}\,dx$ con $u=x+16$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0037::numeric,
      0.001::numeric,
      'Con $u=x+16$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+16)^2}\,dx=\left[-\frac{1}{x+16}\right]_{0}^{1}=\frac{1}{272} \approx 0.0037$.',
      65
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+13)^2}\,dx$ con $u=x+13$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0055::numeric,
      0.001::numeric,
      'Con $u=x+13$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+13)^2}\,dx=\left[-\frac{1}{x+13}\right]_{0}^{1}=\frac{1}{182} \approx 0.0055$.',
      66
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+7)^2}\,dx$ con $u=x+7$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0179::numeric,
      0.001::numeric,
      'Con $u=x+7$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+7)^2}\,dx=\left[-\frac{1}{x+7}\right]_{0}^{1}=\frac{1}{56} \approx 0.0179$.',
      67
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+10)^2}\,dx$ con $u=x+10$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0091::numeric,
      0.001::numeric,
      'Con $u=x+10$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+10)^2}\,dx=\left[-\frac{1}{x+10}\right]_{0}^{1}=\frac{1}{110} \approx 0.0091$.',
      68
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+4)^2}\,dx$ con $u=x+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.05::numeric,
      0.001::numeric,
      'Con $u=x+4$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+4)^2}\,dx=\left[-\frac{1}{x+4}\right]_{0}^{1}=\frac{1}{20} \approx 0.05$.',
      69
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+14)^2}\,dx$ con $u=x+14$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0048::numeric,
      0.001::numeric,
      'Con $u=x+14$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+14)^2}\,dx=\left[-\frac{1}{x+14}\right]_{0}^{1}=\frac{1}{210} \approx 0.0048$.',
      70
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+3)^2}\,dx$ con $u=x+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0833::numeric,
      0.001::numeric,
      'Con $u=x+3$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+3)^2}\,dx=\left[-\frac{1}{x+3}\right]_{0}^{1}=\frac{1}{12} \approx 0.0833$.',
      71
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+8)^2}\,dx$ con $u=x+8$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0139::numeric,
      0.001::numeric,
      'Con $u=x+8$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+8)^2}\,dx=\left[-\frac{1}{x+8}\right]_{0}^{1}=\frac{1}{72} \approx 0.0139$.',
      72
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+2)^2}\,dx$ con $u=x+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.1667::numeric,
      0.001::numeric,
      'Con $u=x+2$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+2)^2}\,dx=\left[-\frac{1}{x+2}\right]_{0}^{1}=\frac{1}{6} \approx 0.1667$.',
      73
    ),
    (
      'Calcula $\int_{0}^{1} \frac{1}{(x+5)^2}\,dx$ con $u=x+5$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0333::numeric,
      0.001::numeric,
      'Con $u=x+5$, $du=dx$. Entonces $\int_{0}^{1} \frac{1}{(x+5)^2}\,dx=\left[-\frac{1}{x+5}\right]_{0}^{1}=\frac{1}{30} \approx 0.0333$.',
      74
    ),
    (
      'Si $F(x)=\int 3x^2(x^3+2)^{3}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      2496::numeric,
      0.000001::numeric,
      'Con $u=x^3+2$, $du=3x^2\,dx$. Entonces $F(x)=\frac{(x^3+2)^{4}}{4}+C$. Como $F(0)=0$, $C=-\frac{2^{4}}{4}$, así que $F(2)=2496$.',
      75
    ),
    (
      'Si $F(x)=\int 3x^2(x^3+4)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      64::numeric,
      0.000001::numeric,
      'Con $u=x^3+4$, $du=3x^2\,dx$. Entonces $F(x)=\frac{(x^3+4)^{2}}{2}+C$. Como $F(0)=0$, $C=-\frac{4^{2}}{2}$, así que $F(2)=64$.',
      76
    ),
    (
      'Si $F(x)=\int 3x^2(x^3+6)^{3}\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      276.25::numeric,
      0.001::numeric,
      'Con $u=x^3+6$, $du=3x^2\,dx$. Entonces $F(x)=\frac{(x^3+6)^{4}}{4}+C$. Como $F(0)=0$, $C=-\frac{6^{4}}{4}$, así que $F(1)=\frac{1105}{4} \approx 276.25$.',
      77
    ),
    (
      'Si $F(x)=\int 3x^2(x^3+6)^{2}\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      42.3333::numeric,
      0.001::numeric,
      'Con $u=x^3+6$, $du=3x^2\,dx$. Entonces $F(x)=\frac{(x^3+6)^{3}}{3}+C$. Como $F(0)=0$, $C=-\frac{6^{3}}{3}$, así que $F(1)=\frac{127}{3} \approx 42.3333$.',
      78
    ),
    (
      'Si $F(x)=\int 3x^2(x^3+1)^{3}\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      3.75::numeric,
      0.001::numeric,
      'Con $u=x^3+1$, $du=3x^2\,dx$. Entonces $F(x)=\frac{(x^3+1)^{4}}{4}+C$. Como $F(0)=0$, $C=-\frac{1^{4}}{4}$, así que $F(1)=\frac{15}{4} \approx 3.75$.',
      79
    ),
    (
      'Si $F(x)=\int 3x^2(x^3+5)\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      5.5::numeric,
      0.001::numeric,
      'Con $u=x^3+5$, $du=3x^2\,dx$. Entonces $F(x)=\frac{(x^3+5)^{2}}{2}+C$. Como $F(0)=0$, $C=-\frac{5^{2}}{2}$, así que $F(1)=\frac{11}{2} \approx 5.5$.',
      80
    ),
    (
      'Si $F(x)=\int 3x^2(x^3+3)^{3}\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      43.75::numeric,
      0.001::numeric,
      'Con $u=x^3+3$, $du=3x^2\,dx$. Entonces $F(x)=\frac{(x^3+3)^{4}}{4}+C$. Como $F(0)=0$, $C=-\frac{3^{4}}{4}$, así que $F(1)=\frac{175}{4} \approx 43.75$.',
      81
    ),
    (
      'Si $F(x)=\int 3x^2(x^3+2)^{2}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      330.6667::numeric,
      0.001::numeric,
      'Con $u=x^3+2$, $du=3x^2\,dx$. Entonces $F(x)=\frac{(x^3+2)^{3}}{3}+C$. Como $F(0)=0$, $C=-\frac{2^{3}}{3}$, así que $F(2)=\frac{992}{3} \approx 330.6667$.',
      82
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+7)^2}\,dx$ con $u=x^3+7$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.006::numeric,
      0.001::numeric,
      'Con $u=x^3+7$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+7)^2}\,dx=\left[-\frac{1}{3(x^3+7)}\right]_{0}^{1}=\frac{1}{168} \approx 0.006$.',
      83
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+12)^2}\,dx$ con $u=x^3+12$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0021::numeric,
      0.001::numeric,
      'Con $u=x^3+12$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+12)^2}\,dx=\left[-\frac{1}{3(x^3+12)}\right]_{0}^{1}=\frac{1}{468} \approx 0.0021$.',
      84
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+10)^2}\,dx$ con $u=x^3+10$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.003::numeric,
      0.001::numeric,
      'Con $u=x^3+10$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+10)^2}\,dx=\left[-\frac{1}{3(x^3+10)}\right]_{0}^{1}=\frac{1}{330} \approx 0.003$.',
      85
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+8)^2}\,dx$ con $u=x^3+8$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0046::numeric,
      0.001::numeric,
      'Con $u=x^3+8$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+8)^2}\,dx=\left[-\frac{1}{3(x^3+8)}\right]_{0}^{1}=\frac{1}{216} \approx 0.0046$.',
      86
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+2)^2}\,dx$ con $u=x^3+2$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0556::numeric,
      0.001::numeric,
      'Con $u=x^3+2$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+2)^2}\,dx=\left[-\frac{1}{3(x^3+2)}\right]_{0}^{1}=\frac{1}{18} \approx 0.0556$.',
      87
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+4)^2}\,dx$ con $u=x^3+4$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0167::numeric,
      0.001::numeric,
      'Con $u=x^3+4$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+4)^2}\,dx=\left[-\frac{1}{3(x^3+4)}\right]_{0}^{1}=\frac{1}{60} \approx 0.0167$.',
      88
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+3)^2}\,dx$ con $u=x^3+3$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0278::numeric,
      0.001::numeric,
      'Con $u=x^3+3$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+3)^2}\,dx=\left[-\frac{1}{3(x^3+3)}\right]_{0}^{1}=\frac{1}{36} \approx 0.0278$.',
      89
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+13)^2}\,dx$ con $u=x^3+13$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0018::numeric,
      0.001::numeric,
      'Con $u=x^3+13$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+13)^2}\,dx=\left[-\frac{1}{3(x^3+13)}\right]_{0}^{1}=\frac{1}{546} \approx 0.0018$.',
      90
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+6)^2}\,dx$ con $u=x^3+6$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0079::numeric,
      0.001::numeric,
      'Con $u=x^3+6$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+6)^2}\,dx=\left[-\frac{1}{3(x^3+6)}\right]_{0}^{1}=\frac{1}{126} \approx 0.0079$.',
      91
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+9)^2}\,dx$ con $u=x^3+9$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0037::numeric,
      0.001::numeric,
      'Con $u=x^3+9$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+9)^2}\,dx=\left[-\frac{1}{3(x^3+9)}\right]_{0}^{1}=\frac{1}{270} \approx 0.0037$.',
      92
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+15)^2}\,dx$ con $u=x^3+15$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0014::numeric,
      0.001::numeric,
      'Con $u=x^3+15$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+15)^2}\,dx=\left[-\frac{1}{3(x^3+15)}\right]_{0}^{1}=\frac{1}{720} \approx 0.0014$.',
      93
    ),
    (
      'Calcula $\int_{0}^{1} \frac{x^2}{(x^3+16)^2}\,dx$ con $u=x^3+16$.',
      'numeric',
      null::jsonb,
      null::integer,
      0.0012::numeric,
      0.001::numeric,
      'Con $u=x^3+16$, $du=3x^2\,dx$. Entonces $\int_{0}^{1} \frac{x^2}{(x^3+16)^2}\,dx=\left[-\frac{1}{3(x^3+16)}\right]_{0}^{1}=\frac{1}{816} \approx 0.0012$.',
      94
    ),
    (
      'Calcula $\int_{1}^{8} \frac{x}{\sqrt{x^2+80}}\,dx$ con $u=x^2+80$.',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      'Con $u=x^2+80$, $du=2x\,dx$. Entonces $\int_{1}^{8} \frac{x}{\sqrt{x^2+80}}\,dx=\left[\sqrt{x^2+80}\right]_{1}^{8}=3$.',
      95
    ),
    (
      'Calcula $\int_{2}^{6} \frac{x}{\sqrt{x^2+45}}\,dx$ con $u=x^2+45$.',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Con $u=x^2+45$, $du=2x\,dx$. Entonces $\int_{2}^{6} \frac{x}{\sqrt{x^2+45}}\,dx=\left[\sqrt{x^2+45}\right]_{2}^{6}=2$.',
      96
    ),
    (
      'Calcula $\int_{1}^{5} \frac{x}{\sqrt{x^2+24}}\,dx$ con $u=x^2+24$.',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Con $u=x^2+24$, $du=2x\,dx$. Entonces $\int_{1}^{5} \frac{x}{\sqrt{x^2+24}}\,dx=\left[\sqrt{x^2+24}\right]_{1}^{5}=2$.',
      97
    ),
    (
      'Calcula $\int_{3}^{9} \frac{x}{\sqrt{x^2+40}}\,dx$ con $u=x^2+40$.',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'Con $u=x^2+40$, $du=2x\,dx$. Entonces $\int_{3}^{9} \frac{x}{\sqrt{x^2+40}}\,dx=\left[\sqrt{x^2+40}\right]_{3}^{9}=4$.',
      98
    ),
    (
      'Calcula $\int_{0}^{3} \frac{x}{\sqrt{x^2+16}}\,dx$ con $u=x^2+16$.',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.000001::numeric,
      'Con $u=x^2+16$, $du=2x\,dx$. Entonces $\int_{0}^{3} \frac{x}{\sqrt{x^2+16}}\,dx=\left[\sqrt{x^2+16}\right]_{0}^{3}=1$.',
      99
    ),
    (
      'Calcula $\int_{0}^{4} \frac{x}{\sqrt{x^2+9}}\,dx$ con $u=x^2+9$.',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Con $u=x^2+9$, $du=2x\,dx$. Entonces $\int_{0}^{4} \frac{x}{\sqrt{x^2+9}}\,dx=\left[\sqrt{x^2+9}\right]_{0}^{4}=2$.',
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
  select id from public.modules where slug = 'cambio-variable-100'
) as m
where not exists (
  select 1
  from public.exercises e
  where e.module_id = m.id
);
