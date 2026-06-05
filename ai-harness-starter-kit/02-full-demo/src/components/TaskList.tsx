"use client";

import { useState } from "react";

export interface Task {
  id: string;
  title: string;
  done: boolean;
}

export interface TaskListProps {
  initialTasks: Task[];
}

export function TaskList({ initialTasks }: TaskListProps) {
  const [tasks, setTasks] = useState<Task[]>(initialTasks);
  const [title, setTitle] = useState("");
  const [error, setError] = useState<string | null>(null);

  async function add() {
    setError(null);
    const res = await fetch("/api/tasks", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title }),
    });
    if (!res.ok) {
      const data = await res.json();
      setError(data?.error?.message ?? "Something went wrong");
      return;
    }
    const { task } = await res.json();
    setTasks((prev) => [task, ...prev]);
    setTitle("");
  }

  async function toggle(id: string) {
    setTasks((prev) => prev.map((t) => (t.id === id ? { ...t, done: !t.done } : t)));
    await fetch("/api/tasks", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id }),
    });
  }

  return (
    <section className="mt-10">
      <div className="flex gap-2">
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && title.trim() && add()}
          placeholder="Add a task…"
          className="flex-1 rounded-lg border border-neutral-700 bg-neutral-900 px-3 py-2 text-sm outline-none focus:border-neutral-500"
        />
        <button
          onClick={add}
          disabled={!title.trim()}
          className="rounded-lg bg-neutral-100 px-4 py-2 text-sm font-medium text-neutral-900 disabled:opacity-40"
        >
          Add
        </button>
      </div>
      {error && <p className="mt-2 text-sm text-red-400">{error}</p>}

      <ul className="mt-6 space-y-2">
        {tasks.map((task) => (
          <li
            key={task.id}
            className="flex items-center gap-3 rounded-lg border border-neutral-800 bg-neutral-900/50 px-4 py-3"
          >
            <input
              type="checkbox"
              checked={task.done}
              onChange={() => toggle(task.id)}
              className="h-4 w-4"
            />
            <span className={task.done ? "text-neutral-500 line-through" : ""}>{task.title}</span>
          </li>
        ))}
      </ul>
    </section>
  );
}
