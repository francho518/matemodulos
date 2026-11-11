export type SelectableExercise = {
  id: string;
  order_index: number;
};

/**
 * Convierte un texto en una semilla de 32 bits (FNV-1a).
 */
function hashString(value: string) {
  let hash = 2166136261;

  for (let i = 0; i < value.length; i++) {
    hash ^= value.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }

  return hash >>> 0;
}

/**
 * Generador pseudoaleatorio determinista (mulberry32).
 * La misma semilla produce siempre la misma secuencia.
 */
function mulberry32(seed: number) {
  let state = seed >>> 0;

  return () => {
    state = (state + 0x6d2b79f5) >>> 0;

    let value = state;
    value = Math.imul(value ^ (value >>> 15), value | 1);
    value ^= value + Math.imul(value ^ (value >>> 7), value | 61);

    return ((value ^ (value >>> 14)) >>> 0) / 4294967296;
  };
}

/**
 * Devuelve la selección de ejercicios que verá un estudiante.
 *
 * - Si `randomize` es false, respeta el orden y limita la cantidad.
 * - Si `randomize` es true, mezcla los ejercicios usando una semilla
 *   formada por el usuario y el módulo. Así cada estudiante recibe una
 *   combinación distinta, pero estable entre sesiones.
 * - `exercisesPerStudent = 0` significa "todos los ejercicios".
 */
export function selectExercisesForStudent<T extends SelectableExercise>(
  exercises: T[],
  userId: string,
  moduleId: string,
  randomize: boolean,
  exercisesPerStudent: number,
): T[] {
  const ordered = [...exercises].sort(
    (a, b) => a.order_index - b.order_index || a.id.localeCompare(b.id),
  );

  const limit =
    Number.isFinite(exercisesPerStudent) && exercisesPerStudent > 0
      ? Math.floor(exercisesPerStudent)
      : 0;

  if (!randomize) {
    return limit > 0 ? ordered.slice(0, limit) : ordered;
  }

  const random = mulberry32(hashString(`v1:${userId}:${moduleId}`));
  const shuffled = [...ordered];

  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }

  return limit > 0 ? shuffled.slice(0, limit) : shuffled;
}

/**
 * Selección de ejercicios para una reasignación (ronda 2 o superior).
 *
 * Intenta entregar ejercicios que el estudiante no vio en las rondas
 * anteriores. Si el banco no alcanza, completa con los ya vistos.
 * La selección es determinista para que la ronda no cambie al recargar.
 */
export function selectExercisesForRound<T extends SelectableExercise>(
  exercises: T[],
  userId: string,
  moduleId: string,
  randomize: boolean,
  exercisesPerStudent: number,
  round: number,
  previousExerciseIds: Iterable<string>,
): T[] {
  if (round <= 1) {
    return selectExercisesForStudent(
      exercises,
      userId,
      moduleId,
      randomize,
      exercisesPerStudent,
    );
  }

  const ordered = [...exercises].sort(
    (a, b) => a.order_index - b.order_index || a.id.localeCompare(b.id),
  );

  const limit =
    Number.isFinite(exercisesPerStudent) && exercisesPerStudent > 0
      ? Math.floor(exercisesPerStudent)
      : ordered.length;

  const previous = new Set(previousExerciseIds);
  const unseen = ordered.filter((exercise) => !previous.has(exercise.id));
  const seen = ordered.filter((exercise) => previous.has(exercise.id));

  const shuffle = (items: T[], salt: string) => {
    const random = mulberry32(hashString(`${salt}:${userId}:${moduleId}:${round}`));
    const copy = [...items];

    for (let i = copy.length - 1; i > 0; i--) {
      const j = Math.floor(random() * (i + 1));
      [copy[i], copy[j]] = [copy[j], copy[i]];
    }

    return copy;
  };

  const pool = [...shuffle(unseen, "nuevos"), ...shuffle(seen, "repaso")];

  return pool
    .slice(0, limit)
    .sort((a, b) => a.order_index - b.order_index || a.id.localeCompare(b.id));
}
