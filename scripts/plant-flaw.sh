#!/usr/bin/env bash
# Lab 11 helper — plant a deliberately vulnerable change on a branch and open
# a PR, so CodeQL has something real to find and Copilot Autofix has
# something real to fix.
#
# The flaw: a new /echo endpoint that reflects user input into an HTML
# response without escaping — a classic reflected-XSS pattern (CWE-79).
#
# Run from the repository root:
#   bash scripts/plant-flaw.sh
# Requires: gh CLI authenticated, clean working tree.
set -euo pipefail

branch="lab11/reflected-input"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: working tree not clean. Commit or stash first." >&2
  exit 1
fi

default_branch="$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)"
git checkout -b "$branch" "$default_branch"

# Append the vulnerable route to server.js, just before the 404 handler.
python3 - <<'PY'
from pathlib import Path

path = Path("app/src/server.js")
src = path.read_text(encoding="utf-8")

vulnerable = '''
  if (url.pathname === "/echo") {
    // Echo back whatever the caller sent us. What could go wrong?
    const message = url.searchParams.get("message") ?? "";
    res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
    res.end(`<h1>You said:</h1><p>${message}</p>`);
    return;
  }

'''

marker = '  res.writeHead(404'
if "/echo" in src:
    print("The /echo route is already present; nothing to do.")
else:
    src = src.replace(marker, vulnerable + marker, 1)
    path.write_text(src, encoding="utf-8")
    print("Planted vulnerable /echo route in app/src/server.js")
PY

git add app/src/server.js
git commit -m "Add /echo endpoint that reflects the caller's message"
git push -u origin "$branch"

gh pr create \
  --title "Add /echo endpoint" \
  --body "$(cat <<'EOF'
Adds a small `/echo` endpoint that reflects the `message` query parameter
back to the caller as HTML.

*(Lab 11 note: this PR is intentionally flawed — it reflects untrusted input
into HTML without escaping. Let code scanning find it before you read the
diff too closely.)*
EOF
)"

git checkout "$default_branch"
echo ""
echo "PR opened. Next (Lab 11): wait for CodeQL to scan it, then review the"
echo "security alert and ask Copilot Autofix for a remediation."
