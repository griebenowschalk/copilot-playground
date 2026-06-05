import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AI Harness Demo",
  description: "Production AI harness for GitHub Copilot + Claude Code",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
