# Lab 00 — Attendee Setup

**Time:** ~20 minutes, before the workshop starts or during the welcome block.
**Goal:** a working copy of this repository with Actions enabled and one green workflow run.

## Prerequisites

- A GitHub account (github.com — a free personal account works for every lab except where noted)
- A browser. That's genuinely it — all labs run in the GitHub UI and on GitHub-hosted runners.
- *Optional but recommended:* [GitHub Codespaces](https://github.com/features/codespaces) or a local `git` + editor for the labs where editing many files at once is more comfortable. Lab 7 (self-hosted runners) requires a Codespace **or** a machine with Docker.

> [!IMPORTANT]
> **Use a public repository** when you create your copy. Two features used in Lab 3 and Lab 8 — environment protection rules (required reviewers) — are only available on free plans if the repository is **public**. Everything else works either way.

## Step 1 — Create your copy from the template

1. Open this repository on GitHub and select **Use this template → Create a new repository**.
   (If the button is missing, the facilitator will share the template link — or fork the repo instead.)
2. Owner: your personal account. Name: `actions-workshop` (any name works).
3. Visibility: **Public** (see the note above).
4. Select **Create repository**.

## Step 2 — Enable Actions

Actions is usually enabled by default on new repositories, but verify:

1. In your new repository, open **Settings → Actions → General**.
2. Under *Actions permissions*, select **Allow all actions and reusable workflows** for the duration of the workshop.
   (Lab 4 discusses what the stricter options do and why organizations use them.)
3. Under *Workflow permissions* (same page, scroll down), note the default — we'll come back to this in Lab 3.

## Step 3 — Trigger your first run

The repository ships with one workflow: [`hello-world.yml`](../.github/workflows/hello-world.yml).

1. Open the **Actions** tab.
2. Select **Hello World** in the left sidebar.
3. Select **Run workflow → Run workflow** (the green button — this is a `workflow_dispatch` trigger; Lab 2 explains it).
4. Wait for the run to appear, open it, and confirm the job is green ✅.

## Step 4 — Look around (2 minutes)

While others finish, open the run you just made and find:

- [ ] The **job log** — expand the *Say hello* step. What did it print?
- [ ] The **workflow file** link on the run page (top right, "…" menu → *View workflow file*)
- [ ] The **Usage** section under *Settings → Billing* on your account — where hosted-runner minutes appear

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| No **Actions** tab | Settings → Actions → General → make sure Actions isn't disabled |
| "Workflows aren't being run on this forked repository" | You forked instead of using the template — Actions tab → **I understand my workflows, go ahead and enable them** |
| Run stays queued for minutes | Check [githubstatus.com](https://www.githubstatus.com); hosted runner queues occasionally back up |

---

✅ **Done when:** the *Hello World* workflow has at least one green run in your repository.

Next: [Lab 1 — Your first workflow](01-first-workflow.md)
