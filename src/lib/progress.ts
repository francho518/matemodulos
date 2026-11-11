import { scoreByExercise } from "./scoring";
import {
  selectExercisesForStudent,
  type SelectableExercise,
} from "./exercise-selection";

/** Intentos permitidos por ejercicio en cada ronda. */
export const MAX_ROUND_ATTEMPTS = 4;

export type RoundAttempt = {
  exercise_id: string;
  is_correct: boolean;
  created_at?: string | null;
  round?: number | null;
};

/** Fila de public.module_rounds (rondas 2 en adelante). */
export type StoredRound = {
  round: number;
  exercise_ids: string[];
};

export type RoundPlan<T extends SelectableExercise> = {
  round: number;
  exercises: T[];
};

export type RoundStats<T extends SelectableExercise> = RoundPlan<T> & {
  total: number;
  solved: number;
  locked: number;
  completed: boolean;
  points: number;
  grade: number;
  solvedIds: Set<string>;
  lockedIds: Set<string>;
  scores: Map<string, number>;
  attemptsUsed: Map<string, number>;
};

/**
 * Construye todas las rondas de un estudiante en un módulo:
 * la ronda 1 (asignación original) y las reasignaciones guardadas.
 */
export function buildRoundPlans<T extends SelectableExercise>({
  exercises,
  userId,
  moduleId,
  randomize,
  exercisesPerStudent,
  rounds = [],
}: {
  exercises: T[];
  userId: string;
  moduleId: string;
  randomize: boolean;
  exercisesPerStudent: number;
  rounds?: StoredRound[];
}): RoundPlan<T>[] {
  const base = selectExercisesForStudent(
    exercises,
    userId,
    moduleId,
    randomize,
    exercisesPerStudent,
  );

  const byId = new Map(exercises.map((exercise) => [exercise.id, exercise]));
  const plans: RoundPlan<T>[] = [{ round: 1, exercises: base }];

  const stored = [...rounds].sort((a, b) => a.round - b.round);

  for (const item of stored) {
    if (!Number.isFinite(item.round) || item.round < 2) continue;

    const list = (item.exercise_ids ?? [])
      .map((id) => byId.get(id))
      .filter((exercise): exercise is T => Boolean(exercise));

    // Si el banco cambió y ya no quedan ejercicios de esa ronda, se
    // ignora para no dejar al estudiante con una ronda vacía.
    if (list.length === 0) continue;

    plans.push({ round: item.round, exercises: list });
  }

  return plans.sort((a, b) => a.round - b.round);
}

/** La ronda que el estudiante está resolviendo ahora. */
export function currentRoundPlan<T extends SelectableExercise>(
  plans: RoundPlan<T>[],
): RoundPlan<T> {
  return plans[plans.length - 1];
}

/**
 * Puntaje, nota y estado de una ronda concreta. Solo cuenta los
 * intentos de esa ronda, así una reasignación empieza de cero.
 */
export function statsForPlan<T extends SelectableExercise>(
  plan: RoundPlan<T>,
  attempts: RoundAttempt[],
): RoundStats<T> {
  const exerciseIds = new Set(plan.exercises.map((exercise) => exercise.id));

  const relevant = attempts.filter(
    (attempt) =>
      Number(attempt.round ?? 1) === plan.round &&
      exerciseIds.has(attempt.exercise_id),
  );

  const scores = scoreByExercise(relevant);
  const solvedIds = new Set(
    relevant
      .filter((attempt) => attempt.is_correct)
      .map((attempt) => attempt.exercise_id),
  );

  const attemptsUsed = new Map<string, number>();

  for (const attempt of relevant) {
    attemptsUsed.set(
      attempt.exercise_id,
      (attemptsUsed.get(attempt.exercise_id) ?? 0) + 1,
    );
  }

  let locked = 0;
  let points = 0;
  const lockedIds = new Set<string>();

  for (const exercise of plan.exercises) {
    points += scores.get(exercise.id) ?? 0;

    if (
      solvedIds.has(exercise.id) ||
      (attemptsUsed.get(exercise.id) ?? 0) >= MAX_ROUND_ATTEMPTS
    ) {
      locked += 1;
      lockedIds.add(exercise.id);
    }
  }

  const total = plan.exercises.length;

  return {
    round: plan.round,
    exercises: plan.exercises,
    total,
    solved: solvedIds.size,
    locked,
    completed: total > 0 && locked === total,
    points,
    grade: total > 0 ? (points / total) * 10 : 0,
    solvedIds,
    lockedIds,
    scores,
    attemptsUsed,
  };
}

/** Ronda con la mejor nota (desempata a favor de la primera). */
export function bestRoundStats<T extends SelectableExercise>(
  stats: RoundStats<T>[],
): RoundStats<T> | null {
  let best: RoundStats<T> | null = null;

  for (const item of stats) {
    if (!best || item.grade > best.grade + 1e-9) {
      best = item;
    }
  }

  return best;
}

/**
 * Mejor nota entre las rondas ya terminadas. Si todavía no hay ninguna
 * terminada, devuelve la mejor de las que están en curso.
 */
export function bestGradedRound<T extends SelectableExercise>(
  stats: RoundStats<T>[],
): RoundStats<T> | null {
  const completed = stats.filter((item) => item.completed);
  return bestRoundStats(completed.length > 0 ? completed : stats);
}
