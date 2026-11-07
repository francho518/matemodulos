import Link from "next/link";

export default function NotFound() {
  return (
    <div className="mx-auto flex max-w-xl flex-col items-center px-4 py-24 text-center">
      <span className="text-6xl font-extrabold text-indigo-200">404</span>
      <h1 className="mt-4 text-2xl font-bold text-slate-900">
        No encontramos esta página
      </h1>
      <p className="mt-2 text-slate-600">
        Puede que el módulo no exista, esté despublicado o que el enlace sea
        incorrecto.
      </p>
      <Link href="/dashboard" className="btn-primary mt-8">
        Ir a mis módulos
      </Link>
    </div>
  );
}
