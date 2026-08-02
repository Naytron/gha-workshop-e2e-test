# GitHub Actions Fundamentals — Workshop Repository

Companion hands-on repository for the **GitHub Actions Fundamentals** workshop. Each lecture module ends in a lab you run in **your own copy of this repo**, so every concept — events, syntax, secrets, environments, custom actions, runners, CI/CD — is practiced against a real (but tiny) Node.js application.

The repo carries two tracks:

- **Part 1 — Actions Fundamentals (Labs 00–08):** you automate the pipeline. Deterministic workflows: events, secrets, environments, custom actions, migration, runners, and a CI/CD capstone.
- **Part 2 — Agentic DevOps (Labs 09–12):** agents work in and around your pipeline — and the pipeline you built in Part 1 is their safety net. AI inference inside workflows, Copilot coding agent, agentic code review + Autofix, and scheduled autonomous workflows.

Part 1 is built for **solo learners on `github.com`**: one attendee per repository. Features that require an organization (Actions policies, org secrets, runner groups, starter-workflow templates) are covered as **instructor demos** and marked as such in the labs.

## Before You Start

Complete **[Lab 00 — Attendee Setup](labs/00-attendee-setup.md)** first. It creates your copy of this repository from the template, confirms Actions is enabled, and runs your first (pre-shipped) workflow.

## Lab Sequence

Work through these in order — each lab assumes the previous one's context.

### Part 1 — Actions Fundamentals (day 1)

| # | Lab | Deck module | Time |
|---|-----|-------------|------|
| 0 | [Attendee Setup](labs/00-attendee-setup.md) | — | ~20 min |
| 1 | [Your First Workflow](labs/01-first-workflow.md) | Introduction | ~45 min |
| 2 | [Events & Workflow Syntax](labs/02-events-and-syntax.md) | Workflow syntax | ~60 min |
| 3 | [Secrets & Environments](labs/03-secrets-environments.md) | Environments and secrets | ~45 min |
| 4 | [Sharing & Caching](labs/04-sharing-and-caching.md) | Managing workflows & Actions | ~45 min |
| 5 | [Building Custom Actions](labs/05-custom-actions.md) | Building Actions | ~60 min |
| 6 | [Migration](labs/06-migration.md) | Migration | ~40 min |
| 7 | [Runners](labs/07-runners.md) | Runners | ~45 min |
| 8 | [CI/CD Capstone](labs/08-ci-cd-capstone.md) | CI/CD workflows | ~75 min |

### Part 2 — Agentic DevOps (day 2)

| # | Lab | Theme | Time |
|---|-----|-------|------|
| 9 | [AI in Your Workflows](labs/09-ai-in-workflows.md) | Copilot inference via `actions/ai-inference` | ~50 min |
| 10 | [Copilot Coding Agent as a Teammate](labs/10-copilot-coding-agent.md) | Delegating issues to an agent | ~60 min |
| 11 | [Agentic Code Review & Autofix](labs/11-agentic-code-review.md) | AI on the review side + CodeQL | ~50 min |
| 12 | [Continuous AI (Capstone)](labs/12-continuous-ai.md) | Scheduled autonomous agents (gh-aw) | ~60 min |

> **Part 2 entitlements:** all four labs need Copilot. Labs 10–12 assume a
> **Copilot Business or Enterprise** seat with the coding agent enabled by
> org policy (agent tasks consume premium requests), and work best in a repo
> owned by the org. Lab 9 needs any Copilot plan plus one fine-grained PAT
> (created in the lab). Lab 11's CodeQL/Autofix half is free on public
> repos. Lab 12 uses gh-aw (technical preview — expect drift).

Facilitators: see the **[Facilitator Runsheet](labs/facilitator-runsheet.md)** for the run-of-show, the org-demo and Part 2 pre-flight checklists, and risk mitigations.

## What's in This Repo

```
.github/workflows/   Pre-shipped workflows: hello-world.yml (setup check),
                     debug-me.yml (intentionally broken — Lab 1 fixes it),
                     copilot-setup-steps.yml (agent environment — Lab 10)
.github/
  copilot-instructions.md   Repo conventions every Copilot surface reads (Lab 10)
labs/                Step-by-step lab guides 00–12 + facilitator runsheet
app/                 Sample Node.js service: src/, tests/, Dockerfile
                     (zero runtime dependencies → CI runs are fast and cheap)
actions/             Scaffolds for the three custom action types
                     (composite, JavaScript, Docker) — completed in Lab 5
migration-samples/   Jenkinsfile, azure-pipelines.yml, .gitlab-ci.yml that all
                     build the same app — translated to Actions in Lab 6
prompts/             .prompt.yml files used by the Lab 9 Models workflows
solutions/           Completed workflow YAML per lab. Stuck or behind? Copy the
                     solution into .github/workflows/ and keep moving.
org-assets/          Starter-workflow template files facilitators copy into an
                     org's .github repository for the Lab 4 instructor demo
scripts/             Runner setup helper (Lab 7) + Part 2 seed/sabotage scripts
                     (seed-issues, plant-flaw, plant-flaky-test)
AGENTS.md            Ground rules for any coding agent working here (Lab 10)
```

## How to Use These Labs

1. Finish [Lab 00](labs/00-attendee-setup.md) — everything else depends on it.
2. Do the labs in order. **You author the workflows yourself**; only `hello-world.yml` and `debug-me.yml` ship in `.github/workflows/`.
3. When a lab says *"Instructor demo"*, watch — those steps need an organization you may not have.
4. If you fall behind, copy the matching file from `solutions/` into `.github/workflows/` — the labs are designed so you can rejoin at any checkpoint.
5. Keep an eye on your [Actions usage](https://github.com/settings/billing) — the labs are sized to stay well inside the free tier, but the capstone matrix is the biggest spender.

## Costs & Guardrails

- All lab workflows use small runners (`ubuntu-latest`), 2-cell matrices, and `concurrency` groups with `cancel-in-progress` so abandoned runs don't burn minutes.
- The sample app has **no npm dependencies** — installs are instant, caching still demonstrable via the lockfile.
- Public repos get free GitHub-hosted runner minutes; private repos consume your plan's quota. Lab 3's environment protection rules require a **public repo or GitHub Pro/Team/Enterprise**.
