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

function wrapText(
  text: string,
  font: PDFFont,
  size: number,
  maxWidth: number,
): string[] {
  const words = text.split(/\s+/).filter(Boolean);
  const lines: string[] = [];
  let current = "";

  for (const word of words) {
    const candidate = current ? `${current} ${word}` : word;

    if (font.widthOfTextAtSize(candidate, size) <= maxWidth) {
      current = candidate;
      continue;
    }

    if (current) lines.push(current);

    // Una palabra más larga que el ancho disponible se parte por caracteres.
    if (font.widthOfTextAtSize(word, size) > maxWidth) {
      let chunk = "";

      for (const character of word) {
        if (font.widthOfTextAtSize(chunk + character, size) > maxWidth) {
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
  const logo = await embedHeaderLogo(pdf);

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

    const lines = wrapText(text, font, size, CONTENT_WIDTH - indent);

    for (const line of lines) {
      ensureSpace(lineHeight);
      page.drawText(line, {
        x: MARGIN_X + indent,
        y,
        size,
        font,
        color,
      });
      y -= lineHeight;
    }
  };

  const drawSectionHeading = (text: string) => {
    y -= SECTION_GAP;
    ensureSpace(HEADING_SIZE + 4);
    page.drawText(text, {
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
    const lines = wrapText(text, regular, BODY_SIZE, CONTENT_WIDTH - bulletIndent);

    lines.forEach((line, index) => {
      ensureSpace(LINE_HEIGHT);

      if (index === 0) {
        page.drawText("•", {
          x: MARGIN_X,
          y,
          size: BODY_SIZE,
          font: regular,
          color: GRAY,
        });
      }

      page.drawText(line, {
        x: MARGIN_X + bulletIndent,
        y,
        size: BODY_SIZE,
        font: regular,
        color: rgb(0.13, 0.13, 0.13),
      });
      y -= LINE_HEIGHT;
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
        BODY_SIZE,
        CONTENT_WIDTH - numberWidth,
      );
      const tagLines = exercise.tag
        ? wrapText(
            latexToPlainText(exercise.tag),
            bold,
            9,
            CONTENT_WIDTH - numberWidth,
          )
        : [];

      const options =
        exercise.type === "multiple_choice" && exercise.options
          ? exercise.options.map((option, optionIndex) => {
              const letter = String.fromCharCode(97 + optionIndex);
              return `${letter}) ${latexToPlainText(option)}`;
            })
          : [];

      const requiredHeight =
        tagLines.length * (LINE_HEIGHT - 4) +
        Math.max(promptLines.length, 1) * LINE_HEIGHT +
        options.length * LINE_HEIGHT +
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
        page.drawText(line, {
          x: MARGIN_X + numberWidth,
          y,
          size: 9,
          font: bold,
          color: BRAND_TEAL,
        });
        y -= LINE_HEIGHT - 4;
      });

      promptLines.forEach((line) => {
        page.drawText(line, {
          x: MARGIN_X + numberWidth,
          y,
          size: BODY_SIZE,
          font: regular,
          color: rgb(0.13, 0.13, 0.13),
        });
        y -= LINE_HEIGHT;
      });

      options.forEach((option) => {
        const optionLines = wrapText(
          option,
          regular,
          BODY_SIZE,
          CONTENT_WIDTH - numberWidth - 14,
        );

        optionLines.forEach((line) => {
          ensureSpace(LINE_HEIGHT);
          page.drawText(line, {
            x: MARGIN_X + numberWidth + 14,
            y,
            size: BODY_SIZE,
            font: regular,
            color: GRAY,
          });
          y -= LINE_HEIGHT;
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
        page.drawText("Respuesta: ______________________________________________", {
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
