import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        brand: {
          navy: "#0b2a4a",
          deep: "#061a30",
          teal: "#13b8a6",
          mint: "#8ee6d8",
          orange: "#f26a0a",
          "orange-dark": "#d95a00",
        },
      },
    },
  },
  plugins: [],
};

export default config;
