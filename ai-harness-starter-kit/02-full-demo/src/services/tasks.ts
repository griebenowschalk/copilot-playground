import { createTask, listTasks, toggleTask, type TaskRecord } from "@/db/repos/tasks";

export async function getTasks(): Promise<TaskRecord[]> {
  return listTasks();
}

export async function addTask(title: string): Promise<TaskRecord> {
  return createTask(title);
}

export async function flipTask(id: string): Promise<void> {
  return toggleTask(id);
}
