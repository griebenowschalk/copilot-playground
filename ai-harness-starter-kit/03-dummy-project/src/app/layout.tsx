import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Tasks",
  description: "A small tasks app for harness setup testing",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
