import assert from "node:assert/strict";
import { rm, writeFile } from "node:fs/promises";
import { test } from "node:test";

process.env.NODE_ENV = "test";

const buildInfoPath = new URL("../src/build-info.json", import.meta.url);

async function requestVersion(server) {
  await new Promise((resolve) => server.listen(0, resolve));
  const address = server.address();
  assert.notEqual(address, null);
  assert.equal(typeof address, "object");

  const res = await fetch(`http://127.0.0.1:${address.port}/version`);
  const json = await res.json();

  await new Promise((resolve, reject) =>
    server.close((error) => (error ? reject(error) : resolve()))
  );

  return { res, json };
}

test("GET /version returns fallback metadata when build info is missing", async () => {
  await rm(buildInfoPath, { force: true });

  const { server } = await import(`../src/server.js?fallback=${Date.now()}`);
  const { res, json } = await requestVersion(server);

  assert.equal(res.status, 200);
  assert.equal(res.headers.get("content-type"), "application/json");
  assert.deepEqual(json, { version: "dev", sha: "local" });
});

test("GET /version returns metadata from build-info.json", async () => {
  await writeFile(
    buildInfoPath,
    JSON.stringify({ version: "1.2.3+99", sha: "abc1234" })
  );

  try {
    const { server } = await import(`../src/server.js?happy=${Date.now()}`);
    const { res, json } = await requestVersion(server);

    assert.equal(res.status, 200);
    assert.equal(res.headers.get("content-type"), "application/json");
    assert.deepEqual(json, { version: "1.2.3+99", sha: "abc1234" });
  } finally {
    await rm(buildInfoPath, { force: true });
  }
});
