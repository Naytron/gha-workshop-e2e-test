/**
 * Minimal HTTP server built on node:http — no frameworks, no dependencies.
 * Routes:
 *   GET /            → greeting (optional ?name= query parameter)
 *   GET /health      → JSON health payload with build metadata
 */
import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { buildGreeting, healthPayload } from "./greeting.js";

const PORT = Number(process.env.PORT ?? 3000);

async function loadBuildInfo() {
  try {
    // Written by `npm run build` (scripts/build.mjs); absent in local dev.
    const raw = await readFile(
      new URL("./build-info.json", import.meta.url),
      "utf8"
    );
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

const buildInfo = await loadBuildInfo();

export const server = createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host ?? "localhost"}`);

  if (url.pathname === "/health") {
    res.writeHead(200, { "content-type": "application/json" });
    res.end(JSON.stringify(healthPayload(buildInfo)));
    return;
  }

  if (url.pathname === "/") {
    res.writeHead(200, { "content-type": "text/plain; charset=utf-8" });
    res.end(buildGreeting(url.searchParams.get("name")));
    return;
  }

  res.writeHead(404, { "content-type": "application/json" });
  res.end(JSON.stringify({ error: "not found" }));
});

if (process.env.NODE_ENV !== "test") {
  server.listen(PORT, () => {
    console.log(`actions-workshop-app listening on http://localhost:${PORT}`);
  });
}
