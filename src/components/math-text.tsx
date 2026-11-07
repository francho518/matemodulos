import katex from "katex";

/**
 * Renderiza texto que puede contener fórmulas LaTeX entre $...$
 * o $$...$$. El resto del texto se muestra normal.
 */
export function MathText({ children }: { children: string }) {
  const parts = children.split(/(\$\$[\s\S]+?\$\$|\$[^$]+\$)/g);

  return (
    <>
      {parts.map((part, index) => {
        if (part.startsWith("$$") && part.endsWith("$$") && part.length > 4) {
          const html = katex.renderToString(part.slice(2, -2), {
            throwOnError: false,
            displayMode: true,
            strict: false,
          });

          return (
            <span
              key={index}
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        }

        if (part.startsWith("$") && part.endsWith("$") && part.length > 2) {
          const html = katex.renderToString(part.slice(1, -1), {
            throwOnError: false,
            displayMode: false,
            strict: false,
          });

          return (
            <span
              key={index}
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        }

        return <span key={index}>{part}</span>;
      })}
    </>
  );
}
