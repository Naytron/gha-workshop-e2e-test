# Solutions

Completed, working workflow files for each lab. They live **outside** `.github/workflows/` on purpose — nothing here runs until you copy it into `.github/workflows/` in your own repository.

| File | Lab | Copy to |
| --- | --- | --- |
| `01-debug-me-fixed.yml` | 1 | replaces `.github/workflows/debug-me.yml` |
| `02-ci.yml` | 2 | `.github/workflows/ci.yml` |
| `03-deploy-gated.yml` | 3 | `.github/workflows/deploy.yml` (requires `staging`/`production` environments) |
| `04-reusable-build.yml` | 4 | `.github/workflows/reusable-build.yml` |
| `04-caller.yml` | 4 | `.github/workflows/use-reusable.yml` |
| `05-use-custom-actions.yml` | 5 | `.github/workflows/try-actions.yml` |
| `06-migrated-ci.yml` | 6 | `.github/workflows/migrated-ci.yml` |
| `07-self-hosted.yml` | 7 | `.github/workflows/self-hosted.yml` **in your private runner-playground repo** |
| `08-capstone-pipeline.yml` | 8 | `.github/workflows/pipeline.yml` |
| `09-issue-triage.yml` | 9 | `.github/workflows/issue-triage.yml` (uses `prompts/issue-triage.prompt.yml`) |
| `09-ci-failure-summary.yml` | 9 | `.github/workflows/ci-failure-summary.yml` (uses `prompts/failure-summary.prompt.yml`) |
| `11-codeql.yml` | 11 | `.github/workflows/codeql.yml` |
| `12-repo-gardener.md` | 12 | `.github/workflows/repo-gardener.md`, then `gh aw compile` (commit the `.lock.yml` too) |
| `12-self-healing-ci.md` | 12 | `.github/workflows/self-healing-ci.md`, then `gh aw compile` (commit the `.lock.yml` too) |

> The two `12-*.md` files are **GitHub Agentic Workflow sources** (gh-aw,
> technical preview), not plain Actions YAML — they compile to a locked
> `.lock.yml` that is what actually runs. See
> [Lab 12](../labs/12-continuous-ai.md).

Conventions used throughout (and worth stealing for real projects):

- **Actions pinned to full commit SHAs** with the version tag as a comment — tags can be moved, SHAs can't.
- **Least-privilege `permissions:`** at the top level, elevated only where a job needs it.
- **`concurrency` groups** so stale CI runs cancel, but deploys never do.
- **`timeout-minutes`** on every job — nothing should be able to hang for the 6-hour default.
