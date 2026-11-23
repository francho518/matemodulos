-- ============================================================
--  Matemódulos · Sólidos de revolución · 100 ejercicios
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
  'Sólidos de revolución · 100 ejercicios',
  'solidos-revolucion-100',
  '100 ejercicios de volúmenes de sólidos de revolución por discos, arandelas y capas cilíndricas. La respuesta es el coeficiente k del volumen kπ.',
  10,
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
      'La región limitada por $y=3$, el eje $x$ y las rectas $x=0$ y $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      36::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{0}^{4} 3^2\,dx=9(4-0)\pi=36\pi$. Por lo tanto, $k=36$.',
      1
    ),
    (
      'La región limitada por $y=2$, el eje $x$ y las rectas $x=1$ y $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{1}^{5} 2^2\,dx=4(5-1)\pi=16\pi$. Por lo tanto, $k=16$.',
      2
    ),
    (
      'La región limitada por $y=3$, el eje $x$ y las rectas $x=2$ y $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      18::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{2}^{4} 3^2\,dx=9(4-2)\pi=18\pi$. Por lo tanto, $k=18$.',
      3
    ),
    (
      'La región limitada por $y=2$, el eje $x$ y las rectas $x=2$ y $x=6$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{2}^{6} 2^2\,dx=4(6-2)\pi=16\pi$. Por lo tanto, $k=16$.',
      4
    ),
    (
      'La región limitada por $y=3$, el eje $x$ y las rectas $x=2$ y $x=6$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      36::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{2}^{6} 3^2\,dx=9(6-2)\pi=36\pi$. Por lo tanto, $k=36$.',
      5
    ),
    (
      'La región limitada por $y=5$, el eje $x$ y las rectas $x=1$ y $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      100::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{1}^{5} 5^2\,dx=25(5-1)\pi=100\pi$. Por lo tanto, $k=100$.',
      6
    ),
    (
      'La región limitada por $y=4$, el eje $x$ y las rectas $x=0$ y $x=2$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      32::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{0}^{2} 4^2\,dx=16(2-0)\pi=32\pi$. Por lo tanto, $k=32$.',
      7
    ),
    (
      'La región limitada por $y=3$, el eje $x$ y las rectas $x=2$ y $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      27::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{2}^{5} 3^2\,dx=9(5-2)\pi=27\pi$. Por lo tanto, $k=27$.',
      8
    ),
    (
      'La región limitada por $y=5$, el eje $x$ y las rectas $x=0$ y $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      75::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{0}^{3} 5^2\,dx=25(3-0)\pi=75\pi$. Por lo tanto, $k=75$.',
      9
    ),
    (
      'La región limitada por $y=2$, el eje $x$ y las rectas $x=0$ y $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{0}^{4} 2^2\,dx=4(4-0)\pi=16\pi$. Por lo tanto, $k=16$.',
      10
    ),
    (
      'La región limitada por $y=4$, el eje $x$ y las rectas $x=2$ y $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      48::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{2}^{5} 4^2\,dx=16(5-2)\pi=48\pi$. Por lo tanto, $k=48$.',
      11
    ),
    (
      'La región limitada por $y=4$, el eje $x$ y las rectas $x=2$ y $x=6$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      64::numeric,
      0.000001::numeric,
      'Por el método de discos, $V=\pi\int_{2}^{6} 4^2\,dx=16(6-2)\pi=64\pi$. Por lo tanto, $k=64$.',
      12
    ),
    (
      'La región limitada por $y=x$, el eje $x$ y la recta $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      41.6667::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{5} (x)^2\,dx=\pi\int_{0}^{5} 1x^2\,dx=\frac{1\cdot 5^3}{3}\pi=\frac{125}{3}\pi$. Por lo tanto, $k=\frac{125}{3} \approx 41.6667$.',
      13
    ),
    (
      'La región limitada por $y=x$, el eje $x$ y la recta $x=1$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.3333::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{1} (x)^2\,dx=\pi\int_{0}^{1} 1x^2\,dx=\frac{1\cdot 1^3}{3}\pi=\frac{1}{3}\pi$. Por lo tanto, $k=\frac{1}{3} \approx 0.3333$.',
      14
    ),
    (
      'La región limitada por $y=x$, el eje $x$ y la recta $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      9::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (x)^2\,dx=\pi\int_{0}^{3} 1x^2\,dx=\frac{1\cdot 3^3}{3}\pi=9\pi$. Por lo tanto, $k=9$.',
      15
    ),
    (
      'La región limitada por $y=2x$, el eje $x$ y la recta $x=6$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      288::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{6} (2x)^2\,dx=\pi\int_{0}^{6} 4x^2\,dx=\frac{4\cdot 6^3}{3}\pi=288\pi$. Por lo tanto, $k=288$.',
      16
    ),
    (
      'La región limitada por $y=3x$, el eje $x$ y la recta $x=2$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{2} (3x)^2\,dx=\pi\int_{0}^{2} 9x^2\,dx=\frac{9\cdot 2^3}{3}\pi=24\pi$. Por lo tanto, $k=24$.',
      17
    ),
    (
      'La región limitada por $y=x$, el eje $x$ y la recta $x=6$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      72::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{6} (x)^2\,dx=\pi\int_{0}^{6} 1x^2\,dx=\frac{1\cdot 6^3}{3}\pi=72\pi$. Por lo tanto, $k=72$.',
      18
    ),
    (
      'La región limitada por $y=2x$, el eje $x$ y la recta $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      85.3333::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{4} (2x)^2\,dx=\pi\int_{0}^{4} 4x^2\,dx=\frac{4\cdot 4^3}{3}\pi=\frac{256}{3}\pi$. Por lo tanto, $k=\frac{256}{3} \approx 85.3333$.',
      19
    ),
    (
      'La región limitada por $y=x$, el eje $x$ y la recta $x=2$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      2.6667::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{2} (x)^2\,dx=\pi\int_{0}^{2} 1x^2\,dx=\frac{1\cdot 2^3}{3}\pi=\frac{8}{3}\pi$. Por lo tanto, $k=\frac{8}{3} \approx 2.6667$.',
      20
    ),
    (
      'La región limitada por $y=3x$, el eje $x$ y la recta $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      192::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{4} (3x)^2\,dx=\pi\int_{0}^{4} 9x^2\,dx=\frac{9\cdot 4^3}{3}\pi=192\pi$. Por lo tanto, $k=192$.',
      21
    ),
    (
      'La región limitada por $y=3x$, el eje $x$ y la recta $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      375::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{5} (3x)^2\,dx=\pi\int_{0}^{5} 9x^2\,dx=\frac{9\cdot 5^3}{3}\pi=375\pi$. Por lo tanto, $k=375$.',
      22
    ),
    (
      'La región limitada por $y=2x$, el eje $x$ y la recta $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      166.6667::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{5} (2x)^2\,dx=\pi\int_{0}^{5} 4x^2\,dx=\frac{4\cdot 5^3}{3}\pi=\frac{500}{3}\pi$. Por lo tanto, $k=\frac{500}{3} \approx 166.6667$.',
      23
    ),
    (
      'La región limitada por $y=2x$, el eje $x$ y la recta $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      36::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (2x)^2\,dx=\pi\int_{0}^{3} 4x^2\,dx=\frac{4\cdot 3^3}{3}\pi=36\pi$. Por lo tanto, $k=36$.',
      24
    ),
    (
      'La región bajo $y=2x^2$ entre $x=0$ y $x=1$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.8::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{1} (2x^2)^2\,dx=\frac{4\cdot 1^5}{5}\pi=\frac{4}{5}\pi$. Por lo tanto, $k=\frac{4}{5} \approx 0.8$.',
      25
    ),
    (
      'La región bajo $y=2x^2$ entre $x=0$ y $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      194.4::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (2x^2)^2\,dx=\frac{4\cdot 3^5}{5}\pi=\frac{972}{5}\pi$. Por lo tanto, $k=\frac{972}{5} \approx 194.4$.',
      26
    ),
    (
      'La región bajo $y=2x^2$ entre $x=0$ y $x=2$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      25.6::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{2} (2x^2)^2\,dx=\frac{4\cdot 2^5}{5}\pi=\frac{128}{5}\pi$. Por lo tanto, $k=\frac{128}{5} \approx 25.6$.',
      27
    ),
    (
      'La región bajo $y=x^2$ entre $x=0$ y $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      204.8::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{4} (x^2)^2\,dx=\frac{1\cdot 4^5}{5}\pi=\frac{1024}{5}\pi$. Por lo tanto, $k=\frac{1024}{5} \approx 204.8$.',
      28
    ),
    (
      'La región bajo $y=x^2$ entre $x=0$ y $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      48.6::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (x^2)^2\,dx=\frac{1\cdot 3^5}{5}\pi=\frac{243}{5}\pi$. Por lo tanto, $k=\frac{243}{5} \approx 48.6$.',
      29
    ),
    (
      'La región bajo $y=x^2$ entre $x=0$ y $x=2$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      6.4::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{2} (x^2)^2\,dx=\frac{1\cdot 2^5}{5}\pi=\frac{32}{5}\pi$. Por lo tanto, $k=\frac{32}{5} \approx 6.4$.',
      30
    ),
    (
      'La región bajo $y=x^2$ entre $x=0$ y $x=6$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      1555.2::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{6} (x^2)^2\,dx=\frac{1\cdot 6^5}{5}\pi=\frac{7776}{5}\pi$. Por lo tanto, $k=\frac{7776}{5} \approx 1555.2$.',
      31
    ),
    (
      'La región bajo $y=x^2$ entre $x=0$ y $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      625::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{5} (x^2)^2\,dx=\frac{1\cdot 5^5}{5}\pi=625\pi$. Por lo tanto, $k=625$.',
      32
    ),
    (
      'La región bajo $y=2x^2$ entre $x=0$ y $x=6$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      6220.8::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{6} (2x^2)^2\,dx=\frac{4\cdot 6^5}{5}\pi=\frac{31104}{5}\pi$. Por lo tanto, $k=\frac{31104}{5} \approx 6220.8$.',
      33
    ),
    (
      'La región bajo $y=2x^2$ entre $x=0$ y $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      2500::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{5} (2x^2)^2\,dx=\frac{4\cdot 5^5}{5}\pi=2500\pi$. Por lo tanto, $k=2500$.',
      34
    ),
    (
      'La región bajo $y=x^2$ entre $x=0$ y $x=1$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.2::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{1} (x^2)^2\,dx=\frac{1\cdot 1^5}{5}\pi=\frac{1}{5}\pi$. Por lo tanto, $k=\frac{1}{5} \approx 0.2$.',
      35
    ),
    (
      'La región bajo $y=2x^2$ entre $x=0$ y $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      819.2::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{4} (2x^2)^2\,dx=\frac{4\cdot 4^5}{5}\pi=\frac{4096}{5}\pi$. Por lo tanto, $k=\frac{4096}{5} \approx 819.2$.',
      36
    ),
    (
      'La región bajo $y=3\sqrt{x}$ entre $x=0$ y $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      112.5::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{5} (3\sqrt{x})^2\,dx=\pi\int_{0}^{5} 9x\,dx=\frac{9\cdot 5^2}{2}\pi=\frac{225}{2}\pi$. Por lo tanto, $k=\frac{225}{2} \approx 112.5$.',
      37
    ),
    (
      'La región bajo $y=\sqrt{x}$ entre $x=0$ y $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      4.5::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (\sqrt{x})^2\,dx=\pi\int_{0}^{3} 1x\,dx=\frac{1\cdot 3^2}{2}\pi=\frac{9}{2}\pi$. Por lo tanto, $k=\frac{9}{2} \approx 4.5$.',
      38
    ),
    (
      'La región bajo $y=3\sqrt{x}$ entre $x=0$ y $x=1$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      4.5::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{1} (3\sqrt{x})^2\,dx=\pi\int_{0}^{1} 9x\,dx=\frac{9\cdot 1^2}{2}\pi=\frac{9}{2}\pi$. Por lo tanto, $k=\frac{9}{2} \approx 4.5$.',
      39
    ),
    (
      'La región bajo $y=3\sqrt{x}$ entre $x=0$ y $x=6$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      162::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{6} (3\sqrt{x})^2\,dx=\pi\int_{0}^{6} 9x\,dx=\frac{9\cdot 6^2}{2}\pi=162\pi$. Por lo tanto, $k=162$.',
      40
    ),
    (
      'La región bajo $y=2\sqrt{x}$ entre $x=0$ y $x=1$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{1} (2\sqrt{x})^2\,dx=\pi\int_{0}^{1} 4x\,dx=\frac{4\cdot 1^2}{2}\pi=2\pi$. Por lo tanto, $k=2$.',
      41
    ),
    (
      'La región bajo $y=\sqrt{x}$ entre $x=0$ y $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      12.5::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{5} (\sqrt{x})^2\,dx=\pi\int_{0}^{5} 1x\,dx=\frac{1\cdot 5^2}{2}\pi=\frac{25}{2}\pi$. Por lo tanto, $k=\frac{25}{2} \approx 12.5$.',
      42
    ),
    (
      'La región bajo $y=2\sqrt{x}$ entre $x=0$ y $x=5$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      50::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{5} (2\sqrt{x})^2\,dx=\pi\int_{0}^{5} 4x\,dx=\frac{4\cdot 5^2}{2}\pi=50\pi$. Por lo tanto, $k=50$.',
      43
    ),
    (
      'La región bajo $y=\sqrt{x}$ entre $x=0$ y $x=1$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.5::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{1} (\sqrt{x})^2\,dx=\pi\int_{0}^{1} 1x\,dx=\frac{1\cdot 1^2}{2}\pi=\frac{1}{2}\pi$. Por lo tanto, $k=\frac{1}{2} \approx 0.5$.',
      44
    ),
    (
      'La región bajo $y=\sqrt{x}$ entre $x=0$ y $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{4} (\sqrt{x})^2\,dx=\pi\int_{0}^{4} 1x\,dx=\frac{1\cdot 4^2}{2}\pi=8\pi$. Por lo tanto, $k=8$.',
      45
    ),
    (
      'La región bajo $y=3\sqrt{x}$ entre $x=0$ y $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      72::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{4} (3\sqrt{x})^2\,dx=\pi\int_{0}^{4} 9x\,dx=\frac{9\cdot 4^2}{2}\pi=72\pi$. Por lo tanto, $k=72$.',
      46
    ),
    (
      'La región bajo $y=3\sqrt{x}$ entre $x=0$ y $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      40.5::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (3\sqrt{x})^2\,dx=\pi\int_{0}^{3} 9x\,dx=\frac{9\cdot 3^2}{2}\pi=\frac{81}{2}\pi$. Por lo tanto, $k=\frac{81}{2} \approx 40.5$.',
      47
    ),
    (
      'La región bajo $y=\sqrt{x}$ entre $x=0$ y $x=6$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      18::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{6} (\sqrt{x})^2\,dx=\pi\int_{0}^{6} 1x\,dx=\frac{1\cdot 6^2}{2}\pi=18\pi$. Por lo tanto, $k=18$.',
      48
    ),
    (
      'La región limitada por $y=x+3$, el eje $x$ y la recta $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      63::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (x+3)^2\,dx=\pi\left[\frac{(x+3)^3}{3}\right]_{0}^{3}=63\pi$. Por lo tanto, $k=63$.',
      49
    ),
    (
      'La región limitada por $y=x+5$, el eje $x$ y la recta $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      201.3333::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{4} (x+5)^2\,dx=\pi\left[\frac{(x+5)^3}{3}\right]_{0}^{4}=\frac{604}{3}\pi$. Por lo tanto, $k=\frac{604}{3} \approx 201.3333$.',
      50
    ),
    (
      'La región limitada por $y=x+4$, el eje $x$ y la recta $x=2$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      50.6667::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{2} (x+4)^2\,dx=\pi\left[\frac{(x+4)^3}{3}\right]_{0}^{2}=\frac{152}{3}\pi$. Por lo tanto, $k=\frac{152}{3} \approx 50.6667$.',
      51
    ),
    (
      'La región limitada por $y=x+2$, el eje $x$ y la recta $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      69.3333::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{4} (x+2)^2\,dx=\pi\left[\frac{(x+2)^3}{3}\right]_{0}^{4}=\frac{208}{3}\pi$. Por lo tanto, $k=\frac{208}{3} \approx 69.3333$.',
      52
    ),
    (
      'La región limitada por $y=x+5$, el eje $x$ y la recta $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      129::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (x+5)^2\,dx=\pi\left[\frac{(x+5)^3}{3}\right]_{0}^{3}=129\pi$. Por lo tanto, $k=129$.',
      53
    ),
    (
      'La región limitada por $y=x+3$, el eje $x$ y la recta $x=1$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      12.3333::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{1} (x+3)^2\,dx=\pi\left[\frac{(x+3)^3}{3}\right]_{0}^{1}=\frac{37}{3}\pi$. Por lo tanto, $k=\frac{37}{3} \approx 12.3333$.',
      54
    ),
    (
      'La región limitada por $y=x+1$, el eje $x$ y la recta $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      21::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (x+1)^2\,dx=\pi\left[\frac{(x+1)^3}{3}\right]_{0}^{3}=21\pi$. Por lo tanto, $k=21$.',
      55
    ),
    (
      'La región limitada por $y=x+4$, el eje $x$ y la recta $x=1$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      20.3333::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{1} (x+4)^2\,dx=\pi\left[\frac{(x+4)^3}{3}\right]_{0}^{1}=\frac{61}{3}\pi$. Por lo tanto, $k=\frac{61}{3} \approx 20.3333$.',
      56
    ),
    (
      'La región limitada por $y=x+2$, el eje $x$ y la recta $x=3$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      39::numeric,
      0.000001::numeric,
      'Por discos, $V=\pi\int_{0}^{3} (x+2)^2\,dx=\pi\left[\frac{(x+2)^3}{3}\right]_{0}^{3}=39\pi$. Por lo tanto, $k=39$.',
      57
    ),
    (
      'La región limitada por $y=x+4$, el eje $x$ y la recta $x=4$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      149.3333::numeric,
      0.001::numeric,
      'Por discos, $V=\pi\int_{0}^{4} (x+4)^2\,dx=\pi\left[\frac{(x+4)^3}{3}\right]_{0}^{4}=\frac{448}{3}\pi$. Por lo tanto, $k=\frac{448}{3} \approx 149.3333$.',
      58
    ),
    (
      'La región entre $y=2x$ y $y=2x^4$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.8889::numeric,
      0.001::numeric,
      'La curva exterior es $y=2x$ y la interior $y=2x^4$. Por arandelas, $V=\pi\int_{0}^{1}\left[(2x)^2-(2x^4)^2\right]dx=\frac{8}{9}\pi$. Por lo tanto, $k=\frac{8}{9} \approx 0.8889$.',
      59
    ),
    (
      'La región entre $y=2x$ y $y=2x^3$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.7619::numeric,
      0.001::numeric,
      'La curva exterior es $y=2x$ y la interior $y=2x^3$. Por arandelas, $V=\pi\int_{0}^{1}\left[(2x)^2-(2x^3)^2\right]dx=\frac{16}{21}\pi$. Por lo tanto, $k=\frac{16}{21} \approx 0.7619$.',
      60
    ),
    (
      'La región entre $y=x$ y $y=x^3$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.1905::numeric,
      0.001::numeric,
      'La curva exterior es $y=x$ y la interior $y=x^3$. Por arandelas, $V=\pi\int_{0}^{1}\left[(x)^2-(x^3)^2\right]dx=\frac{4}{21}\pi$. Por lo tanto, $k=\frac{4}{21} \approx 0.1905$.',
      61
    ),
    (
      'La región entre $y=2x$ y $y=2x^2$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.5333::numeric,
      0.001::numeric,
      'La curva exterior es $y=2x$ y la interior $y=2x^2$. Por arandelas, $V=\pi\int_{0}^{1}\left[(2x)^2-(2x^2)^2\right]dx=\frac{8}{15}\pi$. Por lo tanto, $k=\frac{8}{15} \approx 0.5333$.',
      62
    ),
    (
      'La región entre $y=2x$ y $y=2x^5$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.9697::numeric,
      0.001::numeric,
      'La curva exterior es $y=2x$ y la interior $y=2x^5$. Por arandelas, $V=\pi\int_{0}^{1}\left[(2x)^2-(2x^5)^2\right]dx=\frac{32}{33}\pi$. Por lo tanto, $k=\frac{32}{33} \approx 0.9697$.',
      63
    ),
    (
      'La región entre $y=2x$ y $y=2x^6$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      1.0256::numeric,
      0.001::numeric,
      'La curva exterior es $y=2x$ y la interior $y=2x^6$. Por arandelas, $V=\pi\int_{0}^{1}\left[(2x)^2-(2x^6)^2\right]dx=\frac{40}{39}\pi$. Por lo tanto, $k=\frac{40}{39} \approx 1.0256$.',
      64
    ),
    (
      'La región entre $y=x$ y $y=x^5$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.2424::numeric,
      0.001::numeric,
      'La curva exterior es $y=x$ y la interior $y=x^5$. Por arandelas, $V=\pi\int_{0}^{1}\left[(x)^2-(x^5)^2\right]dx=\frac{8}{33}\pi$. Por lo tanto, $k=\frac{8}{33} \approx 0.2424$.',
      65
    ),
    (
      'La región entre $y=x$ y $y=x^6$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.2564::numeric,
      0.001::numeric,
      'La curva exterior es $y=x$ y la interior $y=x^6$. Por arandelas, $V=\pi\int_{0}^{1}\left[(x)^2-(x^6)^2\right]dx=\frac{10}{39}\pi$. Por lo tanto, $k=\frac{10}{39} \approx 0.2564$.',
      66
    ),
    (
      'La región entre $y=x$ y $y=x^2$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.1333::numeric,
      0.001::numeric,
      'La curva exterior es $y=x$ y la interior $y=x^2$. Por arandelas, $V=\pi\int_{0}^{1}\left[(x)^2-(x^2)^2\right]dx=\frac{2}{15}\pi$. Por lo tanto, $k=\frac{2}{15} \approx 0.1333$.',
      67
    ),
    (
      'La región entre $y=x$ y $y=x^4$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.2222::numeric,
      0.001::numeric,
      'La curva exterior es $y=x$ y la interior $y=x^4$. Por arandelas, $V=\pi\int_{0}^{1}\left[(x)^2-(x^4)^2\right]dx=\frac{2}{9}\pi$. Por lo tanto, $k=\frac{2}{9} \approx 0.2222$.',
      68
    ),
    (
      'La región entre $y=x^{1/6}$ y $y=x$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.4167::numeric,
      0.001::numeric,
      'La curva exterior es $y=x^{1/6}$. Por arandelas, $V=\pi\int_{0}^{1}\left[(x^{1/6})^2-(x)^2\right]dx=\frac{5}{12}\pi$. Por lo tanto, $k=\frac{5}{12} \approx 0.4167$.',
      69
    ),
    (
      'La región entre $y=2x^{1/5}$ y $y=2x$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      1.5238::numeric,
      0.001::numeric,
      'La curva exterior es $y=2x^{1/5}$. Por arandelas, $V=\pi\int_{0}^{1}\left[(2x^{1/5})^2-(2x)^2\right]dx=\frac{32}{21}\pi$. Por lo tanto, $k=\frac{32}{21} \approx 1.5238$.',
      70
    ),
    (
      'La región entre $y=2x^{1/3}$ y $y=2x$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      1.0667::numeric,
      0.001::numeric,
      'La curva exterior es $y=2x^{1/3}$. Por arandelas, $V=\pi\int_{0}^{1}\left[(2x^{1/3})^2-(2x)^2\right]dx=\frac{16}{15}\pi$. Por lo tanto, $k=\frac{16}{15} \approx 1.0667$.',
      71
    ),
    (
      'La región entre $y=x^{1/3}$ y $y=x$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.2667::numeric,
      0.001::numeric,
      'La curva exterior es $y=x^{1/3}$. Por arandelas, $V=\pi\int_{0}^{1}\left[(x^{1/3})^2-(x)^2\right]dx=\frac{4}{15}\pi$. Por lo tanto, $k=\frac{4}{15} \approx 0.2667$.',
      72
    ),
    (
      'La región entre $y=x^{1/5}$ y $y=x$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.381::numeric,
      0.001::numeric,
      'La curva exterior es $y=x^{1/5}$. Por arandelas, $V=\pi\int_{0}^{1}\left[(x^{1/5})^2-(x)^2\right]dx=\frac{8}{21}\pi$. Por lo tanto, $k=\frac{8}{21} \approx 0.381$.',
      73
    ),
    (
      'La región entre $y=2x^{1/6}$ y $y=2x$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      1.6667::numeric,
      0.001::numeric,
      'La curva exterior es $y=2x^{1/6}$. Por arandelas, $V=\pi\int_{0}^{1}\left[(2x^{1/6})^2-(2x)^2\right]dx=\frac{5}{3}\pi$. Por lo tanto, $k=\frac{5}{3} \approx 1.6667$.',
      74
    ),
    (
      'La región entre $y=2x^{1/4}$ y $y=2x$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      1.3333::numeric,
      0.001::numeric,
      'La curva exterior es $y=2x^{1/4}$. Por arandelas, $V=\pi\int_{0}^{1}\left[(2x^{1/4})^2-(2x)^2\right]dx=\frac{4}{3}\pi$. Por lo tanto, $k=\frac{4}{3} \approx 1.3333$.',
      75
    ),
    (
      'La región entre $y=x^{1/4}$ y $y=x$ en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.3333::numeric,
      0.001::numeric,
      'La curva exterior es $y=x^{1/4}$. Por arandelas, $V=\pi\int_{0}^{1}\left[(x^{1/4})^2-(x)^2\right]dx=\frac{1}{3}\pi$. Por lo tanto, $k=\frac{1}{3} \approx 0.3333$.',
      76
    ),
    (
      'La región limitada por $y=x$, el eje $x$ y la recta $x=4$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      42.6667::numeric,
      0.001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{4} x\cdot x\,dx=2\pi\int_{0}^{4} 1x^2\,dx=\frac{128}{3}\pi$. Por lo tanto, $k=\frac{128}{3} \approx 42.6667$.',
      77
    ),
    (
      'La región limitada por $y=3x$, el eje $x$ y la recta $x=4$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      128::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{4} x\cdot 3x\,dx=2\pi\int_{0}^{4} 3x^2\,dx=128\pi$. Por lo tanto, $k=128$.',
      78
    ),
    (
      'La región limitada por $y=2x$, el eje $x$ y la recta $x=2$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      10.6667::numeric,
      0.001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{2} x\cdot 2x\,dx=2\pi\int_{0}^{2} 2x^2\,dx=\frac{32}{3}\pi$. Por lo tanto, $k=\frac{32}{3} \approx 10.6667$.',
      79
    ),
    (
      'La región limitada por $y=3x$, el eje $x$ y la recta $x=2$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{2} x\cdot 3x\,dx=2\pi\int_{0}^{2} 3x^2\,dx=16\pi$. Por lo tanto, $k=16$.',
      80
    ),
    (
      'La región limitada por $y=3x$, el eje $x$ y la recta $x=3$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      54::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{3} x\cdot 3x\,dx=2\pi\int_{0}^{3} 3x^2\,dx=54\pi$. Por lo tanto, $k=54$.',
      81
    ),
    (
      'La región limitada por $y=x$, el eje $x$ y la recta $x=2$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      5.3333::numeric,
      0.001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{2} x\cdot x\,dx=2\pi\int_{0}^{2} 1x^2\,dx=\frac{16}{3}\pi$. Por lo tanto, $k=\frac{16}{3} \approx 5.3333$.',
      82
    ),
    (
      'La región limitada por $y=x$, el eje $x$ y la recta $x=3$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      18::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{3} x\cdot x\,dx=2\pi\int_{0}^{3} 1x^2\,dx=18\pi$. Por lo tanto, $k=18$.',
      83
    ),
    (
      'La región limitada por $y=3x$, el eje $x$ y la recta $x=1$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{1} x\cdot 3x\,dx=2\pi\int_{0}^{1} 3x^2\,dx=2\pi$. Por lo tanto, $k=2$.',
      84
    ),
    (
      'La región limitada por $y=2x$, el eje $x$ y la recta $x=4$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      85.3333::numeric,
      0.001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{4} x\cdot 2x\,dx=2\pi\int_{0}^{4} 2x^2\,dx=\frac{256}{3}\pi$. Por lo tanto, $k=\frac{256}{3} \approx 85.3333$.',
      85
    ),
    (
      'La región limitada por $y=x$, el eje $x$ y la recta $x=1$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.6667::numeric,
      0.001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{1} x\cdot x\,dx=2\pi\int_{0}^{1} 1x^2\,dx=\frac{2}{3}\pi$. Por lo tanto, $k=\frac{2}{3} \approx 0.6667$.',
      86
    ),
    (
      'La región bajo $y=3x^2$ entre $x=0$ y $x=1$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      1.5::numeric,
      0.001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{1} x\cdot 3x^2\,dx=2\pi\int_{0}^{1} 3x^3\,dx=\frac{3}{2}\pi$. Por lo tanto, $k=\frac{3}{2} \approx 1.5$.',
      87
    ),
    (
      'La región bajo $y=x^2$ entre $x=0$ y $x=3$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      40.5::numeric,
      0.001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{3} x\cdot x^2\,dx=2\pi\int_{0}^{3} 1x^3\,dx=\frac{81}{2}\pi$. Por lo tanto, $k=\frac{81}{2} \approx 40.5$.',
      88
    ),
    (
      'La región bajo $y=3x^2$ entre $x=0$ y $x=2$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{2} x\cdot 3x^2\,dx=2\pi\int_{0}^{2} 3x^3\,dx=24\pi$. Por lo tanto, $k=24$.',
      89
    ),
    (
      'La región bajo $y=2x^2$ entre $x=0$ y $x=2$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{2} x\cdot 2x^2\,dx=2\pi\int_{0}^{2} 2x^3\,dx=16\pi$. Por lo tanto, $k=16$.',
      90
    ),
    (
      'La región bajo $y=2x^2$ entre $x=0$ y $x=3$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      81::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{3} x\cdot 2x^2\,dx=2\pi\int_{0}^{3} 2x^3\,dx=81\pi$. Por lo tanto, $k=81$.',
      91
    ),
    (
      'La región bajo $y=3x^2$ entre $x=0$ y $x=3$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      121.5::numeric,
      0.001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{3} x\cdot 3x^2\,dx=2\pi\int_{0}^{3} 3x^3\,dx=\frac{243}{2}\pi$. Por lo tanto, $k=\frac{243}{2} \approx 121.5$.',
      92
    ),
    (
      'La región bajo $y=2x^2$ entre $x=0$ y $x=1$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{1} x\cdot 2x^2\,dx=2\pi\int_{0}^{1} 2x^3\,dx=1\pi$. Por lo tanto, $k=1$.',
      93
    ),
    (
      'La región bajo $y=x^2$ entre $x=0$ y $x=1$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      0.5::numeric,
      0.001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{1} x\cdot x^2\,dx=2\pi\int_{0}^{1} 1x^3\,dx=\frac{1}{2}\pi$. Por lo tanto, $k=\frac{1}{2} \approx 0.5$.',
      94
    ),
    (
      'La región limitada por $y=5$, el eje $x$ y la recta $x=3$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      45::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{3} x\cdot 5\,dx=2\pi\cdot 5\cdot\frac{3^2}{2}=45\pi$. Por lo tanto, $k=45$.',
      95
    ),
    (
      'La región limitada por $y=4$, el eje $x$ y la recta $x=1$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{1} x\cdot 4\,dx=2\pi\cdot 4\cdot\frac{1^2}{2}=4\pi$. Por lo tanto, $k=4$.',
      96
    ),
    (
      'La región limitada por $y=3$, el eje $x$ y la recta $x=2$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{2} x\cdot 3\,dx=2\pi\cdot 3\cdot\frac{2^2}{2}=12\pi$. Por lo tanto, $k=12$.',
      97
    ),
    (
      'La región limitada por $y=5$, el eje $x$ y la recta $x=1$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{1} x\cdot 5\,dx=2\pi\cdot 5\cdot\frac{1^2}{2}=5\pi$. Por lo tanto, $k=5$.',
      98
    ),
    (
      'La región limitada por $y=1$, el eje $x$ y la recta $x=1$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{1} x\cdot 1\,dx=2\pi\cdot 1\cdot\frac{1^2}{2}=1\pi$. Por lo tanto, $k=1$.',
      99
    ),
    (
      'La región limitada por $y=4$, el eje $x$ y la recta $x=4$ gira alrededor del eje $y$. Si el volumen es $k\pi$, ¿cuánto vale $k$?',
      'numeric',
      null::jsonb,
      null::integer,
      64::numeric,
      0.000001::numeric,
      'Por capas cilíndricas, $V=2\pi\int_{0}^{4} x\cdot 4\,dx=2\pi\cdot 4\cdot\frac{4^2}{2}=64\pi$. Por lo tanto, $k=64$.',
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
  select id from public.modules where slug = 'solidos-revolucion-100'
) as m
where not exists (
  select 1
  from public.exercises e
  where e.module_id = m.id
);
