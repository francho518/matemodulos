export type ExerciseType = "multiple_choice" | "numeric";

export type ModuleRow = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  order_index: number;
  is_published: boolean;
  randomize_exercises: boolean;
  exercises_per_student: number;
  module_time_limit_minutes: number | null;
  question_time_limit_seconds: number | null;
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
  created_at: string;
};

export type ProfileRow = {
  id: string;
  full_name: string | null;
  email: string | null;
  role: "student" | "admin";
};

export type GroupRow = {
  id: string;
  name: string;
  description: string | null;
  created_at: string;
};

export type ModuleSessionRow = {
  id: string;
  user_id: string;
  module_id: string;
  started_at: string;
  expires_at: string | null;
  completed_at: string | null;
};

export type QuestionSessionRow = {
  id: string;
  module_session_id: string;
  exercise_id: string;
  started_at: string;
  expires_at: string | null;
  submitted_at: string | null;
};
