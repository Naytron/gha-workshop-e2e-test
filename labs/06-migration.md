# Lab 6 — Migrating to GitHub Actions

**Time:** ~40 minutes · **Deck module:** Migrating to GitHub Actions
**Goal:** translate an existing CI pipeline (Jenkins, Azure Pipelines, or GitLab CI) into a working Actions workflow, and know what tooling exists for doing this at scale.

## 6.1 The mental model

Migrations are 90% vocabulary. The core mapping:

| Concept | Jenkins | Azure Pipelines | GitLab CI | GitHub Actions |
| --- | --- | --- | --- | --- |
| Definition file | `Jenkinsfile` | `azure-pipelines.yml` | `.gitlab-ci.yml` | `.github/workflows/*.yml` |
| Machine | `agent` / node label | `pool.vmImage` | `image:` (container) | `runs-on:` (+ `container:`) |
| Grouping | `stage` | `stage` → `job` → `step` | `stages:` list | `jobs` (+ `needs:` for ordering) |
| Ordering | sequential stages | `dependsOn` | stage order / `needs` | `needs:` |
| Shell step | `sh 'npm test'` | `script:` | `script:` list | `run:` |
| Reused tooling | plugins | tasks (`UseNode@1`) | — (images do this) | **actions** (`actions/setup-node`) |
| Trigger | `triggers { cron }` / webhooks | `trigger:` / `pr:` | `rules:` / `only:` | `on:` |
| Variables | `environment {}` | `variables:` | `variables:` | `env:` |
| Conditions | `when {}` | `condition:` | `rules: if:` | `if:` |
| Fan-out | matrix (plugin) | `strategy.matrix` | `parallel: matrix` | `strategy.matrix` |
| Store output | `archiveArtifacts` | `PublishBuildArtifacts@1` | `artifacts: paths` | `actions/upload-artifact` |

Differences that surprise people:

- **Actions has no first-class "stage" layer** — jobs + `needs:` express the same DAG, and the visual graph shows it.
- **Every job is a fresh machine.** Jenkins workspaces persist across stages on one agent; in Actions, pass files between jobs with artifacts (or rebuild).
- **Plugins → actions or preinstalled tools.** Much of what needed a Jenkins plugin is either an action or already on the hosted runner image.
- **Secrets are platform-level** (Lab 3), not a credentials plugin.

## 6.2 Translate one pipeline

The [`migration-samples/`](../migration-samples) folder has the **same pipeline written three ways** for this repo's `app/`: [`Jenkinsfile`](../migration-samples/Jenkinsfile), [`azure-pipelines.yml`](../migration-samples/azure-pipelines.yml), [`.gitlab-ci.yml`](../migration-samples/.gitlab-ci.yml). Each file's header comment carries its own concept map.

Pick the one closest to your day job (or Jenkins if none) and port it to `.github/workflows/migrated-ci.yml`. It must preserve **all** the behaviors:

- [ ] Install → test → build ordering, with build depending on test
- [ ] The **test matrix** (Node 22 + 24) from the Azure/GitLab versions — Jenkins folks: add it anyway, Actions makes it easy
- [ ] Build runs **only on `main`** (`when { branch 'main' }` / `rules:` → `if:`)
- [ ] The nightly **cron trigger** from the Jenkinsfile (`H 2 * * 1-5` → pick a fixed UTC time; Actions cron has no `H` hash syntax)
- [ ] `dist/` archived as an **artifact** on success
- [ ] The Jenkins `post { always }` "finished" log line → a step with `if: always()`

Run it, then diff your result against [`solutions/06-migrated-ci.yml`](../solutions/06-migrated-ci.yml). Anything the solution does that yours doesn't? (Look at `permissions:` and pinning — migrations are the perfect moment to *raise* the security bar, not copy the old one.)

## 6.3 Migration at scale (read + discuss)

Hand-porting is fine for a handful of pipelines. For dozens or hundreds:

- **[GitHub Actions Importer](https://docs.github.com/actions/migrating-to-github-actions/using-github-actions-importer-to-automate-migrations)** (`gh actions-importer`) — audits and bulk-converts Jenkins, Azure DevOps, GitLab, CircleCI, Travis, and Bamboo pipelines. Expect it to do the boring 80%; plugins/tasks with no Actions equivalent land as TODO comments for humans.
- Plan the long tail: shared libraries (Jenkins) and templates (Azure) usually become **reusable workflows + composite actions** (Lab 4/5) — design those first, then migrate consumers onto them.
- Run old and new CI **in parallel** on the same commits for a week or two and compare outcomes before decommissioning.

> Discussion: in your organization, what's the *one* pipeline feature you'd have to solve before Actions could be the default?

## 6.4 Stretch goals

- Port a **second** sample and factor the shared parts into your Lab 4 reusable workflow — feel the payoff.
- The GitLab sample caches `.npm/`; carry that behavior over with `actions/cache` (Lab 4 showed how).
- If you have a real pipeline at work small enough to share, sketch its Actions translation in pseudo-YAML with a neighbor.

---

✅ **Done when:** `migrated-ci.yml` is green and preserves all six checklist behaviors.

Next: [Lab 7 — Runners](07-runners.md)
