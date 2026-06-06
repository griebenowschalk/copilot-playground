import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { TaskList } from "./TaskList";

describe("TaskList", () => {
  beforeEach(() => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ task: { id: "new", title: "Buy milk", done: false } }),
    }) as unknown as typeof fetch;
  });

  it("renders the initial tasks", () => {
    render(<TaskList initialTasks={[{ id: "1", title: "Existing", done: false }]} />);
    expect(screen.getByText("Existing")).toBeDefined();
  });

  it("adds a task and clears the input", async () => {
    render(<TaskList initialTasks={[]} />);
    const input = screen.getByPlaceholderText("Add a task…") as HTMLInputElement;
    fireEvent.change(input, { target: { value: "Buy milk" } });
    fireEvent.click(screen.getByText("Add"));
    await waitFor(() => expect(screen.getByText("Buy milk")).toBeDefined());
    expect(input.value).toBe("");
  });

  it("shows an error when the API rejects input", async () => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: false,
      json: async () => ({ error: { code: "BAD_REQUEST", message: "Title is required" } }),
    }) as unknown as typeof fetch;
    render(<TaskList initialTasks={[]} />);
    fireEvent.change(screen.getByPlaceholderText("Add a task…"), { target: { value: "x" } });
    fireEvent.click(screen.getByText("Add"));
    await waitFor(() => expect(screen.getByText("Title is required")).toBeDefined());
  });
});
