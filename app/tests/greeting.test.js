import { test } from "node:test";
import assert from "node:assert/strict";
import {
  buildGreeting,
  isProductionLike,
  healthPayload,
} from "../src/greeting.js";

test("buildGreeting greets a named visitor", () => {
  assert.equal(buildGreeting("Mona"), "Hello, Mona!");
});

test("buildGreeting trims surrounding whitespace", () => {
  assert.equal(buildGreeting("  Hubot  "), "Hello, Hubot!");
});

test("buildGreeting falls back to world for empty input", () => {
  assert.equal(buildGreeting(""), "Hello, world!");
  assert.equal(buildGreeting("   "), "Hello, world!");
  assert.equal(buildGreeting(undefined), "Hello, world!");
});

test("isProductionLike recognises production aliases", () => {
  assert.equal(isProductionLike("production"), true);
  assert.equal(isProductionLike("PROD"), true);
  assert.equal(isProductionLike("live"), true);
});

test("isProductionLike rejects non-production environments", () => {
  assert.equal(isProductionLike("staging"), false);
  assert.equal(isProductionLike(""), false);
  assert.equal(isProductionLike(undefined), false);
});

test("healthPayload reports ok with build metadata", () => {
  const payload = healthPayload({ version: "1.2.3", sha: "abc1234" });
  assert.deepEqual(payload, { status: "ok", version: "1.2.3", sha: "abc1234" });
});

test("healthPayload defaults when no build info is present", () => {
  assert.deepEqual(healthPayload(), {
    status: "ok",
    version: "dev",
    sha: "local",
  });
});
