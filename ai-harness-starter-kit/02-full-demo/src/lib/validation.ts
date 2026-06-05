import { z } from "zod";

// All external input is validated before use (security.instructions.md).
export const createTaskInput = z.object({
  title: z.string().trim().min(1, "Title is required").max(200),
});

export const toggleTaskInput = z.object({
  id: z.string().min(1),
});

export type CreateTaskInput = z.infer<typeof createTaskInput>;
