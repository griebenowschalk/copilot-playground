import { prisma } from "@/db/client";

export interface TaskRecord {
  id: string;
  title: string;
  done: boolean;
  createdAt: Date;
}

const notDeleted = { deletedAt: null };

export async function listTasks(): Promise<TaskRecord[]> {
  const rows = await prisma.task.findMany({
    where: notDeleted,
    orderBy: { createdAt: "desc" },
  });
  return rows.map(({ id, title, done, createdAt }) => ({ id, title, done, createdAt }));
}

export async function createTask(title: string): Promise<TaskRecord> {
  const { id, done, createdAt } = await prisma.task.create({ data: { title } });
  return { id, title, done, createdAt };
}

export async function toggleTask(id: string): Promise<void> {
  const task = await prisma.task.findFirst({ where: { id, ...notDeleted } });
  if (!task) return;
  await prisma.task.update({ where: { id }, data: { done: !task.done } });
}
