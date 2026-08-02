# Lab 1 — Your First Workflow

**Time:** ~45 minutes · **Deck modules:** Introduction to GitHub Actions & Workflow Syntax (first half)
**Goal:** read a workflow file fluently, navigate runs and logs, and debug a broken workflow.

## 1.1 Anatomy of the Hello World workflow

Open [`.github/workflows/hello-world.yml`](../.github/workflows/hello-world.yml) in your repository and match each piece to the vocabulary:

| Term | In the file | What it means |
| --- | --- | --- |
| **Event** | `on: push`, `workflow_dispatch` | What causes the workflow to run |
| **Workflow** | the whole YAML file | An automated procedure, made of jobs |
| **Job** | `jobs.say-hello` | A set of steps that runs on one runner |
| **Runner** | `runs-on: ubuntu-latest` | The machine that executes the job |
| **Step** | items under `steps:` | A shell command (`run:`) or an action (`uses:`) |
| **Action** | `uses: actions/checkout@...` | A reusable unit someone else wrote |

Things to notice:

- The `actions/checkout` step is **pinned to a full commit SHA** with the tag in a comment. Tags like `@v7` can be moved; a SHA can't. Pinning is a supply-chain best practice you'll see throughout this repo.
- `permissions: contents: read` — the job gets a *least-privilege* token. Lab 3 digs into this.
- `${{ github.actor }}` is an **expression** reading the `github` **context**. The last step dumps the entire context with `toJSON(github)` — find that output in your Lab 00 run and skim what's in there (event payload, ref, sha, actor…).

## 1.2 Where workflows live and run

- [ ] Every workflow **must** be in `.github/workflows/` on the branch where the event happens.
- [ ] Open the **Actions** tab → your Hello World run. Identify: the trigger (why it ran), the job list (left), the log (right), and the **timing/billing** info (job page → gear icon → *View raw logs* vs. the pretty view).
- [ ] Re-run it: **Re-run all jobs**. Note that the `github.run_number` stays put but `run_attempt` increments.

## 1.3 Fix the broken workflow 🔧

The repository ships with a second workflow that has **three bugs**: [`.github/workflows/debug-me.yml`](../.github/workflows/debug-me.yml).

1. Actions tab → **Debug Me (broken on purpose)** → **Run workflow**.
2. It fails. Open the run and use the logs to find and fix all three bugs, one at a time — re-run after each fix so you see how each failure presents differently:
   - One bug fails **before any step runs** (look at the error banner, not the step logs).
   - One fails at a **step**, with a clear message about a path.
   - One fails at a **step**, with npm telling you what it couldn't find.
3. Edit the file directly in the GitHub UI (pencil icon) — each commit to `main` also triggers the workflow if you edit workflow files… does it? Check the `on:` block and explain to your neighbor why or why not.

<details>
<summary>Hints (expand only after trying)</summary>

- Bug 1: does the version tag on one of the actions look… plausible?
- Bug 2: compare `working-directory:` with the actual folder names in the repo.
- Bug 3: read the `run:` line letter by letter.

</details>

Stuck or want to compare? The fixed file is at [`solutions/01-debug-me-fixed.yml`](../solutions/01-debug-me-fixed.yml).

## 1.4 Explore the Marketplace

1. Visit [github.com/marketplace?type=actions](https://github.com/marketplace?type=actions).
2. Find `actions/setup-node`. Check: who publishes it? (Look for the *verified creator* badge.) How is it versioned?
3. Open its repository and find the `action.yml` file — every action has one. You'll write your own in Lab 5.

> [!NOTE]
> **Choosing actions responsibly:** prefer actions from `actions/*`, `github/*`, or verified creators; read the source of small third-party actions; pin to a commit SHA. Your organization can also *restrict* which actions are allowed — Lab 4 shows where.

## 1.5 Stretch goals (if you're ahead)

- Add a step to Hello World that prints the runner's OS using the `runner` context.
- Make the greeting say your username in the *step name* itself, not just the log output.
- Find the workflow **file** for a public repo you use daily. How do they structure jobs?

---

✅ **Done when:** *Debug Me* has a green run, and you can name the event → workflow → job → step → runner chain without looking.

Next: [Lab 2 — Events and workflow syntax](02-events-and-syntax.md)
