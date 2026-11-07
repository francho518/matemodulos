"use client";

type Props = {
  message: string;
  className?: string;
  children: React.ReactNode;
};

/**
 * Botón de envío que pide confirmación antes de ejecutar una acción
 * destructiva (por ejemplo, eliminar un módulo).
 */
export function ConfirmButton({ message, className, children }: Props) {
  return (
    <button
      type="submit"
      className={className}
      onClick={(event) => {
        if (!window.confirm(message)) {
          event.preventDefault();
        }
      }}
    >
      {children}
    </button>
  );
}
