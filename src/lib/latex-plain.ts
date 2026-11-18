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
  text = replaceCommandWithArgument(text, "sqrt", (arg) => `raíz(${arg})`);
  text = replaceCommandWithArgument(text, "frac", null, (numerator, denominator) => {
    return `(${numerator})/(${denominator})`;
  });

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
    "\u221a": "raíz",
    "\u2248": "~",
    "\u00b0": "°",
  };

  let text = value;

  for (const [from, to] of Object.entries(replacements)) {
    text = text.split(from).join(to);
  }

  let output = "";

  for (const character of text) {
    const code = character.codePointAt(0) ?? 0;

    if (character === "\n" || character === "\t") {
      output += " ";
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
