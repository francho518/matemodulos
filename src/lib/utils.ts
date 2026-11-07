/**
 * Convierte un texto en un slug seguro para URLs.
 * Ejemplo: "Álgebra Básica" -> "algebra-basica"
 */
export function slugify(value: string) {
  return value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80);
}

export function firstParam(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}

export function formatDate(value: string) {
  return new Intl.DateTimeFormat("es", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(value));
}

export function percentage(part: number, total: number) {
  if (total <= 0) return 0;
  return Math.round((part / total) * 100);
}
