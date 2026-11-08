import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { selectExercisesForStudent } from "@/lib/exercise-selection";
import { scoreByExercise } from "@/lib/scoring";
import { slugify } from "@/lib/utils";
import type { ModuleRow } from "@/lib/types";

export const dynamic = "force-dynamic";

type StudentProfile = {
  id: string;
  full_name: string | null;
  email: string | null;
};

type ExportAttempt = {
  user_id: string;
  module_id: string;
  exercise_id: string;
  is_correct: boolean;
  created_at: string;
};

type ExportExercise = {
  id: string;
  module_id: string;
  order_index: number;
};

function csvText(value: string | null | undefined) {
  const text = value ?? "";
  return `"${text.replace(/"/g, '""')}"`;
}

function csvNumber(value: number) {
  return String(value);
}

function csvDecimal(value: number) {
  return value.toFixed(2).replace(".", ",");
}

type StudentModuleStats = {
  module: ModuleRow;
  total: number;
  solved: number;
  points: number;
  grade: number | null;
  percentage: number | null;
};

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> },
) {
  const { id } = await params;
  const format = new URL(request.url).searchParams.get("formato");
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json(
      { error: "No autenticado." },
      { status: 401 },
    );
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  if (profile?.role !== "admin") {
    return NextResponse.json(
      { error: "No autorizado." },
      { status: 403 },
    );
  }

  const { data: group } = await supabase
    .from("groups")
    .select("id, name")
    .eq("id", id)
    .maybeSingle();

  if (!group) {
    return NextResponse.json(
      { error: "Grupo no encontrado." },
      { status: 404 },
    );
  }

  const { data: memberships } = await supabase
    .from("group_members")
    .select("user_id")
    .eq("group_id", id);

  const userIds = (memberships ?? []).map((row) => row.user_id);

  let students: StudentProfile[] = [];

  if (userIds.length > 0) {
    const { data } = await supabase
      .from("profiles")
      .select("id, full_name, email")
      .in("id", userIds);

    students = (data ?? []) as StudentProfile[];
  }

  students.sort((a, b) =>
    (a.full_name ?? "").localeCompare(b.full_name ?? "", "es"),
  );

  const { data: assignments } = await supabase
    .from("group_modules")
    .select("module_id")
    .eq("group_id", id);

  const assignedModuleIds = (assignments ?? []).map((row) => row.module_id);

  // Solo se exportan los módulos asignados al grupo. Un módulo sin
  // grupo no es visible para ningún estudiante.
  let modules: ModuleRow[] = [];

  if (assignedModuleIds.length > 0) {
    const { data } = await supabase
      .from("modules")
      .select("*")
      .in("id", assignedModuleIds)
      .order("order_index", { ascending: true })
      .order("created_at", { ascending: true });

    modules = (data ?? []) as ModuleRow[];
  }

  const moduleIds = modules.map((module) => module.id);

  let exercises: ExportExercise[] = [];
  let attempts: ExportAttempt[] = [];

  if (moduleIds.length > 0) {
    const { data: exerciseData } = await supabase
      .from("exercises")
      .select("id, module_id, order_index")
      .in("module_id", moduleIds);

    exercises = (exerciseData ?? []) as ExportExercise[];

    if (userIds.length > 0) {
      const { data: attemptData } = await supabase
        .from("attempts")
        .select("user_id, module_id, exercise_id, is_correct, created_at")
        .in("user_id", userIds)
        .in("module_id", moduleIds);

      attempts = (attemptData ?? []) as ExportAttempt[];
    }
  }

  const exercisesByModule = new Map<string, ExportExercise[]>();

  for (const exercise of exercises) {
    if (!exercisesByModule.has(exercise.module_id)) {
      exercisesByModule.set(exercise.module_id, []);
    }
    exercisesByModule.get(exercise.module_id)!.push(exercise);
  }

  const attemptsByStudentModule = new Map<string, ExportAttempt[]>();

  for (const attempt of attempts) {
    const key = `${attempt.user_id}:${attempt.module_id}`;

    if (!attemptsByStudentModule.has(key)) {
      attemptsByStudentModule.set(key, []);
    }
    attemptsByStudentModule.get(key)!.push(attempt);
  }

  const statsFor = (studentId: string): StudentModuleStats[] => {
    return modules.map((module) => {
      const assigned = selectExercisesForStudent(
        exercisesByModule.get(module.id) ?? [],
        studentId,
        module.id,
        Boolean(module.randomize_exercises),
        Number(module.exercises_per_student) || 0,
      );

      const assignedIds = new Set(
        assigned.map((exercise) => exercise.id),
      );

      const studentAttempts =
        attemptsByStudentModule.get(`${studentId}:${module.id}`) ?? [];

      const relevantAttempts = studentAttempts.filter((attempt) =>
        assignedIds.has(attempt.exercise_id),
      );

      const solved = new Set(
        relevantAttempts
          .filter((attempt) => attempt.is_correct)
          .map((attempt) => attempt.exercise_id),
      );

      const scores = scoreByExercise(relevantAttempts);

      const total = assigned.length;
      const solvedCount = solved.size;
      const points = assigned.reduce(
        (sum, exercise) => sum + (scores.get(exercise.id) ?? 0),
        0,
      );

      return {
        module,
        total,
        solved: solvedCount,
        points,
        grade: total > 0 ? (points / total) * 10 : null,
        percentage: total > 0 ? (points / total) * 100 : null,
      };
    });
  };

  const lines: string[] = [];

  if (format === "detalle") {
    lines.push(
      [
        "Grupo",
        "Estudiante",
        "Correo",
        "Módulo",
        "Ejercicios asignados",
        "Ejercicios resueltos",
        "Puntos obtenidos",
        "Puntaje máximo",
        "Nota (0-10)",
        "Porcentaje (%)",
      ]
        .map(csvText)
        .join(";"),
    );

    for (const student of students) {
      for (const stats of statsFor(student.id)) {
        lines.push(
          [
            csvText(group.name),
            csvText(student.full_name ?? "Sin nombre"),
            csvText(student.email ?? ""),
            csvText(stats.module.title),
            csvNumber(stats.total),
            csvNumber(stats.solved),
            csvDecimal(stats.points),
            csvNumber(stats.total),
            stats.grade === null ? "" : csvDecimal(stats.grade),
            stats.percentage === null
              ? ""
              : csvDecimal(stats.percentage),
          ].join(";"),
        );
      }
    }
  } else {
    // Planilla: una fila por estudiante y una columna de nota/porcentaje
    // por cada módulo asignado al grupo.
    const header = ["Grupo", "Estudiante", "Correo"];

    for (const module of modules) {
      header.push(`${module.title} · Nota (0-10)`);
      header.push(`${module.title} · %`);
    }

    header.push("Promedio (0-10)");
    lines.push(header.map(csvText).join(";"));

    for (const student of students) {
      const stats = statsFor(student.id);
      const row = [
        csvText(group.name),
        csvText(student.full_name ?? "Sin nombre"),
        csvText(student.email ?? ""),
      ];

      let sum = 0;
      let counted = 0;

      for (const item of stats) {
        row.push(item.grade === null ? "" : csvDecimal(item.grade));
        row.push(
          item.percentage === null ? "" : csvDecimal(item.percentage),
        );

        if (item.grade !== null) {
          sum += item.grade;
          counted += 1;
        }
      }

      row.push(counted > 0 ? csvDecimal(sum / counted) : "");
      lines.push(row.join(";"));
    }
  }

  const csv = `\ufeff${lines.join("\r\n")}\r\n`;
  const date = new Date().toISOString().slice(0, 10);
  const filePrefix = format === "detalle" ? "detalle-notas" : "planilla-notas";
  const fileName = `${filePrefix}-${slugify(group.name) || "grupo"}-${date}.csv`;

  return new NextResponse(csv, {
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="${fileName}"; filename*=UTF-8''${encodeURIComponent(
        fileName,
      )}`,
      "Cache-Control": "no-store",
    },
  });
}
