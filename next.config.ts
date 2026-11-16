import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // La guía de práctica lee el logo desde public/ en tiempo de ejecución.
  // Incluirlo en el bundle de la función asegura que esté disponible
  // también en el despliegue (por ejemplo, en Vercel).
  outputFileTracingIncludes: {
    "/modules/[slug]/guia": ["./public/images/crisfe-logo.png"],
  },
};

export default nextConfig;
