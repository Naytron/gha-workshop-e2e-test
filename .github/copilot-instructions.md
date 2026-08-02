# Copilot instructions for this repository

This is a **workshop repository** for learning GitHub Actions and agentic
DevOps. It contains a tiny zero-dependency Node.js service in `app/` plus lab
guides, solution workflows, and custom-action scaffolds.

## Repository layout

- `app/` — the sample service. All application changes happen here.
- `labs/` — attendee-facing lab guides. Don't edit unless asked.
- `solutions/` — reference workflow YAML. Don't edit unless asked.
- `.github/workflows/` — live workflows. New workflows must follow the
  conventions below.

## Application conventions (`app/`)

- **Zero runtime dependencies.** Never add packages to `dependencies`.
  The standard library (`node:http`, `node:test`, etc.) covers everything
  this app needs. This keeps workshop CI runs fast and cheap.
- ES modules only (`"type": "module"`); use `import`, never `require`.
- Tests use the built-in `node:test` runner and live in `app/tests/`.
  Run them with `npm test` from the `app/` directory.
- Pure logic goes in `app/src/greeting.js` (or a new module beside it);
  HTTP wiring stays in `app/src/server.js`. Keep handlers thin.
- Every behavior change needs a matching test in `app/tests/`.
- JSON endpoints return `content-type: application/json`; unknown routes
  return `404` with a JSON error body.

## Workflow conventions (`.github/workflows/`)

- Pin third-party and first-party actions to a **full commit SHA** with the
  version tag as a trailing comment.
- Declare least-privilege `permissions:` at the top of every workflow.
- Every job sets `timeout-minutes`.
- CI-style workflows use a `concurrency` group with `cancel-in-progress: true`.

## Validation before finishing

From the `app/` directory:

```bash
npm ci
npm test
npm run build
```

All three must pass. If you changed workflow YAML, ensure it parses.
