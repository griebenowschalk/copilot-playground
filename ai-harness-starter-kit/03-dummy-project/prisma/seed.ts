import { prisma } from "../src/db/client";

async function main() {
  await prisma.task.deleteMany();
  await prisma.task.createMany({
    data: [
      { title: "Review the API layer" },
      { title: "Add a due date field", done: true },
      { title: "Write a component test" },
    ],
  });
  console.log("Seeded tasks.");
}

main().finally(() => prisma.$disconnect());
