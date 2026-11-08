export type ActionState = {
  error?: string;
  success?: string;
};

export type AttemptState =
  | { status: "idle" }
  | {
      status: "correct";
      message: string;
      explanation: string | null;
      points: number;
      attemptNumber: number;
    }
  | {
      status: "incorrect";
      message: string;
      explanation: string | null;
      attemptNumber: number;
      nextPoints: number;
    }
  | { status: "expired"; message: string }
  | { status: "locked"; message: string; explanation?: string | null }
  | { status: "error"; message: string };

export type TimingActionError = {
  ok: false;
  reason: "auth" | "not_found" | "module_expired" | "error";
  message: string;
  serverNow: string;
};

export type StartSessionResult =
  | {
      ok: true;
      serverNow: string;
      moduleExpiresAt: string | null;
      questionExpiresAt: string | null;
      questionSubmittedAt: string | null;
    }
  | TimingActionError;

export type ExpireQuestionResult =
  | {
      ok: true;
      serverNow: string;
      expired: boolean;
      alreadySubmitted: boolean;
    }
  | TimingActionError;
