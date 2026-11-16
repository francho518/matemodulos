"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { startModuleSession } from "@/app/modules/actions";

type Props = {
  moduleId: string;
  moduleTimeLimitMinutes: number | null;
  questionTimeLimitSeconds: number | null;
};

/**
 * El reloj del módulo no arranca al abrir la página: el estudiante debe
 * pulsar “Iniciar módulo”. Hasta entonces puede leer las instrucciones o
 * descargar la guía de práctica sin gastar tiempo.
 */
export function StartModuleButton({
  moduleId,
  moduleTimeLimitMinutes,
  questionTimeLimitSeconds,
}: Props) {
  const router = useRouter();
  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const minutes = Number(moduleTimeLimitMinutes) || 0;
  const seconds = Number(questionTimeLimitSeconds) || 0;

  async function handleStart() {
    setPending(true);
    setError(null);

    try {
      const result = await startModuleSession(moduleId);

      if (!result.ok) {
        setError(result.message);
        setPending(false);
        return;
      }

      // Al refrescar, la página ya ve la sesión y muestra el módulo con
      // el cronómetro corriendo desde este momento.
      router.refresh();
    } catch {
      setError("No se pudo iniciar el módulo. Inténtalo de nuevo.");
      setPending(false);
    }
  }

  return (
    <div className="card border-amber-200 bg-amber-50/60 p-6 text-center sm:p-8">
      <p className="text-4xl" aria-hidden="true">
        ⏱
      </p>
      <h2 className="mt-3 text-xl font-bold text-slate-900">
        ¿Listo para comenzar?
      </h2>
      <p className="mx-auto mt-2 max-w-xl text-sm text-slate-600">
        El tiempo empezará a contar cuando pulses{" "}
        <span className="font-semibold text-slate-800">Iniciar módulo</span>.
        Antes de eso puedes leer las instrucciones y descargar tu guía de
        práctica.
      </p>

      <div className="mt-4 flex flex-wrap items-center justify-center gap-2">
        {minutes > 0 && (
          <span className="badge bg-amber-100 text-amber-800">
            ⏱ Tiempo del módulo: {minutes} min
          </span>
        )}
        {seconds > 0 && (
          <span className="badge bg-amber-100 text-amber-800">
            ⏱ Por pregunta: {seconds} s
          </span>
        )}
      </div>

      <button
        type="button"
        onClick={handleStart}
        disabled={pending}
        className="btn-primary mt-6"
      >
        {pending ? "Iniciando…" : "▶ Iniciar módulo"}
      </button>

      <p className="mt-3 text-xs text-slate-500">
        Una vez iniciado, el cronómetro no se puede pausar.
      </p>

      {error && (
        <p className="mx-auto mt-4 max-w-lg rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </p>
      )}
    </div>
  );
}
