#!/usr/bin/env node

import { cpSync, mkdirSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));

if (process.argv.includes("--install-skill")) {
  const src = join(__dirname, "..", "express", "SKILL.md");
  const dest = join(process.cwd(), ".claude", "skills", "SKILL.md");
  mkdirSync(dirname(dest), { recursive: true });
  cpSync(src, dest);
  console.log("Installed SKILL.md → .claude/skills/SKILL.md");
  process.exit(0);
}

await import("../express-mcp-server/index.js");
