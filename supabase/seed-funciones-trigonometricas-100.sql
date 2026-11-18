-- ============================================================
--  Mate Dual Brücke · Funciones trigonométricas · 100 ejercicios
--
--  Requisitos:
--    1. Haber ejecutado schema.sql
--    2. Haber ejecutado migration-student-variants.sql
--       (o tener ya las columnas nuevas en public.modules)
--
--  Este archivo crea (o reemplaza el banco de) el módulo
--  'funciones-trigonometricas-100'. Contiene exactamente 100
--  ejercicios que usan únicamente las funciones seno y coseno:
--    - Identificación de amplitud, periodo y desplazamientos.
--    - Evaluación de funciones trigonométricas.
--    - Construcción de ecuaciones a partir de descripciones.
--    - Análisis de rango, máximos, mínimos y ceros.
--    - Aplicaciones: norias, mareas, temperatura, luz, resortes,
--      voltaje, ondas, presión arterial y otras oscilaciones.
--
--  Cada estudiante recibe 40 de los 100 ejercicios, con una
--  selección distinta, para que la guía de práctica y las
--  reasignaciones usen ejercicios diferentes a los de su ronda.
--
--  ATENCIÓN: al eliminar los ejercicios anteriores se borran en
--  cascada los intentos y el progreso de los estudiantes en este
--  módulo. Ejecuta este archivo solo cuando quieras reemplazar el
--  banco completo.
--
--  IMPORTANTE: con la visibilidad estricta por grupos, este módulo
--  solo lo verán los estudiantes de los grupos a los que se asigne.
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
  'Funciones trigonométricas · 100 ejercicios',
  'funciones-trigonometricas-100',
  '100 ejercicios sobre funciones seno y coseno: amplitud, periodo, desplazamientos vertical y horizontal, análisis de gráficas y aplicaciones.',
  6,
  true,
  true,
  40
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
  where slug = 'funciones-trigonometricas-100';

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
  select id from public.modules where slug = 'funciones-trigonometricas-100'
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
  -- A. Identificación de parámetros (1-15)
    (
      'En la función $y=3\sin x+2$, ¿cuál es la amplitud?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.01::numeric,
      'La amplitud es $|A|$. En $y=A\sin x+D$ se tiene $A=3$, así que la amplitud es $3$.',
      1
    ),
    (
      'En la función $y=3\sin x+2$, ¿cuál es el desplazamiento vertical?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.01::numeric,
      'El término independiente $D=2$ desplaza la gráfica $2$ unidades hacia arriba.',
      2
    ),
    (
      'En la función $y=-2\cos x+1$, ¿cuál es la amplitud?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.01::numeric,
      'La amplitud es $|A|=|-2|=2$. El signo negativo solo indica una reflexión respecto al eje $x$.',
      3
    ),
    (
      '¿Cuál es el periodo de la función $y=4\sin(2x)-3$?',
      'multiple_choice',
      jsonb_build_array('$2\pi$', '$\pi$', '$4\pi$', '$\frac{\pi}{2}$'),
      1,
      null::numeric,
      0.001::numeric,
      'El periodo se calcula con $T=\frac{2\pi}{B}$. Aquí $B=2$, así que $T=\frac{2\pi}{2}=\pi$.',
      4
    ),
    (
      '¿Cuál es el periodo de la función $y=\cos(3x)+1$?',
      'multiple_choice',
      jsonb_build_array('$3\pi$', '$2\pi$', '$\frac{2\pi}{3}$', '$\frac{\pi}{3}$'),
      2,
      null::numeric,
      0.001::numeric,
      'Con $B=3$, el periodo es $T=\frac{2\pi}{3}$.',
      5
    ),
    (
      'En la función $y=2\sin\left(x-\frac{\pi}{4}\right)+1$, ¿cuál es el desplazamiento horizontal?',
      'multiple_choice',
      jsonb_build_array('$\frac{\pi}{4}$ a la izquierda', '$\frac{\pi}{4}$ a la derecha', '$2$ a la derecha', '$\frac{\pi}{2}$ a la derecha'),
      1,
      null::numeric,
      0.001::numeric,
      'La forma es $y=A\sin(B(x-C))+D$. Aquí $C=\frac{\pi}{4}$, así que la gráfica se desplaza $\frac{\pi}{4}$ a la derecha.',
      6
    ),
    (
      'En la función $y=\cos\left(x+\frac{\pi}{3}\right)-2$, ¿cuál es el desplazamiento horizontal?',
      'multiple_choice',
      jsonb_build_array('$\frac{\pi}{3}$ a la derecha', '$2$ a la izquierda', '$\frac{2\pi}{3}$ a la izquierda', '$\frac{\pi}{3}$ a la izquierda'),
      3,
      null::numeric,
      0.001::numeric,
      'Se escribe $x+\frac{\pi}{3}=x-\left(-\frac{\pi}{3}\right)$, así que el desplazamiento es $\frac{\pi}{3}$ a la izquierda.',
      7
    ),
    (
      'En la función $y=5\sin(2x+\pi)+4$, ¿cuál es el desplazamiento horizontal?',
      'multiple_choice',
      jsonb_build_array('$\frac{\pi}{2}$ a la izquierda', '$\pi$ a la izquierda', '$\frac{\pi}{2}$ a la derecha', '$\pi$ a la derecha'),
      0,
      null::numeric,
      0.001::numeric,
      'Se factoriza: $2x+\pi=2\left(x+\frac{\pi}{2}\right)$. El desplazamiento es $\frac{\pi}{2}$ a la izquierda.',
      8
    ),
    (
      '¿Cuál es el rango de la función $y=-3\cos(2x)-1$?',
      'multiple_choice',
      jsonb_build_array('$[-3,3]$', '$[-2,4]$', '$[-4,2]$', '$[-1,5]$'),
      2,
      null::numeric,
      0.001::numeric,
      'La amplitud es $3$ y el desplazamiento vertical es $-1$. El rango es $[-3-1,3-1]=[-4,2]$.',
      9
    ),
    (
      '¿Cuál es el valor máximo de la función $y=2\sin x+5$?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.01::numeric,
      'El máximo de $\sin x$ es $1$, así que el máximo es $2(1)+5=7$.',
      10
    ),
    (
      '¿Cuál es el valor mínimo de la función $y=2\sin x+5$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.01::numeric,
      'El mínimo de $\sin x$ es $-1$, así que el mínimo es $2(-1)+5=3$.',
      11
    ),
    (
      '¿Cuál es el rango de la función $y=4\cos x-1$?',
      'multiple_choice',
      jsonb_build_array('$[-3,5]$', '$[-5,3]$', '$[-4,4]$', '$[-1,7]$'),
      1,
      null::numeric,
      0.001::numeric,
      'La amplitud es $4$ y el desplazamiento vertical es $-1$. El rango es $[-4-1,4-1]=[-5,3]$.',
      12
    ),
    (
      'En la función $y=\sin\left(2x-\frac{\pi}{3}\right)$, ¿cuál es el desplazamiento horizontal?',
      'multiple_choice',
      jsonb_build_array('$\frac{\pi}{3}$ a la derecha', '$\frac{\pi}{3}$ a la izquierda', '$\frac{\pi}{6}$ a la izquierda', '$\frac{\pi}{6}$ a la derecha'),
      3,
      null::numeric,
      0.001::numeric,
      'Se factoriza: $2x-\frac{\pi}{3}=2\left(x-\frac{\pi}{6}\right)$. El desplazamiento es $\frac{\pi}{6}$ a la derecha.',
      13
    ),
    (
      '¿Cuál es el periodo de la función $y=3\cos(\pi x)+2$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.01::numeric,
      'Con $B=\pi$, el periodo es $T=\frac{2\pi}{\pi}=2$.',
      14
    ),
    (
      '¿Qué transformaciones se aplicaron a $y=\sin x$ para obtener $y=-\sin x+4$?',
      'multiple_choice',
      jsonb_build_array('Reflexión respecto al eje $y$ y desplazamiento vertical $4$ hacia arriba', 'Desplazamiento vertical $4$ hacia abajo', 'Reflexión respecto al eje $x$ y desplazamiento vertical $4$ hacia arriba', 'Amplitud $4$ y desplazamiento horizontal'),
      2,
      null::numeric,
      0.001::numeric,
      'El signo negativo refleja la gráfica respecto al eje $x$ y el $+4$ la desplaza $4$ unidades hacia arriba.',
      15
    ),
  -- B. Evaluación de funciones (16-30)
    (
      'Si $f(x)=2\sin x+1$, calcula $f\left(\frac{\pi}{2}\right)$.',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.01::numeric,
      '$\sin\left(\frac{\pi}{2}\right)=1$, entonces $f\left(\frac{\pi}{2}\right)=2(1)+1=3$.',
      16
    ),
    (
      'Si $f(x)=3\cos x-2$, calcula $f(0)$.',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.01::numeric,
      '$\cos 0=1$, entonces $f(0)=3(1)-2=1$.',
      17
    ),
    (
      'Si $f(x)=4\sin(2x)$, calcula $f\left(\frac{\pi}{4}\right)$.',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.01::numeric,
      '$2\cdot\frac{\pi}{4}=\frac{\pi}{2}$ y $\sin\left(\frac{\pi}{2}\right)=1$, entonces $f\left(\frac{\pi}{4}\right)=4$.',
      18
    ),
    (
      'Si $f(x)=2\cos(2x)+1$, calcula $f\left(\frac{\pi}{2}\right)$.',
      'numeric',
      null::jsonb,
      null::integer,
      -1::numeric,
      0.01::numeric,
      '$2\cdot\frac{\pi}{2}=\pi$ y $\cos\pi=-1$, entonces $f\left(\frac{\pi}{2}\right)=2(-1)+1=-1$.',
      19
    ),
    (
      'Si $f(x)=\sin\left(x-\frac{\pi}{2}\right)+3$, calcula $f(\pi)$.',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.01::numeric,
      '$\pi-\frac{\pi}{2}=\frac{\pi}{2}$ y $\sin\left(\frac{\pi}{2}\right)=1$, entonces $f(\pi)=1+3=4$.',
      20
    ),
    (
      'Si $f(x)=\cos\left(x+\frac{\pi}{2}\right)$, calcula $f(0)$.',
      'numeric',
      null::jsonb,
      null::integer,
      0::numeric,
      0.01::numeric,
      '$f(0)=\cos\left(\frac{\pi}{2}\right)=0$.',
      21
    ),
    (
      'Si $f(x)=3\sin\left(x+\frac{\pi}{6}\right)+2$, calcula $f\left(\frac{\pi}{3}\right)$.',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.01::numeric,
      '$\frac{\pi}{3}+\frac{\pi}{6}=\frac{\pi}{2}$ y $\sin\left(\frac{\pi}{2}\right)=1$, entonces $f\left(\frac{\pi}{3}\right)=3(1)+2=5$.',
      22
    ),
    (
      'Si $f(x)=2\cos\left(x-\frac{\pi}{3}\right)-1$, calcula $f(\pi)$.',
      'numeric',
      null::jsonb,
      null::integer,
      -2::numeric,
      0.01::numeric,
      '$\pi-\frac{\pi}{3}=\frac{2\pi}{3}$ y $\cos\left(\frac{2\pi}{3}\right)=-\frac{1}{2}$. Entonces $f(\pi)=2\left(-\frac{1}{2}\right)-1=-2$.',
      23
    ),
    (
      'Si $f(x)=5\sin(\pi x)$, calcula $f\left(\frac{1}{2}\right)$.',
      'numeric',
      null::jsonb,
      null::integer,
      5::numeric,
      0.01::numeric,
      '$\pi\cdot\frac{1}{2}=\frac{\pi}{2}$ y $\sin\left(\frac{\pi}{2}\right)=1$, entonces $f\left(\frac{1}{2}\right)=5$.',
      24
    ),
    (
      'Si $f(x)=4\cos\left(\frac{\pi x}{2}\right)$, calcula $f(1)$.',
      'numeric',
      null::jsonb,
      null::integer,
      0::numeric,
      0.01::numeric,
      '$f(1)=4\cos\left(\frac{\pi}{2}\right)=4(0)=0$.',
      25
    ),
    (
      'Si $f(x)=-2\sin x+3$, calcula $f\left(\frac{\pi}{2}\right)$.',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.01::numeric,
      '$\sin\left(\frac{\pi}{2}\right)=1$, entonces $f\left(\frac{\pi}{2}\right)=-2(1)+3=1$.',
      26
    ),
    (
      'Si $f(x)=3\cos(2x-\pi)$, calcula $f\left(\frac{\pi}{4}\right)$.',
      'numeric',
      null::jsonb,
      null::integer,
      0::numeric,
      0.01::numeric,
      '$2\cdot\frac{\pi}{4}-\pi=-\frac{\pi}{2}$ y $\cos\left(-\frac{\pi}{2}\right)=0$, entonces $f\left(\frac{\pi}{4}\right)=0$.',
      27
    ),
    (
      'Si $f(x)=2\sin(3x)+4$, calcula $f\left(\frac{\pi}{6}\right)$.',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.01::numeric,
      '$3\cdot\frac{\pi}{6}=\frac{\pi}{2}$ y $\sin\left(\frac{\pi}{2}\right)=1$, entonces $f\left(\frac{\pi}{6}\right)=2(1)+4=6$.',
      28
    ),
    (
      'Si $f(x)=\cos(2x)+2$, calcula $f\left(\frac{\pi}{6}\right)$.',
      'numeric',
      null::jsonb,
      null::integer,
      2.5::numeric,
      0.01::numeric,
      '$2\cdot\frac{\pi}{6}=\frac{\pi}{3}$ y $\cos\left(\frac{\pi}{3}\right)=\frac{1}{2}$, entonces $f\left(\frac{\pi}{6}\right)=\frac{1}{2}+2=2.5$.',
      29
    ),
    (
      'Si $f(x)=6\sin\left(\frac{x}{2}\right)$, calcula $f(\pi)$.',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.01::numeric,
      '$f(\pi)=6\sin\left(\frac{\pi}{2}\right)=6(1)=6$.',
      30
    ),
  -- C. Construcción de la ecuación (31-45)
    (
      '¿Cuál es la ecuación de una función seno con amplitud $3$, periodo $2\pi$ y desplazamiento vertical $1$ hacia arriba?',
      'multiple_choice',
      jsonb_build_array('$y=3\cos x+1$', '$y=\sin x+3$', '$y=3\sin x+1$', '$y=3\sin(x+1)$'),
      2,
      null::numeric,
      0.001::numeric,
      'La amplitud es $3$, el periodo $2\pi$ implica $B=1$ y el desplazamiento vertical es $+1$: $y=3\sin x+1$.',
      31
    ),
    (
      '¿Cuál es la ecuación de una función coseno con amplitud $2$, periodo $\pi$ y desplazamiento vertical $3$ hacia abajo?',
      'multiple_choice',
      jsonb_build_array('$y=2\cos(2x)-3$', '$y=2\cos x-3$', '$y=2\sin(2x)-3$', '$y=2\cos(2x)+3$'),
      0,
      null::numeric,
      0.001::numeric,
      'El periodo $\pi$ implica $B=\frac{2\pi}{\pi}=2$; la amplitud es $2$ y el desplazamiento vertical es $-3$: $y=2\cos(2x)-3$.',
      32
    ),
    (
      '¿Cuál es la ecuación de una función seno con amplitud $4$, periodo $4\pi$ y sin desplazamientos?',
      'multiple_choice',
      jsonb_build_array('$y=4\sin(2x)$', '$y=4\cos\left(\frac{x}{2}\right)$', '$y=4\sin x-2$', '$y=4\sin\left(\frac{x}{2}\right)$'),
      3,
      null::numeric,
      0.001::numeric,
      'El periodo $4\pi$ implica $B=\frac{2\pi}{4\pi}=\frac{1}{2}$: $y=4\sin\left(\frac{x}{2}\right)$.',
      33
    ),
    (
      '¿Cuál es la ecuación de una función coseno con amplitud $1$, periodo $\frac{2\pi}{3}$ y desplazamiento vertical $2$ hacia arriba?',
      'multiple_choice',
      jsonb_build_array('$y=\cos\left(\frac{x}{3}\right)+2$', '$y=\cos(3x)+2$', '$y=3\cos x+2$', '$y=\cos(3x)-2$'),
      1,
      null::numeric,
      0.001::numeric,
      'El periodo $\frac{2\pi}{3}$ implica $B=3$; la amplitud es $1$ y el desplazamiento vertical es $+2$: $y=\cos(3x)+2$.',
      34
    ),
    (
      '¿Cuál es la ecuación de una función seno con amplitud $3$, periodo $2\pi$, desplazada $\frac{\pi}{2}$ a la derecha y $1$ hacia arriba?',
      'multiple_choice',
      jsonb_build_array('$y=3\sin\left(x+\frac{\pi}{2}\right)+1$', '$y=3\cos\left(x-\frac{\pi}{2}\right)+1$', '$y=3\sin\left(x-\frac{\pi}{2}\right)+1$', '$y=3\sin\left(x-\frac{\pi}{2}\right)-1$'),
      2,
      null::numeric,
      0.001::numeric,
      'La forma es $y=A\sin(B(x-C))+D$ con $A=3$, $B=1$, $C=\frac{\pi}{2}$ y $D=1$: $y=3\sin\left(x-\frac{\pi}{2}\right)+1$.',
      35
    ),
    (
      '¿Cuál es la ecuación de una función coseno con amplitud $2$, periodo $2\pi$, desplazada $\frac{\pi}{4}$ a la izquierda y $1$ hacia abajo?',
      'multiple_choice',
      jsonb_build_array('$y=2\cos\left(x+\frac{\pi}{4}\right)-1$', '$y=2\cos\left(x-\frac{\pi}{4}\right)-1$', '$y=2\sin\left(x+\frac{\pi}{4}\right)-1$', '$y=2\cos\left(x+\frac{\pi}{4}\right)+1$'),
      0,
      null::numeric,
      0.001::numeric,
      'Con desplazamiento a la izquierda se usa $x+\frac{\pi}{4}$: $y=2\cos\left(x+\frac{\pi}{4}\right)-1$.',
      36
    ),
    (
      '¿Cuál es la ecuación de una función seno con amplitud $5$, periodo $2\pi$ y desplazada $\frac{\pi}{3}$ a la derecha?',
      'multiple_choice',
      jsonb_build_array('$y=5\sin\left(x+\frac{\pi}{3}\right)$', '$y=5\cos\left(x-\frac{\pi}{3}\right)$', '$y=5\sin\left(3x-\frac{\pi}{3}\right)$', '$y=5\sin\left(x-\frac{\pi}{3}\right)$'),
      3,
      null::numeric,
      0.001::numeric,
      'El periodo $2\pi$ implica $B=1$ y el desplazamiento a la derecha es $C=\frac{\pi}{3}$: $y=5\sin\left(x-\frac{\pi}{3}\right)$.',
      37
    ),
    (
      '¿Cuál es la ecuación de una función coseno con amplitud $2$, periodo $\pi$, desplazada $\frac{\pi}{6}$ a la derecha y $3$ hacia arriba?',
      'multiple_choice',
      jsonb_build_array('$y=2\cos\left(2x+\frac{\pi}{3}\right)+3$', '$y=2\cos\left(2x-\frac{\pi}{3}\right)+3$', '$y=2\cos\left(2x-\frac{\pi}{6}\right)+3$', '$y=2\sin\left(2x-\frac{\pi}{3}\right)+3$'),
      1,
      null::numeric,
      0.001::numeric,
      'Con $B=2$ y $C=\frac{\pi}{6}$: $y=2\cos\left(2\left(x-\frac{\pi}{6}\right)\right)+3=2\cos\left(2x-\frac{\pi}{3}\right)+3$.',
      38
    ),
    (
      '¿Cuál es la ecuación de una función seno con amplitud $4$, periodo $2\pi$, desplazada $\frac{\pi}{2}$ a la izquierda y $2$ hacia abajo?',
      'multiple_choice',
      jsonb_build_array('$y=4\sin\left(x-\frac{\pi}{2}\right)-2$', '$y=4\cos\left(x+\frac{\pi}{2}\right)-2$', '$y=4\sin\left(x+\frac{\pi}{2}\right)+2$', '$y=4\sin\left(x+\frac{\pi}{2}\right)-2$'),
      3,
      null::numeric,
      0.001::numeric,
      'El desplazamiento a la izquierda es $x+\frac{\pi}{2}$ y el vertical es $-2$: $y=4\sin\left(x+\frac{\pi}{2}\right)-2$.',
      39
    ),
    (
      '¿Cuál es la ecuación de una función coseno con amplitud $3$, periodo $8\pi$, desplazada $\frac{\pi}{2}$ a la derecha y $1$ hacia arriba?',
      'multiple_choice',
      jsonb_build_array('$y=3\cos\left(\frac{x}{4}-\frac{\pi}{8}\right)+1$', '$y=3\cos\left(\frac{x}{4}+\frac{\pi}{8}\right)+1$', '$y=3\cos\left(4x-\frac{\pi}{8}\right)+1$', '$y=3\cos\left(\frac{x}{4}-\frac{\pi}{2}\right)+1$'),
      0,
      null::numeric,
      0.001::numeric,
      'El periodo $8\pi$ implica $B=\frac{1}{4}$. Con $C=\frac{\pi}{2}$: $y=3\cos\left(\frac{1}{4}\left(x-\frac{\pi}{2}\right)\right)+1=3\cos\left(\frac{x}{4}-\frac{\pi}{8}\right)+1$.',
      40
    ),
    (
      '¿Cuál es la ecuación de una función seno con amplitud $0.5$, periodo $\frac{\pi}{2}$ y desplazamiento vertical $2$ hacia arriba?',
      'multiple_choice',
      jsonb_build_array('$y=0.5\sin(2x)+2$', '$y=0.5\sin(4x)+2$', '$y=2\sin(4x)+0.5$', '$y=0.5\sin(4x)-2$'),
      1,
      null::numeric,
      0.001::numeric,
      'El periodo $\frac{\pi}{2}$ implica $B=\frac{2\pi}{\pi/2}=4$: $y=0.5\sin(4x)+2$.',
      41
    ),
    (
      '¿Cuál es la ecuación de una función coseno con amplitud $7$, periodo $12\pi$ y desplazamiento vertical $4$ hacia abajo?',
      'multiple_choice',
      jsonb_build_array('$y=7\cos(6x)-4$', '$y=7\cos\left(\frac{x}{6}\right)+4$', '$y=7\cos\left(\frac{x}{6}\right)-4$', '$y=7\sin\left(\frac{x}{6}\right)-4$'),
      2,
      null::numeric,
      0.001::numeric,
      'El periodo $12\pi$ implica $B=\frac{2\pi}{12\pi}=\frac{1}{6}$: $y=7\cos\left(\frac{x}{6}\right)-4$.',
      42
    ),
    (
      '¿Cuál es la ecuación de una función seno con amplitud $2$, periodo $6\pi$ y desplazamiento vertical $1$ hacia arriba?',
      'multiple_choice',
      jsonb_build_array('$y=2\sin(3x)+1$', '$y=2\sin\left(\frac{x}{3}\right)-1$', '$y=2\cos\left(\frac{x}{3}\right)+1$', '$y=2\sin\left(\frac{x}{3}\right)+1$'),
      3,
      null::numeric,
      0.001::numeric,
      'El periodo $6\pi$ implica $B=\frac{1}{3}$: $y=2\sin\left(\frac{x}{3}\right)+1$.',
      43
    ),
    (
      '¿Cuál es la ecuación de una función coseno reflejada respecto al eje $x$, con amplitud $3$, periodo $2\pi$ y desplazamiento vertical $5$ hacia arriba?',
      'multiple_choice',
      jsonb_build_array('$y=-3\cos x+5$', '$y=3\cos x+5$', '$y=-3\sin x+5$', '$y=-3\cos x-5$'),
      0,
      null::numeric,
      0.001::numeric,
      'La reflexión se logra con amplitud negativa y el desplazamiento vertical es $+5$: $y=-3\cos x+5$.',
      44
    ),
    (
      '¿Cuál es la ecuación de una función seno con amplitud $2$, periodo $3\pi$ y desplazada $\frac{\pi}{3}$ a la derecha?',
      'multiple_choice',
      jsonb_build_array('$y=2\sin\left(\frac{3x}{2}-\frac{\pi}{3}\right)$', '$y=2\sin\left(\frac{2x}{3}+\frac{2\pi}{9}\right)$', '$y=2\sin\left(\frac{2x}{3}-\frac{2\pi}{9}\right)$', '$y=2\cos\left(\frac{2x}{3}-\frac{2\pi}{9}\right)$'),
      2,
      null::numeric,
      0.001::numeric,
      'El periodo $3\pi$ implica $B=\frac{2}{3}$. Con $C=\frac{\pi}{3}$: $y=2\sin\left(\frac{2}{3}\left(x-\frac{\pi}{3}\right)\right)=2\sin\left(\frac{2x}{3}-\frac{2\pi}{9}\right)$.',
      45
    ),
  -- D. Análisis de gráficas, rango y ceros (46-60)
    (
      '¿Cuál es el rango de la función $y=3\sin x-2$?',
      'multiple_choice',
      jsonb_build_array('$[-3,3]$', '$[-1,5]$', '$[-5,1]$', '$[-2,2]$'),
      2,
      null::numeric,
      0.001::numeric,
      'La amplitud es $3$ y el desplazamiento vertical es $-2$: el rango es $[-3-2,3-2]=[-5,1]$.',
      46
    ),
    (
      '¿Cuál es el valor máximo de la función $y=-4\cos x+6$?',
      'numeric',
      null::jsonb,
      null::integer,
      10::numeric,
      0.01::numeric,
      'El máximo ocurre cuando $\cos x=-1$: $y=-4(-1)+6=10$.',
      47
    ),
    (
      '¿Cuál es el valor mínimo de la función $y=2\sin x-3$?',
      'numeric',
      null::jsonb,
      null::integer,
      -5::numeric,
      0.01::numeric,
      'El mínimo ocurre cuando $\sin x=-1$: $y=2(-1)-3=-5$.',
      48
    ),
    (
      '¿Cuántos ciclos completos tiene la gráfica de $y=\sin(3x)$ en el intervalo $[0,2\pi]$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.01::numeric,
      'El periodo es $\frac{2\pi}{3}$, así que en $2\pi$ caben $\frac{2\pi}{2\pi/3}=3$ ciclos completos.',
      49
    ),
    (
      '¿Cuál es el rango de la función $y=2\cos(2x)+1$?',
      'multiple_choice',
      jsonb_build_array('$[-3,3]$', '$[-1,3]$', '$[0,4]$', '$[-2,2]$'),
      1,
      null::numeric,
      0.001::numeric,
      'La amplitud es $2$ y el desplazamiento vertical es $+1$: el rango es $[-2+1,2+1]=[-1,3]$.',
      50
    ),
    (
      '¿Cuál es el valor máximo de la función $y=-3\sin x+4$?',
      'numeric',
      null::jsonb,
      null::integer,
      7::numeric,
      0.01::numeric,
      'El máximo de $-3\sin x$ es $3$ (cuando $\sin x=-1$), entonces el máximo es $3+4=7$.',
      51
    ),
    (
      '¿Cuáles son los ceros de $y=5\cos\left(x-\frac{\pi}{2}\right)$ en el intervalo $[0,2\pi]$?',
      'multiple_choice',
      jsonb_build_array('$0$ y $\pi$', '$\frac{\pi}{2}$ y $\frac{3\pi}{2}$', '$0$ y $2\pi$', '$0$, $\pi$ y $2\pi$'),
      3,
      null::numeric,
      0.001::numeric,
      '$\cos\left(x-\frac{\pi}{2}\right)=\sin x$, que se anula en $x=0$, $x=\pi$ y $x=2\pi$.',
      52
    ),
    (
      '¿Cuántos ceros tiene $y=3\sin(2x)$ en el intervalo $[0,\pi]$?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.01::numeric,
      '$2x=0,\pi,2\pi$ dan $x=0,\frac{\pi}{2},\pi$: hay $3$ ceros.',
      53
    ),
    (
      '¿Cuál es el rango de la función $y=\cos x+2$?',
      'multiple_choice',
      jsonb_build_array('$[1,3]$', '$[-1,1]$', '$[0,2]$', '$[2,4]$'),
      0,
      null::numeric,
      0.001::numeric,
      'Como $-1\le\cos x\le 1$, al sumar $2$ se obtiene $1\le y\le 3$.',
      54
    ),
    (
      '¿Cuál es la amplitud de la función $y=-2\cos(3x)-1$?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.01::numeric,
      'La amplitud es $|A|=|-2|=2$.',
      55
    ),
    (
      'En la función $y=4\sin x+1$, ¿cuánto suman el valor máximo y el valor mínimo?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.01::numeric,
      'El máximo es $4+1=5$ y el mínimo es $-4+1=-3$. La suma es $5+(-3)=2$.',
      56
    ),
    (
      '¿Cuál es el periodo de la función $y=6\cos\left(\frac{\pi x}{3}\right)$?',
      'numeric',
      null::jsonb,
      null::integer,
      6::numeric,
      0.01::numeric,
      'Con $B=\frac{\pi}{3}$, el periodo es $T=\frac{2\pi}{\pi/3}=6$.',
      57
    ),
    (
      '¿Cuál es el periodo de la función $y=2\sin\left(\frac{x}{4}\right)$?',
      'multiple_choice',
      jsonb_build_array('$4\pi$', '$\frac{\pi}{2}$', '$8\pi$', '$2\pi$'),
      2,
      null::numeric,
      0.001::numeric,
      'Con $B=\frac{1}{4}$, el periodo es $T=\frac{2\pi}{1/4}=8\pi$.',
      58
    ),
    (
      '¿Cuál es el rango de la función $y=\cos(4x)+3$?',
      'multiple_choice',
      jsonb_build_array('$[-1,1]$', '$[3,5]$', '$[0,4]$', '$[2,4]$'),
      3,
      null::numeric,
      0.001::numeric,
      'Como $-1\le\cos(4x)\le 1$, al sumar $3$ se obtiene $2\le y\le 4$.',
      59
    ),
    (
      '¿Qué ecuación resulta de desplazar la gráfica de $y=\sin x$ tres unidades hacia abajo?',
      'multiple_choice',
      jsonb_build_array('$y=\sin(x-3)$', '$y=\sin x-3$', '$y=\sin x+3$', '$y=3\sin x$'),
      1,
      null::numeric,
      0.001::numeric,
      'Un desplazamiento vertical hacia abajo se resta fuera de la función: $y=\sin x-3$.',
      60
    ),
  -- E. Aplicaciones (61-100)
    (
      'Una noria tiene una altura modelada por $h(t)=12\cos\left(\frac{\pi t}{30}\right)+15$ metros, donde $t$ se mide en segundos. ¿Qué altura alcanza en $t=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      27::numeric,
      0.01::numeric,
      'En $t=0$, $\cos 0=1$, entonces $h(0)=12(1)+15=27$ m.',
      61
    ),
    (
      'Para la noria del ejercicio anterior, $h(t)=12\cos\left(\frac{\pi t}{30}\right)+15$, ¿cuál es la altura mínima?',
      'numeric',
      null::jsonb,
      null::integer,
      3::numeric,
      0.01::numeric,
      'El mínimo de $\cos$ es $-1$: $h_{\min}=12(-1)+15=3$ m.',
      62
    ),
    (
      'Para la noria del ejercicio anterior, $h(t)=12\cos\left(\frac{\pi t}{30}\right)+15$, ¿cuál es el periodo en segundos?',
      'numeric',
      null::jsonb,
      null::integer,
      60::numeric,
      0.01::numeric,
      'El periodo es $T=\frac{2\pi}{\pi/30}=60$ s.',
      63
    ),
    (
      'Para la noria del ejercicio anterior, $h(t)=12\cos\left(\frac{\pi t}{30}\right)+15$, ¿qué altura alcanza en $t=15$ s?',
      'numeric',
      null::jsonb,
      null::integer,
      15::numeric,
      0.01::numeric,
      '$h(15)=12\cos\left(\frac{\pi}{2}\right)+15=12(0)+15=15$ m.',
      64
    ),
    (
      'La altura de la marea se modela con $h(t)=2.5\cos\left(\frac{\pi t}{6}\right)+4.2$ metros, con $t$ en horas. ¿Qué altura hay en $t=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      6.7::numeric,
      0.1::numeric,
      '$h(0)=2.5(1)+4.2=6.7$ m.',
      65
    ),
    (
      'Para la marea del ejercicio anterior, $h(t)=2.5\cos\left(\frac{\pi t}{6}\right)+4.2$, ¿cuál es la altura mínima?',
      'numeric',
      null::jsonb,
      null::integer,
      1.7::numeric,
      0.1::numeric,
      '$h_{\min}=2.5(-1)+4.2=1.7$ m.',
      66
    ),
    (
      'Para la marea del ejercicio anterior, $h(t)=2.5\cos\left(\frac{\pi t}{6}\right)+4.2$, ¿cuál es el periodo en horas?',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.01::numeric,
      '$T=\frac{2\pi}{\pi/6}=12$ h.',
      67
    ),
    (
      'La temperatura de una ciudad se modela con $T(t)=8\cos\left(\frac{\pi(t-14)}{12}\right)+22$ grados Celsius, con $t$ en horas. ¿Cuál es la temperatura máxima?',
      'numeric',
      null::jsonb,
      null::integer,
      30::numeric,
      0.01::numeric,
      'El máximo de $\cos$ es $1$: $T_{\max}=8(1)+22=30$ °C.',
      68
    ),
    (
      'Para la temperatura del ejercicio anterior, $T(t)=8\cos\left(\frac{\pi(t-14)}{12}\right)+22$, ¿cuál es la temperatura mínima?',
      'numeric',
      null::jsonb,
      null::integer,
      14::numeric,
      0.01::numeric,
      '$T_{\min}=8(-1)+22=14$ °C.',
      69
    ),
    (
      'Para la temperatura del ejercicio anterior, $T(t)=8\cos\left(\frac{\pi(t-14)}{12}\right)+22$, ¿qué temperatura hay a las 14:00, es decir, en $t=14$?',
      'numeric',
      null::jsonb,
      null::integer,
      30::numeric,
      0.01::numeric,
      '$T(14)=8\cos 0+22=8+22=30$ °C.',
      70
    ),
    (
      'Las horas de luz diurna se modelan con $D(t)=2.5\cos\left(\frac{2\pi(t-172)}{365}\right)+12.2$ horas. ¿Cuál es el máximo de horas de luz?',
      'numeric',
      null::jsonb,
      null::integer,
      14.7::numeric,
      0.1::numeric,
      '$D_{\max}=2.5(1)+12.2=14.7$ h.',
      71
    ),
    (
      'Para la función de luz diurna del ejercicio anterior, $D(t)=2.5\cos\left(\frac{2\pi(t-172)}{365}\right)+12.2$, ¿cuál es el mínimo de horas de luz?',
      'numeric',
      null::jsonb,
      null::integer,
      9.7::numeric,
      0.1::numeric,
      '$D_{\min}=2.5(-1)+12.2=9.7$ h.',
      72
    ),
    (
      'Para la función de luz diurna del ejercicio anterior, $D(t)=2.5\cos\left(\frac{2\pi(t-172)}{365}\right)+12.2$, ¿cuál es el periodo en días?',
      'numeric',
      null::jsonb,
      null::integer,
      365::numeric,
      0.01::numeric,
      '$T=\frac{2\pi}{2\pi/365}=365$ días.',
      73
    ),
    (
      'La posición de un resorte se modela con $y(t)=4\cos(4\pi t)$ centímetros. ¿Cuál es la posición inicial, en $t=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.01::numeric,
      '$y(0)=4\cos 0=4$ cm.',
      74
    ),
    (
      'Para el resorte del ejercicio anterior, $y(t)=4\cos(4\pi t)$, ¿cuál es el periodo en segundos?',
      'numeric',
      null::jsonb,
      null::integer,
      0.5::numeric,
      0.01::numeric,
      '$T=\frac{2\pi}{4\pi}=0.5$ s.',
      75
    ),
    (
      'Para el resorte del ejercicio anterior, $y(t)=4\cos(4\pi t)$, ¿cuál es la amplitud en centímetros?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.01::numeric,
      'La amplitud es el coeficiente de la función: $4$ cm.',
      76
    ),
    (
      'Un voltaje alterno se modela con $V(t)=120\cos(120\pi t)$ voltios. ¿Cuál es el voltaje máximo?',
      'numeric',
      null::jsonb,
      null::integer,
      120::numeric,
      0.01::numeric,
      'El máximo de $\cos$ es $1$: $V_{\max}=120$ V.',
      77
    ),
    (
      'Para el voltaje del ejercicio anterior, $V(t)=120\cos(120\pi t)$, ¿cuál es el periodo en segundos? Redondea a tres decimales.',
      'numeric',
      null::jsonb,
      null::integer,
      0.017::numeric,
      0.001::numeric,
      '$T=\frac{2\pi}{120\pi}=\frac{1}{60}\approx 0.017$ s.',
      78
    ),
    (
      'Para el voltaje del ejercicio anterior, $V(t)=120\cos(120\pi t)$, ¿cuál es la frecuencia en hercios?',
      'numeric',
      null::jsonb,
      null::integer,
      60::numeric,
      0.01::numeric,
      'La frecuencia es $f=\frac{1}{T}=60$ Hz.',
      79
    ),
    (
      'Una onda sonora se modela con $y(t)=0.02\sin(1760\pi t)$. ¿Cuál es la amplitud?',
      'numeric',
      null::jsonb,
      null::integer,
      0.02::numeric,
      0.001::numeric,
      'La amplitud es el coeficiente de la función: $0.02$.',
      80
    ),
    (
      'Una noria tiene una altura modelada por $h(t)=10\sin\left(\frac{\pi(t-5)}{10}\right)+12$ metros. ¿Qué altura hay en $t=5$ segundos?',
      'numeric',
      null::jsonb,
      null::integer,
      12::numeric,
      0.01::numeric,
      '$h(5)=10\sin 0+12=12$ m.',
      81
    ),
    (
      'Para la noria del ejercicio anterior, $h(t)=10\sin\left(\frac{\pi(t-5)}{10}\right)+12$, ¿cuál es la altura máxima?',
      'numeric',
      null::jsonb,
      null::integer,
      22::numeric,
      0.01::numeric,
      '$h_{\max}=10(1)+12=22$ m.',
      82
    ),
    (
      'Para la noria del ejercicio anterior, $h(t)=10\sin\left(\frac{\pi(t-5)}{10}\right)+12$, ¿cuál es la altura mínima?',
      'numeric',
      null::jsonb,
      null::integer,
      2::numeric,
      0.01::numeric,
      '$h_{\min}=10(-1)+12=2$ m.',
      83
    ),
    (
      'El consumo eléctrico de una fábrica se modela con $P(t)=150\cos\left(\frac{\pi(t-13)}{12}\right)+400$ kilovatios. ¿Cuál es el consumo máximo?',
      'numeric',
      null::jsonb,
      null::integer,
      550::numeric,
      0.01::numeric,
      '$P_{\max}=150(1)+400=550$ kW.',
      84
    ),
    (
      'Para el consumo del ejercicio anterior, $P(t)=150\cos\left(\frac{\pi(t-13)}{12}\right)+400$, ¿cuál es el consumo mínimo?',
      'numeric',
      null::jsonb,
      null::integer,
      250::numeric,
      0.01::numeric,
      '$P_{\min}=150(-1)+400=250$ kW.',
      85
    ),
    (
      'Para el consumo del ejercicio anterior, $P(t)=150\cos\left(\frac{\pi(t-13)}{12}\right)+400$, ¿cuál es el periodo en horas?',
      'numeric',
      null::jsonb,
      null::integer,
      24::numeric,
      0.01::numeric,
      '$T=\frac{2\pi}{\pi/12}=24$ h.',
      86
    ),
    (
      'La presión arterial se modela con $P(t)=10\cos\left(\frac{2\pi t}{0.8}\right)+120$ milímetros de mercurio. ¿Cuál es la presión máxima?',
      'numeric',
      null::jsonb,
      null::integer,
      130::numeric,
      0.01::numeric,
      '$P_{\max}=10(1)+120=130$ mmHg.',
      87
    ),
    (
      'Para la presión arterial del ejercicio anterior, $P(t)=10\cos\left(\frac{2\pi t}{0.8}\right)+120$, ¿cuál es la presión mínima?',
      'numeric',
      null::jsonb,
      null::integer,
      110::numeric,
      0.01::numeric,
      '$P_{\min}=10(-1)+120=110$ mmHg.',
      88
    ),
    (
      'Para la presión arterial del ejercicio anterior, $P(t)=10\cos\left(\frac{2\pi t}{0.8}\right)+120$, ¿cuál es el periodo en segundos?',
      'numeric',
      null::jsonb,
      null::integer,
      0.8::numeric,
      0.01::numeric,
      '$T=0.8$ s, porque el coeficiente de $t$ es $\frac{2\pi}{0.8}$.',
      89
    ),
    (
      'El volumen de aire en los pulmones se modela con $V(t)=0.5\sin\left(\frac{\pi t}{2}\right)+0.5$ litros. ¿Cuál es el volumen máximo?',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.01::numeric,
      '$V_{\max}=0.5(1)+0.5=1.0$ L.',
      90
    ),
    (
      'Para la respiración del ejercicio anterior, $V(t)=0.5\sin\left(\frac{\pi t}{2}\right)+0.5$, ¿cuál es el periodo en segundos?',
      'numeric',
      null::jsonb,
      null::integer,
      4::numeric,
      0.01::numeric,
      '$T=\frac{2\pi}{\pi/2}=4$ s.',
      91
    ),
    (
      'Una ola se modela con $y(x)=1.8\sin\left(\frac{\pi(x-2)}{4}\right)$ metros. ¿Cuál es la amplitud?',
      'numeric',
      null::jsonb,
      null::integer,
      1.8::numeric,
      0.01::numeric,
      'La amplitud es el coeficiente de la función: $1.8$ m.',
      92
    ),
    (
      'Para la ola del ejercicio anterior, $y(x)=1.8\sin\left(\frac{\pi(x-2)}{4}\right)$, ¿cuál es el periodo o longitud de onda en metros?',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.01::numeric,
      '$T=\frac{2\pi}{\pi/4}=8$ m.',
      93
    ),
    (
      'Una boya tiene una altura modelada por $h(t)=0.9\cos\left(\frac{\pi t}{3}\right)+1.4$ metros. ¿Cuál es la altura máxima?',
      'numeric',
      null::jsonb,
      null::integer,
      2.3::numeric,
      0.1::numeric,
      '$h_{\max}=0.9(1)+1.4=2.3$ m.',
      94
    ),
    (
      'Para la boya del ejercicio anterior, $h(t)=0.9\cos\left(\frac{\pi t}{3}\right)+1.4$, ¿cuál es la altura mínima?',
      'numeric',
      null::jsonb,
      null::integer,
      0.5::numeric,
      0.01::numeric,
      '$h_{\min}=0.9(-1)+1.4=0.5$ m.',
      95
    ),
    (
      'Para la boya del ejercicio anterior, $h(t)=0.9\cos\left(\frac{\pi t}{3}\right)+1.4$, ¿qué altura hay en $t=2$ segundos?',
      'numeric',
      null::jsonb,
      null::integer,
      0.95::numeric,
      0.01::numeric,
      '$h(2)=0.9\cos\left(\frac{2\pi}{3}\right)+1.4=0.9\left(-\frac{1}{2}\right)+1.4=0.95$ m.',
      96
    ),
    (
      'El brillo de la Luna se modela con $B(t)=0.5\cos\left(\frac{2\pi t}{29.5}\right)+0.5$. ¿Cuál es el brillo máximo?',
      'numeric',
      null::jsonb,
      null::integer,
      1::numeric,
      0.01::numeric,
      '$B_{\max}=0.5(1)+0.5=1.0$.',
      97
    ),
    (
      'La corriente alterna de un circuito se modela con $I(t)=8\sin\left(100\pi t+\frac{\pi}{2}\right)$ amperios. ¿Cuál es la corriente en $t=0$?',
      'numeric',
      null::jsonb,
      null::integer,
      8::numeric,
      0.01::numeric,
      '$I(0)=8\sin\left(\frac{\pi}{2}\right)=8(1)=8$ A.',
      98
    ),
    (
      'En una marea, la altura máxima es $5.2$ m a las 4 horas, la mínima es $1.2$ m y el periodo es 12 horas. Si $h(t)=2\cos\left(\frac{\pi(t-4)}{6}\right)+3.2$, ¿qué altura hay a las 10 horas?',
      'numeric',
      null::jsonb,
      null::integer,
      1.2::numeric,
      0.1::numeric,
      '$h(10)=2\cos\left(\frac{\pi(6)}{6}\right)+3.2=2\cos\pi+3.2=2(-1)+3.2=1.2$ m.',
      99
    ),
    (
      'Una noria tiene su centro a 20 m de altura, radio 15 m, arranca en el punto más bajo en $t=0$ y tarda 40 s en dar una vuelta. Si $h(t)=-15\cos\left(\frac{\pi t}{20}\right)+20$, ¿qué altura hay a los 10 segundos?',
      'numeric',
      null::jsonb,
      null::integer,
      20::numeric,
      0.01::numeric,
      '$h(10)=-15\cos\left(\frac{\pi}{2}\right)+20=-15(0)+20=20$ m.',
      100
    )
) as v(
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
  select id from public.modules where slug = 'funciones-trigonometricas-100'
) as m
order by v.order_index;
