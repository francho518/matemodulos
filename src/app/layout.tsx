import type { Metadata } from "next";
import "katex/dist/katex.min.css";
import "./globals.css";
import { SiteHeader } from "@/components/site-header";

export const dynamic = "force-dynamic";

export const metadata: Metadata = {
  title: {
    default: "Matemódulos · Practica matemáticas",
    template: "%s · Matemódulos",
  },
  description:
    "Plataforma modular de ejercicios de matemáticas con corrección automática, progreso por usuario y panel de administración.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className="flex min-h-screen flex-col">
        <SiteHeader />
        <main className="flex-1">{children}</main>
        <footer className="border-t border-slate-200 bg-white">
          <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-2 px-4 py-6 text-sm text-slate-500 sm:flex-row">
            <p>
              Matemódulos · Hecho con Next.js, Supabase y mucho café.
            </p>
            <p>Gratis para siempre en su versión básica.</p>
          </div>
        </footer>
      </body>
    </html>
  );
}
