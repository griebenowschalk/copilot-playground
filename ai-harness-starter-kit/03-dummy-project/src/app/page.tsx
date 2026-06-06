import { getTasks } from "@/services/tasks";
import { TaskList } from "@/components/TaskList";

export default async function Home() {
  const tasks = await getTasks();
  return (
    <main className="mx-auto max-w-2xl px-6 py-16">
      <h1 className="text-3xl font-semibold tracking-tight">Tasks</h1>
      <p className="mt-2 text-sm text-neutral-400">
        A small layered app — UI, API, services, and repositories — with no AI harness yet.
      </p>
      <TaskList initialTasks={tasks.map((t) => ({ id: t.id, title: t.title, done: t.done }))} />
    </main>
  );
}
