export type ExerciseType = "multiple_choice" | "numeric";

export type ModuleRow = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  order_index: number;
  is_published: boolean;
  created_at: string;
};

export type PublicExercise = {
  id: string;
  prompt: string;
  type: ExerciseType;
  options: string[] | null;
  order_index: number;
};

export type AdminExercise = PublicExercise & {
  module_id: string;
  correct_option: number | null;
  correct_answer: number | null;
  tolerance: number;
  explanation: string | null;
};

export type AttemptRow = {
  exercise_id: string;
  module_id: string;
  is_correct: boolean;
};

export type ProfileRow = {
  id: string;
  full_name: string | null;
  role: "student" | "admin";
};
