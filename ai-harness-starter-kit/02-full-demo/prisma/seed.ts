import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  await prisma.task.deleteMany();
  await prisma.task.createMany({
    data: [
      { title: "Open this repo in VS Code and ask Copilot to add a task field" },
      { title: "Run /review in Claude Code on a staged change" },
      { title: "Try the /figma skill against a frame", done: true },
    ],
  });
  console.log("Seeded tasks.");
}

main().finally(() => prisma.$disconnect());
