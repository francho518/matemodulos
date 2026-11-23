-- ============================================================
--  Matemódulos · Integrales polinómicas y radicales · indefinidas · 100 ejercicios
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
  'Integrales polinómicas y radicales · indefinidas · 100 ejercicios',
  'integrales-indefinidas-100',
  '100 integrales indefinidas de polinomios y radicales con respuesta numérica: se pide la antiderivada evaluada en un punto o con una condición inicial.',
  7,
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
      'Si $F(x)=\int 6x\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      27::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=3x^{2}$. Como $F(0)=0$, $F(3)=27$.',
      1
    ),
    (
      'Si $F(x)=\int 8x^{3}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      32::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2x^{4}$. Como $F(0)=0$, $F(2)=32$.',
      2
    ),
    (
      'Si $F(x)=\int 10x\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      20::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=5x^{2}$. Como $F(0)=0$, $F(2)=20$.',
      3
    ),
    (
      'Si $F(x)=\int 9x^{2}\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      81::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=3x^{3}$. Como $F(0)=0$, $F(3)=81$.',
      4
    ),
    (
      'Si $F(x)=\int 4x^{4}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      25.6::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{5}x^{5}$. Como $F(0)=0$, $F(2)=\frac{128}{5} \approx 25.6$.',
      5
    ),
    (
      'Si $F(x)=\int 4x^{3}\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      81::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=x^{4}$. Como $F(0)=0$, $F(3)=81$.',
      6
    ),
    (
      'Si $F(x)=\int 4x^{3}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=x^{4}$. Como $F(0)=0$, $F(2)=16$.',
      7
    ),
    (
      'Si $F(x)=\int 10x^{3}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      40::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{5}{2}x^{4}$. Como $F(0)=0$, $F(2)=40$.',
      8
    ),
    (
      'Si $F(x)=\int 5x^{3}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      20::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{5}{4}x^{4}$. Como $F(0)=0$, $F(2)=20$.',
      9
    ),
    (
      'Si $F(x)=\int 9x\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      18::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{9}{2}x^{2}$. Como $F(0)=0$, $F(2)=18$.',
      10
    ),
    (
      'Si $F(x)=\int 12x^{4}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      76.8::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{12}{5}x^{5}$. Como $F(0)=0$, $F(2)=\frac{384}{5} \approx 76.8$.',
      11
    ),
    (
      'Si $F(x)=\int 6x^{4}\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      291.6::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{6}{5}x^{5}$. Como $F(0)=0$, $F(3)=\frac{1458}{5} \approx 291.6$.',
      12
    ),
    (
      'Si $F(x)=\int 12x^{2}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      32::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=4x^{3}$. Como $F(0)=0$, $F(2)=32$.',
      13
    ),
    (
      'Si $F(x)=\int 4x^{2}\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      10.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{3}x^{3}$. Como $F(0)=0$, $F(2)=\frac{32}{3} \approx 10.6667$.',
      14
    ),
    (
      'Si $F(x)=\int 5x^{2}\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      45::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{5}{3}x^{3}$. Como $F(0)=0$, $F(3)=45$.',
      15
    ),
    (
      'Si $F(x)=\int 4x^{4}\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      194.4::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{5}x^{5}$. Como $F(0)=0$, $F(3)=\frac{972}{5} \approx 194.4$.',
      16
    ),
    (
      'Si $F(x)=\int (4x^{2} + 3x)\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      49.5::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{3}x^{3} + \frac{3}{2}x^{2}$. Como $F(0)=0$, $F(3)=\frac{99}{2} \approx 49.5$.',
      17
    ),
    (
      'Si $F(x)=\int (2x^{4} + 8x^{2})\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      169.2::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{2}{5}x^{5} + \frac{8}{3}x^{3}$. Como $F(0)=0$, $F(3)=\frac{846}{5} \approx 169.2$.',
      18
    ),
    (
      'Si $F(x)=\int (4x^{3} + 5x)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      26::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=x^{4} + \frac{5}{2}x^{2}$. Como $F(0)=0$, $F(2)=26$.',
      19
    ),
    (
      'Si $F(x)=\int (7x^{3} + 5x)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      38::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{7}{4}x^{4} + \frac{5}{2}x^{2}$. Como $F(0)=0$, $F(2)=38$.',
      20
    ),
    (
      'Si $F(x)=\int (2x^{4} + 6x^{2})\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      151.2::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{2}{5}x^{5} + 2x^{3}$. Como $F(0)=0$, $F(3)=\frac{756}{5} \approx 151.2$.',
      21
    ),
    (
      'Si $F(x)=\int (4x^{4} + 2x^{2})\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      212.4::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{5}x^{5} + \frac{2}{3}x^{3}$. Como $F(0)=0$, $F(3)=\frac{1062}{5} \approx 212.4$.',
      22
    ),
    (
      'Si $F(x)=\int (3x^{3} + 5x)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      22::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{3}{4}x^{4} + \frac{5}{2}x^{2}$. Como $F(0)=0$, $F(2)=22$.',
      23
    ),
    (
      'Si $F(x)=\int (5x^{3} + 5x^{2})\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      33.3333::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{5}{4}x^{4} + \frac{5}{3}x^{3}$. Como $F(0)=0$, $F(2)=\frac{100}{3} \approx 33.3333$.',
      24
    ),
    (
      'Si $F(x)=\int (6x^{4} + 8x)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      54.4::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{6}{5}x^{5} + 4x^{2}$. Como $F(0)=0$, $F(2)=\frac{272}{5} \approx 54.4$.',
      25
    ),
    (
      'Si $F(x)=\int (6x^{4} + 6x)\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      318.6::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{6}{5}x^{5} + 3x^{2}$. Como $F(0)=0$, $F(3)=\frac{1593}{5} \approx 318.6$.',
      26
    ),
    (
      'Si $F(x)=\int (6x^{4} + 2x)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      42.4::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{6}{5}x^{5} + x^{2}$. Como $F(0)=0$, $F(2)=\frac{212}{5} \approx 42.4$.',
      27
    ),
    (
      'Si $F(x)=\int (5x^{4} + 9x^{2})\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      56::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=x^{5} + 3x^{3}$. Como $F(0)=0$, $F(2)=56$.',
      28
    ),
    (
      'Si $F(x)=\int (6x^{2} + x)\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      58.5::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=2x^{3} + \frac{1}{2}x^{2}$. Como $F(0)=0$, $F(3)=\frac{117}{2} \approx 58.5$.',
      29
    ),
    (
      'Si $F(x)=\int (2x^{3} + x)\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      45::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{1}{2}x^{4} + \frac{1}{2}x^{2}$. Como $F(0)=0$, $F(3)=45$.',
      30
    ),
    (
      'Si $F(x)=\int (x^{2} + x + 3)\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      3.8333::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{1}{3}x^{3} + \frac{1}{2}x^{2} + 3x$. Como $F(0)=0$, $F(1)=\frac{23}{6} \approx 3.8333$.',
      31
    ),
    (
      'Si $F(x)=\int (x^{2} - 3x + 3)\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      1.8333::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{1}{3}x^{3} - \frac{3}{2}x^{2} + 3x$. Como $F(0)=0$, $F(1)=\frac{11}{6} \approx 1.8333$.',
      32
    ),
    (
      'Si $F(x)=\int (2x^{2} + 3x + 3)\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      5.1667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{2}{3}x^{3} + \frac{3}{2}x^{2} + 3x$. Como $F(0)=0$, $F(1)=\frac{31}{6} \approx 5.1667$.',
      33
    ),
    (
      'Si $F(x)=\int (2x^{2} + 4x + 3)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      19.3333::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{2}{3}x^{3} + 2x^{2} + 3x$. Como $F(0)=0$, $F(2)=\frac{58}{3} \approx 19.3333$.',
      34
    ),
    (
      'Si $F(x)=\int (3x^{2} - x + 3)\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      3.5::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=x^{3} - \frac{1}{2}x^{2} + 3x$. Como $F(0)=0$, $F(1)=\frac{7}{2} \approx 3.5$.',
      35
    ),
    (
      'Si $F(x)=\int (3x^{2} + 2x + 3)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      18::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=x^{3} + x^{2} + 3x$. Como $F(0)=0$, $F(2)=18$.',
      36
    ),
    (
      'Si $F(x)=\int (x^{2} + 4x + 4)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      18.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{1}{3}x^{3} + 2x^{2} + 4x$. Como $F(0)=0$, $F(2)=\frac{56}{3} \approx 18.6667$.',
      37
    ),
    (
      'Si $F(x)=\int (4x^{2} + 2x + 4)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      22.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{3}x^{3} + x^{2} + 4x$. Como $F(0)=0$, $F(2)=\frac{68}{3} \approx 22.6667$.',
      38
    ),
    (
      'Si $F(x)=\int (2x^{2} - x + 4)\,dx$ y $F(0)=0$, ¿cuánto vale $F(1)$?',
      'numeric',
      null::jsonb,
      null::integer,
      4.1667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{2}{3}x^{3} - \frac{1}{2}x^{2} + 4x$. Como $F(0)=0$, $F(1)=\frac{25}{6} \approx 4.1667$.',
      39
    ),
    (
      'Si $F(x)=\int (3x^{2} + 3x + 5)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=x^{3} + \frac{3}{2}x^{2} + 5x$. Como $F(0)=0$, $F(2)=24$.',
      40
    ),
    (
      'Si $F(x)=\int (4x^{2} - 4x + 3)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      8.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{3}x^{3} - 2x^{2} + 3x$. Como $F(0)=0$, $F(2)=\frac{26}{3} \approx 8.6667$.',
      41
    ),
    (
      'Si $F(x)=\int (3x^{2} + 2x + 2)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=x^{3} + x^{2} + 2x$. Como $F(0)=0$, $F(2)=16$.',
      42
    ),
    (
      'Si $F(x)=\int (3x^{3} + 3)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      18::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{3}{4}x^{4} + 3x$. Como $F(0)=0$, $F(2)=18$.',
      43
    ),
    (
      'Si $F(x)=\int (5x^{3} + 9)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      38::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{5}{4}x^{4} + 9x$. Como $F(0)=0$, $F(2)=38$.',
      44
    ),
    (
      'Si $F(x)=\int (4x^{3} + 7)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      30::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=x^{4} + 7x$. Como $F(0)=0$, $F(2)=30$.',
      45
    ),
    (
      'Si $F(x)=\int (6x^{2} + 8)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      32::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2x^{3} + 8x$. Como $F(0)=0$, $F(2)=32$.',
      46
    ),
    (
      'Si $F(x)=\int (4x^{2} + 1)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      12.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{3}x^{3} + x$. Como $F(0)=0$, $F(2)=\frac{38}{3} \approx 12.6667$.',
      47
    ),
    (
      'Si $F(x)=\int (5x^{3} + 8)\,dx$ y $F(0)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      125.25::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{5}{4}x^{4} + 8x$. Como $F(0)=0$, $F(3)=\frac{501}{4} \approx 125.25$.',
      48
    ),
    (
      'Si $F(x)=\int (2x^{2} + 8)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      21.3333::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{2}{3}x^{3} + 8x$. Como $F(0)=0$, $F(2)=\frac{64}{3} \approx 21.3333$.',
      49
    ),
    (
      'Si $F(x)=\int (2x + 2)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=x^{2} + 2x$. Como $F(0)=0$, $F(2)=8$.',
      50
    ),
    (
      'Si $F(x)=\int (2x^{3} + 9)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      26::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{1}{2}x^{4} + 9x$. Como $F(0)=0$, $F(2)=26$.',
      51
    ),
    (
      'Si $F(x)=\int (6x^{2} + 7)\,dx$ y $F(0)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      30::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2x^{3} + 7x$. Como $F(0)=0$, $F(2)=30$.',
      52
    ),
    (
      'Si $F(x)=\int 8\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      42.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{16}{3}x\sqrt{x}$. Como $F(0)=0$, $F(4)=\frac{128}{3} \approx 42.6667$.',
      53
    ),
    (
      'Si $F(x)=\int \sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      5.3333::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{2}{3}x\sqrt{x}$. Como $F(0)=0$, $F(4)=\frac{16}{3} \approx 5.3333$.',
      54
    ),
    (
      'Si $F(x)=\int 7\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(16)$?',
      'numeric',
      null::jsonb,
      null::integer,
      298.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{14}{3}x\sqrt{x}$. Como $F(0)=0$, $F(16)=\frac{896}{3} \approx 298.6667$.',
      55
    ),
    (
      'Si $F(x)=\int 5\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(25)$?',
      'numeric',
      null::jsonb,
      null::integer,
      416.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{10}{3}x\sqrt{x}$. Como $F(0)=0$, $F(25)=\frac{1250}{3} \approx 416.6667$.',
      56
    ),
    (
      'Si $F(x)=\int 2\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(25)$?',
      'numeric',
      null::jsonb,
      null::integer,
      166.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{3}x\sqrt{x}$. Como $F(0)=0$, $F(25)=\frac{500}{3} \approx 166.6667$.',
      57
    ),
    (
      'Si $F(x)=\int \sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(16)$?',
      'numeric',
      null::jsonb,
      null::integer,
      42.6667::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{2}{3}x\sqrt{x}$. Como $F(0)=0$, $F(16)=\frac{128}{3} \approx 42.6667$.',
      58
    ),
    (
      'Si $F(x)=\int 6\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      108::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=4x\sqrt{x}$. Como $F(0)=0$, $F(9)=108$.',
      59
    ),
    (
      'Si $F(x)=\int 3\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(16)$?',
      'numeric',
      null::jsonb,
      null::integer,
      128::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2x\sqrt{x}$. Como $F(0)=0$, $F(16)=128$.',
      60
    ),
    (
      'Si $F(x)=\int 4\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(25)$?',
      'numeric',
      null::jsonb,
      null::integer,
      333.3333::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{8}{3}x\sqrt{x}$. Como $F(0)=0$, $F(25)=\frac{1000}{3} \approx 333.3333$.',
      61
    ),
    (
      'Si $F(x)=\int \sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      18::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{2}{3}x\sqrt{x}$. Como $F(0)=0$, $F(9)=18$.',
      62
    ),
    (
      'Si $F(x)=\int 8x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      777.6::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{16}{5}x^2\sqrt{x}$. Como $F(0)=0$, $F(9)=\frac{3888}{5} \approx 777.6$.',
      63
    ),
    (
      'Si $F(x)=\int 5x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(25)$?',
      'numeric',
      null::jsonb,
      null::integer,
      6250::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2x^2\sqrt{x}$. Como $F(0)=0$, $F(25)=6250$.',
      64
    ),
    (
      'Si $F(x)=\int 8x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(25)$?',
      'numeric',
      null::jsonb,
      null::integer,
      10000::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{16}{5}x^2\sqrt{x}$. Como $F(0)=0$, $F(25)=10000$.',
      65
    ),
    (
      'Si $F(x)=\int 5x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      64::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2x^2\sqrt{x}$. Como $F(0)=0$, $F(4)=64$.',
      66
    ),
    (
      'Si $F(x)=\int 2x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      194.4::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{5}x^2\sqrt{x}$. Como $F(0)=0$, $F(9)=\frac{972}{5} \approx 194.4$.',
      67
    ),
    (
      'Si $F(x)=\int 2x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      25.6::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{4}{5}x^2\sqrt{x}$. Como $F(0)=0$, $F(4)=\frac{128}{5} \approx 25.6$.',
      68
    ),
    (
      'Si $F(x)=\int 8x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(16)$?',
      'numeric',
      null::jsonb,
      null::integer,
      3276.8::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{16}{5}x^2\sqrt{x}$. Como $F(0)=0$, $F(16)=\frac{16384}{5} \approx 3276.8$.',
      69
    ),
    (
      'Si $F(x)=\int 7x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(16)$?',
      'numeric',
      null::jsonb,
      null::integer,
      2867.2::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{14}{5}x^2\sqrt{x}$. Como $F(0)=0$, $F(16)=\frac{14336}{5} \approx 2867.2$.',
      70
    ),
    (
      'Si $F(x)=\int 6x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      583.2::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{12}{5}x^2\sqrt{x}$. Como $F(0)=0$, $F(9)=\frac{2916}{5} \approx 583.2$.',
      71
    ),
    (
      'Si $F(x)=\int 3x\sqrt{x}\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      291.6::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{6}{5}x^2\sqrt{x}$. Como $F(0)=0$, $F(9)=\frac{1458}{5} \approx 291.6$.',
      72
    ),
    (
      'Si $F(x)=\int \frac{5}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(16)$?',
      'numeric',
      null::jsonb,
      null::integer,
      40::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=10\sqrt{x}$. Como $F(0)=0$, $F(16)=40$.',
      73
    ),
    (
      'Si $F(x)=\int \frac{3}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(16)$?',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=6\sqrt{x}$. Como $F(0)=0$, $F(16)=24$.',
      74
    ),
    (
      'Si $F(x)=\int \frac{7}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      42::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=14\sqrt{x}$. Como $F(0)=0$, $F(9)=42$.',
      75
    ),
    (
      'Si $F(x)=\int \frac{8}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      32::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=16\sqrt{x}$. Como $F(0)=0$, $F(4)=32$.',
      76
    ),
    (
      'Si $F(x)=\int \frac{1}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(16)$?',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2\sqrt{x}$. Como $F(0)=0$, $F(16)=8$.',
      77
    ),
    (
      'Si $F(x)=\int \frac{6}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      36::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=12\sqrt{x}$. Como $F(0)=0$, $F(9)=36$.',
      78
    ),
    (
      'Si $F(x)=\int \frac{3}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(25)$?',
      'numeric',
      null::jsonb,
      null::integer,
      30::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=6\sqrt{x}$. Como $F(0)=0$, $F(25)=30$.',
      79
    ),
    (
      'Si $F(x)=\int \frac{6}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=12\sqrt{x}$. Como $F(0)=0$, $F(4)=24$.',
      80
    ),
    (
      'Si $F(x)=\int \frac{2}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(25)$?',
      'numeric',
      null::jsonb,
      null::integer,
      20::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=4\sqrt{x}$. Como $F(0)=0$, $F(25)=20$.',
      81
    ),
    (
      'Si $F(x)=\int \frac{3}{\sqrt{x}}\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=6\sqrt{x}$. Como $F(0)=0$, $F(4)=12$.',
      82
    ),
    (
      'Si $F(x)=\int (3x + 6\sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      229.5::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{3}{2}x^{2} + 4x\sqrt{x}$. Como $F(0)=0$, $F(9)=\frac{459}{2} \approx 229.5$.',
      83
    ),
    (
      'Si $F(x)=\int (4x + 4\sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      53.3333::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=2x^{2} + \frac{8}{3}x\sqrt{x}$. Como $F(0)=0$, $F(4)=\frac{160}{3} \approx 53.3333$.',
      84
    ),
    (
      'Si $F(x)=\int (3x + 6\sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      56::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{3}{2}x^{2} + 4x\sqrt{x}$. Como $F(0)=0$, $F(4)=56$.',
      85
    ),
    (
      'Si $F(x)=\int (4x + 6\sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      270::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2x^{2} + 4x\sqrt{x}$. Como $F(0)=0$, $F(9)=270$.',
      86
    ),
    (
      'Si $F(x)=\int (x + 5\sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      130.5::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{1}{2}x^{2} + \frac{10}{3}x\sqrt{x}$. Como $F(0)=0$, $F(9)=\frac{261}{2} \approx 130.5$.',
      87
    ),
    (
      'Si $F(x)=\int (x + \sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      58.5::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{1}{2}x^{2} + \frac{2}{3}x\sqrt{x}$. Como $F(0)=0$, $F(9)=\frac{117}{2} \approx 58.5$.',
      88
    ),
    (
      'Si $F(x)=\int (4x + 5\sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      252::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2x^{2} + \frac{10}{3}x\sqrt{x}$. Como $F(0)=0$, $F(9)=252$.',
      89
    ),
    (
      'Si $F(x)=\int (4x + 3\sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      48::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=2x^{2} + 2x\sqrt{x}$. Como $F(0)=0$, $F(4)=48$.',
      90
    ),
    (
      'Si $F(x)=\int (5x + 6\sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(4)$?',
      'numeric',
      null::jsonb,
      null::integer,
      72::numeric,
      0.000001::numeric,
      'Se integra término a término: $F(x)=\frac{5}{2}x^{2} + 4x\sqrt{x}$. Como $F(0)=0$, $F(4)=72$.',
      91
    ),
    (
      'Si $F(x)=\int (x + 2\sqrt{x})\,dx$ y $F(0)=0$, ¿cuánto vale $F(9)$?',
      'numeric',
      null::jsonb,
      null::integer,
      76.5::numeric,
      0.001::numeric,
      'Se integra término a término: $F(x)=\frac{1}{2}x^{2} + \frac{4}{3}x\sqrt{x}$. Como $F(0)=0$, $F(9)=\frac{153}{2} \approx 76.5$.',
      92
    ),
    (
      'Si $F(x)=\int 8x^{2}\,dx$ y $F(1)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      69.3333::numeric,
      0.001::numeric,
      'Se integra término a término y se ajusta la constante: $F(x)=\frac{8}{3}x^{3} - \frac{8}{3}$. Como $F(1)=0$, $F(3)=\frac{208}{3} \approx 69.3333$.',
      93
    ),
    (
      'Si $F(x)=\int 3x^{4}\,dx$ y $F(1)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      18.6::numeric,
      0.001::numeric,
      'Se integra término a término y se ajusta la constante: $F(x)=\frac{3}{5}x^{5} - \frac{3}{5}$. Como $F(1)=0$, $F(2)=\frac{93}{5} \approx 18.6$.',
      94
    ),
    (
      'Si $F(x)=\int 4x\,dx$ y $F(1)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Se integra término a término y se ajusta la constante: $F(x)=2x^{2} - 2$. Como $F(1)=0$, $F(3)=16$.',
      95
    ),
    (
      'Si $F(x)=\int 6x\,dx$ y $F(1)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      9::numeric,
      0.000001::numeric,
      'Se integra término a término y se ajusta la constante: $F(x)=3x^{2} - 3$. Como $F(1)=0$, $F(2)=9$.',
      96
    ),
    (
      'Si $F(x)=\int 6x\,dx$ y $F(1)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.000001::numeric,
      'Se integra término a término y se ajusta la constante: $F(x)=3x^{2} - 3$. Como $F(1)=0$, $F(3)=24$.',
      97
    ),
    (
      'Si $F(x)=\int 5x\,dx$ y $F(1)=0$, ¿cuánto vale $F(2)$?',
      'numeric',
      null::jsonb,
      null::integer,
      7.5::numeric,
      0.001::numeric,
      'Se integra término a término y se ajusta la constante: $F(x)=\frac{5}{2}x^{2} - \frac{5}{2}$. Como $F(1)=0$, $F(2)=\frac{15}{2} \approx 7.5$.',
      98
    ),
    (
      'Si $F(x)=\int 5x^{3}\,dx$ y $F(1)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      100::numeric,
      0.000001::numeric,
      'Se integra término a término y se ajusta la constante: $F(x)=\frac{5}{4}x^{4} - \frac{5}{4}$. Como $F(1)=0$, $F(3)=100$.',
      99
    ),
    (
      'Si $F(x)=\int 4x^{2}\,dx$ y $F(1)=0$, ¿cuánto vale $F(3)$?',
      'numeric',
      null::jsonb,
      null::integer,
      34.6667::numeric,
      0.001::numeric,
      'Se integra término a término y se ajusta la constante: $F(x)=\frac{4}{3}x^{3} - \frac{4}{3}$. Como $F(1)=0$, $F(3)=\frac{104}{3} \approx 34.6667$.',
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
  select id from public.modules where slug = 'integrales-indefinidas-100'
) as m
where not exists (
  select 1
  from public.exercises e
  where e.module_id = m.id
);
