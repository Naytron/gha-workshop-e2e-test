#!/usr/bin/env bash
# Lab 10 helper — seed three well-scoped issues for Copilot coding agent.
# Run from anywhere inside your repository copy:
#   bash scripts/seed-issues.sh
# Requires: gh CLI authenticated with access to this repo.
set -euo pipefail

repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
echo "Seeding coding-agent issues in ${repo}..."

gh label create "agent-task" --color 8250DF \
  --description "Scoped task suitable for Copilot coding agent" 2>/dev/null || true

gh issue create \
  --title "Add a /version endpoint" \
  --label "agent-task,enhancement" \
  --body "$(cat <<'EOF'
## What

Add a `GET /version` endpoint to the sample app in `app/`.

## Acceptance criteria

- [ ] `GET /version` returns `200` with content-type `application/json`
- [ ] Response body is `{ "version": "<pkg version>", "sha": "<build sha>" }`,
      sourced the same way `/health` sources its build metadata
- [ ] Returns `"dev"` / `"local"` fallbacks when no build-info.json exists
- [ ] Tests added in `app/tests/` covering the happy path and the fallback
- [ ] No new npm dependencies

## Out of scope

Anything outside `app/`. Don't modify `/health`.
EOF
)"

gh issue create \
  --title "Include uptime in the /health payload" \
  --label "agent-task,enhancement" \
  --body "$(cat <<'EOF'
## What

Extend the `/health` endpoint's JSON payload with an `uptimeSeconds` field.

## Acceptance criteria

- [ ] `/health` response gains `"uptimeSeconds": <number>` (integer, rounded down)
- [ ] Value is derived from `process.uptime()`
- [ ] Existing fields (`status`, `version`, `sha`) are unchanged
- [ ] `healthPayload()` in `app/src/greeting.js` stays a pure function —
      pass uptime in as an argument rather than reading global state inside it
- [ ] Tests updated/added in `app/tests/`
- [ ] No new npm dependencies

## Hint

Look at how `server.js` already passes `buildInfo` into `healthPayload()`.
EOF
)"

gh issue create \
  --title "Reject absurdly long names in the greeting" \
  --label "agent-task,enhancement" \
  --body "$(cat <<'EOF'
## What

`GET /?name=...` currently accepts input of any length. Cap it.

## Acceptance criteria

- [ ] Names longer than 100 characters (after trimming) get a `400` response
      with a JSON error body `{ "error": "name too long" }`
- [ ] `buildGreeting()` itself stays pure — do the length check in the HTTP
      layer (`server.js`), or add a separate validation helper with tests
- [ ] Behavior for normal names and the empty/missing name is unchanged
- [ ] Tests added in `app/tests/` for: 100 chars (ok), 101 chars (rejected)
- [ ] No new npm dependencies
EOF
)"

echo ""
echo "Done. Three issues created:"
gh issue list --label "agent-task" --limit 5
echo ""
echo "Next (Lab 10): open one of these issues in the browser and assign it to Copilot."
