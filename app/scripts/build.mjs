/**
 * Build script: copies src/ into dist/ and stamps build metadata.
 * In CI, GITHUB_SHA and GITHUB_RUN_NUMBER are provided by the runner —
 * the labs use this to show artifacts carrying traceable build info.
 */
import { cp, mkdir, writeFile, readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";

const appRoot = fileURLToPath(new URL("..", import.meta.url));
const distDir = path.join(appRoot, "dist");

const pkg = JSON.parse(
  await readFile(path.join(appRoot, "package.json"), "utf8")
);

await mkdir(distDir, { recursive: true });
await cp(path.join(appRoot, "src"), path.join(distDir, "src"), {
  recursive: true,
});
await cp(
  path.join(appRoot, "package.json"),
  path.join(distDir, "package.json")
);

const buildInfo = {
  version: `${pkg.version}+${process.env.GITHUB_RUN_NUMBER ?? "0"}`,
  sha: (process.env.GITHUB_SHA ?? "local").slice(0, 7),
  builtAt: new Date().toISOString(),
};

await writeFile(
  path.join(distDir, "src", "build-info.json"),
  JSON.stringify(buildInfo, null, 2)
);

console.log("Built dist/ with build info:", buildInfo);
