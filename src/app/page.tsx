import Link from "next/link";

const steps = [
  {
    number: "01",
    title: "Crea tu cuenta",
    description:
      "Regístrate con tu correo y accede a todos los módulos publicados.",
  },
  {
    number: "02",
    title: "Tu docente te asigna un módulo",
    description:
      "Tu docente asigna los módulos que verás según tu grupo y tu avance.",
  },
  {
    number: "03",
    title: "Practica y aprende",
    description:
      "Responde, recibe retroalimentación inmediata y sigue tu progreso.",
  },
];

const stats = [
  { value: "Muchos", label: "ejercicios por módulo" },
  { value: "Muchos", label: "módulos temáticos" },
  { value: "Varias", label: "opciones por ejercicio" },
  { value: "100 %", label: "corrección automática" },
];

const floatingSymbols = [
  { symbol: "∑", className: "left-[3%] top-[10%] text-7xl" },
  { symbol: "π", className: "left-[30%] top-[6%] text-6xl" },
  { symbol: "√", className: "right-[4%] top-[8%] text-8xl" },
  { symbol: "∞", className: "left-[8%] bottom-[14%] text-7xl" },
  { symbol: "θ", className: "right-[6%] top-[36%] text-7xl" },
  { symbol: "Δ", className: "left-[44%] bottom-[6%] text-5xl" },
  { symbol: "∫", className: "right-[28%] bottom-[8%] text-7xl" },
  { symbol: "±", className: "left-[22%] top-[40%] text-5xl" },
  { symbol: "≈", className: "right-[20%] top-[56%] text-5xl" },
  { symbol: "α", className: "left-[58%] top-[14%] text-5xl" },
  { symbol: "β", className: "left-[50%] top-[52%] text-4xl" },
  { symbol: "ƒ", className: "right-[12%] bottom-[32%] text-6xl" },
  { symbol: "∂", className: "left-[14%] top-[62%] text-5xl" },
  { symbol: "∑", className: "right-[38%] top-[4%] text-4xl" },
  { symbol: "λ", className: "left-[70%] bottom-[26%] text-5xl" },
  { symbol: "φ", className: "left-[4%] top-[46%] text-4xl" },
  { symbol: "≡", className: "right-[46%] bottom-[42%] text-4xl" },
  { symbol: "·", className: "left-[40%] top-[68%] text-6xl" },
];

const floatingFormulas = [
  {
    formula: "a² + b² = c²",
    className: "left-[16%] top-[22%] -rotate-6 text-brand-mint/25",
  },
  {
    formula: "sen θ = op / hip",
    className: "right-[14%] top-[18%] rotate-3 text-white/15",
  },
  {
    formula: "A = πr²",
    className: "left-[36%] bottom-[20%] rotate-2 text-brand-orange/25",
  },
  {
    formula: "lim x→∞",
    className: "right-[3%] bottom-[10%] -rotate-3 text-white/15",
  },
  {
    formula: "x = (-b ± √(b²-4ac)) / 2a",
    className: "right-[24%] top-[70%] rotate-2 text-white/10",
  },
  {
    formula: "tan θ = a / b",
    className: "left-[2%] bottom-[38%] -rotate-2 text-brand-teal/25",
  },
];

const formulas = [
  { label: "Pitágoras", value: "a² + b² = c²" },
  { label: "Seno", value: "sen θ = op / hip" },
  { label: "Coseno", value: "cos θ = ady / hip" },
  { label: "Tangente", value: "tan θ = op / ady" },
];

export default function HomePage() {
  return (
    <div className="overflow-hidden bg-white">
      {/* Hero */}
      <section className="relative isolate overflow-hidden bg-brand-deep">
        <div
          className="pointer-events-none absolute inset-0"
          aria-hidden="true"
          style={{
            background:
              "radial-gradient(circle at 18% 18%, rgba(19,184,166,0.22), transparent 42%), radial-gradient(circle at 82% 30%, rgba(242,106,10,0.16), transparent 38%), radial-gradient(circle at 60% 90%, rgba(142,230,216,0.10), transparent 35%)",
          }}
        />
        <div
          className="pointer-events-none absolute inset-0 opacity-[0.07]"
          aria-hidden="true"
          style={{
            backgroundImage:
              "linear-gradient(rgba(255,255,255,0.55) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.55) 1px, transparent 1px)",
            backgroundSize: "52px 52px",
          }}
        />

        <div
          className="pointer-events-none absolute inset-0 select-none overflow-hidden font-serif"
          aria-hidden="true"
        >
          {floatingSymbols.map((item) => (
            <span
              key={item.symbol}
              className={`absolute font-bold text-white/[0.07] ${item.className}`}
            >
              {item.symbol}
            </span>
          ))}
          {floatingFormulas.map((item) => (
            <span
              key={item.formula}
              className={`absolute whitespace-nowrap text-2xl font-semibold tracking-tight ${item.className}`}
            >
              {item.formula}
            </span>
          ))}
        </div>

        <div className="relative mx-auto grid max-w-6xl items-center gap-12 px-4 py-20 sm:py-24 lg:grid-cols-[1.05fr_0.95fr] lg:py-28">
          <div className="max-w-2xl">
            <span className="inline-flex items-center rounded-full bg-brand-mint px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-brand-navy">
              Aprende a tu ritmo
            </span>

            <h1 className="mt-6 text-5xl font-extrabold tracking-tight text-white sm:text-6xl lg:text-7xl">
              Mate <span className="text-brand-mint">Dual Brücke</span>
            </h1>

            <p className="mt-6 max-w-xl text-lg leading-relaxed text-slate-200 sm:text-xl">
              Una plataforma de práctica para tus temas vistos en clases.
              Resuelve ejercicios, recibe retroalimentación inmediata y observa
              tu progreso desde un solo lugar.
            </p>

            <div className="mt-9 flex flex-wrap gap-3">
              <Link href="/register" className="btn-brand px-6 py-3 text-base">
                Empezar gratis <span aria-hidden="true">→</span>
              </Link>
              <Link
                href="/login"
                className="btn-brand-outline px-6 py-3 text-base"
              >
                Ya tengo cuenta <span aria-hidden="true">→</span>
              </Link>
            </div>
          </div>

          {/* Pizarra de fórmulas */}
          <div className="relative mx-auto w-full max-w-xl lg:mx-0 lg:max-w-none">
            <div className="absolute -inset-6 -z-10 rounded-[2.5rem] bg-brand-teal/10 blur-3xl" />
            <div className="relative overflow-hidden rounded-3xl border border-white/10 bg-white/[0.04] p-6 shadow-2xl backdrop-blur">
              <div className="flex items-center justify-between gap-3">
                <p className="text-xs font-semibold uppercase tracking-wider text-brand-mint">
                  Pizarra de fórmulas
                </p>
                <span className="rounded-full bg-brand-orange/20 px-3 py-1 text-[10px] font-bold uppercase tracking-wider text-brand-orange">
                  Trigonometría
                </span>
              </div>

              <div className="mt-5 rounded-2xl border border-white/10 bg-brand-deep/60 p-4">
                <svg
                  viewBox="0 0 340 210"
                  className="h-auto w-full"
                  role="img"
                  aria-label="Triángulo rectángulo con ángulo theta, catetos a y b, e hipotenusa c"
                >
                  <polygon
                    points="45,170 295,170 295,45"
                    fill="rgba(142,230,216,0.08)"
                    stroke="#8ee6d8"
                    strokeWidth="2.5"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M45 170 A 34 34 0 0 0 72 148"
                    fill="none"
                    stroke="#f26a0a"
                    strokeWidth="2.5"
                  />
                  <text
                    x="63"
                    y="162"
                    fill="#f26a0a"
                    fontSize="16"
                    fontWeight="700"
                  >
                    θ
                  </text>
                  <text x="165" y="192" fill="#cbd5e1" fontSize="15">
                    b
                  </text>
                  <text x="305" y="112" fill="#cbd5e1" fontSize="15">
                    a
                  </text>
                  <text x="160" y="103" fill="#8ee6d8" fontSize="15">
                    c
                  </text>
                </svg>
              </div>

              <div className="mt-5 grid grid-cols-2 gap-3">
                {formulas.map((item) => (
                  <div
                    key={item.label}
                    className="rounded-xl border border-white/10 bg-white/[0.03] px-4 py-3"
                  >
                    <p className="text-[10px] font-semibold uppercase tracking-wider text-brand-mint">
                      {item.label}
                    </p>
                    <p className="mt-1 text-sm font-semibold text-white">
                      {item.value}
                    </p>
                  </div>
                ))}
              </div>

              <div className="mt-3 flex items-center justify-between rounded-xl border border-white/10 bg-white/[0.03] px-4 py-3 text-sm text-slate-200">
                <span>
                  <span className="text-brand-mint">∫</span> x² dx = x³/3 + C
                </span>
                <span className="text-brand-orange">ƒ(x)</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Banda de datos */}
      <section className="bg-brand-mint">
        <div className="mx-auto grid max-w-6xl grid-cols-2 gap-x-6 gap-y-8 px-4 py-8 sm:grid-cols-4">
          {stats.map((stat) => (
            <div key={stat.label}>
              <p className="text-3xl font-extrabold tracking-tight text-brand-navy">
                {stat.value}
              </p>
              <p className="mt-1 text-xs font-semibold uppercase tracking-wide text-brand-navy/70">
                {stat.label}
              </p>
            </div>
          ))}
        </div>
      </section>

      {/* Cómo funciona */}
      <section id="como-funciona" className="bg-white">
        <div className="mx-auto max-w-6xl px-4 py-20">
          <div className="max-w-2xl">
            <p className="text-sm font-semibold uppercase tracking-wider text-brand-orange">
              Así de simple
            </p>
            <h2 className="mt-2 text-3xl font-bold tracking-tight text-brand-navy sm:text-4xl">
              Cómo funciona
            </h2>
            <p className="mt-3 text-slate-600">
              Tres pasos para empezar a practicar.
            </p>
          </div>

          <div className="mt-10 grid gap-5 md:grid-cols-3">
            {steps.map((step) => (
              <div
                key={step.number}
                className="rounded-2xl border border-slate-200 bg-slate-50 p-6"
              >
                <span className="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-brand-navy text-sm font-bold text-brand-mint">
                  {step.number}
                </span>
                <h3 className="mt-5 text-lg font-semibold text-brand-navy">
                  {step.title}
                </h3>
                <p className="mt-2 text-sm leading-relaxed text-slate-600">
                  {step.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA final */}
      <section className="bg-slate-50">
        <div className="mx-auto max-w-6xl px-4 py-16">
          <div className="relative overflow-hidden rounded-3xl bg-brand-navy px-6 py-14 text-center shadow-xl sm:px-12">
            <div className="absolute -right-20 -top-20 h-64 w-64 rounded-full bg-brand-teal/20 blur-3xl" />
            <div className="absolute -bottom-24 -left-20 h-64 w-64 rounded-full bg-brand-orange/20 blur-3xl" />
            <div className="relative">
              <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
                ¿Listo para practicar?
              </h2>
              <p className="mx-auto mt-3 max-w-xl text-slate-200">
                Crea tu cuenta y resuelve los módulos que te asigna tu docente
                con retroalimentación inmediata.
              </p>
              <div className="mt-8 flex flex-wrap justify-center gap-3">
                <Link
                  href="/register"
                  className="btn-brand px-6 py-3 text-base"
                >
                  Crear cuenta gratis
                </Link>
                <Link
                  href="/login"
                  className="btn-brand-outline px-6 py-3 text-base"
                >
                  Ingresar
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
