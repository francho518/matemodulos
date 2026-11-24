/**
 * Convierte texto con fórmulas LaTeX (como el que se guarda en los
 * ejercicios) a texto plano legible dentro de un PDF.
 *
 * No pretende ser un renderizador de LaTeX: solo cubre las fórmulas que
 * usa la plataforma (`$...$`, fracciones, raíces, grados, funciones
 * trigonométricas y algunos símbolos).
 */
export function latexToPlainText(value: string) {
  let text = value;

  // Quita los delimitadores de matemáticas: $...$ y $$...$$.
  text = text.replace(/\$\$([\s\S]+?)\$\$/g, "$1");
  text = text.replace(/\$([^$]+?)\$/g, "$1");

  // Comandos con contenido entre llaves.
  text = replaceCommandWithArgument(text, "operatorname", (arg) => arg);
  text = replaceCommandWithArgument(text, "mathrm", (arg) => arg);
  text = replaceCommandWithArgument(text, "text", (arg) => arg);
  text = replaceCommandWithArgument(text, "textbf", (arg) => arg);
  text = replaceCommandWithArgument(text, "sqrt", (arg) => `√(${arg})`);
  text = replaceCommandWithArgument(text, "frac", null, (numerator, denominator) => {
    return `(${numerator})/(${denominator})`;
  });

  // Los límites de una integral definida se guardan en un marcador para que
  // el PDF pueda dibujarlos arriba y abajo del signo, no como texto inline.
  text = convertIntegralLimits(text);

  // Grados y exponentes simples.
  text = text.replace(/\^\{?\\circ\}?/g, "°");
  text = text.replace(/\^\{?2\}?/g, "²");
  text = text.replace(/\^\{?3\}?/g, "³");
  text = text.replace(/\^\{([^{}]*)\}/g, "^$1");
  text = text.replace(/_\{([^{}]*)\}/g, "_$1");

  // Comandos sin argumento.
  const commands: Record<string, string> = {
    // Deben ir antes de \le y \ge: si no, \left se convierte en <=ft.
    "\\left": "",
    "\\right": "",
    "\\cdot": "·",
    "\\times": "×",
    "\\div": "÷",
    "\\pm": "±",
    "\\leq": "<=",
    "\\le": "<=",
    "\\geq": ">=",
    "\\ge": ">=",
    "\\neq": "!=",
    "\\ne": "!=",
    "\\approx": "~",
    "\\theta": "theta",
    "\\alpha": "alfa",
    "\\beta": "beta",
    "\\pi": "pi",
    "\\angle": "ángulo",
    "\\infty": "infinito",
    // La fuente Symbol tiene ∫ y √. Las integrales dobles/triples se
    // representan repitiendo el signo para evitar glifos que Symbol no
    // contiene (∬, ∭, ∮) y que harían fallar la generación del PDF.
    "\\int": "∫",
    "\\iint": "∫∫",
    "\\iiint": "∫∫∫",
    "\\oint": "∫",
    "\\Delta": "Delta",
    "\\sen": "sen ",
    "\\sin": "sen ",
    "\\cos": "cos ",
    "\\tan": "tan ",
    "\\arcsin": "arcsen ",
    "\\arccos": "arccos ",
    "\\arctan": "arctan ",
    "\\log": "log ",
    "\\ln": "ln ",
    "\\quad": "  ",
    "\\qquad": "    ",
    "\\,": " ",
    "\\;": " ",
    "\\:": " ",
    "\\!": "",
    "\\ ": " ",
    "\\%": "%",
    "\\&": "&",
    "\\_": "_",
    "\\#": "#",
    "\\{": "{",
    "\\}": "}",
  };

  for (const [command, replacement] of Object.entries(commands)) {
    text = text.split(command).join(replacement);
  }

  // Cualquier comando restante se elimina (por ejemplo, \displaystyle).
  text = text.replace(/\\[a-zA-Z]+/g, "");

  return sanitizeForPdf(text);
}

/**
 * Convierte `\\int_a^b` en un marcador `∫[a|b]` que el renderizador de PDF
 * interpreta para dibujar el límite inferior debajo y el superior encima del
 * signo. Se aceptan límites con y sin llaves, en cualquiera de los dos
 * órdenes en que aparezcan en el LaTeX.
 */
function convertIntegralLimits(text: string): string {
  const apply = (
    pattern: RegExp,
    build: (...groups: string[]) => string,
  ) => {
    text = text.replace(pattern, (match, ...args: unknown[]) => {
      // El último argumento de `replace` es el texto completo, no un grupo.
      const groups = args.slice(0, -2).filter(
        (value): value is string => typeof value === "string",
      );
      return build(...groups);
    });
  };

  // Con llaves en ambos límites.
  apply(/\\int\s*_\{([^{}]*)\}\s*\^\{([^{}]*)\}/g, (lower, upper) =>
    `∫[${lower}|${upper}]`,
  );
  apply(/\\int\s*\^\{([^{}]*)\}\s*_\{([^{}]*)\}/g, (upper, lower) =>
    `∫[${lower}|${upper}]`,
  );

  // Con llaves en un solo límite.
  apply(/\\int\s*_\{([^{}]*)\}/g, (lower) => `∫[${lower}|]`);
  apply(/\\int\s*\^\{([^{}]*)\}/g, (upper) => `∫[|${upper}]`);

  // Mixtos: inferior sin llaves y superior con llaves, o al revés.
  apply(/\\int\s*_\s*(\w)\s*\^\{([^{}]*)\}/g, (lower, upper) =>
    `∫[${lower}|${upper}]`,
  );
  apply(/\\int\s*_\{([^{}]*)\}\s*\^\s*(\w)/g, (lower, upper) =>
    `∫[${lower}|${upper}]`,
  );

  // Sin llaves (un solo carácter por límite).
  apply(/\\int\s*_\s*(\w)\s*\^\s*(\w)/g, (lower, upper) =>
    `∫[${lower}|${upper}]`,
  );
  apply(/\\int\s*_\s*(\w)/g, (lower) => `∫[${lower}|]`);
  apply(/\\int\s*\^\s*(\w)/g, (upper) => `∫[|${upper}]`);

  return text;
}

/**
 * Reemplaza un comando con uno o dos argumentos entre llaves simples.
 * Se repite hasta que no queden coincidencias para admitir anidamientos
 * sencillos como \frac{\sqrt{2}}{2}.
 */
function replaceCommandWithArgument(
  text: string,
  command: string,
  oneArg: ((argument: string) => string) | null,
  twoArgs?: (first: string, second: string) => string,
) {
  let result = text;
  let guard = 0;

  while (guard < 50) {
    guard += 1;

    const pattern = twoArgs
      ? new RegExp(
          `\\\\${command}\\{([^{}]*)\\}\\{([^{}]*)\\}`,
        )
      : new RegExp(`\\\\${command}\\{([^{}]*)\\}`);

    const replaced = result.replace(pattern, (_match, first, second) => {
      return twoArgs ? twoArgs(first, second) : oneArg!(first);
    });

    if (replaced === result) break;
    result = replaced;
  }

  return result;
}

/**
 * Deja solo caracteres representables con la codificación WinAnsi que
 * usan las fuentes estándar de PDF (Helvetica/Arial), para que pdf-lib
 * no falle al escribir acentos, signos o símbolos.
 */
function sanitizeForPdf(value: string) {
  const replacements: Record<string, string> = {
    "\u00a0": " ",
    "\u2018": "'",
    "\u2019": "'",
    "\u201c": '"',
    "\u201d": '"',
    "\u2013": "-",
    "\u2014": "-",
    "\u2026": "...",
    "\u2212": "-",
    "\u2192": "->",
    "\u2264": "<=",
    "\u2265": ">=",
    "\u2260": "!=",
    "\u221e": "infinito",
    "\u03c0": "pi",
    "\u03b8": "theta",
    "\u03b1": "alfa",
    "\u03b2": "beta",
    "\u0394": "Delta",
    "\u2248": "~",
    "\u00b0": "°",
  };

  let text = value;

  for (const [from, to] of Object.entries(replacements)) {
    text = text.split(from).join(to);
  }

  // Estos símbolos no pertenecen a WinAnsi, pero se mantienen para que el
  // generador de PDF pueda dibujarlos con la fuente Symbol.
  const pdfSymbols = new Set(["∫", "√"]);

  let output = "";

  for (const character of text) {
    const code = character.codePointAt(0) ?? 0;

    if (character === "\n" || character === "\t") {
      output += " ";
    } else if (pdfSymbols.has(character)) {
      output += character;
    } else if (code < 128 || (code >= 160 && code <= 255)) {
      output += character;
    } else if (character === "\u00a0") {
      output += " ";
    } else {
      output += "?";
    }
  }

  return output.replace(/[ \t]+/g, " ").trim();
}
