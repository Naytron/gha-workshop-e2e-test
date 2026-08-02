/**
 * Pure business logic for the workshop app. Deliberately dependency-free so
 * `npm ci` is instant and CI runs stay fast and cheap during the labs.
 */

/**
 * Build a greeting for a visitor.
 * @param {string} name - Who to greet.
 * @returns {string}
 */
export function buildGreeting(name) {
  const trimmed = (name ?? "").trim();
  if (trimmed.length === 0) {
    return "Hello, world!";
  }
  return `Hello, ${trimmed}!`;
}

/**
 * Classify a deployment environment string as production-like or not.
 * Used by the capstone lab to demonstrate branching logic worth testing.
 * @param {string} environment
 * @returns {boolean}
 */
export function isProductionLike(environment) {
  return ["production", "prod", "live"].includes(
    (environment ?? "").trim().toLowerCase()
  );
}

/**
 * Payload returned by the /health endpoint.
 * @param {{ version?: string, sha?: string }} [buildInfo]
 * @returns {{ status: string, version: string, sha: string }}
 */
export function healthPayload(buildInfo = {}) {
  return {
    status: "ok",
    version: buildInfo.version ?? "dev",
    sha: buildInfo.sha ?? "local",
  };
}
