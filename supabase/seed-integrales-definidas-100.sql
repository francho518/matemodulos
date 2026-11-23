-- ============================================================
--  Matemódulos · Integrales polinómicas y radicales · definidas · 100 ejercicios
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
  'Integrales polinómicas y radicales · definidas · 100 ejercicios',
  'integrales-definidas-100',
  '100 integrales definidas de polinomios y radicales con respuesta numérica y límites escogidos para obtener resultados exactos.',
  8,
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
      'Calcula $\int_{0}^{1} 4x^{2}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      1.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3}$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=\frac{4}{3}-0=\frac{4}{3} \approx 1.3333$.',
      1
    ),
    (
      'Calcula $\int_{0}^{3} 8x\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      36::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=4x^{2}$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=36-0=36$.',
      2
    ),
    (
      'Calcula $\int_{0}^{2} 8x^{3}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      32::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=2x^{4}$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=32-0=32$.',
      3
    ),
    (
      'Calcula $\int_{0}^{4} 2x^{2}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      42.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{3}x^{3}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=\frac{128}{3}-0=\frac{128}{3} \approx 42.6667$.',
      4
    ),
    (
      'Calcula $\int_{0}^{1} 4x\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=2x^{2}$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=2-0=2$.',
      5
    ),
    (
      'Calcula $\int_{0}^{3} 5x^{2}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      45::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{5}{3}x^{3}$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=45-0=45$.',
      6
    ),
    (
      'Calcula $\int_{0}^{3} 4x^{2}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      36::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3}$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=36-0=36$.',
      7
    ),
    (
      'Calcula $\int_{0}^{4} 8x^{2}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      170.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{8}{3}x^{3}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=\frac{512}{3}-0=\frac{512}{3} \approx 170.6667$.',
      8
    ),
    (
      'Calcula $\int_{0}^{2} 6x^{2}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=2x^{3}$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=16-0=16$.',
      9
    ),
    (
      'Calcula $\int_{0}^{2} 8x^{2}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      21.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{8}{3}x^{3}$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{64}{3}-0=\frac{64}{3} \approx 21.3333$.',
      10
    ),
    (
      'Calcula $\int_{0}^{1} 4x^{3}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{4}$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=1-0=1$.',
      11
    ),
    (
      'Calcula $\int_{0}^{3} 2x\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      9::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{2}$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=9-0=9$.',
      12
    ),
    (
      'Calcula $\int_{0}^{4} 3x^{2}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      64::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{3}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=64-0=64$.',
      13
    ),
    (
      'Calcula $\int_{0}^{3} 5x\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      22.5::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{5}{2}x^{2}$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=\frac{45}{2}-0=\frac{45}{2} \approx 22.5$.',
      14
    ),
    (
      'Calcula $\int_{1}^{3} (4x^{2} + 2)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      38.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3} + 2x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(1)=42-\frac{10}{3}=\frac{116}{3} \approx 38.6667$.',
      15
    ),
    (
      'Calcula $\int_{1}^{2} (4x^{3} + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      19::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{4} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(1)=24-5=19$.',
      16
    ),
    (
      'Calcula $\int_{0}^{3} (5x^{2} + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      57::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{5}{3}x^{3} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=57-0=57$.',
      17
    ),
    (
      'Calcula $\int_{0}^{3} (2x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      21::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=21-0=21$.',
      18
    ),
    (
      'Calcula $\int_{1}^{2} (2x^{2} + 2)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      6.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{3}x^{3} + 2x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(1)=\frac{28}{3}-\frac{8}{3}=\frac{20}{3} \approx 6.6667$.',
      19
    ),
    (
      'Calcula $\int_{1}^{3} (x + 3)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{2}x^{2} + 3x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(1)=\frac{27}{2}-\frac{7}{2}=10$.',
      20
    ),
    (
      'Calcula $\int_{0}^{2} (x^{2} + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      10.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{32}{3}-0=\frac{32}{3} \approx 10.6667$.',
      21
    ),
    (
      'Calcula $\int_{0}^{2} (2x + 3)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{2} + 3x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=10-0=10$.',
      22
    ),
    (
      'Calcula $\int_{0}^{1} (5x^{3} + 1)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      2.25::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{5}{4}x^{4} + x$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=\frac{9}{4}-0=\frac{9}{4} \approx 2.25$.',
      23
    ),
    (
      'Calcula $\int_{0}^{3} (4x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      30::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=2x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=30-0=30$.',
      24
    ),
    (
      'Calcula $\int_{1}^{2} (x^{3} + 1)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      4.75::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{4}x^{4} + x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(1)=6-\frac{5}{4}=\frac{19}{4} \approx 4.75$.',
      25
    ),
    (
      'Calcula $\int_{0}^{1} (x^{2} + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      4.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=\frac{13}{3}-0=\frac{13}{3} \approx 4.3333$.',
      26
    ),
    (
      'Calcula $\int_{1}^{2} (x^{3} + 2)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      5.75::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{4}x^{4} + 2x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(1)=8-\frac{9}{4}=\frac{23}{4} \approx 5.75$.',
      27
    ),
    (
      'Calcula $\int_{0}^{3} (4x^{2} + 5)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      51::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3} + 5x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=51-0=51$.',
      28
    ),
    (
      'Calcula $\int_{0}^{3} (3x^{2} + x + 1)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      34.5::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=x^{3} + \frac{1}{2}x^{2} + x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=\frac{69}{2}-0=\frac{69}{2} \approx 34.5$.',
      29
    ),
    (
      'Calcula $\int_{0}^{2} (2x^{2} - x + 2)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      7.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{3}x^{3} - \frac{1}{2}x^{2} + 2x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{22}{3}-0=\frac{22}{3} \approx 7.3333$.',
      30
    ),
    (
      'Calcula $\int_{0}^{2} (2x^{2} - 2x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      9.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{3}x^{3} - x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{28}{3}-0=\frac{28}{3} \approx 9.3333$.',
      31
    ),
    (
      'Calcula $\int_{0}^{3} (3x^{2} - 2x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      30::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{3} - x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=30-0=30$.',
      32
    ),
    (
      'Calcula $\int_{0}^{2} (4x^{2} - 2x + 2)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      10.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3} - x^{2} + 2x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{32}{3}-0=\frac{32}{3} \approx 10.6667$.',
      33
    ),
    (
      'Calcula $\int_{0}^{1} (2x^{2} + x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      5.1667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{3}x^{3} + \frac{1}{2}x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=\frac{31}{6}-0=\frac{31}{6} \approx 5.1667$.',
      34
    ),
    (
      'Calcula $\int_{0}^{2} (3x^{2} + 2x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      20::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{3} + x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=20-0=20$.',
      35
    ),
    (
      'Calcula $\int_{0}^{2} (4x^{2} + 2x + 1)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      16.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3} + x^{2} + x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{50}{3}-0=\frac{50}{3} \approx 16.6667$.',
      36
    ),
    (
      'Calcula $\int_{0}^{3} (2x^{2} + x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      34.5::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{3}x^{3} + \frac{1}{2}x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=\frac{69}{2}-0=\frac{69}{2} \approx 34.5$.',
      37
    ),
    (
      'Calcula $\int_{0}^{2} (3x^{2} - x + 1)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{3} - \frac{1}{2}x^{2} + x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=8-0=8$.',
      38
    ),
    (
      'Calcula $\int_{0}^{3} (4x^{2} + x + 2)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      46.5::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3} + \frac{1}{2}x^{2} + 2x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=\frac{93}{2}-0=\frac{93}{2} \approx 46.5$.',
      39
    ),
    (
      'Calcula $\int_{0}^{3} (3x^{2} + 3x + 3)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      49.5::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=x^{3} + \frac{3}{2}x^{2} + 3x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=\frac{99}{2}-0=\frac{99}{2} \approx 49.5$.',
      40
    ),
    (
      'Calcula $\int_{0}^{1} 4\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      2.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{8}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=\frac{8}{3}-0=\frac{8}{3} \approx 2.6667$.',
      41
    ),
    (
      'Calcula $\int_{1}^{9} \sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      17.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(1)=18-\frac{2}{3}=\frac{52}{3} \approx 17.3333$.',
      42
    ),
    (
      'Calcula $\int_{0}^{4} 5\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      26.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{10}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=\frac{80}{3}-0=\frac{80}{3} \approx 26.6667$.',
      43
    ),
    (
      'Calcula $\int_{0}^{4} 6\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      32::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=4x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=32-0=32$.',
      44
    ),
    (
      'Calcula $\int_{0}^{4} \sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      5.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=\frac{16}{3}-0=\frac{16}{3} \approx 5.3333$.',
      45
    ),
    (
      'Calcula $\int_{0}^{9} 4\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      72::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{8}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=72-0=72$.',
      46
    ),
    (
      'Calcula $\int_{1}^{4} 3\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      14::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=2x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=16-2=14$.',
      47
    ),
    (
      'Calcula $\int_{0}^{4} 2\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      10.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=\frac{32}{3}-0=\frac{32}{3} \approx 10.6667$.',
      48
    ),
    (
      'Calcula $\int_{0}^{9} \sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      18::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=18-0=18$.',
      49
    ),
    (
      'Calcula $\int_{0}^{9} 5\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      90::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{10}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=90-0=90$.',
      50
    ),
    (
      'Calcula $\int_{1}^{4} 2\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      9.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=\frac{32}{3}-\frac{4}{3}=\frac{28}{3} \approx 9.3333$.',
      51
    ),
    (
      'Calcula $\int_{0}^{9} 6\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      108::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=4x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=108-0=108$.',
      52
    ),
    (
      'Calcula $\int_{4}^{9} 4x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      337.6::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{8}{5}x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(4)=\frac{1944}{5}-\frac{256}{5}=\frac{1688}{5} \approx 337.6$.',
      53
    ),
    (
      'Calcula $\int_{0}^{9} 2x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      194.4::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{5}x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=\frac{972}{5}-0=\frac{972}{5} \approx 194.4$.',
      54
    ),
    (
      'Calcula $\int_{0}^{4} 2x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      25.6::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{5}x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=\frac{128}{5}-0=\frac{128}{5} \approx 25.6$.',
      55
    ),
    (
      'Calcula $\int_{0}^{9} 5x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      486::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=2x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=486-0=486$.',
      56
    ),
    (
      'Calcula $\int_{4}^{9} x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      84.4::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{5}x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(4)=\frac{486}{5}-\frac{64}{5}=\frac{422}{5} \approx 84.4$.',
      57
    ),
    (
      'Calcula $\int_{4}^{9} 3x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      253.2::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{6}{5}x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(4)=\frac{1458}{5}-\frac{192}{5}=\frac{1266}{5} \approx 253.2$.',
      58
    ),
    (
      'Calcula $\int_{4}^{9} 5x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      422::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=2x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(4)=486-64=422$.',
      59
    ),
    (
      'Calcula $\int_{0}^{4} x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      12.8::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{5}x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=\frac{64}{5}-0=\frac{64}{5} \approx 12.8$.',
      60
    ),
    (
      'Calcula $\int_{0}^{9} 4x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      388.8::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{8}{5}x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=\frac{1944}{5}-0=\frac{1944}{5} \approx 388.8$.',
      61
    ),
    (
      'Calcula $\int_{0}^{9} x\sqrt{x}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      97.2::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{2}{5}x^2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=\frac{486}{5}-0=\frac{486}{5} \approx 97.2$.',
      62
    ),
    (
      'Calcula $\int_{4}^{16} \frac{4}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=8\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(16)-F(4)=32-16=16$.',
      63
    ),
    (
      'Calcula $\int_{1}^{4} \frac{6}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=12\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=24-12=12$.',
      64
    ),
    (
      'Calcula $\int_{1}^{9} \frac{4}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=8\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(1)=24-8=16$.',
      65
    ),
    (
      'Calcula $\int_{1}^{4} \frac{4}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=8\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=16-8=8$.',
      66
    ),
    (
      'Calcula $\int_{4}^{9} \frac{4}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=8\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(4)=24-16=8$.',
      67
    ),
    (
      'Calcula $\int_{9}^{16} \frac{1}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=2\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(16)-F(9)=8-6=2$.',
      68
    ),
    (
      'Calcula $\int_{4}^{16} \frac{6}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=12\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(16)-F(4)=48-24=24$.',
      69
    ),
    (
      'Calcula $\int_{1}^{4} \frac{5}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=10\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=20-10=10$.',
      70
    ),
    (
      'Calcula $\int_{9}^{16} \frac{2}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=4\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(16)-F(9)=16-12=4$.',
      71
    ),
    (
      'Calcula $\int_{4}^{9} \frac{3}{\sqrt{x}}\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=6\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(4)=18-12=6$.',
      72
    ),
    (
      'Calcula $\int_{1}^{4} (x + 4\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      26.1667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{2}x^{2} + \frac{8}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=\frac{88}{3}-\frac{19}{6}=\frac{157}{6} \approx 26.1667$.',
      73
    ),
    (
      'Calcula $\int_{1}^{4} (3x + 2\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      31.8333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{3}{2}x^{2} + \frac{4}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=\frac{104}{3}-\frac{17}{6}=\frac{191}{6} \approx 31.8333$.',
      74
    ),
    (
      'Calcula $\int_{0}^{4} (x + 3\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{2}x^{2} + 2x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=24-0=24$.',
      75
    ),
    (
      'Calcula $\int_{0}^{9} (3x + 2\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      157.5::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{3}{2}x^{2} + \frac{4}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=\frac{315}{2}-0=\frac{315}{2} \approx 157.5$.',
      76
    ),
    (
      'Calcula $\int_{0}^{9} (4x + 2\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      198::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=2x^{2} + \frac{4}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=198-0=198$.',
      77
    ),
    (
      'Calcula $\int_{0}^{9} (x + 3\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      94.5::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{2}x^{2} + 2x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(9)-F(0)=\frac{189}{2}-0=\frac{189}{2} \approx 94.5$.',
      78
    ),
    (
      'Calcula $\int_{1}^{4} (4x + 2\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      39.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=2x^{2} + \frac{4}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=\frac{128}{3}-\frac{10}{3}=\frac{118}{3} \approx 39.3333$.',
      79
    ),
    (
      'Calcula $\int_{1}^{4} (2x + 2\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      24.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=x^{2} + \frac{4}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=\frac{80}{3}-\frac{7}{3}=\frac{73}{3} \approx 24.3333$.',
      80
    ),
    (
      'Calcula $\int_{0}^{4} (3x + 3\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      40::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{3}{2}x^{2} + 2x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=40-0=40$.',
      81
    ),
    (
      'Calcula $\int_{1}^{4} (3x + 4\sqrt{x})\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      41.1667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{3}{2}x^{2} + \frac{8}{3}x\sqrt{x}$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(1)=\frac{136}{3}-\frac{25}{6}=\frac{247}{6} \approx 41.1667$.',
      82
    ),
    (
      'Calcula $\int_{0}^{3} (x+1)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      21::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + x^{2} + x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=21-0=21$.',
      83
    ),
    (
      'Calcula $\int_{0}^{4} (x+3)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      105.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + 3x^{2} + 9x$. Por el teorema fundamental del cálculo, el resultado es $F(4)-F(0)=\frac{316}{3}-0=\frac{316}{3} \approx 105.3333$.',
      84
    ),
    (
      'Calcula $\int_{0}^{2} (x+3)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      32.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + 3x^{2} + 9x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{98}{3}-0=\frac{98}{3} \approx 32.6667$.',
      85
    ),
    (
      'Calcula $\int_{0}^{1} (x+3)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      12.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + 3x^{2} + 9x$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=\frac{37}{3}-0=\frac{37}{3} \approx 12.3333$.',
      86
    ),
    (
      'Calcula $\int_{0}^{1} (x+6)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      42.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + 6x^{2} + 36x$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=\frac{127}{3}-0=\frac{127}{3} \approx 42.3333$.',
      87
    ),
    (
      'Calcula $\int_{0}^{2} (x+1)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      8.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + x^{2} + x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{26}{3}-0=\frac{26}{3} \approx 8.6667$.',
      88
    ),
    (
      'Calcula $\int_{0}^{2} (x+2)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      18.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + 2x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{56}{3}-0=\frac{56}{3} \approx 18.6667$.',
      89
    ),
    (
      'Calcula $\int_{0}^{3} (x+3)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      63::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + 3x^{2} + 9x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=63-0=63$.',
      90
    ),
    (
      'Calcula $\int_{0}^{1} (x+1)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      2.3333::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + x^{2} + x$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=\frac{7}{3}-0=\frac{7}{3} \approx 2.3333$.',
      91
    ),
    (
      'Calcula $\int_{0}^{3} (x+2)^2\,dx$ desarrollando primero el binomio.',
      'numeric',
      null::jsonb,
      null::integer,
      39::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + 2x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(3)-F(0)=39-0=39$.',
      92
    ),
    (
      'Calcula $\int_{0}^{1} (3x^{2} + x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      5.5::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=x^{3} + \frac{1}{2}x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=\frac{11}{2}-0=\frac{11}{2} \approx 5.5$.',
      93
    ),
    (
      'Calcula $\int_{0}^{2} (4x^{2} - x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      16.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3} - \frac{1}{2}x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{50}{3}-0=\frac{50}{3} \approx 16.6667$.',
      94
    ),
    (
      'Calcula $\int_{0}^{1} (3x^{2} - 2x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{3} - x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=4-0=4$.',
      95
    ),
    (
      'Calcula $\int_{0}^{2} (3x^{2} - 2x + 2)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{3} - x^{2} + 2x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=8-0=8$.',
      96
    ),
    (
      'Calcula $\int_{0}^{1} (3x^{2} + 2x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.000001::numeric,
      'Una antiderivada es $F(x)=x^{3} + x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(1)-F(0)=6-0=6$.',
      97
    ),
    (
      'Calcula $\int_{0}^{2} (4x^{2} + x + 4)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      20.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3} + \frac{1}{2}x^{2} + 4x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{62}{3}-0=\frac{62}{3} \approx 20.6667$.',
      98
    ),
    (
      'Calcula $\int_{0}^{2} (x^{2} + x + 3)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      10.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{1}{3}x^{3} + \frac{1}{2}x^{2} + 3x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{32}{3}-0=\frac{32}{3} \approx 10.6667$.',
      99
    ),
    (
      'Calcula $\int_{0}^{2} (4x^{2} + x + 3)\,dx$.',
      'numeric',
      null::jsonb,
      null::integer,
      18.6667::numeric,
      0.001::numeric,
      'Una antiderivada es $F(x)=\frac{4}{3}x^{3} + \frac{1}{2}x^{2} + 3x$. Por el teorema fundamental del cálculo, el resultado es $F(2)-F(0)=\frac{56}{3}-0=\frac{56}{3} \approx 18.6667$.',
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
  select id from public.modules where slug = 'integrales-definidas-100'
) as m
where not exists (
  select 1
  from public.exercises e
  where e.module_id = m.id
);
