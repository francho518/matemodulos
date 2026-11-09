-- ============================================================
--  Matemódulos · Módulo de Factorización · 100 ejercicios
--
--  Requisitos:
--    1. Haber ejecutado schema.sql
--    2. Haber ejecutado migration-student-variants.sql
--       (o tener ya las columnas nuevas en public.modules)
--
--  Este módulo contiene exactamente 100 ejercicios de factorización.
--  TODAS las respuestas son números enteros, así que se corrigen con
--  el tipo "numeric" y una tolerancia mínima.
--
--  El módulo entrega los 100 ejercicios completos a cada estudiante
--  (randomize_exercises = false y exercises_per_student = 0). El
--  estudiante los resuelve de uno en uno: al acertar o agotar los
--  4 intentos aparece el siguiente. Si prefieres que cada alumno
--  reciba solo una parte, cambia "Ejercicios por estudiante" desde
--  Administración → Factorización.
--
--  IMPORTANTE: con la visibilidad estricta por grupos, este módulo
--  solo lo verán los estudiantes de los grupos a los que se asigne.
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
  'Factorización · 100 ejercicios',
  'factorizacion-100',
  '100 ejercicios de factorización con respuesta entera: factor común, diferencia de cuadrados, trinomios, cuadrados perfectos, cubos, agrupación y aplicaciones.',
  3,
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
    -- Factor común: máximo común divisor de los coeficientes
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $12x+18$?',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.000001::numeric,
      'Los coeficientes son $12$ y $18$. Su máximo común divisor es $6$: $12x+18=6(2x+3)$.',
      1
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $15x^2+25x$?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      'El máximo común divisor de $15$ y $25$ es $5$: $15x^2+25x=5x(3x+5)$.',
      2
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $8x^3+12x^2$?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'El máximo común divisor de $8$ y $12$ es $4$: $8x^3+12x^2=4x^2(2x+3)$.',
      3
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $14a^2b+21ab^2$?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.000001::numeric,
      'El máximo común divisor de $14$ y $21$ es $7$: $14a^2b+21ab^2=7ab(2a+3b)$.',
      4
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $18m^3-24m^2$?',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.000001::numeric,
      'El máximo común divisor de $18$ y $24$ es $6$: $18m^3-24m^2=6m^2(3m-4)$.',
      5
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $20x^4+30x^2$?',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.000001::numeric,
      'El máximo común divisor de $20$ y $30$ es $10$: $20x^4+30x^2=10x^2(2x^2+3)$.',
      6
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $9a^3b^2-15a^2b^3$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      'El máximo común divisor de $9$ y $15$ es $3$: $9a^3b^2-15a^2b^3=3a^2b^2(3a-5b)$.',
      7
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $16x^2y+24xy^2$?',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.000001::numeric,
      'El máximo común divisor de $16$ y $24$ es $8$: $16x^2y+24xy^2=8xy(2x+3y)$.',
      8
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $35p^2q-49pq^2$?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.000001::numeric,
      'El máximo común divisor de $35$ y $49$ es $7$: $35p^2q-49pq^2=7pq(5p-7q)$.',
      9
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $22x^3+33x$?',
      'numeric',
      null::jsonb,
      null::integer,
      11::numeric,
      0.000001::numeric,
      'El máximo común divisor de $22$ y $33$ es $11$: $22x^3+33x=11x(2x^2+3)$.',
      10
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $45a^4-60a^3$?',
      'numeric',
      null::jsonb,
      null::integer,
      15::numeric,
      0.000001::numeric,
      'El máximo común divisor de $45$ y $60$ es $15$: $45a^4-60a^3=15a^3(3a-4)$.',
      11
    ),
    (
      '¿Cuál es el máximo común divisor de los coeficientes de $28m^2n+42mn^2$?',
      'numeric',
      null::jsonb,
      null::integer,
      14::numeric,
      0.000001::numeric,
      'El máximo común divisor de $28$ y $42$ es $14$: $28m^2n+42mn^2=14mn(2m+3n)$.',
      12
    ),
    -- Diferencia de cuadrados
    (
      '¿Cuál es la mayor raíz de $x^2-16=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'Diferencia de cuadrados: $x^2-16=(x-4)(x+4)$. Las raíces son $-4$ y $4$; la mayor es $4$.',
      13
    ),
    (
      '¿Cuál es la raíz positiva de $x^2-49=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.000001::numeric,
      '$x^2-49=(x-7)(x+7)$. Las raíces son $-7$ y $7$; la positiva es $7$.',
      14
    ),
    (
      '¿Cuál es la suma de las raíces de $x^2-81=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      0::numeric,
      0.000001::numeric,
      '$x^2-81=(x-9)(x+9)$. Las raíces son $-9$ y $9$; su suma es $-9+9=0$.',
      15
    ),
    (
      '¿Cuál es el producto de las raíces de $x^2-100=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      -100::numeric,
      0.000001::numeric,
      '$x^2-100=(x-10)(x+10)$. Las raíces son $-10$ y $10$; su producto es $(-10)(10)=-100$.',
      16
    ),
    (
      '¿Cuál es la raíz positiva de $4x^2-36=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      '$4x^2-36=4(x^2-9)=4(x-3)(x+3)$. Las raíces son $-3$ y $3$; la positiva es $3$.',
      17
    ),
    (
      '¿Cuál es la raíz positiva de $9x^2-81=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      '$9x^2-81=9(x^2-9)=9(x-3)(x+3)$. Las raíces son $-3$ y $3$; la positiva es $3$.',
      18
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-144=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.000001::numeric,
      '$x^2-144=(x-12)(x+12)$. Las raíces son $-12$ y $12$; la mayor es $12$.',
      19
    ),
    (
      '¿Cuál es la menor raíz de $x^2-64=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      -8::numeric,
      0.000001::numeric,
      '$x^2-64=(x-8)(x+8)$. Las raíces son $-8$ y $8$; la menor es $-8$.',
      20
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-1=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.000001::numeric,
      '$x^2-1=(x-1)(x+1)$. Las raíces son $-1$ y $1$; la mayor es $1$.',
      21
    ),
    (
      '¿Cuál es la raíz positiva de $25x^2-100=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      '$25x^2-100=25(x^2-4)=25(x-2)(x+2)$. Las raíces son $-2$ y $2$; la positiva es $2$.',
      22
    ),
    (
      '¿Cuál es la raíz positiva de $x^2-121=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      11::numeric,
      0.000001::numeric,
      '$x^2-121=(x-11)(x+11)$. Las raíces son $-11$ y $11$; la positiva es $11$.',
      23
    ),
    (
      '¿Cuál es la raíz positiva de $16x^2-64=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      '$16x^2-64=16(x^2-4)=16(x-2)(x+2)$. Las raíces son $-2$ y $2$; la positiva es $2$.',
      24
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-169=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      13::numeric,
      0.000001::numeric,
      '$x^2-169=(x-13)(x+13)$. Las raíces son $-13$ y $13$; la mayor es $13$.',
      25
    ),
    (
      '¿Cuál es la raíz positiva de $36x^2-144=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      '$36x^2-144=36(x^2-4)=36(x-2)(x+2)$. Las raíces son $-2$ y $2$; la positiva es $2$.',
      26
    ),
    -- Trinomios de la forma x² + bx + c
    (
      '¿Cuál es la mayor raíz de $x^2-7x+12=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      '$x^2-7x+12=(x-3)(x-4)$. Las raíces son $3$ y $4$; la mayor es $4$.',
      27
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-5x+6=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      '$x^2-5x+6=(x-2)(x-3)$. Las raíces son $2$ y $3$; la mayor es $3$.',
      28
    ),
    (
      '¿Cuál es la mayor raíz de $x^2+7x+12=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      -3::numeric,
      0.000001::numeric,
      '$x^2+7x+12=(x+3)(x+4)$. Las raíces son $-3$ y $-4$; la mayor es $-3$.',
      29
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-x-6=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      '$x^2-x-6=(x-3)(x+2)$. Las raíces son $3$ y $-2$; la mayor es $3$.',
      30
    ),
    (
      '¿Cuál es la mayor raíz de $x^2+x-12=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      '$x^2+x-12=(x+4)(x-3)$. Las raíces son $-4$ y $3$; la mayor es $3$.',
      31
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-9x+20=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      '$x^2-9x+20=(x-4)(x-5)$. Las raíces son $4$ y $5$; la mayor es $5$.',
      32
    ),
    (
      '¿Cuál es la menor raíz de $x^2-11x+30=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      '$x^2-11x+30=(x-5)(x-6)$. Las raíces son $5$ y $6$; la menor es $5$.',
      33
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-4x-12=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.000001::numeric,
      '$x^2-4x-12=(x-6)(x+2)$. Las raíces son $6$ y $-2$; la mayor es $6$.',
      34
    ),
    (
      '¿Cuál es la mayor raíz de $x^2+2x-15=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      '$x^2+2x-15=(x+5)(x-3)$. Las raíces son $-5$ y $3$; la mayor es $3$.',
      35
    ),
    (
      '¿Cuál es el producto de las raíces de $x^2-8x+15=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      15::numeric,
      0.000001::numeric,
      '$x^2-8x+15=(x-3)(x-5)$. Las raíces son $3$ y $5$; su producto es $3\cdot 5=15$.',
      36
    ),
    (
      '¿Cuál es la suma de las raíces de $x^2-6x+8=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.000001::numeric,
      '$x^2-6x+8=(x-2)(x-4)$. Las raíces son $2$ y $4$; su suma es $2+4=6$.',
      37
    ),
    (
      '¿Cuál es la mayor raíz de $x^2+9x+20=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      -4::numeric,
      0.000001::numeric,
      '$x^2+9x+20=(x+4)(x+5)$. Las raíces son $-4$ y $-5$; la mayor es $-4$.',
      38
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-13x+42=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.000001::numeric,
      '$x^2-13x+42=(x-6)(x-7)$. Las raíces son $6$ y $7$; la mayor es $7$.',
      39
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-3x-10=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      '$x^2-3x-10=(x-5)(x+2)$. Las raíces son $5$ y $-2$; la mayor es $5$.',
      40
    ),
    (
      '¿Cuál es la mayor raíz de $x^2+3x-10=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      '$x^2+3x-10=(x+5)(x-2)$. Las raíces son $-5$ y $2$; la mayor es $2$.',
      41
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-10x+21=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.000001::numeric,
      '$x^2-10x+21=(x-3)(x-7)$. Las raíces son $3$ y $7$; la mayor es $7$.',
      42
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-2x-8=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      '$x^2-2x-8=(x-4)(x+2)$. Las raíces son $4$ y $-2$; la mayor es $4$.',
      43
    ),
    (
      '¿Cuál es la mayor raíz de $x^2+8x+15=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      -3::numeric,
      0.000001::numeric,
      '$x^2+8x+15=(x+3)(x+5)$. Las raíces son $-3$ y $-5$; la mayor es $-3$.',
      44
    ),
    (
      '¿Cuál es la suma de las raíces de $x^2-12x+35=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.000001::numeric,
      '$x^2-12x+35=(x-5)(x-7)$. Las raíces son $5$ y $7$; su suma es $5+7=12$.',
      45
    ),
    (
      '¿Cuál es la mayor raíz de $x^2-15x+56=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.000001::numeric,
      '$x^2-15x+56=(x-7)(x-8)$. Las raíces son $7$ y $8$; la mayor es $8$.',
      46
    ),
    (
      '¿Cuál es la mayor raíz de $x^2+4x-21=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      '$x^2+4x-21=(x+7)(x-3)$. Las raíces son $-7$ y $3$; la mayor es $3$.',
      47
    ),
    (
      '¿Cuál es la menor raíz de $x^2-14x+45=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      '$x^2-14x+45=(x-5)(x-9)$. Las raíces son $5$ y $9$; la menor es $5$.',
      48
    ),
    -- Trinomios cuadrados perfectos
    (
      '¿Cuál es la raíz doble de $x^2+10x+25=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      -5::numeric,
      0.000001::numeric,
      '$x^2+10x+25=(x+5)^2$. La raíz doble es $-5$.',
      49
    ),
    (
      '¿Cuál es la raíz doble de $x^2-12x+36=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.000001::numeric,
      '$x^2-12x+36=(x-6)^2$. La raíz doble es $6$.',
      50
    ),
    (
      '¿Cuál es la raíz doble de $x^2+14x+49=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      -7::numeric,
      0.000001::numeric,
      '$x^2+14x+49=(x+7)^2$. La raíz doble es $-7$.',
      51
    ),
    (
      '¿Cuál es la raíz doble de $x^2-18x+81=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      9::numeric,
      0.000001::numeric,
      '$x^2-18x+81=(x-9)^2$. La raíz doble es $9$.',
      52
    ),
    (
      '¿Cuál es la raíz doble de $x^2+6x+9=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      -3::numeric,
      0.000001::numeric,
      '$x^2+6x+9=(x+3)^2$. La raíz doble es $-3$.',
      53
    ),
    (
      '¿Cuál es la raíz doble de $x^2-20x+100=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.000001::numeric,
      '$x^2-20x+100=(x-10)^2$. La raíz doble es $10$.',
      54
    ),
    (
      '¿Cuál es la raíz doble de $x^2+16x+64=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      -8::numeric,
      0.000001::numeric,
      '$x^2+16x+64=(x+8)^2$. La raíz doble es $-8$.',
      55
    ),
    (
      '¿Cuál es la raíz doble de $x^2-8x+16=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      '$x^2-8x+16=(x-4)^2$. La raíz doble es $4$.',
      56
    ),
    (
      '¿Qué valor positivo de $k$ hace que $x^2+kx+36$ sea un trinomio cuadrado perfecto?',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.000001::numeric,
      'Debe cumplirse $k=2\sqrt{36}=2\cdot 6=12$: $x^2+12x+36=(x+6)^2$.',
      57
    ),
    (
      '¿Qué valor positivo de $k$ hace que $x^2+kx+64$ sea un trinomio cuadrado perfecto?',
      'numeric',
      null::jsonb,
      null::integer,
      16::numeric,
      0.000001::numeric,
      'Debe cumplirse $k=2\sqrt{64}=2\cdot 8=16$: $x^2+16x+64=(x+8)^2$.',
      58
    ),
    (
      '¿Qué valor positivo de $k$ hace que $x^2-kx+49$ sea un trinomio cuadrado perfecto?',
      'numeric',
      null::jsonb,
      null::integer,
      14::numeric,
      0.000001::numeric,
      'Debe cumplirse $k=2\sqrt{49}=2\cdot 7=14$: $x^2-14x+49=(x-7)^2$.',
      59
    ),
    (
      '¿Qué valor positivo de $k$ hace que $x^2+kx+81$ sea un trinomio cuadrado perfecto?',
      'numeric',
      null::jsonb,
      null::integer,
      18::numeric,
      0.000001::numeric,
      'Debe cumplirse $k=2\sqrt{81}=2\cdot 9=18$: $x^2+18x+81=(x+9)^2$.',
      60
    ),
    -- Suma y diferencia de cubos
    (
      'En la factorización $x^3+27=(x+b)(x^2-bx+b^2)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      'Como $27=3^3$, se tiene $b=3$: $x^3+27=(x+3)(x^2-3x+9)$.',
      61
    ),
    (
      'En la factorización $x^3-64=(x-b)(x^2+bx+b^2)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'Como $64=4^3$, se tiene $b=4$: $x^3-64=(x-4)(x^2+4x+16)$.',
      62
    ),
    (
      'En la factorización $x^3+125=(x+b)(x^2-bx+b^2)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      'Como $125=5^3$, se tiene $b=5$: $x^3+125=(x+5)(x^2-5x+25)$.',
      63
    ),
    (
      'En la factorización $x^3-1=(x-b)(x^2+bx+b^2)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.000001::numeric,
      'Como $1=1^3$, se tiene $b=1$: $x^3-1=(x-1)(x^2+x+1)$.',
      64
    ),
    (
      'En la factorización $x^3+216=(x+b)(x^2-bx+b^2)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.000001::numeric,
      'Como $216=6^3$, se tiene $b=6$: $x^3+216=(x+6)(x^2-6x+36)$.',
      65
    ),
    (
      'En la factorización $x^3-343=(x-b)(x^2+bx+b^2)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.000001::numeric,
      'Como $343=7^3$, se tiene $b=7$: $x^3-343=(x-7)(x^2+7x+49)$.',
      66
    ),
    (
      'En la factorización $x^3+1000=(x+b)(x^2-bx+b^2)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.000001::numeric,
      'Como $1000=10^3$, se tiene $b=10$: $x^3+1000=(x+10)(x^2-10x+100)$.',
      67
    ),
    (
      'En la factorización $x^3-8=(x-b)(x^2+bx+b^2)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Como $8=2^3$, se tiene $b=2$: $x^3-8=(x-2)(x^2+2x+4)$.',
      68
    ),
    (
      'En la factorización $x^3+64=(x+a)(x^2-ax+a^2)$, ¿cuánto vale $a$?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'Como $64=4^3$, se tiene $a=4$: $x^3+64=(x+4)(x^2-4x+16)$.',
      69
    ),
    (
      'En la factorización $x^3-125=(x-a)(x^2+ax+a^2)$, ¿cuánto vale $a$?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      'Como $125=5^3$, se tiene $a=5$: $x^3-125=(x-5)(x^2+5x+25)$.',
      70
    ),
    (
      'Evalúa el factor $x+2$ de la factorización de $x^3+8$ en $x=2$.',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      '$x^3+8=(x+2)(x^2-2x+4)$. Al sustituir $x=2$ en $x+2$: $2+2=4$.',
      71
    ),
    (
      'Evalúa el factor $x-3$ de la factorización de $x^3-27$ en $x=5$.',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      '$x^3-27=(x-3)(x^2+3x+9)$. Al sustituir $x=5$ en $x-3$: $5-3=2$.',
      72
    ),
    -- Factorización por agrupación
    (
      'Al factorizar por agrupación $x^3+2x^2+3x+6$, se obtiene $(x+2)(x^2+3)$. ¿Qué constante aparece en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Agrupamos: $x^2(x+2)+3(x+2)=(x+2)(x^2+3)$. La constante del factor lineal es $2$.',
      73
    ),
    (
      'Al factorizar por agrupación $x^3+4x^2+2x+8$, se obtiene $(x+4)(x^2+2)$. ¿Qué constante aparece en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      'Agrupamos: $x^2(x+4)+2(x+4)=(x+4)(x^2+2)$. La constante del factor lineal es $4$.',
      74
    ),
    (
      'Al factorizar por agrupación $x^3-3x^2+5x-15$, se obtiene $(x-3)(x^2+5)$. ¿Qué constante aparece en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      -3::numeric,
      0.000001::numeric,
      'Agrupamos: $x^2(x-3)+5(x-3)=(x-3)(x^2+5)$. La constante del factor lineal es $-3$.',
      75
    ),
    (
      'Al factorizar por agrupación $x^3+5x^2-2x-10$, se obtiene $(x+5)(x^2-2)$. ¿Qué constante aparece en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      'Agrupamos: $x^2(x+5)-2(x+5)=(x+5)(x^2-2)$. La constante del factor lineal es $5$.',
      76
    ),
    (
      'Al factorizar por agrupación $x^3-2x^2+4x-8$, se obtiene $(x-2)(x^2+4)$. ¿Qué constante aparece en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      -2::numeric,
      0.000001::numeric,
      'Agrupamos: $x^2(x-2)+4(x-2)=(x-2)(x^2+4)$. La constante del factor lineal es $-2$.',
      77
    ),
    (
      'Al factorizar $2x^3+3x^2+4x+6=(2x+3)(x^2+2)$, ¿cuál es el coeficiente de $x$ en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Agrupamos: $x^2(2x+3)+2(2x+3)=(2x+3)(x^2+2)$. El coeficiente de $x$ es $2$.',
      78
    ),
    (
      'Al factorizar $3x^3-6x^2+x-2=(x-2)(3x^2+1)$, ¿qué constante aparece en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      -2::numeric,
      0.000001::numeric,
      'Agrupamos: $3x^2(x-2)+(x-2)=(x-2)(3x^2+1)$. La constante del factor lineal es $-2$.',
      79
    ),
    (
      'Al factorizar por agrupación $x^3+7x^2-3x-21$, se obtiene $(x+7)(x^2-3)$. ¿Qué constante aparece en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.000001::numeric,
      'Agrupamos: $x^2(x+7)-3(x+7)=(x+7)(x^2-3)$. La constante del factor lineal es $7$.',
      80
    ),
    (
      'Al factorizar por agrupación $x^3-5x^2+2x-10$, se obtiene $(x-5)(x^2+2)$. ¿Qué constante aparece en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      -5::numeric,
      0.000001::numeric,
      'Agrupamos: $x^2(x-5)+2(x-5)=(x-5)(x^2+2)$. La constante del factor lineal es $-5$.',
      81
    ),
    (
      'Al factorizar $4x^3+8x^2+3x+6=(x+2)(4x^2+3)$, ¿qué constante aparece en el factor lineal?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      'Agrupamos: $4x^2(x+2)+3(x+2)=(x+2)(4x^2+3)$. La constante del factor lineal es $2$.',
      82
    ),
    -- Aplicaciones y factorizaciones mixtas
    (
      'El área de un rectángulo es $x^2+7x+12$ y uno de sus lados mide $x+3$. ¿Cuál es la constante del otro lado?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      '$x^2+7x+12=(x+3)(x+4)$. El otro lado mide $x+4$; su constante es $4$.',
      83
    ),
    (
      'El área de un rectángulo es $x^2+9x+20$ y uno de sus lados mide $x+4$. ¿Cuál es la constante del otro lado?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      '$x^2+9x+20=(x+4)(x+5)$. El otro lado mide $x+5$; su constante es $5$.',
      84
    ),
    (
      'Un cuadrado tiene área $x^2+12x+36$. ¿Cuánto mide su lado cuando $x=4$?',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.000001::numeric,
      '$x^2+12x+36=(x+6)^2$, así que el lado mide $x+6$. Con $x=4$: $4+6=10$.',
      85
    ),
    (
      'Un cubo tiene volumen $x^3+27$. Su base mide $x^2-3x+9$. ¿Cuánto mide el área de la base cuando $x=1$?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.000001::numeric,
      '$x^3+27=(x+3)(x^2-3x+9)$. En $x=1$: $1-3+9=7$.',
      86
    ),
    (
      'El área de un rectángulo es $x^2-81$ y su lado mayor mide $x+9$. ¿Cuál es la constante del lado menor?',
      'numeric',
      null::jsonb,
      null::integer,
      -9::numeric,
      0.000001::numeric,
      '$x^2-81=(x-9)(x+9)$. El lado menor mide $x-9$; su constante es $-9$.',
      87
    ),
    (
      'Al factorizar $2x^2+7x+3=(2x+1)(x+3)$, ¿cuál es la suma de las constantes de los dos factores?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      '$2x^2+7x+3=(2x+1)(x+3)$. Las constantes son $1$ y $3$; su suma es $4$.',
      88
    ),
    (
      'Al factorizar $3x^2-10x+8=(3x-4)(x-2)$, ¿cuál es la suma de las constantes de los dos factores?',
      'numeric',
      null::jsonb,
      null::integer,
      -6::numeric,
      0.000001::numeric,
      '$3x^2-10x+8=(3x-4)(x-2)$. Las constantes son $-4$ y $-2$; su suma es $-6$.',
      89
    ),
    (
      'Al factorizar $6x^2+11x+4=(3x+4)(2x+1)$, ¿cuál es el producto de las constantes de los dos factores?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.000001::numeric,
      '$6x^2+11x+4=(3x+4)(2x+1)$. Las constantes son $4$ y $1$; su producto es $4$.',
      90
    ),
    (
      '¿Cuántas raíces enteras distintas tiene $x^2-25=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.000001::numeric,
      '$x^2-25=(x-5)(x+5)$. Las raíces son $5$ y $-5$: hay $2$ raíces enteras distintas.',
      91
    ),
    (
      '¿Cuántas raíces reales distintas tiene $x^2+4x+4=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.000001::numeric,
      '$x^2+4x+4=(x+2)^2$. La única raíz real distinta es $-2$.',
      92
    ),
    (
      'Evalúa $x^2+5x+6$ en $x=3$ usando su forma factorizada.',
      'numeric',
      null::jsonb,
      null::integer,
      30::numeric,
      0.000001::numeric,
      '$x^2+5x+6=(x+2)(x+3)$. Con $x=3$: $(3+2)(3+3)=5\cdot 6=30$.',
      93
    ),
    (
      'Evalúa $(x+4)(x-2)$ en $x=5$.',
      'numeric',
      null::jsonb,
      null::integer,
      27::numeric,
      0.000001::numeric,
      'Sustituimos $x=5$: $(5+4)(5-2)=9\cdot 3=27$.',
      94
    ),
    (
      'Si $x^2+bx+24=(x+3)(x+8)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      11::numeric,
      0.000001::numeric,
      '$(x+3)(x+8)=x^2+11x+24$, por lo tanto $b=11$.',
      95
    ),
    (
      'Si $x^2+bx-18=(x-3)(x+6)$, ¿cuánto vale $b$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      '$(x-3)(x+6)=x^2+3x-18$, por lo tanto $b=3$.',
      96
    ),
    (
      'Si $x^2+7x+c=(x+2)(x+5)$, ¿cuánto vale $c$?',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.000001::numeric,
      '$(x+2)(x+5)=x^2+7x+10$, por lo tanto $c=10$.',
      97
    ),
    (
      'Si $x^2-9x+c=(x-4)(x-5)$, ¿cuánto vale $c$?',
      'numeric',
      null::jsonb,
      null::integer,
      20::numeric,
      0.000001::numeric,
      '$(x-4)(x-5)=x^2-9x+20$, por lo tanto $c=20$.',
      98
    ),
    (
      'El área de un rectángulo es $x^2-x-12$ y su base mide $x-4$. ¿Cuál es la constante de la altura?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.000001::numeric,
      '$x^2-x-12=(x-4)(x+3)$. La altura mide $x+3$; su constante es $3$.',
      99
    ),
    (
      'Un cuadrado tiene área $4x^2+12x+9$. ¿Cuánto mide su lado cuando $x=1$?',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.000001::numeric,
      '$4x^2+12x+9=(2x+3)^2$, así que el lado mide $2x+3$. Con $x=1$: $2+3=5$.',
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
  select id from public.modules where slug = 'factorizacion-100'
) as m
where not exists (
  select 1
  from public.exercises e
  where e.module_id = m.id
);
