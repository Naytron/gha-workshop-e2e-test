# Lab 12 — Continuous AI (Capstone)

**Time:** ~60 minutes · **Part 2 module:** Agents that run themselves
**Goal:** graduate from agents you invoke to agents that run on schedules and events inside GitHub Actions — using **GitHub Agentic Workflows (gh-aw)** — and internalize the safety architecture that makes unattended AI tolerable.

> **Tech preview, stated plainly:** gh-aw is a research-preview GitHub CLI
> extension. Syntax and behavior move fast; if something here doesn't match
> what you see, trust `gh aw --help` and the docs at
> https://githubnext.github.io/gh-aw/ over this page, and tell your
> facilitator (the runsheet has a drift log). The *architecture* this lab
> teaches — read-only agents, allowlisted outputs, human gates — outlives
> any particular tool.
>
> **Entitlements:** Copilot seat + a fine-grained PAT (below). Repo must be
> in an org/account where Actions can run — everything else is Part 1 plumbing.

## 12.0 The idea: Continuous AI

CI is *continuous integration*: deterministic checks on every change.
**Continuous AI** is the emerging pattern of LLM-powered work running the
same way — scheduled, event-driven, unattended: issue gardening, doc drift
patrol, failure triage, dependency review. The pieces you already own:

- **Actions** is the scheduler/sandbox (Labs 1–2: `schedule`, `workflow_run`).
- **Least privilege** bounds what an agent can touch (Lab 3).
- **PRs + protections** keep humans in the loop (Labs 3, 10, 11).

gh-aw packages that pattern: you write an agent as a **markdown file** with
YAML frontmatter; it compiles to a locked-down Actions workflow.

## 12.1 Install and inspect

```bash
gh extension install github/gh-aw
gh aw --version
```

This repo ships two agent definitions as *solutions* (inert until you copy
them into `.github/workflows/`):

- [`solutions/12-repo-gardener.md`](../solutions/12-repo-gardener.md) —
  nightly issue triage: labels new/stale issues, comments guidance.
- [`solutions/12-self-healing-ci.md`](../solutions/12-self-healing-ci.md) —
  wakes on CI failure, investigates the log, opens a **draft** fix PR (or
  files an issue if it can't fix).

Open the gardener now. Anatomy of an agentic workflow:

```markdown
---
on:
  schedule: [{ cron: "17 3 * * *" }]
  workflow_dispatch:
permissions:
  contents: read        # the AGENT's token is read-only
  issues: read
engine: copilot
strict: true
network: { allowed: [defaults, github] }
tools:
  github: { mode: gh-proxy, toolsets: [default] }
safe-outputs:
  add-labels: { allowed: [bug, enhancement, question, agent-task], max: 3 }
  add-comment: { max: 3 }
---

# Repo Gardener
(natural-language instructions the agent follows...)
```

The load-bearing wall is **`safe-outputs`**: the agent itself can only
*read*. Anything it wants to *do* — label, comment, open a PR — is emitted
as a structured request and executed by a separate, deterministic job that
enforces the allowlist. The model never holds a write token. Compare
`permissions:` here with Lab 3: same principle, applied to a probabilistic
actor.

## 12.2 The Copilot token (created in Lab 9 — verify it)

The Copilot engine inside the workflow authenticates with the same repo
secret you created in Lab 9 §9.1: `COPILOT_GITHUB_TOKEN`, a fine-grained PAT
with **no repo access** and only **Copilot Requests: read**. Confirm it's
still there:

```bash
gh secret list | grep COPILOT_GITHUB_TOKEN
```

(If you skipped Lab 9: create it now — Lab 9 §9.1 has the two steps.)

Lab 3 callback, restated for unattended agents: narrowest possible
credential — this PAT can spend Copilot requests and do *nothing else*. Even
if the agent were fully hijacked, the stolen token can't touch code.

## 12.3 Deploy the gardener

```bash
mkdir -p .github/workflows
cp solutions/12-repo-gardener.md .github/workflows/repo-gardener.md
gh aw compile
git add .github/workflows/repo-gardener.md .github/workflows/repo-gardener.lock.yml
git commit -m "Add repo gardener agentic workflow"
git push
```

Two files, on purpose. The `.md` is the source; the **`.lock.yml`** is the
compiled, reviewable, pinned Actions workflow — *that* is what runs. Skim
the lock file: triggers, the sandboxed agent job, the safe-output jobs
enforcing your allowlist, a firewall around network egress. Commit both;
review diffs of both. (Compilation is a build step — Lab 5 vibes.)

Make sure there's at least one unlabeled issue (rerun
`scripts/seed-issues.sh` if the backlog is empty), then run it:

```bash
gh aw run repo-gardener      # or: Actions tab → Repo Gardener → Run workflow
```

Watch the run in the Actions tab. Verify against the allowlist: labels only
from the allowed set, ≤3 comments, and **nothing else** — no closed issues,
no pushed commits, because those verbs simply aren't in `safe-outputs`. If
the backlog needed nothing, expect a clean no-op — "do nothing" is a valid,
safe outcome.

## 12.4 Self-healing CI

Deploy the second agent, then break the build:

```bash
cp solutions/12-self-healing-ci.md .github/workflows/self-healing-ci.md
gh aw compile
git add .github/workflows/self-healing-ci.*
git commit -m "Add self-healing CI agentic workflow" && git push

bash scripts/plant-flaky-test.sh    # sabotages a test expectation on main
```

The chain you're about to watch: your push trips **CI** (Lab 2) → red →
`workflow_run` wakes the agent (same trigger family as Lab 9's failure
summarizer) → it reads the failing log, forms a hypothesis, and — via
safe-outputs — opens a **draft PR** restricted to `app/**` with its fix
(`create-pull-request: draft: true, allowed-files: app/**`), or files an
issue explaining what it found if it can't fix confidently.

When the draft PR appears:

- CI runs on it (of course), and should go green — the agent must clear the
  same bar you do.
- Read the diff and the agent's explanation. Then *you* mark ready + merge.
  Repeat the mantra: **the agent drafts, the pipeline gates, the human
  ships.**

If the agent misdiagnoses (it happens — the planted bug is deliberately a
one-character semantic change), that's your discussion moment, not a
failure: close its PR, fix by hand (`git revert` works), and note that the
blast radius was one draft PR.

## 12.5 The safety architecture (the actual lesson)

Every knob you just used, mapped to the risk it mitigates:

| Guardrail | Mitigates |
| --- | --- |
| `permissions:` read-only on agent job | direct writes by a confused/hijacked model |
| `safe-outputs` allowlist (+ `max`, `allowed-files`, `draft`) | over-reach; caps blast radius per verb |
| `network:` allowlist + firewall | data exfiltration, unvetted tool downloads |
| `strict: true` compile checks | privilege creep sneaking into frontmatter |
| Draft PRs + branch protection (Lab 3) | unreviewed AI code reaching main |
| CI on agent PRs (Lab 2) | plausible-but-wrong fixes |
| `COPILOT_GITHUB_TOKEN` scoped to Copilot-only | credential theft impact |
| Cron + `max` caps + premium budget (Lab 10) | runaway cost |
| `.lock.yml` in git + Actions logs | no audit trail |

Prompt injection deserves its own line: your Lab 9 experiment (hostile issue
body) is *the* threat model here, because unattended agents read untrusted
input with nobody watching. The mitigation is everything above — assume
injection *will* land, and make sure a fully-compromised agent still can't
do anything worse than propose.

## 12.6 Where to go next

- **gh-aw docs & samples:** https://githubnext.github.io/gh-aw/
- **Hands-on workshop:** https://github.com/githubnext/gh-aw-workshop
- **Continuous AI (GitHub Next):** https://githubnext.com/projects/continuous-ai/
- Roll your own without gh-aw: Copilot CLI headless (`copilot -p "..."`) in
  a plain workflow job — you now know exactly which guardrails you'd have to
  rebuild by hand (that's the exercise).

## Checkpoint

- [ ] `gh aw compile` produced `.lock.yml` files and you read one
- [ ] `COPILOT_GITHUB_TOKEN` secret set (Copilot-Requests-only PAT)
- [ ] Gardener ran; every action it took was inside the allowlist
- [ ] Planted failure → agent draft PR (or fallback issue) → human merge
- [ ] You can defend each row of the 12.5 table to a security reviewer

## You're done — the whole arc

Part 1: you built a pipeline that tests, gates, and ships deterministically.
Part 2: you hired probabilistic teammates — in your editor's stead (Lab 9),
on your backlog (Lab 10), across your PRs (Lab 11), and on the clock
(Lab 12) — and the reason you could do it *safely* is the pipeline from
Part 1. Automation isn't replaced by agents; it's what makes agents
deployable.
