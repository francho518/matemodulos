export type ActionState = {
  error?: string;
  success?: string;
};

export type AttemptState =
  | { status: "idle" }
  | { status: "correct"; message: string; explanation: string | null }
  | { status: "incorrect"; message: string; explanation: string | null }
  | { status: "error"; message: string };
