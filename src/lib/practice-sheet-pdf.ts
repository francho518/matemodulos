import { readFile } from "node:fs/promises";
import path from "node:path";
import {
  PDFDocument,
  StandardFonts,
  rgb,
  type PDFFont,
  type PDFImage,
  type PDFPage,
} from "pdf-lib";
import { latexToPlainText } from "./latex-plain";

export type PracticeSheetExercise = {
  prompt: string;
  type: "multiple_choice" | "numeric";
  options: string[] | null;
  /** Etiqueta corta que se muestra sobre el enunciado (por ejemplo, el módulo). */
  tag?: string | null;
  /** Solo se usa en el solucionario. */
  answer?: string | null;
  explanation?: string | null;
};

export type PracticeSheetInput = {
  moduleTitle: string;
  moduleDescription: string | null;
  studentName: string | null;
  exercises: PracticeSheetExercise[];
  /** Texto del cintillo superior. Por defecto, "Guía de práctica". */
  documentLabel?: string;
  title?: string;
  metaLine?: string | null;
  objective?: string | null;
  instructions?: string[] | null;
  exerciseHeading?: string;
  /** Dibuja respuestas y explicaciones en lugar de la línea en blanco. */
  solutionMode?: boolean;
  /** Cada bloque empieza en una página nueva (por defecto, sí). */
  startNewPage?: boolean;
};

const PAGE_WIDTH = 595.28; // A4
const PAGE_HEIGHT = 841.89;
const MARGIN_X = 83;
// Deja espacio para el cintillo superior con los logos.
const MARGIN_TOP = 104;
const MARGIN_BOTTOM = 88;
const CONTENT_WIDTH = PAGE_WIDTH - MARGIN_X * 2;

const TITLE_SIZE = 14;
const SUBTITLE_SIZE = 11;
const HEADING_SIZE = 11.5;
const BODY_SIZE = 10.5;
const LINE_HEIGHT = 16;
const SECTION_GAP = 20;

// Tres líneas en blanco entre un ejercicio y el siguiente.
const EXERCISE_GAP = LINE_HEIGHT * 3;

const GRAY = rgb(0.38, 0.38, 0.38);
const LIGHT_GRAY = rgb(0.55, 0.55, 0.55);

const BRAND_NAVY = rgb(0.043, 0.165, 0.29);
const BRAND_TEAL = rgb(0.075, 0.722, 0.651);

const LOGO_PATH = path.join(
  process.cwd(),
  "public",
  "images",
  "crisfe-logo.png",
);

/**
 * Incrusta el logo del cintillo. Si el archivo no está disponible en el
 * servidor, el PDF se genera igual sin logo.
 */
async function embedHeaderLogo(pdf: PDFDocument): Promise<PDFImage | null> {
  try {
    const bytes = await readFile(LOGO_PATH);
    return await pdf.embedPng(bytes);
  } catch {
    return null;
  }
}

const PDF_SYMBOLS = new Set(["∫", "√"]);
// Marcadores emitidos por latexToPlainText: ∫[inferior|superior] y √«radicando».
const MATH_TOKEN = /∫\[([^\]|]*)\|([^\]]*)\]|√«([^»]*)»/g;
const SYMBOL_SPLIT = /(∫|√)/g;

// Proporciones tipográficas de los símbolos compuestos.
const INTEGRAL_GLYPH_RATIO = 1.25;
const LIMIT_SIZE_RATIO = 0.6;
const RADICAL_GLYPH_RATIO = 1.2;
// Los límites van a la derecha del signo (notación inline), así que no
// hace falta reservar altura extra: caben dentro del interlineado normal.
const INTEGRAL_EXTRA_ABOVE = 0;
const INTEGRAL_EXTRA_BELOW = 0;

type TextSegment =
  | { kind: "text"; text: string }
  | { kind: "symbol"; text: string }
  | { kind: "integral"; lower: string; upper: string }
  | { kind: "radical"; radicand: string };

function splitSymbols(text: string): TextSegment[] {
  return text
    .split(SYMBOL_SPLIT)
    .filter(Boolean)
    .map((part) =>
      PDF_SYMBOLS.has(part)
        ? { kind: "symbol" as const, text: part }
        : { kind: "text" as const, text: part },
    );
}

/** Divide una línea en texto, símbolos, integrales y raíces. */
function tokenize(text: string): TextSegment[] {
  const segments: TextSegment[] = [];
  const pattern = new RegExp(MATH_TOKEN.source, "g");
  let lastIndex = 0;
  let match: RegExpExecArray | null;

  while ((match = pattern.exec(text)) !== null) {
    if (match.index > lastIndex) {
      segments.push(...splitSymbols(text.slice(lastIndex, match.index)));
    }

    if (match[3] !== undefined) {
      segments.push({ kind: "radical", radicand: match[3] });
    } else {
      segments.push({
        kind: "integral",
        lower: match[1],
        upper: match[2],
      });
    }

    lastIndex = match.index + match[0].length;
  }

  if (lastIndex < text.length) {
    segments.push(...splitSymbols(text.slice(lastIndex)));
  }

  return segments.length > 0 ? segments : [{ kind: "text", text }];
}

function hasIntegral(text: string): boolean {
  return /∫\[[^\]]*\]/.test(text);
}

function extraAbove(text: string): number {
  return hasIntegral(text) ? INTEGRAL_EXTRA_ABOVE : 0;
}

function advanceFor(text: string, base: number): number {
  return hasIntegral(text) ? base + INTEGRAL_EXTRA_BELOW : base;
}

function linesHeight(lines: string[], base: number): number {
  return lines.reduce(
    (total, line) => total + extraAbove(line) + advanceFor(line, base),
    0,
  );
}

function segmentWidth(
  segment: TextSegment,
  font: PDFFont,
  symbolFont: PDFFont,
  size: number,
): number {
  if (segment.kind === "integral") {
    const limitSize = size * LIMIT_SIZE_RATIO;
    const glyphWidth = symbolFont.widthOfTextAtSize(
      "∫",
      size * INTEGRAL_GLYPH_RATIO,
    );
    const lowerWidth = font.widthOfTextAtSize(segment.lower, limitSize);
    const upperWidth = font.widthOfTextAtSize(segment.upper, limitSize);
    return glyphWidth + 1.5 + Math.max(lowerWidth, upperWidth);
  }

  if (segment.kind === "radical") {
    const glyphWidth = symbolFont.widthOfTextAtSize(
      "√",
      size * RADICAL_GLYPH_RATIO,
    );
    const innerWidth = font.widthOfTextAtSize(segment.radicand, size);
    return glyphWidth + 1 + innerWidth + 1;
  }

  const usedFont = segment.kind === "symbol" ? symbolFont : font;
  return usedFont.widthOfTextAtSize(segment.text, size);
}

/** Ancho real de una línea que puede mezclar Helvetica, Symbol y límites. */
function mixedWidth(
  text: string,
  font: PDFFont,
  symbolFont: PDFFont,
  size: number,
): number {
  return tokenize(text).reduce(
    (total, segment) => total + segmentWidth(segment, font, symbolFont, size),
    0,
  );
}

function wrapText(
  text: string,
  font: PDFFont,
  symbolFont: PDFFont,
  size: number,
  maxWidth: number,
): string[] {
  const words = text.split(/\s+/).filter(Boolean);
  const lines: string[] = [];
  let current = "";

  for (const word of words) {
    const candidate = current ? `${current} ${word}` : word;

    if (mixedWidth(candidate, font, symbolFont, size) <= maxWidth) {
      current = candidate;
      continue;
    }

    if (current) lines.push(current);

    // Una palabra más larga que el ancho disponible se parte por caracteres.
    if (mixedWidth(word, font, symbolFont, size) > maxWidth) {
      let chunk = "";

      for (const character of word) {
        if (mixedWidth(chunk + character, font, symbolFont, size) > maxWidth) {
          if (chunk) lines.push(chunk);
          chunk = character;
        } else {
          chunk += character;
        }
      }

      current = chunk;
    } else {
      current = word;
    }
  }

  if (current) lines.push(current);

  return lines.length > 0 ? lines : [""];
}

/**
 * Genera un PDF con uno o varios bloques (guías, evaluaciones o solucionarios)
 * usando siempre el mismo estilo académico. Los bloques pueden pertenecer a
 * documentos distintos: el cintillo recuerda a qué versión corresponde cada
 * página.
 */
export async function buildPracticeSheetsPdf(
  inputs: PracticeSheetInput[],
): Promise<Uint8Array> {
  const pdf = await PDFDocument.create();
  const regular = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  // Helvetica no incluye los signos de integral; Symbol sí.
  const symbol = await pdf.embedFont(StandardFonts.Symbol);
  const logo = await embedHeaderLogo(pdf);

  /**
   * Dibuja una línea alternando entre la fuente normal y Symbol. Las
   * integrales definidas se componen con el signo ampliado y los límites
   * por encima y por debajo, sin solape. Las raíces llevan una raya sobre
   * todo el radicando.
   */
  const drawMixedText = (
    currentPage: PDFPage,
    text: string,
    options: {
      x: number;
      y: number;
      size: number;
      font: PDFFont;
      color: ReturnType<typeof rgb>;
    },
  ) => {
    let cursor = options.x;

    for (const segment of tokenize(text)) {
      if (segment.kind === "integral") {
        const glyphSize = options.size * INTEGRAL_GLYPH_RATIO;
        const limitSize = options.size * LIMIT_SIZE_RATIO;
        const glyphWidth = symbol.widthOfTextAtSize("∫", glyphSize);
        const lowerWidth = options.font.widthOfTextAtSize(
          segment.lower,
          limitSize,
        );
        const upperWidth = options.font.widthOfTextAtSize(
          segment.upper,
          limitSize,
        );
        const blockWidth = glyphWidth + 1.5 + Math.max(lowerWidth, upperWidth);

        // Signo y límites se dibujan en columnas separadas: así el trazo de
        // la integral nunca queda tapado por el límite superior o inferior.
        currentPage.drawText("∫", {
          x: cursor,
          y: options.y,
          size: glyphSize,
          font: symbol,
          color: options.color,
        });

        const limitsX = cursor + glyphWidth + 1.5;

        if (segment.upper) {
          currentPage.drawText(segment.upper, {
            x: limitsX + (Math.max(lowerWidth, upperWidth) - upperWidth) / 2,
            y: options.y + 6.5,
            size: limitSize,
            font: options.font,
            color: options.color,
          });
        }

        if (segment.lower) {
          currentPage.drawText(segment.lower, {
            x: limitsX + (Math.max(lowerWidth, upperWidth) - lowerWidth) / 2,
            y: options.y - 4.5,
            size: limitSize,
            font: options.font,
            color: options.color,
          });
        }

        cursor += blockWidth;
        continue;
      }

      if (segment.kind === "radical") {
        const glyphSize = options.size * RADICAL_GLYPH_RATIO;
        const glyphWidth = symbol.widthOfTextAtSize("√", glyphSize);
        const innerWidth = options.font.widthOfTextAtSize(
          segment.radicand,
          options.size,
        );
        const innerX = cursor + glyphWidth + 1;

        currentPage.drawText("√", {
          x: cursor,
          y: options.y,
          size: glyphSize,
          font: symbol,
          color: options.color,
        });

        currentPage.drawText(segment.radicand, {
          x: innerX,
          y: options.y,
          size: options.size,
          font: options.font,
          color: options.color,
        });

        const barY = options.y + options.size * 0.8;
        currentPage.drawLine({
          start: { x: innerX - 0.5, y: barY },
          end: { x: innerX + innerWidth + 0.5, y: barY },
          thickness: 0.7,
          color: options.color,
        });

        cursor += glyphWidth + 1 + innerWidth + 1;
        continue;
      }

      const font = segment.kind === "symbol" ? symbol : options.font;
      currentPage.drawText(segment.text, {
        x: cursor,
        y: options.y,
        size: options.size,
        font,
        color: options.color,
      });
      cursor += font.widthOfTextAtSize(segment.text, options.size);
    }
  };

  const pageLabels = new Map<PDFPage, string>();
  let currentLabel = "Guía de práctica";
  let page: PDFPage;
  let y = 0;
  let hasPage = false;

  const drawHeaderBand = (currentPage: PDFPage, label: string) => {
    // Cintillo superior: logo a la izquierda y nombre de la plataforma
    // a la derecha, como en el documento de referencia.
    if (logo) {
      const logoHeight = 30;
      const logoWidth = (logo.width / logo.height) * logoHeight;

      currentPage.drawImage(logo, {
        x: MARGIN_X,
        y: PAGE_HEIGHT - 26 - logoHeight,
        width: logoWidth,
        height: logoHeight,
      });
    } else {
      currentPage.drawText("CRISFE", {
        x: MARGIN_X,
        y: PAGE_HEIGHT - 50,
        size: 13,
        font: bold,
        color: BRAND_NAVY,
      });
    }

    const platform = "Mate Dual Brücke";
    const platformWidth = bold.widthOfTextAtSize(platform, 10.5);
    currentPage.drawText(platform, {
      x: PAGE_WIDTH - MARGIN_X - platformWidth,
      y: PAGE_HEIGHT - 42,
      size: 10.5,
      font: bold,
      color: BRAND_NAVY,
    });

    const subtitleWidth = regular.widthOfTextAtSize(label, 8);
    currentPage.drawText(label, {
      x: PAGE_WIDTH - MARGIN_X - subtitleWidth,
      y: PAGE_HEIGHT - 55,
      size: 8,
      font: regular,
      color: GRAY,
    });

    currentPage.drawLine({
      start: { x: MARGIN_X, y: PAGE_HEIGHT - 68 },
      end: { x: PAGE_WIDTH - MARGIN_X, y: PAGE_HEIGHT - 68 },
      thickness: 1.2,
      color: BRAND_TEAL,
    });
  };

  const startPage = () => {
    page = pdf.addPage([PAGE_WIDTH, PAGE_HEIGHT]);
    pageLabels.set(page, currentLabel);
    y = PAGE_HEIGHT - MARGIN_TOP;
    hasPage = true;
  };

  const ensureSpace = (height: number) => {
    if (!hasPage || y - height < MARGIN_BOTTOM) startPage();
  };

  const drawParagraph = (
    text: string,
    options: {
      font?: PDFFont;
      size?: number;
      lineHeight?: number;
      indent?: number;
      color?: ReturnType<typeof rgb>;
    } = {},
  ) => {
    const font = options.font ?? regular;
    const size = options.size ?? BODY_SIZE;
    const lineHeight = options.lineHeight ?? LINE_HEIGHT;
    const indent = options.indent ?? 0;
    const color = options.color ?? rgb(0.13, 0.13, 0.13);

    const lines = wrapText(
      text,
      font,
      symbol,
      size,
      CONTENT_WIDTH - indent,
    );

    for (const line of lines) {
      const above = extraAbove(line);
      const step = advanceFor(line, lineHeight);
      ensureSpace(above + step + 2);
      y -= above;
      drawMixedText(page, line, {
        x: MARGIN_X + indent,
        y,
        size,
        font,
        color,
      });
      y -= step;
    }
  };

  const drawSectionHeading = (text: string) => {
    y -= SECTION_GAP;
    ensureSpace(HEADING_SIZE + 4);
    drawMixedText(page, text, {
      x: MARGIN_X,
      y,
      size: HEADING_SIZE,
      font: bold,
      color: rgb(0.1, 0.1, 0.1),
    });
    y -= HEADING_SIZE + 12;
  };

  const drawBullet = (text: string) => {
    const bulletIndent = 14;
    const lines = wrapText(
      text,
      regular,
      symbol,
      BODY_SIZE,
      CONTENT_WIDTH - bulletIndent,
    );

    lines.forEach((line, index) => {
      const above = extraAbove(line);
      const step = advanceFor(line, LINE_HEIGHT);
      ensureSpace(above + step + 2);
      y -= above;

      if (index === 0) {
        page.drawText("•", {
          x: MARGIN_X,
          y,
          size: BODY_SIZE,
          font: regular,
          color: GRAY,
        });
      }

      drawMixedText(page, line, {
        x: MARGIN_X + bulletIndent,
        y,
        size: BODY_SIZE,
        font: regular,
        color: rgb(0.13, 0.13, 0.13),
      });
      y -= step;
    });
  };

  for (const input of inputs) {
    currentLabel = input.documentLabel ?? "Guía de práctica";

    if (!hasPage || input.startNewPage !== false) {
      startPage();
    } else {
      y -= 10;
    }

    const title =
      input.title ?? `Guía de práctica · ${input.moduleTitle}`;
    const description =
      input.moduleDescription ??
      `Ejercicios de preparación para el módulo ${input.moduleTitle}.`;
    const metaLine =
      input.metaLine ??
      `Nombre: ${input.studentName ?? "________________________________"} · Fecha: ______________`;
    const objective =
      input.objective ??
      `Practicar con ${input.exercises.length} ${
        input.exercises.length === 1 ? "ejercicio" : "ejercicios"
      } diferentes a los que te asignará el módulo, para llegar mejor preparado a la práctica en la plataforma.`;
    const instructions = input.instructions ?? [
      "Resuelve los ejercicios en el espacio disponible. Puedes usar calculadora, lápiz y tus apuntes.",
      "Esta guía es solo para practicar: las respuestas no se entregan y no afectan tu nota.",
      "Al ingresar al módulo, la plataforma te asignará otra selección de ejercicios parecida en cantidad.",
    ];

    drawParagraph(title, {
      font: bold,
      size: TITLE_SIZE,
      lineHeight: 20,
    });

    y -= 18;

    drawParagraph(description, {
      size: SUBTITLE_SIZE,
      color: GRAY,
      lineHeight: 17,
    });

    y -= 26;

    drawParagraph(metaLine, { size: BODY_SIZE });

    drawSectionHeading("Objetivo");
    drawParagraph(objective);

    drawSectionHeading("Instrucciones");
    instructions.forEach(drawBullet);

    drawSectionHeading(input.exerciseHeading ?? "Ejercicios");
    y -= 6;

    input.exercises.forEach((exercise, index) => {
      const prompt = latexToPlainText(exercise.prompt);
      const numberWidth = 22;
      const promptLines = wrapText(
        prompt,
        regular,
        symbol,
        BODY_SIZE,
        CONTENT_WIDTH - numberWidth,
      );
      const tagLines = exercise.tag
        ? wrapText(
            latexToPlainText(exercise.tag),
            bold,
            symbol,
            9,
            CONTENT_WIDTH - numberWidth,
          )
        : [];

      const optionLines =
        exercise.type === "multiple_choice" && exercise.options
          ? exercise.options.map((option, optionIndex) => {
              const letter = String.fromCharCode(97 + optionIndex);
              return wrapText(
                `${letter}) ${latexToPlainText(option)}`,
                regular,
                symbol,
                BODY_SIZE,
                CONTENT_WIDTH - numberWidth - 14,
              );
            })
          : [];

      const requiredHeight =
        linesHeight(tagLines, LINE_HEIGHT - 4) +
        Math.max(linesHeight(promptLines, LINE_HEIGHT), LINE_HEIGHT) +
        optionLines.reduce(
          (total, lines) => total + linesHeight(lines, LINE_HEIGHT),
          0,
        ) +
        LINE_HEIGHT +
        14;

      ensureSpace(requiredHeight);

      page.drawText(`${index + 1}.`, {
        x: MARGIN_X,
        y,
        size: BODY_SIZE,
        font: bold,
        color: rgb(0.1, 0.1, 0.1),
      });

      tagLines.forEach((line) => {
        const above = extraAbove(line);
        const step = advanceFor(line, LINE_HEIGHT - 4);
        y -= above;
        drawMixedText(page, line, {
          x: MARGIN_X + numberWidth,
          y,
          size: 9,
          font: bold,
          color: BRAND_TEAL,
        });
        y -= step;
      });

      promptLines.forEach((line) => {
        const above = extraAbove(line);
        const step = advanceFor(line, LINE_HEIGHT);
        ensureSpace(above + step + 2);
        y -= above;
        drawMixedText(page, line, {
          x: MARGIN_X + numberWidth,
          y,
          size: BODY_SIZE,
          font: regular,
          color: rgb(0.13, 0.13, 0.13),
        });
        y -= step;
      });

      optionLines.forEach((lines) => {
        lines.forEach((line) => {
          const above = extraAbove(line);
          const step = advanceFor(line, LINE_HEIGHT);
          ensureSpace(above + step + 2);
          y -= above;
          drawMixedText(page, line, {
            x: MARGIN_X + numberWidth + 14,
            y,
            size: BODY_SIZE,
            font: regular,
            color: GRAY,
          });
          y -= step;
        });
      });

      if (input.solutionMode) {
        y -= 2;
        drawParagraph(`Respuesta: ${exercise.answer ?? "—"}`, {
          font: bold,
          indent: numberWidth,
          color: BRAND_TEAL,
        });

        if (exercise.explanation) {
          drawParagraph(`Explicación: ${latexToPlainText(exercise.explanation)}`, {
            indent: numberWidth,
            size: BODY_SIZE - 0.5,
            lineHeight: LINE_HEIGHT - 1,
            color: GRAY,
          });
        }

        y -= 8;
      } else {
        // Línea para escribir la respuesta.
        y -= 2;
        ensureSpace(LINE_HEIGHT);
        drawMixedText(page, "Respuesta: ______________________________________________", {
          x: MARGIN_X + numberWidth,
          y,
          size: BODY_SIZE,
          font: regular,
          color: LIGHT_GRAY,
        });
      }

      y -= LINE_HEIGHT + EXERCISE_GAP;
    });
  }

  const allPages = pdf.getPages();

  // Cintillo superior en todas las páginas.
  allPages.forEach((currentPage) => {
    drawHeaderBand(currentPage, pageLabels.get(currentPage) ?? "Guía de práctica");
  });

  // Pie de página: -- 1 of N --, como en el documento de referencia.
  allPages.forEach((currentPage, index) => {
    const label = `-- ${index + 1} of ${allPages.length} --`;
    const width = regular.widthOfTextAtSize(label, 9);

    currentPage.drawText(label, {
      x: (PAGE_WIDTH - width) / 2,
      y: 40,
      size: 9,
      font: regular,
      color: LIGHT_GRAY,
    });
  });

  return pdf.save();
}

/** Compatibilidad con la guía de práctica existente. */
export async function buildPracticeSheetPdf(
  input: PracticeSheetInput,
): Promise<Uint8Array> {
  return buildPracticeSheetsPdf([input]);
}
