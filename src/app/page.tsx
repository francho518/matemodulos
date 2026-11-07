import Link from "next/link";
import { MathText } from "@/components/math-text";

const features = [
  {
    icon: "🧩",
    title: "Temas modulares",
    description:
      "Cada tema es un módulo independiente. Agrega álgebra, cálculo, geometría o lo que necesites sin tocar el código.",
  },
  {
    icon: "✅",
    title: "Corrección automática",
    description:
      "Ejercicios de opción múltiple y respuesta numérica con tolerancia configurable y explicación de la solución.",
  },
  {
    icon: "📈",
    title: "Progreso por usuario",
    description:
      "Cada estudiante inicia sesión y ve su avance: ejercicios resueltos, porcentaje completado y precisión.",
  },
  {
    icon: "🛠️",
    title: "Panel de administración",
    description:
      "Crea módulos, publica ejercicios y gestiona el contenido desde la web, con roles de alumno y administrador.",
  },
];

const steps = [
  {
    number: "01",
    title: "Crea tu cuenta",
    description: "Regístrate con tu correo y accede a todos los módulos publicados.",
  },
  {
    number: "02",
    title: "Elige un módulo",
    description: "Cada módulo agrupa ejercicios de un tema con dificultad progresiva.",
  },
  {
    number: "03",
    title: "Practica y aprende",
    description: "Responde, recibe retroalimentación inmediata y sigue tu progreso.",
  },
];

export default function HomePage() {
  return (
    <div className="overflow-hidden">
      {/* Hero */}
      <section className="bg-gradient-to-b from-indigo-50 via-white to-slate-50">
        <div className="mx-auto grid max-w-6xl items-center gap-12 px-4 py-20 lg:grid-cols-2 lg:py-28">
          <div>
            <span className="badge bg-indigo-100 text-indigo-700">
              Gratis · Código abierto · En la nube
            </span>

            <h1 className="mt-5 text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
              Practica matemáticas{" "}
              <span className="text-indigo-600">a tu ritmo</span>.
            </h1>

            <p className="mt-6 max-w-xl text-lg leading-relaxed text-slate-600">
              Una plataforma modular de ejercicios con corrección automática.
              Crea temas nuevos, invita a tus estudiantes y observa su progreso
              desde un solo lugar.
            </p>

            <div className="mt-8 flex flex-wrap gap-3">
              <Link href="/register" className="btn-primary px-6 py-3 text-base">
                Empezar gratis
              </Link>
              <Link href="/login" className="btn-secondary px-6 py-3 text-base">
                Ya tengo cuenta
              </Link>
            </div>

            <p className="mt-4 text-sm text-slate-500">
              Sin tarjeta de crédito. Se despliega gratis en Vercel y Supabase.
            </p>
          </div>

          {/* Tarjeta de ejemplo */}
          <div className="relative">
            <div className="absolute -inset-4 -z-10 rounded-[2rem] bg-gradient-to-tr from-indigo-200/60 to-sky-200/40 blur-2xl" />
            <div className="card space-y-6 p-6 sm:p-8">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-wider text-indigo-600">
                    Módulo de ejemplo
                  </p>
                  <h2 className="mt-1 text-xl font-bold text-slate-900">
                    Álgebra básica
                  </h2>
                </div>
                <span className="badge bg-emerald-100 text-emerald-700">
                  2 de 4 resueltos
                </span>
              </div>

              <div className="h-2 overflow-hidden rounded-full bg-slate-100">
                <div className="h-full w-1/2 rounded-full bg-indigo-600" />
              </div>

              <div className="rounded-xl border border-slate-200 bg-slate-50 p-4">
                <p className="text-sm font-medium text-slate-500">
                  Ejercicio 2
                </p>
                <p className="mt-2 text-slate-800">
                  <MathText>
                    {"Escribe la mayor solución de $x^2 - 5x + 6 = 0$."}
                  </MathText>
                </p>

                <div className="mt-4 flex items-center gap-2">
                  <div className="flex-1 rounded-lg border border-indigo-300 bg-white px-3 py-2 text-sm font-semibold text-slate-700">
                    3
                  </div>
                  <span className="badge bg-emerald-100 text-emerald-700">
                    Correcto
                  </span>
                </div>

                <p className="mt-3 text-sm text-slate-500">
                  Factorizamos: <MathText>{"$(x - 2)(x - 3) = 0$"}</MathText>
                </p>
              </div>

              <div className="flex items-center justify-between text-sm text-slate-500">
                <span>Precisión: 100 %</span>
                <span className="font-semibold text-indigo-600">
                  Continuar →
                </span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Características */}
      <section className="mx-auto max-w-6xl px-4 py-20">
        <div className="max-w-2xl">
          <p className="text-sm font-semibold uppercase tracking-wider text-indigo-600">
            Todo lo que necesitas
          </p>
          <h2 className="mt-2 text-3xl font-bold tracking-tight text-slate-900 sm:text-4xl">
            Un servidor de ejercicios pensado para crecer
          </h2>
        </div>

        <div className="mt-10 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {features.map((feature) => (
            <div key={feature.title} className="card p-6">
              <span className="text-2xl" aria-hidden="true">
                {feature.icon}
              </span>
              <h3 className="mt-4 font-semibold text-slate-900">
                {feature.title}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-slate-600">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </section>

      {/* Cómo funciona */}
      <section className="border-y border-slate-200 bg-white">
        <div className="mx-auto max-w-6xl px-4 py-20">
          <h2 className="text-center text-3xl font-bold tracking-tight text-slate-900">
            Cómo funciona
          </h2>

          <div className="mt-12 grid gap-8 md:grid-cols-3">
            {steps.map((step) => (
              <div key={step.number} className="relative">
                <span className="text-4xl font-extrabold text-indigo-100">
                  {step.number}
                </span>
                <h3 className="mt-2 text-lg font-semibold text-slate-900">
                  {step.title}
                </h3>
                <p className="mt-1 text-sm leading-relaxed text-slate-600">
                  {step.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA final */}
      <section className="mx-auto max-w-6xl px-4 py-20">
        <div className="rounded-3xl bg-indigo-600 px-6 py-14 text-center shadow-xl shadow-indigo-200 sm:px-12">
          <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
            ¿Listo para practicar?
          </h2>
          <p className="mx-auto mt-3 max-w-xl text-indigo-100">
            Crea tu cuenta, elige un módulo y empieza a resolver ejercicios con
            retroalimentación inmediata.
          </p>
          <div className="mt-8 flex flex-wrap justify-center gap-3">
            <Link
              href="/register"
              className="inline-flex items-center justify-center rounded-lg bg-white px-6 py-3 text-base font-semibold text-indigo-700 transition hover:bg-indigo-50"
            >
              Crear cuenta gratis
            </Link>
            <Link
              href="/login"
              className="inline-flex items-center justify-center rounded-lg border border-indigo-300/60 px-6 py-3 text-base font-semibold text-white transition hover:bg-indigo-500"
            >
              Ingresar
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
