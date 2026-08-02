# AGENTS.md

Guidance for AI coding agents working in this repository. (Human? You want
[README.md](README.md).) These instructions apply repo-wide and complement
`.github/copilot-instructions.md` — if the two disagree, this file wins for
agent behavior, that file wins for code style.

## What this repo is

A GitHub Actions workshop: a tiny Node.js service (`app/`) that lab attendees
build CI/CD pipelines around, plus lab guides (`labs/`) and reference
solutions (`solutions/`).

## Ground rules

1. **Stay in scope.** Issues assigned to you concern the sample app in
   `app/` unless they explicitly say otherwise. Don't restructure labs,
   solutions, or workflows to "help".
2. **No new runtime dependencies — ever.** `app/package.json` must keep an
   empty dependency list. Use Node's standard library.
3. **Tests are not optional.** Every code change ships with a test in
   `app/tests/` using `node:test`. Bug fix → regression test first.
4. **Small diffs win.** Match the existing style; don't reformat untouched
   code; don't rename things gratuitously.
5. **Don't touch CI config** (`.github/workflows/`) unless the task is
   explicitly about workflows.

## Build and test

```bash
cd app
npm ci        # instant — no dependencies
npm test      # node --test, all tests must pass
npm run build # writes dist/ + build-info.json
```

CI runs these same steps on Node 22.x and 24.x. Your PR is green only when
the `CI` workflow passes — that pipeline is the source of truth.

## Definition of done

- `npm test` passes locally.
- New behavior has a test that fails without your change.
- PR description explains *what* and *why* in two short paragraphs.
