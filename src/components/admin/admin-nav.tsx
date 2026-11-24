"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const items = [
  {
    href: "/admin",
    label: "Módulos",
    isActive: (path: string) =>
      path === "/admin" ||
      (path.startsWith("/admin/modules/") && path !== "/admin/modules/new"),
  },
  {
    href: "/admin/modules/new",
    label: "Nuevo módulo",
    isActive: (path: string) => path === "/admin/modules/new",
  },
  {
    href: "/admin/groups",
    label: "Grupos",
    isActive: (path: string) => path.startsWith("/admin/groups"),
  },
  {
    href: "/admin/users",
    label: "Usuarios",
    isActive: (path: string) => path.startsWith("/admin/users"),
  },
  {
    href: "/admin/evaluaciones",
    label: "Evaluaciones",
    isActive: (path: string) => path.startsWith("/admin/evaluaciones"),
  },
];

export function AdminNav() {
  const pathname = usePathname();

  return (
    <nav className="mt-6 flex flex-wrap gap-1 border-b border-slate-200">
      {items.map((item) => {
        const active = item.isActive(pathname);

        return (
          <Link
            key={item.href}
            href={item.href}
            aria-current={active ? "page" : undefined}
            className={
              active
                ? "border-b-2 border-indigo-600 px-4 py-2 text-sm font-semibold text-indigo-600"
                : "border-b-2 border-transparent px-4 py-2 text-sm font-medium text-slate-500 transition hover:text-slate-800"
            }
          >
            {item.label}
          </Link>
        );
      })}
    </nav>
  );
}
