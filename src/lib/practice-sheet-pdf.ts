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
};

export type PracticeSheetInput = {
  moduleTitle: string;
  moduleDescription: string | null;
  studentName: string | null;
  exercises: PracticeSheetExercise[];
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
const PARAGRAPH_GAP = 10;

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
 * Genera el PDF de la guía de práctica con el mismo estilo de documento
 * académico del formato de referencia: título, secciones y ejercicios
 * numerados con espacio para resolver.
 */
export async function buildPracticeSheetPdf({
  moduleTitle,
  moduleDescription,
  studentName,
  exercises,
}: PracticeSheetInput): Promise<Uint8Array> {
  const pdf = await PDFDocument.create();
  const regular = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const logo = await embedHeaderLogo(pdf);

  const drawHeaderBand = (currentPage: PDFPage) => {
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

    const subtitle = "Guía de práctica";
    const subtitleWidth = regular.widthOfTextAtSize(subtitle, 8);
    currentPage.drawText(subtitle, {
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

  const pages: PDFPage[] = [];
  let page: PDFPage;
  let y = 0;

  const startPage = () => {
    page = pdf.addPage([PAGE_WIDTH, PAGE_HEIGHT]);
    pages.push(page);
    y = PAGE_HEIGHT - MARGIN_TOP;
  };

  const ensureSpace = (height: number) => {
    if (y - height < MARGIN_BOTTOM) startPage();
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

  startPage();

  // Encabezado del documento, con el mismo estilo del formato adjunto.
  drawParagraph(`Guía de práctica · ${moduleTitle}`, {
    font: bold,
    size: TITLE_SIZE,
    lineHeight: 20,
  });

  y -= 18;

  drawParagraph(
    moduleDescription ??
      `Ejercicios de preparación para el módulo ${moduleTitle}.`,
    { size: SUBTITLE_SIZE, color: GRAY, lineHeight: 17 },
  );

  y -= 26;

  drawParagraph(
    `Nombre: ${studentName ?? "________________________________"} · Fecha: ______________`,
    { size: BODY_SIZE },
  );

  drawSectionHeading("Objetivo");
  drawParagraph(
    `Practicar con ${exercises.length} ${
      exercises.length === 1 ? "ejercicio" : "ejercicios"
    } diferentes a los que te asignará el módulo, para llegar mejor preparado a la práctica en la plataforma.`,
  );

  drawSectionHeading("Instrucciones");
  drawBullet(
    "Resuelve los ejercicios en el espacio disponible. Puedes usar calculadora, lápiz y tus apuntes.",
  );
  drawBullet(
    "Esta guía es solo para practicar: las respuestas no se entregan y no afectan tu nota.",
  );
  drawBullet(
    "Al ingresar al módulo, la plataforma te asignará otra selección de ejercicios parecida en cantidad.",
  );

  drawSectionHeading("Ejercicios");
  y -= 6;

  exercises.forEach((exercise, index) => {
    const prompt = latexToPlainText(exercise.prompt);
    const numberWidth = 22;
    const promptLines = wrapText(
      prompt,
      regular,
      BODY_SIZE,
      CONTENT_WIDTH - numberWidth,
    );

    const options =
      exercise.type === "multiple_choice" && exercise.options
        ? exercise.options.map((option, optionIndex) => {
            const letter = String.fromCharCode(97 + optionIndex);
            return `${letter}) ${latexToPlainText(option)}`;
          })
        : [];

    const requiredHeight =
      Math.max(promptLines.length, 1) * LINE_HEIGHT +
      options.length * LINE_HEIGHT +
      LINE_HEIGHT +
      EXERCISE_GAP +
      14;

    ensureSpace(requiredHeight);

    page.drawText(`${index + 1}.`, {
      x: MARGIN_X,
      y,
      size: BODY_SIZE,
      font: bold,
      color: rgb(0.1, 0.1, 0.1),
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
    y -= LINE_HEIGHT + EXERCISE_GAP;
  });

  // Cintillo superior en todas las páginas.
  pages.forEach(drawHeaderBand);

  // Pie de página: -- 1 of N --, como en el documento de referencia.
  pages.forEach((currentPage, index) => {
    const label = `-- ${index + 1} of ${pages.length} --`;
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
