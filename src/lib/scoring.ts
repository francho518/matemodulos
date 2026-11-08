/**
 * Puntaje de un ejercicio según el intento en que se acierta:
 *
 *   1.er intento  → 1,0
 *   2.º intento   → 0,8
 *   3.er intento  → 0,5
 *   4.º o más     → 0
 *
 * Un ejercicio nunca acertado también vale 0.
 */
export const ATTEMPT_SCORES = [1, 0.8, 0.5] as const;

export function scoreForAttempt(attemptNumber: number) {
  if (!Number.isInteger(attemptNumber) || attemptNumber < 1) return 0;
  return ATTEMPT_SCORES[attemptNumber - 1] ?? 0;
}

export type ScoredAttempt = {
  exercise_id: string;
  is_correct: boolean;
  created_at?: string | null;
};

function attemptTime(value: string | null | undefined) {
  if (!value) return 0;
  const time = new Date(value).getTime();
  return Number.isFinite(time) ? time : 0;
}

/**
 * Calcula el puntaje de cada ejercicio a partir de sus intentos.
 *
 * Solo cuenta el primer intento correcto: los intentos anteriores
 * (equivocados o por tiempo agotado) hacen que el acierto valga menos.
 */
export function scoreByExercise(attempts: ScoredAttempt[]) {
  const grouped = new Map<string, ScoredAttempt[]>();

  for (const attempt of attempts) {
    if (!grouped.has(attempt.exercise_id)) {
      grouped.set(attempt.exercise_id, []);
    }
    grouped.get(attempt.exercise_id)!.push(attempt);
  }

  const scores = new Map<string, number>();

  for (const [exerciseId, list] of grouped) {
    const ordered = [...list].sort(
      (a, b) => attemptTime(a.created_at) - attemptTime(b.created_at),
    );

    const firstCorrect = ordered.findIndex((attempt) => attempt.is_correct);

    scores.set(
      exerciseId,
      firstCorrect === -1 ? 0 : scoreForAttempt(firstCorrect + 1),
    );
  }

  return scores;
}

/** Muestra 0,8 en lugar de 0.8 (formato español). */
export function formatScore(value: number) {
  return value.toFixed(1).replace(".", ",");
}

/** Texto para el mensaje de acierto. */
export function pointsLabel(points: number) {
  if (points <= 0) return "0 puntos";
  return `${formatScore(points)} punto${points === 1 ? "" : "s"}`;
}
