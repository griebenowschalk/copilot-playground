import { getTasks } from "@/services/tasks";
import { TaskList } from "@/components/TaskList";

export default async function Home() {
  const tasks = await getTasks();
  return (
    <main className="mx-auto max-w-2xl px-6 py-16">
      <h1 className="text-3xl font-semibold tracking-tight">AI Harness Demo</h1>
      <p className="mt-2 text-sm text-neutral-400">
        A tiny tasks app whose code conventions are enforced by the AI harness in
        this repo. Open <code className="text-neutral-200">docs/harness-explorer.html</code> for the tour.
      </p>
      <TaskList initialTasks={tasks.map((t) => ({ id: t.id, title: t.title, done: t.done }))} />
    </main>
  );
}
