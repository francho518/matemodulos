"use strict";

/**
 * Genera cuatro módulos de 100 ejercicios de cálculo integral:
 *
 *   1. Integrales polinómicas y radicales · indefinidas
 *   2. Integrales polinómicas y radicales · definidas
 *   3. Integrales por cambio de variable
 *   4. Sólidos de revolución
 *
 * Cada ejercicio tiene respuesta numérica, se calcula con aritmética
 * exacta de fracciones y se verifica con integración numérica de Simpson
 * antes de escribir el SQL.
 *
 * Salidas:
 *   supabase/seed-integrales-indefinidas-100.sql
 *   supabase/seed-integrales-definidas-100.sql
 *   supabase/seed-cambio-variable-100.sql
 *   supabase/seed-solidos-revolucion-100.sql
 *
 * Uso:
 *   node scripts/generar-seeds-calculo.js
 */

const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");
const SUPABASE = path.join(ROOT, "supabase");

// ---------------------------------------------------------------------------
// Aritmética exacta de fracciones
// ---------------------------------------------------------------------------
function gcd(a, b) {
  a = Math.abs(a);
  b = Math.abs(b);

  while (b) {
    const next = a % b;
    a = b;
    b = next;
  }

  return a || 1;
}

function Q(n, d = 1) {
  if (!Number.isFinite(n) || !Number.isFinite(d)) {
    throw new Error(`Fracción no finita: ${n}/${d}`);
  }

  if (d === 0) throw new Error("División por cero");

  if (d < 0) {
    n = -n;
    d = -d;
  }

  const factor = gcd(n, d);

  return { n: n / factor, d: d / factor };
}

const addQ = (a, b) => Q(a.n * b.d + b.n * a.d, a.d * b.d);
const subQ = (a, b) => Q(a.n * b.d - b.n * a.d, a.d * b.d);
const mulQ = (a, b) => Q(a.n * b.n, a.d * b.d);
const divQ = (a, b) => Q(a.n * b.d, a.d * b.n);
const numQ = (q) => q.n / q.d;
const isInteger = (q) => q.d === 1;
const ZERO = Q(0);
const ONE = Q(1);

function powQ(base, exponent) {
  const { n, d } = exponent;

  if (d === 1) {
    if (n === 0) return ONE;
    return Q(Math.pow(base, n));
  }

  if (d === 2) {
    if (base < 0) throw new Error("Raíz de un número negativo");

    const root = Math.sqrt(base);

    if (!Number.isInteger(root)) {
      throw new Error(`La raíz de ${base} no es exacta`);
    }

    if (n >= 0) return Q(Math.pow(root, n));

    return Q(1, Math.pow(root, -n));
  }

  throw new Error(`Exponente no soportado: ${n}/${d}`);
}

// ---------------------------------------------------------------------------
// Representación de integrandos polinómicos y con raíces
// ---------------------------------------------------------------------------
// Un término es { c: fracción, p: fracción } y representa c·x^p.
function integrate(terms) {
  return terms.map((term) => ({
    c: divQ(term.c, addQ(term.p, ONE)),
    p: addQ(term.p, ONE),
  }));
}

function evalTerms(terms, x) {
  return terms.reduce(
    (total, term) => addQ(total, mulQ(term.c, powQ(x, term.p))),
    ZERO,
  );
}

function termBody(p) {
  if (p.d === 1) {
    if (p.n === 0) return "";
    if (p.n === 1) return "x";
    return `x^{${p.n}}`;
  }

  if (p.d === 2) {
    if (p.n === 1) return "\\sqrt{x}";
    if (p.n === 3) return "x\\sqrt{x}";
    if (p.n === 5) return "x^2\\sqrt{x}";
    if (p.n === 7) return "x^3\\sqrt{x}";
  }

  return `x^{${p.n}/${p.d}}`;
}

function absNum(q) {
  return Q(Math.abs(q.n), q.d);
}

function numLatex(q) {
  if (q.d === 1) return String(q.n);
  return `\\frac{${Math.abs(q.n)}}{${q.d}}`;
}

function termLatex(term) {
  const negative = term.c.n < 0;
  const coefficient = absNum(term.c);

  // 1/√x se escribe como fracción con el coeficiente en el numerador.
  if (term.p.d === 2 && term.p.n === -1) {
    const numerator = coefficient.d === 1 ? String(coefficient.n) : numLatex(coefficient);
    const body = `\\frac{${numerator}}{\\sqrt{x}}`;
    return { negative, body };
  }

  const body = termBody(term.p);

  if (!body) {
    return { negative, body: numLatex(coefficient) };
  }

  if (coefficient.n === 1 && coefficient.d === 1) {
    return { negative, body };
  }

  return { negative, body: `${numLatex(coefficient)}${body}` };
}

function polyLatex(terms) {
  return terms
    .map((term, index) => {
      const { negative, body } = termLatex(term);

      if (index === 0) return `${negative ? "-" : ""}${body}`;

      return `${negative ? " - " : " + "}${body}`;
    })
    .join("");
}

function integralLatex(terms) {
  const body = terms.length > 1 ? `(${polyLatex(terms)})` : polyLatex(terms);
  return `\\int ${body}\\,dx`;
}

function definiteLatex(terms, a, b) {
  const body = terms.length > 1 ? `(${polyLatex(terms)})` : polyLatex(terms);
  return `\\int_{${a}}^{${b}} ${body}\\,dx`;
}

function displayQ(q) {
  if (q.d === 1) return String(q.n);
  return `${q.n < 0 ? "-" : ""}${numLatex(absNum(q))}`;
}

function displayWithDecimal(q) {
  if (q.d === 1) return String(q.n);

  const decimal = numQ(q).toFixed(4).replace(/0+$/, "").replace(/\.$/, "");

  return `${displayQ(q)} \\approx ${decimal}`;
}

// Exponente listo para LaTeX: n = 1 no lleva "^{1}".
function expSuffix(n) {
  return n === 1 ? "" : `^{${n}}`;
}

// ---------------------------------------------------------------------------
// Integración numérica para verificar
// ---------------------------------------------------------------------------
function simpson(f, a, b, steps = 4000) {
  if (a === b) return 0;

  let n = steps;

  if (n % 2 !== 0) n += 1;

  const h = (b - a) / n;
  let sum = f(a) + f(b);

  for (let i = 1; i < n; i += 1) {
    sum += (i % 2 === 0 ? 2 : 4) * f(a + i * h);
  }

  return (sum * h) / 3;
}

function integrandFn(terms) {
  return (x) =>
    terms.reduce((total, term) => {
      return total + numQ(term.c) * Math.pow(x, numQ(term.p));
    }, 0);
}

// ---------------------------------------------------------------------------
// Construcción de ejercicios
// ---------------------------------------------------------------------------
function sqlNumber(q) {
  if (q.d === 1) return String(q.n);

  return numQ(q).toFixed(4).replace(/0+$/, "").replace(/\.$/, "");
}

function makeExercise({ prompt, answerQ, explanation, verify }) {
  const exact = numQ(answerQ);

  if (!Number.isFinite(exact)) {
    throw new Error(`Respuesta no finita en: ${prompt}`);
  }

  return {
    prompt,
    answerQ,
    answer: sqlNumber(answerQ),
    exact,
    tolerance: isInteger(answerQ) ? "0.000001" : "0.001",
    explanation,
    verify,
  };
}

function makeIndef(terms, x0, options = {}) {
  const start = options.start ?? 0;
  const F = integrate(terms);
  const atStart = evalTerms(F, start);
  const value = subQ(evalTerms(F, x0), atStart);

  // Antiderivada que cumple la condición inicial F(start) = 0.
  const adjusted = start === 0 ? F : addConstant(F, Q(-atStart.n, atStart.d));

  const condition = start === 0 ? "F(0)=0" : `F(${start})=0`;

  const explanation =
    options.explanation ??
    (start === 0
      ? `Se integra término a término: $F(x)=${polyLatex(adjusted)}$. ` +
        `Como $${condition}$, $F(${x0})=${displayWithDecimal(value)}$.`
      : `Se integra término a término y se ajusta la constante: ` +
        `$F(x)=${polyLatex(adjusted)}$. ` +
        `Como $${condition}$, $F(${x0})=${displayWithDecimal(value)}$.`);

  return makeExercise({
    prompt: options.prompt,
    answerQ: value,
    explanation,
    verify:
      options.verifyOverride ??
      (() => simpson(integrandFn(terms), start, x0)),
  });
}

// Suma una constante a un antiderivada expresada como lista de términos.
function addConstant(terms, value) {
  const result = [];
  let current = ZERO;

  for (const term of terms) {
    if (term.p.n === 0 && term.p.d === 1) {
      current = term.c;
    } else {
      result.push(term);
    }
  }

  const total = addQ(current, value);

  if (total.n !== 0) {
    result.push({ c: total, p: ZERO });
  }

  return result;
}

function makeDefinite(terms, a, b, options = {}) {
  const F = integrate(terms);
  const atB = evalTerms(F, b);
  const atA = evalTerms(F, a);
  const value = subQ(atB, atA);

  const explanation =
    options.explanation ??
    `Una antiderivada es $F(x)=${polyLatex(F)}$. Por el teorema fundamental ` +
      `del cálculo, el resultado es $F(${b})-F(${a})=${displayQ(atB)}-${displayQ(
        atA,
      )}=${displayWithDecimal(value)}$.`;

  return makeExercise({
    prompt: options.prompt,
    answerQ: value,
    explanation,
    verify: () => simpson(integrandFn(terms), a, b),
  });
}

function makeSolid({ k, g, a, b, prompt, explanation }) {
  return makeExercise({
    prompt,
    answerQ: k,
    explanation,
    verify: () => simpson(g, a, b),
  });
}

const FACTOR_SAMPLES = 4000;

// ---------------------------------------------------------------------------
// Módulo 1 · Integrales indefinidas
// ---------------------------------------------------------------------------
function m1Monomio() {
  const out = [];

  for (const a of [2, 3, 4, 5, 6, 8, 9, 10, 12]) {
    for (const n of [1, 2, 3, 4]) {
      for (const x0 of [2, 3]) {
        const terms = [{ c: Q(a), p: Q(n) }];

        out.push(
          makeIndef(terms, x0, {
            prompt:
              `Si $F(x)=${integralLatex(terms)}$ y $F(0)=0$, ` +
              `¿cuánto vale $F(${x0})$?`,
          }),
        );
      }
    }
  }

  return out;
}

function m1Binomio() {
  const out = [];

  for (const a of [2, 3, 4, 5, 6, 7]) {
    for (const b of [1, 2, 3, 4, 5, 6, 7, 8, 9]) {
      for (const [n, m] of [
        [2, 1],
        [3, 1],
        [3, 2],
        [4, 1],
        [4, 2],
      ]) {
        for (const x0 of [2, 3]) {
          const terms = [
            { c: Q(a), p: Q(n) },
            { c: Q(b), p: Q(m) },
          ];

          out.push(
            makeIndef(terms, x0, {
              prompt:
                `Si $F(x)=${integralLatex(terms)}$ y $F(0)=0$, ` +
                `¿cuánto vale $F(${x0})$?`,
            }),
          );
        }
      }
    }
  }

  return out;
}

function m1Trinomio() {
  const out = [];

  for (const a of [1, 2, 3, 4]) {
    for (const b of [-4, -3, -2, -1, 1, 2, 3, 4]) {
      for (const c of [1, 2, 3, 4, 5, 6]) {
        for (const x0 of [1, 2]) {
          const terms = [
            { c: Q(a), p: Q(2) },
            { c: Q(b), p: Q(1) },
            { c: Q(c), p: Q(0) },
          ];

          out.push(
            makeIndef(terms, x0, {
              prompt:
                `Si $F(x)=${integralLatex(terms)}$ y $F(0)=0$, ` +
                `¿cuánto vale $F(${x0})$?`,
            }),
          );
        }
      }
    }
  }

  return out;
}

function m1PotenciaConstante() {
  const out = [];

  for (const a of [2, 3, 4, 5, 6]) {
    for (const n of [1, 2, 3]) {
      for (const k of [1, 2, 3, 4, 5, 6, 7, 8, 9]) {
        for (const x0 of [2, 3]) {
          const terms = [
            { c: Q(a), p: Q(n) },
            { c: Q(k), p: Q(0) },
          ];

          out.push(
            makeIndef(terms, x0, {
              prompt:
                `Si $F(x)=${integralLatex(terms)}$ y $F(0)=0$, ` +
                `¿cuánto vale $F(${x0})$?`,
            }),
          );
        }
      }
    }
  }

  return out;
}

function m1Raiz() {
  const out = [];

  for (const a of [1, 2, 3, 4, 5, 6, 7, 8]) {
    for (const x0 of [4, 9, 16, 25]) {
      const terms = [{ c: Q(a), p: Q(1, 2) }];

      out.push(
        makeIndef(terms, x0, {
          prompt:
            `Si $F(x)=${integralLatex(terms)}$ y $F(0)=0$, ` +
            `¿cuánto vale $F(${x0})$?`,
          verifyOverride: () => (2 * a * Math.pow(x0, 1.5)) / 3,
        }),
      );
    }
  }

  return out;
}

function m1RaizCubo() {
  const out = [];

  for (const a of [1, 2, 3, 4, 5, 6, 7, 8]) {
    for (const x0 of [4, 9, 16, 25]) {
      const terms = [{ c: Q(a), p: Q(3, 2) }];

      out.push(
        makeIndef(terms, x0, {
          prompt:
            `Si $F(x)=${integralLatex(terms)}$ y $F(0)=0$, ` +
            `¿cuánto vale $F(${x0})$?`,
        }),
      );
    }
  }

  return out;
}

function m1InversaRaiz() {
  const out = [];

  for (const a of [1, 2, 3, 4, 5, 6, 7, 8]) {
    for (const x0 of [4, 9, 16, 25]) {
      const terms = [{ c: Q(a), p: Q(-1, 2) }];

      out.push(
        makeIndef(terms, x0, {
          prompt:
            `Si $F(x)=${integralLatex(terms)}$ y $F(0)=0$, ` +
            `¿cuánto vale $F(${x0})$?`,
          verifyOverride: () => 2 * a * Math.sqrt(x0),
        }),
      );
    }
  }

  return out;
}

function m1Mixta() {
  const out = [];

  for (const a of [1, 2, 3, 4, 5]) {
    for (const b of [1, 2, 3, 4, 5, 6]) {
      for (const x0 of [4, 9]) {
        const terms = [
          { c: Q(a), p: Q(1) },
          { c: Q(b), p: Q(1, 2) },
        ];

        out.push(
          makeIndef(terms, x0, {
            prompt:
              `Si $F(x)=${integralLatex(terms)}$ y $F(0)=0$, ` +
              `¿cuánto vale $F(${x0})$?`,
          }),
        );
      }
    }
  }

  return out;
}

function m1ConCondicion() {
  const out = [];

  for (const a of [2, 3, 4, 5, 6, 8, 9, 12]) {
    for (const n of [1, 2, 3, 4]) {
      for (const x0 of [2, 3, 4]) {
        if (x0 === 1) continue;

        const terms = [{ c: Q(a), p: Q(n) }];

        out.push(
          makeIndef(terms, x0, {
            start: 1,
            prompt:
              `Si $F(x)=${integralLatex(terms)}$ y $F(1)=0$, ` +
              `¿cuánto vale $F(${x0})$?`,
          }),
        );
      }
    }
  }

  return out;
}

// ---------------------------------------------------------------------------
// Módulo 2 · Integrales definidas
// ---------------------------------------------------------------------------
function m2Potencia() {
  const out = [];

  for (const a of [2, 3, 4, 5, 6, 8]) {
    for (const n of [1, 2, 3]) {
      for (const b of [1, 2, 3, 4]) {
        const terms = [{ c: Q(a), p: Q(n) }];

        out.push(
          makeDefinite(terms, 0, b, {
            prompt: `Calcula $${definiteLatex(terms, 0, b)}$.`,
          }),
        );
      }
    }
  }

  return out;
}

function m2Binomio() {
  const out = [];

  for (const a of [1, 2, 3, 4, 5]) {
    for (const n of [1, 2, 3]) {
      for (const c of [1, 2, 3, 4, 5]) {
        for (const [a0, b0] of [
          [0, 1],
          [0, 2],
          [0, 3],
          [1, 2],
          [1, 3],
        ]) {
          const terms = [
            { c: Q(a), p: Q(n) },
            { c: Q(c), p: Q(0) },
          ];

          out.push(
            makeDefinite(terms, a0, b0, {
              prompt: `Calcula $${definiteLatex(terms, a0, b0)}$.`,
            }),
          );
        }
      }
    }
  }

  return out;
}

function m2Trinomio() {
  const out = [];

  for (const a of [1, 2, 3, 4]) {
    for (const b of [-3, -2, -1, 1, 2, 3]) {
      for (const c of [1, 2, 3, 4]) {
        for (const b0 of [1, 2, 3]) {
          const terms = [
            { c: Q(a), p: Q(2) },
            { c: Q(b), p: Q(1) },
            { c: Q(c), p: Q(0) },
          ];

          out.push(
            makeDefinite(terms, 0, b0, {
              prompt: `Calcula $${definiteLatex(terms, 0, b0)}$.`,
            }),
          );
        }
      }
    }
  }

  return out;
}

const SQUARES = [
  [0, 1],
  [0, 4],
  [0, 9],
  [1, 4],
  [1, 9],
  [4, 9],
];

function m2Raiz() {
  const out = [];

  for (const a of [1, 2, 3, 4, 5, 6]) {
    for (const [a0, b0] of SQUARES) {
      const terms = [{ c: Q(a), p: Q(1, 2) }];

      out.push(
        makeDefinite(terms, a0, b0, {
          prompt: `Calcula $${definiteLatex(terms, a0, b0)}$.`,
        }),
      );
    }
  }

  return out;
}

function m2RaizCubo() {
  const out = [];

  for (const a of [1, 2, 3, 4, 5]) {
    for (const [a0, b0] of [
      [0, 4],
      [0, 9],
      [1, 4],
      [4, 9],
    ]) {
      const terms = [{ c: Q(a), p: Q(3, 2) }];

      out.push(
        makeDefinite(terms, a0, b0, {
          prompt: `Calcula $${definiteLatex(terms, a0, b0)}$.`,
        }),
      );
    }
  }

  return out;
}

function m2InversaRaiz() {
  const out = [];

  for (const a of [1, 2, 3, 4, 5, 6]) {
    for (const [a0, b0] of [
      [1, 4],
      [1, 9],
      [4, 9],
      [1, 16],
      [4, 16],
      [9, 16],
    ]) {
      const terms = [{ c: Q(a), p: Q(-1, 2) }];

      out.push(
        makeDefinite(terms, a0, b0, {
          prompt: `Calcula $${definiteLatex(terms, a0, b0)}$.`,
        }),
      );
    }
  }

  return out;
}

function m2Mixta() {
  const out = [];

  for (const a of [1, 2, 3, 4]) {
    for (const b of [1, 2, 3, 4]) {
      for (const [a0, b0] of [
        [0, 4],
        [0, 9],
        [1, 4],
      ]) {
        const terms = [
          { c: Q(a), p: Q(1) },
          { c: Q(b), p: Q(1, 2) },
        ];

        out.push(
          makeDefinite(terms, a0, b0, {
            prompt: `Calcula $${definiteLatex(terms, a0, b0)}$.`,
          }),
        );
      }
    }
  }

  return out;
}

function m2Cuadrado() {
  const out = [];

  for (const c of [1, 2, 3, 4, 5, 6]) {
    for (const b0 of [1, 2, 3, 4]) {
      const terms = [
        { c: Q(1), p: Q(2) },
        { c: Q(2 * c), p: Q(1) },
        { c: Q(c * c), p: Q(0) },
      ];

      out.push(
        makeDefinite(terms, 0, b0, {
          prompt:
            `Calcula $\\int_{0}^{${b0}} (x+${c})^2\\,dx$ desarrollando primero el binomio.`,
        }),
      );
    }
  }

  return out;
}

function m2Cuadratica() {
  const out = [];

  for (const a of [1, 2, 3, 4]) {
    for (const b of [-2, -1, 1, 2]) {
      for (const c of [1, 2, 3, 4]) {
        for (const b0 of [1, 2, 3]) {
          const terms = [
            { c: Q(a), p: Q(2) },
            { c: Q(b), p: Q(1) },
            { c: Q(c), p: Q(0) },
          ];

          out.push(
            makeDefinite(terms, 0, b0, {
              prompt: `Calcula $${definiteLatex(terms, 0, b0)}$.`,
            }),
          );
        }
      }
    }
  }

  return out;
}

// ---------------------------------------------------------------------------
// Módulo 3 · Cambio de variable
// ---------------------------------------------------------------------------
function makeSubstitution({ f, kQ, a, b, prompt, explanation }) {
  return makeExercise({
    prompt,
    answerQ: kQ,
    explanation,
    verify: () => simpson(f, a, b),
  });
}

function m3PotenciaDosX() {
  const out = [];

  for (const k of [1, 2, 3, 4, 5, 6]) {
    for (const n of [1, 2, 3, 4]) {
      const f = (x) => 2 * x * Math.pow(x * x + k, n);
      const value = Q(Math.pow(k + 1, n + 1) - Math.pow(k, n + 1), n + 1);

      out.push(
        makeSubstitution({
          f,
          kQ: value,
          a: 0,
          b: 1,
          prompt:
            `Calcula $\\int_{0}^{1} 2x(x^2+${k})${expSuffix(n)}\\,dx$ usando el cambio de variable $u=x^2+${k}$.`,
          explanation:
            `Con $u=x^2+${k}$, $du=2x\\,dx$. Entonces ` +
            `$\\int_{0}^{1} 2x(x^2+${k})${expSuffix(n)}\\,dx=\\left[\\frac{(x^2+${k})^{${n + 1}}}{${n + 1}}\\right]_{0}^{1}=${displayWithDecimal(value)}$.`,
        }),
      );
    }
  }

  return out;
}

function m3PotenciaX() {
  const out = [];

  for (const k of [1, 2, 3, 4, 5, 6, 7, 8]) {
    for (const n of [1, 2, 3, 4]) {
      const f = (x) => x * Math.pow(x * x + k, n);
      const value = Q(
        Math.pow(k + 1, n + 1) - Math.pow(k, n + 1),
        2 * (n + 1),
      );

      out.push(
        makeSubstitution({
          f,
          kQ: value,
          a: 0,
          b: 1,
          prompt:
            `Calcula $\\int_{0}^{1} x(x^2+${k})${expSuffix(n)}\\,dx$ con el cambio $u=x^2+${k}$.`,
          explanation:
            `Con $u=x^2+${k}$, $du=2x\\,dx$, así que $x\\,dx=\\frac{du}{2}$. ` +
            `El resultado es $\\left[\\frac{(x^2+${k})^{${n + 1}}}{2\\cdot ${n + 1}}\\right]_{0}^{1}=${displayWithDecimal(value)}$.`,
        }),
      );
    }
  }

  return out;
}

function m3PotenciaX2() {
  const out = [];

  for (const k of [1, 2, 3, 4, 5, 6]) {
    for (const n of [1, 2, 3]) {
      const f = (x) => x * x * Math.pow(x * x * x + k, n);
      const value = Q(
        Math.pow(k + 1, n + 1) - Math.pow(k, n + 1),
        3 * (n + 1),
      );

      out.push(
        makeSubstitution({
          f,
          kQ: value,
          a: 0,
          b: 1,
          prompt:
            `Calcula $\\int_{0}^{1} x^2(x^3+${k})${expSuffix(n)}\\,dx$ con $u=x^3+${k}$.`,
          explanation:
            `Con $u=x^3+${k}$, $du=3x^2\\,dx$. Entonces ` +
            `$\\int_{0}^{1} x^2(x^3+${k})${expSuffix(n)}\\,dx=\\left[\\frac{(x^3+${k})^{${n + 1}}}{3\\cdot ${n + 1}}\\right]_{0}^{1}=${displayWithDecimal(value)}$.`,
        }),
      );
    }
  }

  return out;
}

function m3Binomio() {
  const out = [];

  for (const k of [1, 2, 3, 4, 5, 6]) {
    for (const n of [1, 2, 3]) {
      const f = (x) => (2 * x + 1) * Math.pow(x * x + x + k, n);
      const value = Q(
        Math.pow(k + 2, n + 1) - Math.pow(k, n + 1),
        n + 1,
      );

      out.push(
        makeSubstitution({
          f,
          kQ: value,
          a: 0,
          b: 1,
          prompt:
            `Calcula $\\int_{0}^{1} (2x+1)(x^2+x+${k})${expSuffix(n)}\\,dx$ con $u=x^2+x+${k}$.`,
          explanation:
            `Con $u=x^2+x+${k}$, $du=(2x+1)\\,dx$. El resultado es ` +
            `$\\left[\\frac{(x^2+x+${k})^{${n + 1}}}{${n + 1}}\\right]_{0}^{1}=${displayWithDecimal(value)}$.`,
        }),
      );
    }
  }

  return out;
}

function m3RacionalCuadrado() {
  const out = [];

  for (const k of [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]) {
    const f = (x) => x / Math.pow(x * x + k, 2);
    const value = mulQ(Q(1, 2), subQ(Q(1, k), Q(1, k + 1)));

    out.push(
      makeSubstitution({
        f,
        kQ: value,
        a: 0,
        b: 1,
        prompt:
          `Calcula $\\int_{0}^{1} \\frac{x}{(x^2+${k})^2}\\,dx$ con $u=x^2+${k}$.`,
        explanation:
          `Con $u=x^2+${k}$, $du=2x\\,dx$. Entonces ` +
          `$\\int_{0}^{1} \\frac{x}{(x^2+${k})^2}\\,dx=\\left[-\\frac{1}{2(x^2+${k})}\\right]_{0}^{1}=${displayWithDecimal(value)}$.`,
      }),
    );
  }

  return out;
}

function m3RacionalLineal() {
  const out = [];

  for (const k of [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]) {
    const f = (x) => 1 / Math.pow(x + k, 2);
    const value = subQ(Q(1, k), Q(1, k + 1));

    out.push(
      makeSubstitution({
        f,
        kQ: value,
        a: 0,
        b: 1,
        prompt:
          `Calcula $\\int_{0}^{1} \\frac{1}{(x+${k})^2}\\,dx$ con $u=x+${k}$.`,
        explanation:
          `Con $u=x+${k}$, $du=dx$. Entonces ` +
          `$\\int_{0}^{1} \\frac{1}{(x+${k})^2}\\,dx=\\left[-\\frac{1}{x+${k}}\\right]_{0}^{1}=${displayWithDecimal(value)}$.`,
      }),
    );
  }

  return out;
}

function m3Indefinida() {
  const out = [];

  for (const k of [1, 2, 3, 4, 5, 6]) {
    for (const n of [1, 2, 3]) {
      for (const x0 of [1, 2]) {
        const f = (x) => 3 * x * x * Math.pow(x * x * x + k, n);
        const value = Q(
          Math.pow(Math.pow(x0, 3) + k, n + 1) - Math.pow(k, n + 1),
          n + 1,
        );

        out.push(
          makeSubstitution({
            f,
            kQ: value,
            a: 0,
            b: x0,
            prompt:
              `Si $F(x)=\\int 3x^2(x^3+${k})${expSuffix(n)}\\,dx$ y $F(0)=0$, ` +
              `¿cuánto vale $F(${x0})$?`,
            explanation:
              `Con $u=x^3+${k}$, $du=3x^2\\,dx$. Entonces ` +
              `$F(x)=\\frac{(x^3+${k})^{${n + 1}}}{${n + 1}}+C$. ` +
              `Como $F(0)=0$, $C=-\\frac{${k}^{${n + 1}}}{${n + 1}}$, así que ` +
              `$F(${x0})=${displayWithDecimal(value)}$.`,
          }),
        );
      }
    }
  }

  return out;
}

function m3RacionalCubo() {
  const out = [];

  for (const k of [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]) {
    const f = (x) => (x * x) / Math.pow(x * x * x + k, 2);
    const value = mulQ(Q(1, 3), subQ(Q(1, k), Q(1, k + 1)));

    out.push(
      makeSubstitution({
        f,
        kQ: value,
        a: 0,
        b: 1,
        prompt:
          `Calcula $\\int_{0}^{1} \\frac{x^2}{(x^3+${k})^2}\\,dx$ con $u=x^3+${k}$.`,
        explanation:
          `Con $u=x^3+${k}$, $du=3x^2\\,dx$. Entonces ` +
          `$\\int_{0}^{1} \\frac{x^2}{(x^3+${k})^2}\\,dx=\\left[-\\frac{1}{3(x^3+${k})}\\right]_{0}^{1}=${displayWithDecimal(value)}$.`,
      }),
    );
  }

  return out;
}

function m3Raiz() {
  const cases = [
    { k: 9, a: 0, b: 4, value: 2 },
    { k: 16, a: 0, b: 3, value: 1 },
    { k: 24, a: 1, b: 5, value: 2 },
    { k: 40, a: 3, b: 9, value: 4 },
    { k: 45, a: 2, b: 6, value: 2 },
    { k: 80, a: 1, b: 8, value: 3 },
  ];

  return cases.map(({ k, a, b, value }) => {
    const f = (x) => x / Math.sqrt(x * x + k);

    return makeSubstitution({
      f,
      kQ: Q(value),
      a,
      b,
      prompt:
        `Calcula $\\int_{${a}}^{${b}} \\frac{x}{\\sqrt{x^2+${k}}}\\,dx$ con $u=x^2+${k}$.`,
      explanation:
        `Con $u=x^2+${k}$, $du=2x\\,dx$. Entonces ` +
        `$\\int_{${a}}^{${b}} \\frac{x}{\\sqrt{x^2+${k}}}\\,dx=\\left[\\sqrt{x^2+${k}}\\right]_{${a}}^{${b}}=${value}$.`,
    });
  });
}

// ---------------------------------------------------------------------------
// Módulo 4 · Sólidos de revolución
// ---------------------------------------------------------------------------
function m4Cilindro() {
  const out = [];

  for (const c of [2, 3, 4, 5]) {
    for (const a of [0, 1, 2]) {
      for (const b of [a + 1, a + 2, a + 3, a + 4]) {
        const k = Q(c * c * (b - a));
        const g = () => c * c;

        out.push(
          makeSolid({
            k,
            g,
            a,
            b,
            prompt:
              `La región limitada por $y=${c}$, el eje $x$ y las rectas ` +
              `$x=${a}$ y $x=${b}$ gira alrededor del eje $x$. Si el volumen es $k\\pi$, ` +
              `¿cuánto vale $k$?`,
            explanation:
              `Por el método de discos, $V=\\pi\\int_{${a}}^{${b}} ${c}^2\\,dx=` +
              `${c * c}(${b}-${a})\\pi=${k.n}\\pi$. Por lo tanto, $k=${k.n}$.`,
          }),
        );
      }
    }
  }

  return out;
}

function m4Cono() {
  const out = [];

  for (const c of [1, 2, 3]) {
    for (const b of [1, 2, 3, 4, 5, 6]) {
      const k = Q(c * c * Math.pow(b, 3), 3);
      const g = (x) => c * c * x * x;

      out.push(
        makeSolid({
          k,
          g,
          a: 0,
          b,
          prompt:
            `La región limitada por $y=${c === 1 ? "" : c}x$, el eje $x$ y la recta ` +
            `$x=${b}$ gira alrededor del eje $x$. Si el volumen es $k\\pi$, ` +
            `¿cuánto vale $k$?`,
          explanation:
            `Por discos, $V=\\pi\\int_{0}^{${b}} (${c === 1 ? "" : c}x)^2\\,dx=` +
            `\\pi\\int_{0}^{${b}} ${c * c}x^2\\,dx=\\frac{${c * c}\\cdot ${b}^3}{3}\\pi=` +
            `${displayQ(k)}\\pi$. Por lo tanto, $k=${displayWithDecimal(k)}$.`,
        }),
      );
    }
  }

  return out;
}

function m4Parabola() {
  const out = [];

  for (const c of [1, 2]) {
    for (const b of [1, 2, 3, 4, 5, 6]) {
      const k = Q(c * c * Math.pow(b, 5), 5);
      const g = (x) => c * c * Math.pow(x, 4);

      out.push(
        makeSolid({
          k,
          g,
          a: 0,
          b,
          prompt:
            `La región bajo $y=${c === 1 ? "" : c}x^2$ entre $x=0$ y $x=${b}$ ` +
            `gira alrededor del eje $x$. Si el volumen es $k\\pi$, ¿cuánto vale $k$?`,
          explanation:
            `Por discos, $V=\\pi\\int_{0}^{${b}} (${c === 1 ? "" : c}x^2)^2\\,dx=` +
            `\\frac{${c * c}\\cdot ${b}^5}{5}\\pi=${displayQ(k)}\\pi$. ` +
            `Por lo tanto, $k=${displayWithDecimal(k)}$.`,
        }),
      );
    }
  }

  return out;
}

function m4Raiz() {
  const out = [];

  for (const c of [1, 2, 3]) {
    for (const b of [1, 2, 3, 4, 5, 6]) {
      const k = Q(c * c * b * b, 2);
      const g = (x) => c * c * x;

      out.push(
        makeSolid({
          k,
          g,
          a: 0,
          b,
          prompt:
            `La región bajo $y=${c === 1 ? "" : c}\\sqrt{x}$ entre $x=0$ y $x=${b}$ ` +
            `gira alrededor del eje $x$. Si el volumen es $k\\pi$, ¿cuánto vale $k$?`,
          explanation:
            `Por discos, $V=\\pi\\int_{0}^{${b}} (${c === 1 ? "" : c}\\sqrt{x})^2\\,dx=` +
            `\\pi\\int_{0}^{${b}} ${c * c}x\\,dx=\\frac{${c * c}\\cdot ${b}^2}{2}\\pi=` +
            `${displayQ(k)}\\pi$. Por lo tanto, $k=${displayWithDecimal(k)}$.`,
        }),
      );
    }
  }

  return out;
}

function m4Linea() {
  const out = [];

  for (const c of [1, 2, 3, 4, 5]) {
    for (const b of [1, 2, 3, 4, 5]) {
      const k = Q(Math.pow(b + c, 3) - Math.pow(c, 3), 3);
      const g = (x) => Math.pow(x + c, 2);

      out.push(
        makeSolid({
          k,
          g,
          a: 0,
          b,
          prompt:
            `La región limitada por $y=x+${c}$, el eje $x$ y la recta $x=${b}$ ` +
            `gira alrededor del eje $x$. Si el volumen es $k\\pi$, ¿cuánto vale $k$?`,
          explanation:
            `Por discos, $V=\\pi\\int_{0}^{${b}} (x+${c})^2\\,dx=` +
            `\\pi\\left[\\frac{(x+${c})^3}{3}\\right]_{0}^{${b}}=` +
            `${displayQ(k)}\\pi$. Por lo tanto, $k=${displayWithDecimal(k)}$.`,
        }),
      );
    }
  }

  return out;
}

function m4Arandela() {
  const out = [];

  for (const c of [1, 2]) {
    for (const n of [2, 3, 4, 5, 6]) {
      const k = mulQ(Q(c * c), subQ(Q(1, 3), Q(1, 2 * n + 1)));
      const g = (x) => c * c * (x * x - Math.pow(x, 2 * n));

      out.push(
        makeSolid({
          k,
          g,
          a: 0,
          b: 1,
          prompt:
            `La región entre $y=${c === 1 ? "" : c}x$ y $y=${c === 1 ? "" : c}x^${n}$ ` +
            `en $[0,1]$ gira alrededor del eje $x$. Si el volumen es $k\\pi$, ` +
            `¿cuánto vale $k$?`,
          explanation:
            `La curva exterior es $y=${c === 1 ? "" : c}x$ y la interior ` +
            `$y=${c === 1 ? "" : c}x^${n}$. Por arandelas, ` +
            `$V=\\pi\\int_{0}^{1}\\left[(${c === 1 ? "" : c}x)^2-(${c === 1 ? "" : c}x^${n})^2\\right]dx=` +
            `${displayQ(k)}\\pi$. Por lo tanto, $k=${displayWithDecimal(k)}$.`,
        }),
      );
    }
  }

  return out;
}

function m4ArandelaRaiz() {
  const out = [];

  for (const c of [1, 2]) {
    for (const n of [3, 4, 5, 6]) {
      const k = mulQ(
        Q(c * c),
        subQ(Q(n, n + 2), Q(1, 3)),
      );
      const g = (x) => c * c * (Math.pow(x, 2 / n) - x * x);

      out.push(
        makeSolid({
          k,
          g,
          a: 0,
          b: 1,
          prompt:
            `La región entre $y=${c === 1 ? "" : c}x^{1/${n}}$ y ` +
            `$y=${c === 1 ? "" : c}x$ en $[0,1]$ gira alrededor del eje $x$. ` +
            `Si el volumen es $k\\pi$, ¿cuánto vale $k$?`,
          explanation:
            `La curva exterior es $y=${c === 1 ? "" : c}x^{1/${n}}$. Por arandelas, ` +
            `$V=\\pi\\int_{0}^{1}\\left[(${c === 1 ? "" : c}x^{1/${n}})^2-(${c === 1 ? "" : c}x)^2\\right]dx=` +
            `${displayQ(k)}\\pi$. Por lo tanto, $k=${displayWithDecimal(k)}$.`,
        }),
      );
    }
  }

  return out;
}

function m4CapasLinea() {
  const out = [];

  for (const c of [1, 2, 3]) {
    for (const b of [1, 2, 3, 4]) {
      const k = Q(2 * c * Math.pow(b, 3), 3);
      const g = (x) => 2 * x * (c * x);

      out.push(
        makeSolid({
          k,
          g,
          a: 0,
          b,
          prompt:
            `La región limitada por $y=${c === 1 ? "" : c}x$, el eje $x$ y la recta ` +
            `$x=${b}$ gira alrededor del eje $y$. Si el volumen es $k\\pi$, ` +
            `¿cuánto vale $k$?`,
          explanation:
            `Por capas cilíndricas, $V=2\\pi\\int_{0}^{${b}} x\\cdot ${c === 1 ? "" : c}x\\,dx=` +
            `2\\pi\\int_{0}^{${b}} ${c}x^2\\,dx=${displayQ(k)}\\pi$. ` +
            `Por lo tanto, $k=${displayWithDecimal(k)}$.`,
        }),
      );
    }
  }

  return out;
}

function m4CapasParabola() {
  const out = [];

  for (const c of [1, 2, 3]) {
    for (const b of [1, 2, 3]) {
      const k = Q(c * Math.pow(b, 4), 2);
      const g = (x) => 2 * x * (c * x * x);

      out.push(
        makeSolid({
          k,
          g,
          a: 0,
          b,
          prompt:
            `La región bajo $y=${c === 1 ? "" : c}x^2$ entre $x=0$ y $x=${b}$ ` +
            `gira alrededor del eje $y$. Si el volumen es $k\\pi$, ¿cuánto vale $k$?`,
          explanation:
            `Por capas cilíndricas, $V=2\\pi\\int_{0}^{${b}} x\\cdot ${c === 1 ? "" : c}x^2\\,dx=` +
            `2\\pi\\int_{0}^{${b}} ${c}x^3\\,dx=${displayQ(k)}\\pi$. ` +
            `Por lo tanto, $k=${displayWithDecimal(k)}$.`,
        }),
      );
    }
  }

  return out;
}

function m4CapasConstante() {
  const out = [];

  for (const c of [1, 2, 3, 4, 5, 6]) {
    for (const b of [1, 2, 3, 4]) {
      const k = Q(c * b * b);
      const g = (x) => 2 * x * c;

      out.push(
        makeSolid({
          k,
          g,
          a: 0,
          b,
          prompt:
            `La región limitada por $y=${c}$, el eje $x$ y la recta $x=${b}$ ` +
            `gira alrededor del eje $y$. Si el volumen es $k\\pi$, ¿cuánto vale $k$?`,
          explanation:
            `Por capas cilíndricas, $V=2\\pi\\int_{0}^{${b}} x\\cdot ${c}\\,dx=` +
            `2\\pi\\cdot ${c}\\cdot\\frac{${b}^2}{2}=${displayQ(k)}\\pi$. ` +
            `Por lo tanto, $k=${displayWithDecimal(k)}$.`,
        }),
      );
    }
  }

  return out;
}

// ---------------------------------------------------------------------------
// Definición de los módulos
// ---------------------------------------------------------------------------
const MODULES = [
  {
    slug: "integrales-indefinidas-100",
    title: "Integrales polinómicas y radicales · indefinidas · 100 ejercicios",
    description:
      "100 integrales indefinidas de polinomios y radicales con respuesta numérica: se pide la antiderivada evaluada en un punto o con una condición inicial.",
    order: 7,
    filename: "seed-integrales-indefinidas-100.sql",
    families: [
      ["monomios", 16, m1Monomio],
      ["binomios", 14, m1Binomio],
      ["trinomios", 12, m1Trinomio],
      ["potencia y constante", 10, m1PotenciaConstante],
      ["raíz cuadrada", 10, m1Raiz],
      ["x por raíz", 10, m1RaizCubo],
      ["inversa de raíz", 10, m1InversaRaiz],
      ["polinomio y raíz", 10, m1Mixta],
      ["condición F(1)=0", 8, m1ConCondicion],
    ],
  },
  {
    slug: "integrales-definidas-100",
    title: "Integrales polinómicas y radicales · definidas · 100 ejercicios",
    description:
      "100 integrales definidas de polinomios y radicales con respuesta numérica y límites escogidos para obtener resultados exactos.",
    order: 8,
    filename: "seed-integrales-definidas-100.sql",
    families: [
      ["potencias", 14, m2Potencia],
      ["binomios", 14, m2Binomio],
      ["trinomios", 12, m2Trinomio],
      ["raíz cuadrada", 12, m2Raiz],
      ["x por raíz", 10, m2RaizCubo],
      ["inversa de raíz", 10, m2InversaRaiz],
      ["polinomio y raíz", 10, m2Mixta],
      ["binomio al cuadrado", 10, m2Cuadrado],
      ["cuadráticas", 8, m2Cuadratica],
    ],
  },
  {
    slug: "cambio-variable-100",
    title: "Integrales por cambio de variable · 100 ejercicios",
    description:
      "100 integrales que se resuelven con una sustitución u = g(x): potencias, raíces y funciones racionales, con respuesta numérica.",
    order: 9,
    filename: "seed-cambio-variable-100.sql",
    families: [
      ["u = x² + k", 14, m3PotenciaDosX],
      ["x por u = x² + k", 14, m3PotenciaX],
      ["u = x³ + k", 12, m3PotenciaX2],
      ["u = x² + x + k", 12, m3Binomio],
      ["racional (x² + k)²", 12, m3RacionalCuadrado],
      ["racional (x + k)²", 10, m3RacionalLineal],
      ["indefinida evaluada", 8, m3Indefinida],
      ["racional (x³ + k)²", 12, m3RacionalCubo],
      ["u = x² + k con raíz", 6, m3Raiz],
    ],
  },
  {
    slug: "solidos-revolucion-100",
    title: "Sólidos de revolución · 100 ejercicios",
    description:
      "100 ejercicios de volúmenes de sólidos de revolución por discos, arandelas y capas cilíndricas. La respuesta es el coeficiente k del volumen kπ.",
    order: 10,
    filename: "seed-solidos-revolucion-100.sql",
    families: [
      ["cilindros", 12, m4Cilindro],
      ["conos", 12, m4Cono],
      ["parábolas", 12, m4Parabola],
      ["raíces", 12, m4Raiz],
      ["rectas", 10, m4Linea],
      ["arandelas", 10, m4Arandela],
      ["arandelas con raíz", 8, m4ArandelaRaiz],
      ["capas con recta", 10, m4CapasLinea],
      ["capas con parábola", 8, m4CapasParabola],
      ["capas con constante", 6, m4CapasConstante],
    ],
  },
];

// ---------------------------------------------------------------------------
// Selección y verificación
// ---------------------------------------------------------------------------
function hashString(value) {
  let hash = 2166136261 >>> 0;

  for (let i = 0; i < value.length; i += 1) {
    hash = Math.imul(hash ^ value.charCodeAt(i), 16777619);
  }

  return hash >>> 0;
}

function mulberry32(seed) {
  let state = seed;

  return function random() {
    state = (state + 0x6d2b79f5) | 0;
    let t = Math.imul(state ^ (state >>> 15), 1 | state);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;

    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Barajado determinista: misma semilla (el nombre de la familia) produce
// siempre la misma selección, pero reparte las variantes por todo el rango
// en lugar de quedarse con el primer desplazamiento.
function pick(list, count, name) {
  const seen = new Set();
  const unique = [];

  for (const exercise of list) {
    if (seen.has(exercise.prompt)) continue;
    seen.add(exercise.prompt);
    unique.push(exercise);
  }

  if (unique.length < count) {
    throw new Error(`${name}: ${unique.length} candidatos, se necesitan ${count}`);
  }

  const random = mulberry32(hashString(name));

  for (let i = unique.length - 1; i > 0; i -= 1) {
    const j = Math.floor(random() * (i + 1));
    [unique[i], unique[j]] = [unique[j], unique[i]];
  }

  return unique.slice(0, count);
}

function verify(exercise) {
  const expected = exercise.verify();
  const difference = Math.abs(expected - exercise.exact);

  if (!Number.isFinite(expected)) {
    return { ok: false, difference: Infinity };
  }

  return { ok: difference <= 0.002, difference };
}

function escapeSql(value) {
  return String(value).replace(/'/g, "''");
}

function buildModule(module) {
  const exercises = [];
  const prompts = new Set();

  for (const [name, count, builder] of module.families) {
    const selected = pick(builder(), count, `${module.slug} · ${name}`);

    for (const exercise of selected) {
      if (prompts.has(exercise.prompt)) {
        throw new Error(`Ejercicio repetido en ${module.slug}: ${exercise.prompt}`);
      }

      prompts.add(exercise.prompt);
      exercises.push(exercise);
    }
  }

  if (exercises.length !== 100) {
    throw new Error(`${module.slug}: ${exercises.length} ejercicios en lugar de 100`);
  }

  let worst = 0;

  for (const exercise of exercises) {
    const result = verify(exercise);

    if (!result.ok) {
      throw new Error(
        `Verificación fallida en ${module.slug}: ${exercise.prompt} ` +
          `(error ${result.difference})`,
      );
    }

    worst = Math.max(worst, result.difference);
  }

  return { exercises, worst };
}

function sqlFor(module, exercises) {
  const lines = [];

  lines.push("-- ============================================================");
  lines.push(`--  Matemódulos · ${module.title}`);
  lines.push("--");
  lines.push("--  Requisitos:");
  lines.push("--    1. Haber ejecutado schema.sql");
  lines.push("--    2. Haber ejecutado migration-student-variants.sql");
  lines.push("--");
  lines.push("--  100 ejercicios con respuesta numérica. El módulo entrega");
  lines.push("--  el banco completo a cada estudiante (randomize_exercises =");
  lines.push("--  false y exercises_per_student = 0).");
  lines.push("--");
  lines.push("--  IMPORTANTE: asígnalo a un grupo en Administración → Grupos");
  lines.push("--  para que los estudiantes puedan verlo.");
  lines.push("-- ============================================================");
  lines.push("");
  lines.push("alter table public.modules");
  lines.push("  add column if not exists randomize_exercises boolean not null default false,");
  lines.push("  add column if not exists exercises_per_student integer not null default 0;");
  lines.push("");
  lines.push("insert into public.modules (");
  lines.push("  title,");
  lines.push("  slug,");
  lines.push("  description,");
  lines.push("  order_index,");
  lines.push("  is_published,");
  lines.push("  randomize_exercises,");
  lines.push("  exercises_per_student");
  lines.push(")");
  lines.push("values (");
  lines.push(`  '${escapeSql(module.title)}',`);
  lines.push(`  '${module.slug}',`);
  lines.push(`  '${escapeSql(module.description)}',`);
  lines.push(`  ${module.order},`);
  lines.push("  true,");
  lines.push("  false,");
  lines.push("  0");
  lines.push(")");
  lines.push("on conflict (slug) do update");
  lines.push("set title = excluded.title,");
  lines.push("    description = excluded.description,");
  lines.push("    order_index = excluded.order_index,");
  lines.push("    is_published = excluded.is_published,");
  lines.push("    randomize_exercises = excluded.randomize_exercises,");
  lines.push("    exercises_per_student = excluded.exercises_per_student;");
  lines.push("");
  lines.push("-- Solo inserta el banco si el módulo todavía no tiene ejercicios.");
  lines.push("insert into public.exercises (");
  lines.push("  module_id,");
  lines.push("  prompt,");
  lines.push("  type,");
  lines.push("  options,");
  lines.push("  correct_option,");
  lines.push("  correct_answer,");
  lines.push("  tolerance,");
  lines.push("  explanation,");
  lines.push("  order_index");
  lines.push(")");
  lines.push("select");
  lines.push("  m.id,");
  lines.push("  v.prompt,");
  lines.push("  v.type,");
  lines.push("  v.options,");
  lines.push("  v.correct_option,");
  lines.push("  v.correct_answer,");
  lines.push("  v.tolerance,");
  lines.push("  v.explanation,");
  lines.push("  v.order_index");
  lines.push("from (");
  lines.push("  values");

  exercises.forEach((exercise, index) => {
    const comma = index === exercises.length - 1 ? "" : ",";

    lines.push("    (");
    lines.push(`      '${escapeSql(exercise.prompt)}',`);
    lines.push("      'numeric',");
    lines.push("      null::jsonb,");
    lines.push("      null::integer,");
    lines.push(`      ${exercise.answer}::numeric,`);
    lines.push(`      ${exercise.tolerance}::numeric,`);
    lines.push(`      '${escapeSql(exercise.explanation)}',`);
    lines.push(`      ${index + 1}`);
    lines.push(`    )${comma}`);
  });

  lines.push(") as v (");
  lines.push("  prompt,");
  lines.push("  type,");
  lines.push("  options,");
  lines.push("  correct_option,");
  lines.push("  correct_answer,");
  lines.push("  tolerance,");
  lines.push("  explanation,");
  lines.push("  order_index");
  lines.push(")");
  lines.push("cross join (");
  lines.push(`  select id from public.modules where slug = '${module.slug}'`);
  lines.push(") as m");
  lines.push("where not exists (");
  lines.push("  select 1");
  lines.push("  from public.exercises e");
  lines.push("  where e.module_id = m.id");
  lines.push(");");
  lines.push("");

  return lines.join("\n");
}

function main() {
  for (const module of MODULES) {
    const { exercises, worst } = buildModule(module);
    const sql = sqlFor(module, exercises);
    const target = path.join(SUPABASE, module.filename);

    fs.writeFileSync(target, sql, "utf8");

    console.log(
      `${module.filename} · 100 ejercicios · error máximo ${worst.toFixed(6)}`,
    );
  }
}

if (require.main === module) {
  main();
}

module.exports = { MODULES, buildModule, Q, integrate };
