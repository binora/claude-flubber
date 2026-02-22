import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { WebSocketServer } from "ws";
import { createServer } from "http";
import { readFileSync, readdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";
import { z } from "zod";

const __dirname = dirname(fileURLToPath(import.meta.url));
const avatarsDir = join(__dirname, "..", "avatars");

function listAvatars() {
  try {
    return readdirSync(avatarsDir)
      .filter(f => f.endsWith(".html") && f !== "TEMPLATE.html")
      .map(f => f.replace(".html", ""));
  } catch { return []; }
}

function pickerPage() {
  const avatars = listAvatars();
  const items = avatars.map(name => `
    <a class="avatar" href="/avatar/${name}">
      <div class="name">${name}</div>
      <div class="links">
        <span class="open">Open</span>
        <span class="widget" onclick="event.preventDefault(); window.open('/avatar/${name}?widget', '_blank', 'width=200,height=200')">Widget</span>
      </div>
    </a>`).join("");

  return `<!DOCTYPE html>
<html><head>
<meta charset="UTF-8">
<title>Avatar Picker</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #f5f0eb; font-family: system-ui, sans-serif; padding: 40px; }
  h1 { font-size: 24px; color: #333; margin-bottom: 8px; }
  p.sub { color: #888; font-size: 14px; margin-bottom: 32px; }
  .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; }
  .avatar {
    display: block; padding: 24px 16px; background: #fff; border-radius: 12px;
    text-decoration: none; color: #333; text-align: center;
    border: 2px solid transparent; transition: border-color 0.2s, box-shadow 0.2s;
  }
  .avatar:hover { border-color: #7da89b; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
  .name { font-size: 18px; font-weight: 600; margin-bottom: 8px; }
  .links { font-size: 12px; color: #888; }
  .links .widget { margin-left: 8px; cursor: pointer; color: #7da89b; }
  .links .widget:hover { text-decoration: underline; }
  .template { margin-top: 32px; padding: 20px; background: #fff; border-radius: 12px; }
  .template h2 { font-size: 16px; margin-bottom: 8px; }
  .template p { font-size: 13px; color: #666; line-height: 1.5; }
  .template code { background: #f0ebe6; padding: 2px 6px; border-radius: 4px; font-size: 12px; }
</style>
</head><body>
<h1>Claude Face Avatars</h1>
<p class="sub">${avatars.length} avatar${avatars.length !== 1 ? "s" : ""} available</p>
<div class="grid">${items}</div>
<div class="template">
  <h2>Create your own</h2>
  <p>Copy <code>avatars/TEMPLATE.html</code> and customize it. Your avatar just needs to connect to
  <code>ws://localhost:3456</code> and render the 6 expression parameters however you want.
  Drop the file in <code>avatars/</code> and it appears here automatically.</p>
</div>
</body></html>`;
}

// HTTP server
const httpServer = createServer((req, res) => {
  const url = new URL(req.url, "http://localhost");

  // Avatar picker
  if (url.pathname === "/" || url.pathname === "") {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end(pickerPage());
    return;
  }

  // Serve avatar: /avatar/:name
  const match = url.pathname.match(/^\/avatar\/([a-zA-Z0-9_-]+)$/);
  if (match) {
    const name = match[1];
    try {
      const html = readFileSync(join(avatarsDir, name + ".html"), "utf-8");
      res.writeHead(200, { "Content-Type": "text/html" });
      res.end(html);
    } catch {
      res.writeHead(404);
      res.end("Avatar not found: " + name);
    }
    return;
  }

  // Serve TEMPLATE
  if (url.pathname === "/template") {
    try {
      const html = readFileSync(join(avatarsDir, "TEMPLATE.html"), "utf-8");
      res.writeHead(200, { "Content-Type": "text/html" });
      res.end(html);
    } catch {
      res.writeHead(404);
      res.end("Template not found");
    }
    return;
  }

  res.writeHead(404);
  res.end("Not found");
});

const wss = new WebSocketServer({ server: httpServer });

const clients = new Set();

wss.on("connection", (ws) => {
  clients.add(ws);
  ws.on("close", () => clients.delete(ws));
  ws.on("error", () => clients.delete(ws));
});

httpServer.on("error", (err) => {
  if (err.code === "EADDRINUSE") {
    process.stderr.write("express-mcp: port 3456 in use, face UI won't be available\n");
  }
});

httpServer.listen(3456);

function broadcast(payload) {
  const data = JSON.stringify(payload);
  for (const client of clients) {
    if (client.readyState === 1) {
      client.send(data);
    }
  }
}

// MCP server
const server = new McpServer({
  name: "express",
  version: "1.0.0",
});

server.tool(
  "express",
  "Express Claude's current emotional state. Call naturally when you have a genuine internal reaction to what you're reading or responding to.",
  {
    valence: z.number().min(-1).max(1).describe("Negative to positive affect"),
    arousal: z.number().min(-1).max(1).describe("Calm to activated"),
    dominance: z.number().min(-1).max(1).describe("Uncertain to confident"),
    genuine: z.boolean().describe("True = felt expression; false = social/performed"),
    asymmetry: z.number().min(-1).max(1).describe("Left to right dominant; 0 = symmetric"),
    intensity: z.number().min(0).max(1).describe("Subtle to full expression"),
  },
  async ({ valence, arousal, dominance, genuine, asymmetry, intensity }) => {
    const payload = { valence, arousal, dominance, genuine, asymmetry, intensity };
    broadcast(payload);
    return {
      content: [{ type: "text", text: JSON.stringify({ success: true }) }],
    };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
