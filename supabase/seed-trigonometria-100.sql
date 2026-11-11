-- ============================================================
--  Mate Dual Brucke · Trigonometría · 100 ejercicios
--
--  Requisitos:
--    1. Haber ejecutado schema.sql
--    2. Haber ejecutado migration-student-variants.sql
--       (o tener ya las columnas nuevas en public.modules)
--
--  Contenido: exclusivamente triángulos rectángulos.
--    - Teorema de Pitágoras.
--    - Razones trigonométricas a partir de los lados.
--    - Cálculo de lados con seno, coseno y tangente.
--    - Cálculo de ángulos con razones inversas.
--    - Aplicaciones de alturas, distancias, sombras, rampas y ángulos.
--
--  Las respuestas son numéricas y los enunciados indican el redondeo.
--  El módulo entrega los 100 ejercicios completos a cada estudiante y
--  se resuelven de uno en uno.
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
  'Trigonometría · 100 ejercicios',
  'trigonometria-100',
  '100 ejercicios de triángulos rectángulos: Pitágoras, razones trigonométricas, cálculo de lados y ángulos, y aplicaciones.',
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
      'En un triángulo rectángulo los catetos miden $3$ cm y $4$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=3^2+4^2=25$, así que $c=5$ cm.',
      1
    ),
    (
      'En un triángulo rectángulo los catetos miden $6$ cm y $8$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=6^2+8^2=100$, así que $c=10$ cm.',
      2
    ),
    (
      'En un triángulo rectángulo los catetos miden $5$ cm y $12$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      13::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=5^2+12^2=169$, así que $c=13$ cm.',
      3
    ),
    (
      'En un triángulo rectángulo los catetos miden $8$ cm y $15$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      17::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=8^2+15^2=289$, así que $c=17$ cm.',
      4
    ),
    (
      'En un triángulo rectángulo los catetos miden $7$ cm y $24$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      25::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=7^2+24^2=625$, así que $c=25$ cm.',
      5
    ),
    (
      'En un triángulo rectángulo los catetos miden $9$ cm y $12$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      15::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=9^2+12^2=225$, así que $c=15$ cm.',
      6
    ),
    (
      'En un triángulo rectángulo los catetos miden $10$ cm y $24$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      26::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=10^2+24^2=676$, así que $c=26$ cm.',
      7
    ),
    (
      'En un triángulo rectángulo los catetos miden $12$ cm y $16$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      20::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=12^2+16^2=400$, así que $c=20$ cm.',
      8
    ),
    (
      'En un triángulo rectángulo los catetos miden $15$ cm y $20$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      25::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=15^2+20^2=625$, así que $c=25$ cm.',
      9
    ),
    (
      'En un triángulo rectángulo los catetos miden $20$ cm y $21$ cm. ¿Cuánto mide la hipotenusa?',
      'numeric',
      null::jsonb,
      null::integer,
      29::numeric,
      0.001::numeric,
      'Aplicamos Pitágoras: $c^2=20^2+21^2=841$, así que $c=29$ cm.',
      10
    ),
    (
      'En un triángulo rectángulo la hipotenusa mide $13$ cm y un cateto mide $5$ cm. ¿Cuánto mide el otro cateto?',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.001::numeric,
      'Despejamos el cateto: $b^2=13^2-5^2=144$, así que $b=12$ cm.',
      11
    ),
    (
      'En un triángulo rectángulo la hipotenusa mide $17$ cm y un cateto mide $8$ cm. ¿Cuánto mide el otro cateto?',
      'numeric',
      null::jsonb,
      null::integer,
      15::numeric,
      0.001::numeric,
      'Despejamos el cateto: $b^2=17^2-8^2=225$, así que $b=15$ cm.',
      12
    ),
    (
      'En un triángulo rectángulo la hipotenusa mide $25$ cm y un cateto mide $7$ cm. ¿Cuánto mide el otro cateto?',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.001::numeric,
      'Despejamos el cateto: $b^2=25^2-7^2=576$, así que $b=24$ cm.',
      13
    ),
    (
      'En un triángulo rectángulo la hipotenusa mide $26$ cm y un cateto mide $10$ cm. ¿Cuánto mide el otro cateto?',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.001::numeric,
      'Despejamos el cateto: $b^2=26^2-10^2=576$, así que $b=24$ cm.',
      14
    ),
    (
      'En un triángulo rectángulo la hipotenusa mide $29$ cm y un cateto mide $20$ cm. ¿Cuánto mide el otro cateto?',
      'numeric',
      null::jsonb,
      null::integer,
      21::numeric,
      0.001::numeric,
      'Despejamos el cateto: $b^2=29^2-20^2=441$, así que $b=21$ cm.',
      15
    ),
    (
      'En un triángulo rectángulo la hipotenusa mide $41$ cm y un cateto mide $9$ cm. ¿Cuánto mide el otro cateto?',
      'numeric',
      null::jsonb,
      null::integer,
      40::numeric,
      0.001::numeric,
      'Despejamos el cateto: $b^2=41^2-9^2=1600$, así que $b=40$ cm.',
      16
    ),
    (
      'En un triángulo rectángulo los catetos miden $1$ cm y $1$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      1.41::numeric,
      0.01::numeric,
      'Aplicamos Pitágoras: $c^2=1^2+1^2=2$, así que $c=\sqrt{2}\approx 1.41$ cm.',
      17
    ),
    (
      'En un triángulo rectángulo los catetos miden $2$ cm y $3$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      3.61::numeric,
      0.01::numeric,
      'Aplicamos Pitágoras: $c^2=2^2+3^2=13$, así que $c=\sqrt{13}\approx 3.61$ cm.',
      18
    ),
    (
      'En un triángulo rectángulo los catetos miden $5$ cm y $6$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      7.81::numeric,
      0.01::numeric,
      'Aplicamos Pitágoras: $c^2=5^2+6^2=61$, así que $c=\sqrt{61}\approx 7.81$ cm.',
      19
    ),
    (
      'En un triángulo rectángulo la hipotenusa mide $10$ cm y un cateto mide $6$ cm. ¿Cuánto mide el otro cateto?',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.001::numeric,
      'Despejamos el cateto: $b^2=10^2-6^2=64$, así que $b=8$ cm.',
      20
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $3$ cm, el cateto adyacente mide $4$ cm y la hipotenusa mide $5$ cm. ¿Cuánto vale $\operatorname{sen}\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.6::numeric,
      0.0001::numeric,
      '$\operatorname{sen}\theta=\frac{3}{5}\approx 0.6000$.',
      21
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $3$ cm, el cateto adyacente mide $4$ cm y la hipotenusa mide $5$ cm. ¿Cuánto vale $\cos\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.8::numeric,
      0.0001::numeric,
      '$\cos\theta=\frac{4}{5}\approx 0.8000$.',
      22
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $3$ cm, el cateto adyacente mide $4$ cm y la hipotenusa mide $5$ cm. ¿Cuánto vale $\tan\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.75::numeric,
      0.0001::numeric,
      '$\tan\theta=\frac{3}{4}\approx 0.7500$.',
      23
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $6$ cm, el cateto adyacente mide $8$ cm y la hipotenusa mide $10$ cm. ¿Cuánto vale $\operatorname{sen}\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.6::numeric,
      0.0001::numeric,
      '$\operatorname{sen}\theta=\frac{6}{10}\approx 0.6000$.',
      24
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $5$ cm, el cateto adyacente mide $12$ cm y la hipotenusa mide $13$ cm. ¿Cuánto vale $\operatorname{sen}\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.3846::numeric,
      0.0001::numeric,
      '$\operatorname{sen}\theta=\frac{5}{13}\approx 0.3846$.',
      25
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $5$ cm, el cateto adyacente mide $12$ cm y la hipotenusa mide $13$ cm. ¿Cuánto vale $\cos\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.9231::numeric,
      0.0001::numeric,
      '$\cos\theta=\frac{12}{13}\approx 0.9231$.',
      26
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $5$ cm, el cateto adyacente mide $12$ cm y la hipotenusa mide $13$ cm. ¿Cuánto vale $\tan\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.4167::numeric,
      0.0001::numeric,
      '$\tan\theta=\frac{5}{12}\approx 0.4167$.',
      27
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $8$ cm, el cateto adyacente mide $15$ cm y la hipotenusa mide $17$ cm. ¿Cuánto vale $\operatorname{sen}\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.4706::numeric,
      0.0001::numeric,
      '$\operatorname{sen}\theta=\frac{8}{17}\approx 0.4706$.',
      28
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $8$ cm, el cateto adyacente mide $15$ cm y la hipotenusa mide $17$ cm. ¿Cuánto vale $\cos\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.8824::numeric,
      0.0001::numeric,
      '$\cos\theta=\frac{15}{17}\approx 0.8824$.',
      29
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $8$ cm, el cateto adyacente mide $15$ cm y la hipotenusa mide $17$ cm. ¿Cuánto vale $\tan\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.5333::numeric,
      0.0001::numeric,
      '$\tan\theta=\frac{8}{15}\approx 0.5333$.',
      30
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $7$ cm, el cateto adyacente mide $24$ cm y la hipotenusa mide $25$ cm. ¿Cuánto vale $\operatorname{sen}\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.28::numeric,
      0.0001::numeric,
      '$\operatorname{sen}\theta=\frac{7}{25}\approx 0.2800$.',
      31
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $7$ cm, el cateto adyacente mide $24$ cm y la hipotenusa mide $25$ cm. ¿Cuánto vale $\cos\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.96::numeric,
      0.0001::numeric,
      '$\cos\theta=\frac{24}{25}\approx 0.9600$.',
      32
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $7$ cm, el cateto adyacente mide $24$ cm y la hipotenusa mide $25$ cm. ¿Cuánto vale $\tan\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.2917::numeric,
      0.0001::numeric,
      '$\tan\theta=\frac{7}{24}\approx 0.2917$.',
      33
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $9$ cm, el cateto adyacente mide $40$ cm y la hipotenusa mide $41$ cm. ¿Cuánto vale $\operatorname{sen}\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.2195::numeric,
      0.0001::numeric,
      '$\operatorname{sen}\theta=\frac{9}{41}\approx 0.2195$.',
      34
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $9$ cm, el cateto adyacente mide $40$ cm y la hipotenusa mide $41$ cm. ¿Cuánto vale $\cos\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.9756::numeric,
      0.0001::numeric,
      '$\cos\theta=\frac{40}{41}\approx 0.9756$.',
      35
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $9$ cm, el cateto adyacente mide $40$ cm y la hipotenusa mide $41$ cm. ¿Cuánto vale $\tan\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.225::numeric,
      0.0001::numeric,
      '$\tan\theta=\frac{9}{40}\approx 0.2250$.',
      36
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $20$ cm, el cateto adyacente mide $21$ cm y la hipotenusa mide $29$ cm. ¿Cuánto vale $\operatorname{sen}\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.6897::numeric,
      0.0001::numeric,
      '$\operatorname{sen}\theta=\frac{20}{29}\approx 0.6897$.',
      37
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $20$ cm, el cateto adyacente mide $21$ cm y la hipotenusa mide $29$ cm. ¿Cuánto vale $\cos\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.7241::numeric,
      0.0001::numeric,
      '$\cos\theta=\frac{21}{29}\approx 0.7241$.',
      38
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $20$ cm, el cateto adyacente mide $21$ cm y la hipotenusa mide $29$ cm. ¿Cuánto vale $\tan\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.9524::numeric,
      0.0001::numeric,
      '$\tan\theta=\frac{20}{21}\approx 0.9524$.',
      39
    ),
    (
      'Si $\operatorname{sen}\theta=\frac{3}{5}$ y $\theta$ es agudo, ¿cuánto vale $\cos\theta$? Redondea a cuatro decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.8::numeric,
      0.0001::numeric,
      'En un triángulo rectángulo con cateto opuesto $3$ e hipotenusa $5$, el cateto adyacente mide $\sqrt{5^2-3^2}=4$. Por eso $\cos\theta=\frac{4}{5}=0.8000$.',
      40
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $30^\circ$. La hipotenusa mide $10$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{hipotenusa}\cdot\operatorname{sen}\theta$. Al sustituir: $5.00$ cm.',
      41
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $30^\circ$. La hipotenusa mide $14$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{hipotenusa}\cdot\operatorname{sen}\theta$. Al sustituir: $7.00$ cm.',
      42
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $30^\circ$. El cateto adyacente mide $9$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      10.39::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{hipotenusa}=\frac{\text{adyacente}}{\cos\theta}$. Al sustituir: $10.39$ cm.',
      43
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $45^\circ$. La hipotenusa mide $12$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      8.49::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{hipotenusa}\cdot\operatorname{sen}\theta$. Al sustituir: $8.49$ cm.',
      44
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $45^\circ$. El cateto opuesto mide $7$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      9.9::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{hipotenusa}=\frac{\text{opuesto}}{\operatorname{sen}\theta}$. Al sustituir: $9.90$ cm.',
      45
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $45^\circ$. El cateto adyacente mide $5$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{adyacente}\cdot\tan\theta$. Al sustituir: $5.00$ cm.',
      46
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $60^\circ$. La hipotenusa mide $8$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      6.93::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{hipotenusa}\cdot\operatorname{sen}\theta$. Al sustituir: $6.93$ cm.',
      47
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $60^\circ$. El cateto adyacente mide $4$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{hipotenusa}=\frac{\text{adyacente}}{\cos\theta}$. Al sustituir: $8.00$ cm.',
      48
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $60^\circ$. El cateto opuesto mide $6$ cm. ¿Cuánto mide el cateto adyacente? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      3.46::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{adyacente}=\frac{\text{opuesto}}{\tan\theta}$. Al sustituir: $3.46$ cm.',
      49
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $35^\circ$. La hipotenusa mide $20$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      11.47::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{hipotenusa}\cdot\operatorname{sen}\theta$. Al sustituir: $11.47$ cm.',
      50
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $35^\circ$. El cateto adyacente mide $15$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      18.31::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{hipotenusa}=\frac{\text{adyacente}}{\cos\theta}$. Al sustituir: $18.31$ cm.',
      51
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $40^\circ$. El cateto opuesto mide $9$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      14::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{hipotenusa}=\frac{\text{opuesto}}{\operatorname{sen}\theta}$. Al sustituir: $14.00$ cm.',
      52
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $40^\circ$. La hipotenusa mide $25$ cm. ¿Cuánto mide el cateto adyacente? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      19.15::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{adyacente}=\text{hipotenusa}\cdot\cos\theta$. Al sustituir: $19.15$ cm.',
      53
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $50^\circ$. El cateto adyacente mide $12$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      14.3::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{adyacente}\cdot\tan\theta$. Al sustituir: $14.30$ cm.',
      54
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $50^\circ$. La hipotenusa mide $30$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      22.98::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{hipotenusa}\cdot\operatorname{sen}\theta$. Al sustituir: $22.98$ cm.',
      55
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $55^\circ$. El cateto opuesto mide $14$ cm. ¿Cuánto mide el cateto adyacente? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      9.8::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{adyacente}=\frac{\text{opuesto}}{\tan\theta}$. Al sustituir: $9.80$ cm.',
      56
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $55^\circ$. La hipotenusa mide $18$ cm. ¿Cuánto mide el cateto adyacente? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      10.32::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{adyacente}=\text{hipotenusa}\cdot\cos\theta$. Al sustituir: $10.32$ cm.',
      57
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $65^\circ$. El cateto opuesto mide $20$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      22.07::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{hipotenusa}=\frac{\text{opuesto}}{\operatorname{sen}\theta}$. Al sustituir: $22.07$ cm.',
      58
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $65^\circ$. El cateto adyacente mide $8$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      17.16::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{adyacente}\cdot\tan\theta$. Al sustituir: $17.16$ cm.',
      59
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $70^\circ$. La hipotenusa mide $15$ cm. ¿Cuánto mide el cateto adyacente? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      5.13::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{adyacente}=\text{hipotenusa}\cdot\cos\theta$. Al sustituir: $5.13$ cm.',
      60
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $70^\circ$. El cateto opuesto mide $12$ cm. ¿Cuánto mide el cateto adyacente? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      4.37::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{adyacente}=\frac{\text{opuesto}}{\tan\theta}$. Al sustituir: $4.37$ cm.',
      61
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $25^\circ$. La hipotenusa mide $40$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      16.9::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{hipotenusa}\cdot\operatorname{sen}\theta$. Al sustituir: $16.90$ cm.',
      62
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $25^\circ$. El cateto adyacente mide $22$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      10.26::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{adyacente}\cdot\tan\theta$. Al sustituir: $10.26$ cm.',
      63
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $32^\circ$. El cateto opuesto mide $7$ cm. ¿Cuánto mide la hipotenusa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      13.21::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{hipotenusa}=\frac{\text{opuesto}}{\operatorname{sen}\theta}$. Al sustituir: $13.21$ cm.',
      64
    ),
    (
      'En un triángulo rectángulo, el ángulo agudo $\theta$ mide $58^\circ$. El cateto adyacente mide $11$ cm. ¿Cuánto mide el cateto opuesto? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      17.6::numeric,
      0.01::numeric,
      'Usamos la razón trigonométrica: $\text{opuesto}=\text{adyacente}\cdot\tan\theta$. Al sustituir: $17.60$ cm.',
      65
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $3$ cm y la hipotenusa mide $5$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      36.9::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{3}{5}\approx 0.6000$, por lo que $\theta=\arcsin(0.6000)\approx 36.9^\circ$.',
      66
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $5$ cm y la hipotenusa mide $13$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      22.6::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{5}{13}\approx 0.3846$, por lo que $\theta=\arcsin(0.3846)\approx 22.6^\circ$.',
      67
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $8$ cm y la hipotenusa mide $17$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      28.1::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{8}{17}\approx 0.4706$, por lo que $\theta=\arcsin(0.4706)\approx 28.1^\circ$.',
      68
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $7$ cm y la hipotenusa mide $25$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      16.3::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{7}{25}\approx 0.2800$, por lo que $\theta=\arcsin(0.2800)\approx 16.3^\circ$.',
      69
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $9$ cm y la hipotenusa mide $41$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      12.7::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{9}{41}\approx 0.2195$, por lo que $\theta=\arcsin(0.2195)\approx 12.7^\circ$.',
      70
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $20$ cm y la hipotenusa mide $29$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      43.6::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{20}{29}\approx 0.6897$, por lo que $\theta=\arcsin(0.6897)\approx 43.6^\circ$.',
      71
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $2$ cm y la hipotenusa mide $3$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      41.8::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{2}{3}\approx 0.6667$, por lo que $\theta=\arcsin(0.6667)\approx 41.8^\circ$.',
      72
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $5$ cm y la hipotenusa mide $8$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      38.7::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{5}{8}\approx 0.6250$, por lo que $\theta=\arcsin(0.6250)\approx 38.7^\circ$.',
      73
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $6$ cm y la hipotenusa mide $11$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      33.1::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{6}{11}\approx 0.5455$, por lo que $\theta=\arcsin(0.5455)\approx 33.1^\circ$.',
      74
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $4$ cm y el cateto adyacente mide $7$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      29.7::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{4}{7}\approx 0.5714$, por lo que $\theta=\arctan(0.5714)\approx 29.7^\circ$.',
      75
    ),
    (
      'En un triángulo rectángulo, el cateto opuesto a $\theta$ mide $9$ cm y el cateto adyacente mide $5$ cm. ¿Cuánto mide $\theta$? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      60.9::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{9}{5}\approx 1.8000$, por lo que $\theta=\arctan(1.8000)\approx 60.9^\circ$.',
      76
    ),
    (
      'Si $\operatorname{sen}\theta=0.3$ y $\theta$ es agudo, ¿cuánto mide $\theta$ en grados? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      17.5::numeric,
      0.1::numeric,
      '$\theta=\arcsin(0.3)\approx 17.5^\circ$.',
      77
    ),
    (
      'Si $\cos\theta=0.7$ y $\theta$ es agudo, ¿cuánto mide $\theta$ en grados? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      45.6::numeric,
      0.1::numeric,
      '$\theta=\arccos(0.7)\approx 45.6^\circ$.',
      78
    ),
    (
      'Si $\tan\theta=2$ y $\theta$ es agudo, ¿cuánto mide $\theta$ en grados? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      63.4::numeric,
      0.1::numeric,
      '$\theta=\arctan(2)\approx 63.4^\circ$.',
      79
    ),
    (
      'Si $\operatorname{sen}\theta=0.9$ y $\theta$ es agudo, ¿cuánto mide $\theta$ en grados? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      64.2::numeric,
      0.1::numeric,
      '$\theta=\arcsin(0.9)\approx 64.2^\circ$.',
      80
    ),
    (
      'Un árbol proyecta una sombra de $12$ m. El ángulo de elevación del sol es $35^\circ$. ¿Cuál es la altura del árbol? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      8.4::numeric,
      0.01::numeric,
      '$\tan 35^\circ=\frac{h}{12}$. Al despejar: $h\approx 8.40\ \text{m}$.',
      81
    ),
    (
      'Una escalera de $10$ m se apoya en una pared formando un ángulo de $60^\circ$ con el suelo. ¿A qué altura llega? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      8.66::numeric,
      0.01::numeric,
      '$\operatorname{sen}60^\circ=\frac{h}{10}$. Al despejar: $h\approx 8.66\ \text{m}$.',
      82
    ),
    (
      'Una rampa sube $2$ m en una distancia horizontal de $8$ m. ¿Qué ángulo forma con la horizontal? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      14::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{2}{8}=0.25$. Al despejar: $\theta\approx 14.0^\circ$.',
      83
    ),
    (
      'Una cometa está sujeta a una cuerda de $50$ m que forma $40^\circ$ con el suelo. ¿A qué altura está la cometa? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      32.14::numeric,
      0.01::numeric,
      '$\operatorname{sen}40^\circ=\frac{h}{50}$. Al despejar: $h\approx 32.14\ \text{m}$.',
      84
    ),
    (
      'Desde un punto a $30$ m de la base de un edificio, el ángulo de elevación a la parte superior es $50^\circ$. ¿Cuál es la altura del edificio? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      35.75::numeric,
      0.01::numeric,
      '$\tan 50^\circ=\frac{h}{30}$. Al despejar: $h\approx 35.75\ \text{m}$.',
      85
    ),
    (
      'Una escalera de $6$ m alcanza una altura de $4.5$ m. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      48.6::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{4.5}{6}=0.75$. Al despejar: $\theta\approx 48.6^\circ$.',
      86
    ),
    (
      'Un avión está a $800$ m de altura y a $1200$ m en horizontal del punto de aterrizaje. ¿Cuál es el ángulo de depresión? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      33.7::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{800}{1200}\approx 0.6667$. Al despejar: $\theta\approx 33.7^\circ$.',
      87
    ),
    (
      'Un poste proyecta una sombra de $15$ m cuando el sol tiene una elevación de $40^\circ$. ¿Cuánto mide el poste? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      12.59::numeric,
      0.01::numeric,
      '$\tan 40^\circ=\frac{h}{15}$. Al despejar: $h\approx 12.59\ \text{m}$.',
      88
    ),
    (
      'Un faro mide $80$ m de altura. Un barco está a $500$ m de su base. ¿Qué ángulo de elevación hay desde el barco hasta la parte superior? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      9.1::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{80}{500}=0.16$. Al despejar: $\theta\approx 9.1^\circ$.',
      89
    ),
    (
      'Una rampa de $12$ m de longitud forma un ángulo de $15^\circ$ con el suelo. ¿Qué altura alcanza? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      3.11::numeric,
      0.01::numeric,
      '$\operatorname{sen}15^\circ=\frac{h}{12}$. Al despejar: $h\approx 3.11\ \text{m}$.',
      90
    ),
    (
      'Desde un punto a $25$ m de un monumento, el ángulo de elevación a su parte superior es $55^\circ$. ¿Cuál es la altura del monumento? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      35.7::numeric,
      0.01::numeric,
      '$\tan 55^\circ=\frac{h}{25}$. Al despejar: $h\approx 35.70\ \text{m}$.',
      91
    ),
    (
      'Una cometa está a $30$ m de altura y la cuerda mide $45$ m. ¿Qué ángulo forma la cuerda con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      41.8::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{30}{45}\approx 0.6667$. Al despejar: $\theta\approx 41.8^\circ$.',
      92
    ),
    (
      'Un cable de $20$ m sujeta la parte superior de un poste y forma un ángulo de $65^\circ$ con el suelo. ¿Cuánto mide el poste? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      18.13::numeric,
      0.01::numeric,
      '$\operatorname{sen}65^\circ=\frac{h}{20}$. Al despejar: $h\approx 18.13\ \text{m}$.',
      93
    ),
    (
      'Un árbol de $9$ m de altura proyecta una sombra cuando el sol tiene una elevación de $30^\circ$. ¿Cuánto mide la sombra? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      15.59::numeric,
      0.01::numeric,
      '$\tan 30^\circ=\frac{9}{s}$. Al despejar: $s\approx 15.59\ \text{m}$.',
      94
    ),
    (
      'Desde lo alto de un acantilado de $40$ m, el ángulo de depresión hacia un bote es $25^\circ$. ¿Cuál es la distancia horizontal del bote a la base del acantilado? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      85.78::numeric,
      0.01::numeric,
      '$\tan 25^\circ=\frac{40}{d}$. Al despejar: $d\approx 85.78\ \text{m}$.',
      95
    ),
    (
      'Una carretera sube $150$ m en una distancia horizontal de $1000$ m. ¿Qué ángulo forma con la horizontal? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      8.5::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{150}{1000}=0.15$. Al despejar: $\theta\approx 8.5^\circ$.',
      96
    ),
    (
      'Una escalera de $15$ m llega a una ventana situada a $12$ m del suelo. ¿Qué ángulo forma con el suelo? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      53.1::numeric,
      0.1::numeric,
      '$\operatorname{sen}\theta=\frac{12}{15}=0.8$. Al despejar: $\theta\approx 53.1^\circ$.',
      97
    ),
    (
      'Una torre proyecta una sombra de $18$ m cuando el ángulo de elevación del sol es $60^\circ$. ¿Cuánto mide la torre? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      31.18::numeric,
      0.01::numeric,
      '$\tan 60^\circ=\frac{h}{18}$. Al despejar: $h\approx 31.18\ \text{m}$.',
      98
    ),
    (
      'Un dron está a $120$ m en horizontal de una persona y a $90$ m de altura. ¿Qué ángulo de elevación hay desde la persona hasta el dron? Redondea a un decimal.',
      'numeric',
      null::jsonb,
      null::integer,
      36.9::numeric,
      0.1::numeric,
      '$\tan\theta=\frac{90}{120}=0.75$. Al despejar: $\theta\approx 36.9^\circ$.',
      99
    ),
    (
      'Una rampa para sillas de ruedas debe salvar una altura de $0.8$ m con un ángulo de $5^\circ$. ¿Cuál debe ser su longitud horizontal? Redondea a dos decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      9.14::numeric,
      0.01::numeric,
      '$\tan 5^\circ=\frac{0.8}{d}$. Al despejar: $d\approx 9.14\ \text{m}$.',
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
) as m
where not exists (
  select 1
  from public.exercises e
  where e.module_id = m.id
);
