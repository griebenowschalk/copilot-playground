import { NextRequest, NextResponse } from "next/server";
import { createTaskInput, toggleTaskInput } from "@/lib/validation";
import { addTask, flipTask, getTasks } from "@/services/tasks";

function badRequest(message: string) {
  return NextResponse.json(
    { error: { code: "BAD_REQUEST", message } },
    { status: 400 },
  );
}

export async function GET() {
  const tasks = await getTasks();
  return NextResponse.json({ tasks });
}

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => null);
  const parsed = createTaskInput.safeParse(body);
  if (!parsed.success) return badRequest(parsed.error.issues[0]?.message ?? "Invalid input");

  const task = await addTask(parsed.data.title);
  return NextResponse.json({ task }, { status: 201 });
}

export async function PATCH(req: NextRequest) {
  const body = await req.json().catch(() => null);
  const parsed = toggleTaskInput.safeParse(body);
  if (!parsed.success) return badRequest("Invalid task id");

  await flipTask(parsed.data.id);
  return NextResponse.json({ ok: true });
}
