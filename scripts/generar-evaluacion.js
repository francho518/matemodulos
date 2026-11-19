"use strict";

/**
 * Genera la evaluación imprimible de 45 minutos y 100 puntos:
 *   - Factorización ................ 30 puntos (5 ítems × 6)
 *   - Trigonometría ................ 30 puntos (5 ítems × 6)
 *   - Funciones trigonométricas .... 40 puntos (5 ítems × 8)
 *
 * Salidas:
 *   public/docs/evaluacion-45-minutos.pdf
 *   public/docs/evaluacion-45-minutos-solucionario.pdf
 *
 * Uso:
 *   node scripts/generar-evaluacion.js
 */

const fs = require("fs");
const path = require("path");
const { PDFDocument, rgb } = require("pdf-lib");
const fontkitModule = require("@pdf-lib/fontkit");

const fontkit = fontkitModule.default || fontkitModule;

const ROOT = path.join(__dirname, "..");
const FONT_REGULAR = path.join(__dirname, "fonts", "DejaVuSans.ttf");
const FONT_BOLD = path.join(__dirname, "fonts", "DejaVuSans-Bold.ttf");
const LOGO_PATH = path.join(ROOT, "public", "images", "crisfe-logo.png");
const OUTPUT_DIR = path.join(ROOT, "public", "docs");
const EXAM_PATH = path.join(OUTPUT_DIR, "evaluacion-45-minutos.pdf");
const KEY_PATH = path.join(OUTPUT_DIR, "evaluacion-45-minutos-solucionario.pdf");

const PAGE_WIDTH = 595.28;
const PAGE_HEIGHT = 841.89;
const MARGIN = 48;
const CONTENT_WIDTH = PAGE_WIDTH - MARGIN * 2;
const BOTTOM = 58;

const COLORS = {
  navy: rgb(0.078, 0.137, 0.278),
  teal: rgb(0.043, 0.435, 0.408),
  text: rgb(0.13, 0.16, 0.21),
  gray: rgb(0.36, 0.4, 0.46),
  lightGray: rgb(0.78, 0.82, 0.86),
  pale: rgb(0.945, 0.957, 0.973),
  paleTeal: rgb(0.909, 0.965, 0.957),
  white: rgb(1, 1, 1),
  amber: rgb(0.62, 0.38, 0.06),
};

const ITEMS = [
  // ---------------------------------------------------------------
  // Sección I · Factorización (30 puntos)
  // ---------------------------------------------------------------
  {
    section: "I",
    points: 6,
    statement: "Factoriza completamente la siguiente expresión.",
    formula: "6x³ − 9x² + 3x",
    lines: 4,
    answer: "3x(2x − 1)(x − 1)",
    steps: [
      "Se extrae el factor común 3x: 6x³ − 9x² + 3x = 3x(2x² − 3x + 1).",
      "Se factoriza el trinomio 2x² − 3x + 1 = (2x − 1)(x − 1).",
      "Resultado: 3x(2x − 1)(x − 1).",
    ],
  },
  {
    section: "I",
    points: 6,
    statement: "Factoriza completamente la siguiente expresión.",
    formula: "2x² − 32y²",
    lines: 3,
    answer: "2(x − 4y)(x + 4y)",
    steps: [
      "Se extrae el factor común 2: 2x² − 32y² = 2(x² − 16y²).",
      "Se aplica la diferencia de cuadrados: x² − 16y² = (x − 4y)(x + 4y).",
      "Resultado: 2(x − 4y)(x + 4y).",
    ],
  },
  {
    section: "I",
    points: 6,
    statement: "Factoriza completamente la siguiente expresión.",
    formula: "3x² − 10x + 8",
    lines: 4,
    answer: "(3x − 4)(x − 2)",
    steps: [
      "Se buscan dos números que multiplicados den 3 · 8 = 24 y sumados den −10: son −6 y −4.",
      "Se reescribe: 3x² − 6x − 4x + 8.",
      "Se agrupa: 3x(x − 2) − 4(x − 2) = (3x − 4)(x − 2).",
    ],
  },
  {
    section: "I",
    points: 6,
    statement: "Factoriza completamente la siguiente expresión.",
    formula: "8x³ − 27",
    lines: 3,
    answer: "(2x − 3)(4x² + 6x + 9)",
    steps: [
      "Es una diferencia de cubos: a³ − b³ = (a − b)(a² + ab + b²), con a = 2x y b = 3.",
      "Se sustituye: (2x)³ − 3³ = (2x − 3)((2x)² + (2x)(3) + 3²).",
      "Resultado: (2x − 3)(4x² + 6x + 9).",
    ],
  },
  {
    section: "I",
    points: 6,
    statement:
      "El volumen de una caja rectangular es V(x) = x³ + 2x² − 4x − 8 cm³ y una de sus dimensiones mide x + 2 cm.",
    formula: null,
    parts: [
      { label: "a)", text: "Factoriza completamente el volumen V(x)." },
      {
        label: "b)",
        text: "Determina las otras dos dimensiones de la caja.",
      },
    ],
    lines: 5,
    answer: "V(x) = (x + 2)²(x − 2); las otras dimensiones son x + 2 cm y x − 2 cm.",
    steps: [
      "Se agrupa: x³ + 2x² − 4x − 8 = x²(x + 2) − 4(x + 2) = (x + 2)(x² − 4).",
      "Se factoriza la diferencia de cuadrados: x² − 4 = (x − 2)(x + 2).",
      "Entonces V(x) = (x + 2)²(x − 2).",
      "Las dimensiones son x + 2, x + 2 y x − 2 cm. Si una es x + 2, las otras dos son x + 2 cm y x − 2 cm.",
    ],
  },

  // ---------------------------------------------------------------
  // Sección II · Trigonometría (30 puntos)
  // ---------------------------------------------------------------
  {
    section: "II",
    points: 6,
    statement:
      "Una escalera de 13 m se apoya en una pared. La base de la escalera está a 5 m de la pared. ¿A qué altura de la pared llega la escalera?",
    lines: 4,
    answer: "12 m (12,00 m)",
    steps: [
      "La escalera, la pared y el suelo forman un triángulo rectángulo: hipotenusa 13 m y un cateto 5 m.",
      "Por el teorema de Pitágoras: h² + 5² = 13².",
      "h² = 169 − 25 = 144, por lo tanto h = √144 = 12 m.",
    ],
  },
  {
    section: "II",
    points: 6,
    statement:
      "Desde un punto situado a 12 m de la base de un árbol, el ángulo de elevación hasta la copa es 35°. ¿Cuál es la altura del árbol? Redondea a dos decimales.",
    lines: 4,
    answer: "8,40 m",
    steps: [
      "El cateto opuesto al ángulo es la altura h y el cateto adyacente mide 12 m.",
      "tan 35° = h / 12, entonces h = 12 · tan 35°.",
      "h ≈ 12 · 0,7002075 ≈ 8,4025 m. Redondeando: 8,40 m.",
    ],
  },
  {
    section: "II",
    points: 6,
    statement:
      "Un cable sujeta una antena de 15 m de altura y forma un ángulo de 50° con el suelo. ¿Cuál es la longitud del cable? Redondea a dos decimales.",
    lines: 4,
    answer: "19,58 m",
    steps: [
      "La altura de la antena es el cateto opuesto al ángulo de 50° y el cable es la hipotenusa L.",
      "sen 50° = 15 / L, entonces L = 15 / sen 50°.",
      "L ≈ 15 / 0,7660444 ≈ 19,5811 m. Redondeando: 19,58 m.",
    ],
  },
  {
    section: "II",
    points: 6,
    statement:
      "Una rampa de 8 m de longitud tiene una altura de 3 m. ¿Cuál es el ángulo de inclinación de la rampa? Redondea a un decimal.",
    lines: 4,
    answer: "22,0°",
    steps: [
      "La rampa es la hipotenusa (8 m) y la altura es el cateto opuesto (3 m).",
      "sen θ = 3 / 8 = 0,375.",
      "θ = arcsen(0,375) ≈ 22,0243°. Redondeando: 22,0°.",
    ],
  },
  {
    section: "II",
    points: 6,
    statement:
      "Una torre de 25 m proyecta una sombra de 18 m. ¿Cuál es el ángulo de elevación del Sol? Redondea a un decimal.",
    lines: 4,
    answer: "54,2°",
    steps: [
      "La altura de la torre es el cateto opuesto (25 m) y la sombra es el cateto adyacente (18 m).",
      "tan θ = 25 / 18 ≈ 1,3889.",
      "θ = arctan(1,3889) ≈ 54,2461°. Redondeando: 54,2°.",
    ],
  },

  // ---------------------------------------------------------------
  // Sección III · Funciones trigonométricas (40 puntos)
  // ---------------------------------------------------------------
  {
    section: "III",
    points: 8,
    statement: "Para la función y = −2cos(3x) + 1, determina:",
    table: {
      headers: ["Amplitud", "Periodo", "Rango", "Máximo", "Mínimo"],
      widths: [0.18, 0.18, 0.2, 0.22, 0.22],
      height: 34,
    },
    lines: 3,
    answer:
      "Amplitud: 2 · Periodo: 2π/3 · Rango: [−1, 3] · Máximo: 3 · Mínimo: −1",
    steps: [
      "La amplitud es |A| = |−2| = 2.",
      "El periodo es T = 2π/|B| = 2π/3.",
      "Como −1 ≤ cos(3x) ≤ 1, se tiene −2 ≤ −2cos(3x) ≤ 2. Al sumar 1: −1 ≤ y ≤ 3.",
      "El rango es [−1, 3]; el máximo es 3 y el mínimo es −1.",
    ],
  },
  {
    section: "III",
    points: 8,
    statement: "Si f(x) = 3sen(x + π/6) + 2, calcula:",
    table: {
      headers: ["f(π/3)", "f(2π/3)"],
      widths: [0.5, 0.5],
      height: 34,
    },
    lines: 3,
    answer: "f(π/3) = 5 y f(2π/3) = 3,5",
    steps: [
      "f(π/3) = 3sen(π/3 + π/6) + 2 = 3sen(π/2) + 2 = 3(1) + 2 = 5.",
      "f(2π/3) = 3sen(2π/3 + π/6) + 2 = 3sen(5π/6) + 2 = 3(1/2) + 2 = 1,5 + 2 = 3,5.",
    ],
  },
  {
    section: "III",
    points: 8,
    statement:
      "Escribe la ecuación de una función coseno con amplitud 4, periodo π, desplazada π/4 a la derecha y 2 unidades hacia arriba.",
    lines: 4,
    answer: "y = 4cos(2(x − π/4)) + 2, equivalente a y = 4cos(2x − π/2) + 2",
    steps: [
      "La amplitud es A = 4.",
      "El periodo es π, entonces 2π/B = π y B = 2.",
      "El desplazamiento horizontal es C = π/4 a la derecha y el vertical es D = 2 hacia arriba.",
      "La ecuación es y = 4cos(2(x − π/4)) + 2.",
      "Al distribuir: y = 4cos(2x − π/2) + 2.",
    ],
  },
  {
    section: "III",
    points: 8,
    statement: "Para la función y = 2sen(3x), determina:",
    table: {
      headers: ["Periodo", "Ciclos en [0, 2π]", "Ceros en [0, π]"],
      widths: [0.24, 0.34, 0.42],
      height: 42,
    },
    lines: 2,
    answer: "Periodo: 2π/3 · 3 ciclos completos · Ceros: 0, π/3, 2π/3 y π",
    steps: [
      "El periodo es T = 2π/|B| = 2π/3.",
      "En el intervalo [0, 2π] caben 2π ÷ (2π/3) = 3 ciclos completos.",
      "Los ceros cumplen 3x = kπ, es decir, x = kπ/3. En [0, π]: k = 0, 1, 2, 3, entonces x = 0, π/3, 2π/3 y π.",
    ],
  },
  {
    section: "III",
    points: 8,
    statement:
      "La altura de una noria se modela con h(t) = 12cos(πt/30) + 15, donde h se mide en metros y t en segundos. Determina:",
    table: {
      headers: ["h(0)", "Altura mínima", "Periodo", "h(15)"],
      widths: [0.2, 0.28, 0.22, 0.3],
      height: 34,
    },
    lines: 3,
    answer: "h(0) = 27 m · Altura mínima = 3 m · Periodo = 60 s · h(15) = 15 m",
    steps: [
      "h(0) = 12cos(0) + 15 = 12(1) + 15 = 27 m.",
      "La altura mínima ocurre cuando cos(πt/30) = −1: 12(−1) + 15 = 3 m.",
      "El periodo es T = 2π/(π/30) = 60 s.",
      "h(15) = 12cos(π · 15/30) + 15 = 12cos(π/2) + 15 = 12(0) + 15 = 15 m.",
    ],
  },
];

const SECTIONS = [
  {
    id: "I",
    title: "Factorización",
    points: 30,
    instructions:
      "Factoriza completamente cada expresión. Muestra el procedimiento y escribe la respuesta final en el espacio asignado.",
    items: ITEMS.filter((item) => item.section === "I"),
  },
  {
    id: "II",
    title: "Trigonometría",
    points: 30,
    instructions:
      "Resuelve cada situación con un triángulo rectángulo. Incluye el planteamiento y redondea longitudes a dos decimales y ángulos a un decimal.",
    items: ITEMS.filter((item) => item.section === "II"),
  },
  {
    id: "III",
    title: "Funciones trigonométricas",
    points: 40,
    instructions:
      "Analiza cada función seno o coseno. Justifica tus respuestas con el procedimiento y completa la tabla cuando corresponda.",
    items: ITEMS.filter((item) => item.section === "III"),
  },
];

const INSTRUCTIONS = [
  "Tienes 45 minutos para resolver la evaluación. Al finalizar, entrega todas las hojas.",
  "Puedes usar calculadora científica. No se permite el uso de apuntes, formularios ni dispositivos con conexión.",
  "Resuelve en los espacios asignados y muestra el procedimiento. Una respuesta sin procedimiento puede recibir menos puntaje.",
  "Redondea longitudes a dos decimales y ángulos a un decimal, salvo que se indique otra cosa.",
];

function wrapText(text, font, size, maxWidth) {
  const paragraphs = String(text ?? "").split("\n");
  const lines = [];

  for (const paragraph of paragraphs) {
    const words = paragraph.split(/ +/).filter(Boolean);

    if (words.length === 0) {
      lines.push("");
      continue;
    }

    let current = "";

    for (const word of words) {
      const candidate = current ? `${current} ${word}` : word;

      if (font.widthOfTextAtSize(candidate, size) <= maxWidth) {
        current = candidate;
      } else {
        if (current) lines.push(current);
        current = word;
      }
    }

    if (current) lines.push(current);
  }

  return lines.length > 0 ? lines : [""];
}

function formatNumber(value) {
  return String(value).replace(".", ",");
}

class Document {
  constructor(pdf, fonts, logo, options = {}) {
    this.pdf = pdf;
    this.fonts = fonts;
    this.logo = logo;
    this.pages = [];
    this.page = null;
    this.y = 0;
    this.kind = options.kind ?? "exam";
  }

  addPage(first = false) {
    const page = this.pdf.addPage([PAGE_WIDTH, PAGE_HEIGHT]);
    this.pages.push(page);
    this.page = page;

    if (first) {
      this.drawCover();
    } else {
      this.drawRunningHeader();
      this.y = PAGE_HEIGHT - 78;
    }
  }

  ensure(height) {
    if (this.y - height < BOTTOM) {
      this.addPage(false);
    }
  }

  drawCover() {
    const { page, fonts, logo } = this;
    const isKey = this.kind === "key";

    const logoHeight = 27;
    const logoWidth = (logo.width / logo.height) * logoHeight;

    page.drawImage(logo, {
      x: MARGIN,
      y: PAGE_HEIGHT - 50,
      width: logoWidth,
      height: logoHeight,
    });

    const headerLabel = isKey
      ? "SOLUCIONARIO · USO DEL DOCENTE"
      : "EVALUACIÓN DE MATEMÁTICA";
    const headerWidth = fonts.bold.widthOfTextAtSize(headerLabel, 8.4);

    page.drawText(headerLabel, {
      x: PAGE_WIDTH - MARGIN - headerWidth,
      y: PAGE_HEIGHT - 36,
      size: 8.4,
      font: fonts.bold,
      color: COLORS.navy,
    });

    const headerSub = "45 minutos · 100 puntos";
    const headerSubWidth = fonts.regular.widthOfTextAtSize(headerSub, 8.4);

    page.drawText(headerSub, {
      x: PAGE_WIDTH - MARGIN - headerSubWidth,
      y: PAGE_HEIGHT - 49,
      size: 8.4,
      font: fonts.regular,
      color: COLORS.gray,
    });

    page.drawLine({
      start: { x: MARGIN, y: PAGE_HEIGHT - 66 },
      end: { x: PAGE_WIDTH - MARGIN, y: PAGE_HEIGHT - 66 },
      thickness: 2.2,
      color: COLORS.navy,
    });

    page.drawText(
      isKey ? "Solucionario y criterios de corrección" : "Evaluación de Matemática",
      {
        x: MARGIN,
        y: PAGE_HEIGHT - 100,
        size: isKey ? 21 : 24,
        font: fonts.bold,
        color: COLORS.navy,
      },
    );

    page.drawText(
      isKey
        ? "Respuestas y procedimientos · Evaluación de 45 minutos"
        : "Factorización · Trigonometría · Funciones trigonométricas",
      {
        x: MARGIN,
        y: PAGE_HEIGHT - 121,
        size: 10.5,
        font: fonts.regular,
        color: COLORS.gray,
      },
    );

    if (!isKey) {
      this.drawStudentFields();
      this.drawInstructionBox();
      this.y = PAGE_HEIGHT - 342;
    } else {
      this.drawKeyIntro();
      this.y = PAGE_HEIGHT - 250;
    }
  }

  drawStudentFields() {
    const { page, fonts } = this;

    page.drawText("Nombre:", {
      x: MARGIN,
      y: PAGE_HEIGHT - 151,
      size: 9.2,
      font: fonts.bold,
      color: COLORS.text,
    });

    page.drawLine({
      start: { x: MARGIN + 48, y: PAGE_HEIGHT - 154 },
      end: { x: PAGE_WIDTH - MARGIN, y: PAGE_HEIGHT - 154 },
      thickness: 0.7,
      color: COLORS.lightGray,
    });

    const rowY = PAGE_HEIGHT - 177;

    page.drawText("Grupo:", {
      x: MARGIN,
      y: rowY,
      size: 9.2,
      font: fonts.bold,
      color: COLORS.text,
    });

    page.drawLine({
      start: { x: MARGIN + 44, y: rowY - 3 },
      end: { x: MARGIN + 210, y: rowY - 3 },
      thickness: 0.7,
      color: COLORS.lightGray,
    });

    page.drawText("Fecha:", {
      x: MARGIN + 240,
      y: rowY,
      size: 9.2,
      font: fonts.bold,
      color: COLORS.text,
    });

    page.drawLine({
      start: { x: MARGIN + 278, y: rowY - 3 },
      end: { x: MARGIN + 382, y: rowY - 3 },
      thickness: 0.7,
      color: COLORS.lightGray,
    });

    page.drawText("Puntaje:", {
      x: MARGIN + 404,
      y: rowY,
      size: 9.2,
      font: fonts.bold,
      color: COLORS.text,
    });

    page.drawLine({
      start: { x: MARGIN + 448, y: rowY - 3 },
      end: { x: PAGE_WIDTH - MARGIN - 34, y: rowY - 3 },
      thickness: 0.7,
      color: COLORS.lightGray,
    });

    page.drawText("/ 100", {
      x: PAGE_WIDTH - MARGIN - 31,
      y: rowY,
      size: 8.8,
      font: fonts.regular,
      color: COLORS.gray,
    });
  }

  drawInstructionBox() {
    const { page, fonts } = this;
    const top = PAGE_HEIGHT - 196;
    const height = 128;

    page.drawRectangle({
      x: MARGIN,
      y: top - height,
      width: CONTENT_WIDTH,
      height,
      color: COLORS.pale,
    });

    page.drawRectangle({
      x: MARGIN,
      y: top - height,
      width: 4,
      height,
      color: COLORS.teal,
    });

    page.drawText("Instrucciones", {
      x: MARGIN + 16,
      y: top - 20,
      size: 10.5,
      font: fonts.bold,
      color: COLORS.navy,
    });

    let cursor = top - 40;

    for (const instruction of INSTRUCTIONS) {
      page.drawText("•", {
        x: MARGIN + 16,
        y: cursor,
        size: 9,
        font: fonts.regular,
        color: COLORS.teal,
      });

      const lines = wrapText(
        instruction,
        fonts.regular,
        8.9,
        CONTENT_WIDTH - 46,
      );

      for (const line of lines) {
        page.drawText(line, {
          x: MARGIN + 28,
          y: cursor,
          size: 8.9,
          font: fonts.regular,
          color: COLORS.text,
        });
        cursor -= 11.1;
      }

      cursor -= 2.2;
    }
  }

  drawKeyIntro() {
    const { page, fonts } = this;
    const top = PAGE_HEIGHT - 150;
    const height = 76;

    page.drawRectangle({
      x: MARGIN,
      y: top - height,
      width: CONTENT_WIDTH,
      height,
      color: COLORS.paleTeal,
    });

    page.drawRectangle({
      x: MARGIN,
      y: top - height,
      width: 4,
      height,
      color: COLORS.teal,
    });

    page.drawText("Cómo usar este documento", {
      x: MARGIN + 16,
      y: top - 19,
      size: 10.5,
      font: fonts.bold,
      color: COLORS.navy,
    });

    const text =
      "Este archivo contiene las respuestas y los procedimientos de los 15 ítems. " +
      "Imprime el examen para los estudiantes y conserva este solucionario para la corrección. " +
      "Al final se incluyen los criterios de corrección y la distribución de puntos.";

    let cursor = top - 36;
    for (const line of wrapText(text, fonts.regular, 8.9, CONTENT_WIDTH - 34)) {
      page.drawText(line, {
        x: MARGIN + 16,
        y: cursor,
        size: 8.9,
        font: fonts.regular,
        color: COLORS.text,
      });
      cursor -= 11.2;
    }
  }

  drawRunningHeader() {
    const { page, fonts, logo } = this;
    const isKey = this.kind === "key";
    const logoHeight = 18;
    const logoWidth = (logo.width / logo.height) * logoHeight;

    page.drawImage(logo, {
      x: MARGIN,
      y: PAGE_HEIGHT - 44,
      width: logoWidth,
      height: logoHeight,
    });

    const label = isKey
      ? "Solucionario · Evaluación de Matemática"
      : "Evaluación de Matemática · 45 minutos";
    const width = fonts.bold.widthOfTextAtSize(label, 8.2);

    page.drawText(label, {
      x: PAGE_WIDTH - MARGIN - width,
      y: PAGE_HEIGHT - 38,
      size: 8.2,
      font: fonts.bold,
      color: COLORS.navy,
    });

    page.drawLine({
      start: { x: MARGIN, y: PAGE_HEIGHT - 55 },
      end: { x: PAGE_WIDTH - MARGIN, y: PAGE_HEIGHT - 55 },
      thickness: 0.8,
      color: COLORS.lightGray,
    });
  }

  drawSectionHeader(section) {
    // Evita dejar el título de la sección solo al final de una página:
    // exige espacio también para el primer ítem.
    const firstItemHeight = section.items[0]
      ? this.measureItem(section.items[0])
      : 0;

    this.ensure(34 + 10 + 16 + 20 + firstItemHeight);

    const { page, fonts } = this;
    const top = this.y;

    page.drawRectangle({
      x: MARGIN,
      y: top - 34,
      width: CONTENT_WIDTH,
      height: 34,
      color: COLORS.pale,
    });

    page.drawRectangle({
      x: MARGIN,
      y: top - 34,
      width: 5,
      height: 34,
      color: COLORS.navy,
    });

    page.drawText(`SECCIÓN ${section.id}`, {
      x: MARGIN + 16,
      y: top - 12,
      size: 7.8,
      font: fonts.bold,
      color: COLORS.teal,
    });

    page.drawText(section.title, {
      x: MARGIN + 16,
      y: top - 27,
      size: 12.5,
      font: fonts.bold,
      color: COLORS.navy,
    });

    const pointsLabel = `${section.points} puntos`;
    const pointsWidth = fonts.bold.widthOfTextAtSize(pointsLabel, 9.2);

    page.drawText(pointsLabel, {
      x: PAGE_WIDTH - MARGIN - 14 - pointsWidth,
      y: top - 21,
      size: 9.2,
      font: fonts.bold,
      color: COLORS.navy,
    });

    this.y = top - 34 - 10;

    for (const line of wrapText(
      section.instructions,
      fonts.regular,
      9.2,
      CONTENT_WIDTH,
    )) {
      page.drawText(line, {
        x: MARGIN,
        y: this.y,
        size: 9.2,
        font: fonts.regular,
        color: COLORS.gray,
      });
      this.y -= 11.8;
    }

    this.y -= 10;
  }

  measureItem(item) {
    const textWidth = CONTENT_WIDTH - 28 - 54;
    let height = 0;

    height += wrapText(item.statement, this.fonts.regular, 10, textWidth).length * 13.4;

    if (item.formula) height += 27;

    for (const part of item.parts ?? []) {
      height +=
        wrapText(part.text, this.fonts.regular, 9.6, textWidth - 16).length * 12.6;
    }

    if (item.table) height += 26 + item.table.height + 8;

    height += (item.lines ?? 0) * 18;
    height += 18;

    return height;
  }

  drawItem(item, number) {
    this.ensure(this.measureItem(item));

    const { page, fonts } = this;
    const top = this.y;
    const textX = MARGIN + 28;
    const textWidth = CONTENT_WIDTH - 28 - 54;
    const firstBaseline = top - 11;

    const badgeCenterY = top - 7.4;

    page.drawCircle({
      x: MARGIN + 8.5,
      y: badgeCenterY,
      size: 8.5,
      color: COLORS.navy,
    });

    const numberLabel = String(number);
    const numberWidth = fonts.bold.widthOfTextAtSize(numberLabel, 8.4);

    page.drawText(numberLabel, {
      x: MARGIN + 8.5 - numberWidth / 2,
      y: badgeCenterY - 2.9,
      size: 8.4,
      font: fonts.bold,
      color: COLORS.white,
    });

    const pointsLabel = `${item.points} pts`;
    const pointsWidth = fonts.bold.widthOfTextAtSize(pointsLabel, 8.2);

    page.drawText(pointsLabel, {
      x: PAGE_WIDTH - MARGIN - pointsWidth,
      y: top - 10,
      size: 8.2,
      font: fonts.bold,
      color: COLORS.gray,
    });

    let cursor = firstBaseline;

    for (const line of wrapText(item.statement, fonts.regular, 10, textWidth)) {
      page.drawText(line, {
        x: textX,
        y: cursor,
        size: 10,
        font: fonts.regular,
        color: COLORS.text,
      });
      cursor -= 13.4;
    }

    if (item.formula) {
      cursor -= 6;

      const formulaWidth = fonts.bold.widthOfTextAtSize(item.formula, 12.4);

      page.drawText(item.formula, {
        x: MARGIN + (CONTENT_WIDTH - formulaWidth) / 2,
        y: cursor,
        size: 12.4,
        font: fonts.bold,
        color: COLORS.navy,
      });

      cursor -= 23;
    }

    for (const part of item.parts ?? []) {
      const labelWidth = fonts.bold.widthOfTextAtSize(part.label, 9.6);

      page.drawText(part.label, {
        x: textX,
        y: cursor,
        size: 9.6,
        font: fonts.bold,
        color: COLORS.navy,
      });

      const lines = wrapText(
        part.text,
        fonts.regular,
        9.6,
        textWidth - 16,
      );

      let partX = textX + labelWidth + 5;

      for (const line of lines) {
        page.drawText(line, {
          x: partX,
          y: cursor,
          size: 9.6,
          font: fonts.regular,
          color: COLORS.text,
        });
        cursor -= 12.6;
        partX = textX + 16;
      }
    }

    if (item.table) {
      cursor -= 6;
      cursor = this.drawTable(item.table, textX, cursor, CONTENT_WIDTH - 28);
      cursor -= 8;
    }

    for (let i = 0; i < (item.lines ?? 0); i++) {
      cursor -= 18;

      page.drawLine({
        start: { x: textX, y: cursor },
        end: { x: PAGE_WIDTH - MARGIN, y: cursor },
        thickness: 0.6,
        color: COLORS.lightGray,
        dashArray: [2, 2.5],
      });
    }

    this.y = cursor - 16;
  }

  drawTable(table, x, top, width) {
    const { page, fonts } = this;
    const headerHeight = 26;
    const rowHeight = table.height ?? 34;
    const widths = table.widths.map((fraction) => fraction * width);

    let cursorX = x;

    for (let i = 0; i < table.headers.length; i++) {
      const cellWidth = widths[i];

      page.drawRectangle({
        x: cursorX,
        y: top - headerHeight,
        width: cellWidth,
        height: headerHeight,
        color: COLORS.pale,
        borderColor: COLORS.lightGray,
        borderWidth: 0.6,
      });

      const lines = wrapText(
        table.headers[i],
        fonts.bold,
        8.2,
        cellWidth - 8,
      );

      let textY =
        top - headerHeight / 2 + ((lines.length - 1) * 9.4) / 2 + 2.8;

      for (const line of lines) {
        const lineWidth = fonts.bold.widthOfTextAtSize(line, 8.2);

        page.drawText(line, {
          x: cursorX + (cellWidth - lineWidth) / 2,
          y: textY,
          size: 8.2,
          font: fonts.bold,
          color: COLORS.navy,
        });

        textY -= 9.4;
      }

      cursorX += cellWidth;
    }

    cursorX = x;

    for (let i = 0; i < table.headers.length; i++) {
      const cellWidth = widths[i];

      page.drawRectangle({
        x: cursorX,
        y: top - headerHeight - rowHeight,
        width: cellWidth,
        height: rowHeight,
        color: COLORS.white,
        borderColor: COLORS.lightGray,
        borderWidth: 0.6,
      });

      cursorX += cellWidth;
    }

    return top - headerHeight - rowHeight;
  }

  drawAnswerSheet() {
    this.ensure(300);

    const { page, fonts } = this;
    const top = this.y;

    page.drawRectangle({
      x: MARGIN,
      y: top - 30,
      width: CONTENT_WIDTH,
      height: 30,
      color: COLORS.navy,
    });

    page.drawText("Hoja de respuestas", {
      x: MARGIN + 14,
      y: top - 20,
      size: 11.5,
      font: fonts.bold,
      color: COLORS.white,
    });

    const hint = "Escribe aquí la respuesta final de cada ítem.";
    const hintWidth = fonts.regular.widthOfTextAtSize(hint, 8.2);

    page.drawText(hint, {
      x: PAGE_WIDTH - MARGIN - 14 - hintWidth,
      y: top - 19,
      size: 8.2,
      font: fonts.regular,
      color: COLORS.white,
    });

    let cursor = top - 30;
    const rowHeight = 24;

    for (let i = 0; i < ITEMS.length; i++) {
      const item = ITEMS[i];
      const isEven = i % 2 === 0;

      page.drawRectangle({
        x: MARGIN,
        y: cursor - rowHeight,
        width: CONTENT_WIDTH,
        height: rowHeight,
        color: isEven ? COLORS.white : COLORS.pale,
        borderColor: COLORS.lightGray,
        borderWidth: 0.5,
      });

      const numberLabel = String(i + 1);
      const numberWidth = fonts.bold.widthOfTextAtSize(numberLabel, 9);

      page.drawText(numberLabel, {
        x: MARGIN + 14,
        y: cursor - 15.5,
        size: 9,
        font: fonts.bold,
        color: COLORS.navy,
      });

      page.drawText(`${item.points} pts`, {
        x: MARGIN + 40,
        y: cursor - 15.2,
        size: 7.8,
        font: fonts.regular,
        color: COLORS.gray,
      });

      page.drawLine({
        start: { x: MARGIN + 86, y: cursor - 17 },
        end: { x: PAGE_WIDTH - MARGIN - 14, y: cursor - 17 },
        thickness: 0.6,
        color: COLORS.lightGray,
        dashArray: [2, 2.5],
      });

      cursor -= rowHeight;
    }

    this.y = cursor - 14;

    const note =
      "Entrega esta hoja junto con el examen. El procedimiento completo se califica en las páginas anteriores.";

    for (const line of wrapText(note, fonts.regular, 8.2, CONTENT_WIDTH)) {
      page.drawText(line, {
        x: MARGIN,
        y: this.y,
        size: 8.2,
        font: fonts.regular,
        color: COLORS.gray,
      });
      this.y -= 10.4;
    }
  }

  drawSolutionItem(item, number) {
    const textWidth = CONTENT_WIDTH - 28 - 60;

    const statementLines = wrapText(
      item.statement,
      this.fonts.regular,
      9.6,
      textWidth,
    );
    const answerLines = wrapText(
      item.answer,
      this.fonts.regular,
      9.2,
      textWidth,
    );
    const stepLines = item.steps.flatMap((step) =>
      wrapText(step, this.fonts.regular, 9, textWidth - 12),
    );

    let height = statementLines.length * 12.6;
    if (item.formula) height += 22;
    height += 16 + answerLines.length * 11.8;
    height += 16 + stepLines.length * 11.4;
    height += 18;

    this.ensure(height);

    const { page, fonts } = this;
    const textX = MARGIN + 28;
    const top = this.y;
    const badgeCenterY = top - 7.2;

    page.drawCircle({
      x: MARGIN + 8.5,
      y: badgeCenterY,
      size: 8.5,
      color: COLORS.navy,
    });

    const numberLabel = String(number);
    const numberWidth = fonts.bold.widthOfTextAtSize(numberLabel, 8.4);

    page.drawText(numberLabel, {
      x: MARGIN + 8.5 - numberWidth / 2,
      y: badgeCenterY - 2.9,
      size: 8.4,
      font: fonts.bold,
      color: COLORS.white,
    });

    const pointsLabel = `${item.points} pts`;
    const pointsWidth = fonts.bold.widthOfTextAtSize(pointsLabel, 8.2);

    page.drawText(pointsLabel, {
      x: PAGE_WIDTH - MARGIN - pointsWidth,
      y: top - 10,
      size: 8.2,
      font: fonts.bold,
      color: COLORS.gray,
    });

    let cursor = top - 11;

    for (const line of statementLines) {
      page.drawText(line, {
        x: textX,
        y: cursor,
        size: 9.6,
        font: fonts.regular,
        color: COLORS.text,
      });
      cursor -= 12.6;
    }

    if (item.formula) {
      cursor -= 4;

      const formulaWidth = fonts.bold.widthOfTextAtSize(item.formula, 11);

      page.drawText(item.formula, {
        x: textX,
        y: cursor,
        size: 11,
        font: fonts.bold,
        color: COLORS.navy,
      });

      cursor -= 20;
    }

    cursor -= 4;

    page.drawText("Respuesta:", {
      x: textX,
      y: cursor,
      size: 9.2,
      font: fonts.bold,
      color: COLORS.teal,
    });

    cursor -= 12;

    for (const line of answerLines) {
      page.drawText(line, {
        x: textX + 8,
        y: cursor,
        size: 9.2,
        font: fonts.regular,
        color: COLORS.text,
      });
      cursor -= 11.8;
    }

    cursor -= 6;

    page.drawText("Procedimiento:", {
      x: textX,
      y: cursor,
      size: 9,
      font: fonts.bold,
      color: COLORS.navy,
    });

    cursor -= 12;

    for (const step of item.steps) {
      page.drawText("•", {
        x: textX + 4,
        y: cursor,
        size: 8.4,
        font: fonts.regular,
        color: COLORS.teal,
      });

      for (const line of wrapText(step, fonts.regular, 9, textWidth - 12)) {
        page.drawText(line, {
          x: textX + 14,
          y: cursor,
          size: 9,
          font: fonts.regular,
          color: COLORS.text,
        });
        cursor -= 11.4;
      }
    }

    cursor -= 6;

    page.drawLine({
      start: { x: MARGIN, y: cursor },
      end: { x: PAGE_WIDTH - MARGIN, y: cursor },
      thickness: 0.5,
      color: COLORS.lightGray,
    });

    this.y = cursor - 16;
  }

  drawKeySummary() {
    this.ensure(230);

    const { page, fonts } = this;
    const top = this.y;

    page.drawRectangle({
      x: MARGIN,
      y: top - 30,
      width: CONTENT_WIDTH,
      height: 30,
      color: COLORS.navy,
    });

    page.drawText("Distribución de puntos y criterios de corrección", {
      x: MARGIN + 14,
      y: top - 20,
      size: 10.5,
      font: fonts.bold,
      color: COLORS.white,
    });

    let cursor = top - 30;
    const rows = [
      ["Sección I · Factorización", "1 – 5", "30"],
      ["Sección II · Trigonometría", "6 – 10", "30"],
      ["Sección III · Funciones trigonométricas", "11 – 15", "40"],
      ["Total", "15 ítems", "100"],
    ];

    for (let i = 0; i < rows.length; i++) {
      const [label, items, points] = rows[i];
      const isTotal = i === rows.length - 1;

      page.drawRectangle({
        x: MARGIN,
        y: cursor - 22,
        width: CONTENT_WIDTH,
        height: 22,
        color: isTotal ? COLORS.paleTeal : i % 2 === 0 ? COLORS.white : COLORS.pale,
        borderColor: COLORS.lightGray,
        borderWidth: 0.5,
      });

      page.drawText(label, {
        x: MARGIN + 10,
        y: cursor - 15,
        size: 8.8,
        font: isTotal ? fonts.bold : fonts.regular,
        color: COLORS.text,
      });

      page.drawText(items, {
        x: MARGIN + 310,
        y: cursor - 15,
        size: 8.8,
        font: fonts.regular,
        color: COLORS.text,
      });

      const pointsWidth = fonts.bold.widthOfTextAtSize(points, 8.8);
      page.drawText(points, {
        x: PAGE_WIDTH - MARGIN - 12 - pointsWidth,
        y: cursor - 15,
        size: 8.8,
        font: fonts.bold,
        color: COLORS.navy,
      });

      cursor -= 22;
    }

    cursor -= 14;

    const criteria = [
      "Respuesta correcta con procedimiento completo: 100% del valor del ítem.",
      "Procedimiento correcto con un error de cálculo: se recomienda otorgar el 50% del valor del ítem.",
      "Solo la respuesta correcta, sin procedimiento: se recomienda otorgar el 50% del valor del ítem.",
      "Los errores de redondeo de ±0,01 en longitudes y ±0,1° en ángulos no invalidan la respuesta.",
      "Tiempo sugerido: 12 minutos para la sección I, 15 minutos para la sección II y 18 minutos para la sección III.",
    ];

    for (const criterion of criteria) {
      page.drawText("•", {
        x: MARGIN + 4,
        y: cursor,
        size: 8.4,
        font: fonts.regular,
        color: COLORS.teal,
      });

      for (const line of wrapText(
        criterion,
        fonts.regular,
        8.6,
        CONTENT_WIDTH - 18,
      )) {
        page.drawText(line, {
          x: MARGIN + 14,
          y: cursor,
          size: 8.6,
          font: fonts.regular,
          color: COLORS.text,
        });
        cursor -= 10.8;
      }

      cursor -= 2;
    }

    this.y = cursor;
  }

  drawFooters() {
    const total = this.pages.length;
    const isKey = this.kind === "key";

    this.pages.forEach((page, index) => {
      page.drawLine({
        start: { x: MARGIN, y: 44 },
        end: { x: PAGE_WIDTH - MARGIN, y: 44 },
        thickness: 0.5,
        color: COLORS.lightGray,
      });

      const footer = isKey
        ? "Solucionario · Evaluación de Matemática · 45 minutos"
        : "Evaluación de Matemática · 45 minutos · 100 puntos";

      page.drawText(footer, {
        x: MARGIN,
        y: 32,
        size: 7.6,
        font: this.fonts.regular,
        color: COLORS.gray,
      });

      const label = `Página ${index + 1} de ${total}`;
      const labelWidth = this.fonts.regular.widthOfTextAtSize(label, 7.6);

      page.drawText(label, {
        x: PAGE_WIDTH - MARGIN - labelWidth,
        y: 32,
        size: 7.6,
        font: this.fonts.regular,
        color: COLORS.gray,
      });
    });
  }
}

async function loadDocument() {
  const pdf = await PDFDocument.create();
  pdf.registerFontkit(fontkit);

  const fonts = {
    regular: await pdf.embedFont(fs.readFileSync(FONT_REGULAR), {
      subset: true,
    }),
    bold: await pdf.embedFont(fs.readFileSync(FONT_BOLD), {
      subset: true,
    }),
  };

  const logo = await pdf.embedPng(fs.readFileSync(LOGO_PATH));

  return { pdf, fonts, logo };
}

async function buildExam() {
  const { pdf, fonts, logo } = await loadDocument();

  pdf.setTitle("Evaluación de Matemática · 45 minutos");
  pdf.setAuthor("Colegios CRISFE");
  pdf.setSubject("Factorización, Trigonometría y Funciones trigonométricas");
  pdf.setCreator("Mate Dual Brücke");

  const doc = new Document(pdf, fonts, logo, { kind: "exam" });

  doc.addPage(true);

  let number = 1;

  for (const section of SECTIONS) {
    doc.drawSectionHeader(section);

    for (const item of section.items) {
      doc.drawItem(item, number);
      number += 1;
    }
  }

  doc.drawAnswerSheet();
  doc.drawFooters();

  const bytes = await pdf.save();
  fs.writeFileSync(EXAM_PATH, bytes);

  return { path: EXAM_PATH, pages: doc.pages.length, bytes: bytes.length };
}

async function buildKey() {
  const { pdf, fonts, logo } = await loadDocument();

  pdf.setTitle("Solucionario · Evaluación de Matemática · 45 minutos");
  pdf.setAuthor("Colegios CRISFE");
  pdf.setSubject("Respuestas y criterios de corrección");
  pdf.setCreator("Mate Dual Brücke");

  const doc = new Document(pdf, fonts, logo, { kind: "key" });

  doc.addPage(true);

  let number = 1;

  for (const section of SECTIONS) {
    doc.drawSectionHeader(section);

    for (const item of section.items) {
      doc.drawSolutionItem(item, number);
      number += 1;
    }
  }

  doc.drawKeySummary();
  doc.drawFooters();

  const bytes = await pdf.save();
  fs.writeFileSync(KEY_PATH, bytes);

  return { path: KEY_PATH, pages: doc.pages.length, bytes: bytes.length };
}

async function main() {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });

  const exam = await buildExam();
  const key = await buildKey();

  const total = ITEMS.reduce((sum, item) => sum + item.points, 0);
  const bySection = SECTIONS.map((section) => ({
    section: section.id,
    title: section.title,
    points: section.items.reduce((sum, item) => sum + item.points, 0),
    items: section.items.length,
  }));

  console.log("Evaluación:");
  console.log(`  ${exam.path}`);
  console.log(`  ${exam.pages} páginas · ${formatNumber(exam.bytes / 1024)} KB`);
  console.log("Solucionario:");
  console.log(`  ${key.path}`);
  console.log(`  ${key.pages} páginas · ${formatNumber(key.bytes / 1024)} KB`);
  console.log("Distribución:");
  for (const item of bySection) {
    console.log(
      `  ${item.section}. ${item.title}: ${item.items} ítems · ${item.points} puntos`,
    );
  }
  console.log(`  Total: ${ITEMS.length} ítems · ${total} puntos · 45 minutos`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
