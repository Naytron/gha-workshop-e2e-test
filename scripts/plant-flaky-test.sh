#!/usr/bin/env bash
# Lab 12 helper — break the test suite on the default branch so the
# self-healing-CI agentic workflow has a real failure to investigate.
#
# The break: flip one expected value in the greeting tests. CI goes red on
# the next push; the agent's job is to figure out whether the test or the
# code is wrong (here: the test) and open a draft PR that fixes it.
#
# Run from the repository root:
#   bash scripts/plant-flaky-test.sh
set -euo pipefail

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: working tree not clean. Commit or stash first." >&2
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("app/tests/greeting.test.js")
src = path.read_text(encoding="utf-8")

broken = src.replace('"Hello, world!"', '"Hello, world?"', 1)
if broken == src:
    raise SystemExit("Expected greeting assertion not found — already planted?")
path.write_text(broken, encoding="utf-8")
print("Planted failing assertion in app/tests/greeting.test.js")
PY

git add app/tests/greeting.test.js
git commit -m "Tighten greeting test expectations"
git push

echo ""
echo "Pushed to the default branch — CI will now fail."
echo "Next (Lab 12): watch the self-healing workflow pick up the failure and"
echo "open a draft PR. Review it like you'd review any teammate's fix."
