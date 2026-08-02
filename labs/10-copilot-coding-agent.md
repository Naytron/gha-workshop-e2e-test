# Lab 10 — Copilot Coding Agent as a Teammate

**Time:** ~60 minutes · **Part 2 module:** Delegating work to agents
**Goal:** hand a real issue to Copilot coding agent, watch it work inside a GitHub Actions environment you configured, review its PR like a colleague's, and understand the governance controls an org needs before rolling this out.

> **Entitlements:** Copilot Business or Enterprise seat with **coding agent
> enabled** by your org's Copilot policy, working in a repo owned by the org
> (or Copilot Pro+ on a personal repo). Each agent task consumes **premium
> requests** plus Actions minutes. Facilitator has confirmed org settings in
> the [runsheet pre-flight](facilitator-runsheet.md#part-2-pre-flight-day-before).

## 10.1 What the coding agent actually is

Assign an issue to **Copilot** the way you'd assign it to a person. It then:

1. spins up an **ephemeral development environment on GitHub Actions** —
   the same compute you've used all of Part 1,
2. explores the repo, writes code, runs tests,
3. pushes to a branch (`copilot/...`) and opens a **draft PR** linked to the
   issue,
4. responds to your PR review comments with new commits.

Two Part 1 facts carry the whole security story:

- The agent's runtime **is an Actions job** — so you already know how it's
  sandboxed, billed, and logged.
- Its branch is a branch and its PR is a PR — so **your Lab 2 CI and Lab 3
  protections apply to it unmodified**. Nothing merges because an AI wrote
  it; things merge because checks pass and a human approved.

## 10.2 Give the agent a map: repository custom instructions

An agent in an unfamiliar repo makes unforced errors: wrong test command,
unwanted dependencies, drive-by refactors. You fix that with instruction
files, which this repo now ships:

- [`.github/copilot-instructions.md`](../.github/copilot-instructions.md) —
  repo conventions for Copilot (layout, style, validation commands).
- [`AGENTS.md`](../AGENTS.md) — ground rules aimed at *any* coding agent
  (scope discipline, no new dependencies, tests mandatory).

Read both now — they're short. Note what they optimize for: **things an
agent can't infer** (the zero-dependency rule is a workshop-cost decision,
not a code smell it could detect) and **things agents chronically get wrong**
(scope creep, missing tests).

> These files aren't agent-only magic: code review (Lab 11) and Copilot in
> your editor read them too. One file, every Copilot surface.

## 10.3 Provision the agent's environment: `copilot-setup-steps.yml`

Left alone, the agent discovers your toolchain by trial and error — slow,
token-hungry, occasionally wrong. You can provision its environment
deterministically with a special workflow file:
[`.github/workflows/copilot-setup-steps.yml`](../.github/workflows/copilot-setup-steps.yml)
(shipped in this repo — open it now).

The contract, in Part 1 vocabulary:

- Filename **must** be `.github/workflows/copilot-setup-steps.yml`, on the
  default branch.
- It must contain a single job **named `copilot-setup-steps`** — the name is
  the API.
- Only some job keys are honored: `steps`, `permissions`, `runs-on`,
  `services`, `snapshot`, `timeout-minutes` (max 59). Anything else is
  ignored.
- It runs **before the agent wakes up**; then the agent inherits the warmed
  environment. Keep `permissions` minimal — the agent brings its own token.
- Bonus: it triggers as a normal workflow on changes to itself, so you can
  validate it in a PR like any other workflow. Run it now from the Actions
  tab (`workflow_dispatch`) and confirm it's green.

This is also where an org points agents at **larger runners** or (with the
firewall disabled and eyes open) self-hosted runners — same `runs-on`
semantics as Lab 7.

## 10.4 Seed work for the agent

Run the seeding script (from your repo root, `gh` authenticated):

```bash
bash scripts/seed-issues.sh
```

It creates three issues labeled `agent-task`:

1. **Add a `/version` endpoint** — new route + tests.
2. **Include uptime in `/health`** — extend a pure function without breaking
   its purity.
3. **Reject absurdly long names** — input validation at the HTTP layer.

Open one and study the shape before assigning it. Each has a concrete
**What**, checkable **Acceptance criteria**, and an explicit **Out of
scope**. That's not ceremony — issue quality is the highest-leverage input
to agent output quality. A vague issue produces a vague PR; you'll just do
the specification work in review comments instead, at premium-request prices.

## 10.5 Assign, then watch it work

1. On your chosen issue: **Assignees → Copilot**.
2. Within a minute or two: 👀 reaction on the issue, then a draft PR appears.
3. On the PR, follow the **View session** link. This is the agent's session
   log — its plan, terminal commands, test runs, and reasoning, live.
4. In a second tab, open **Actions** and find the running job. Confirm what
   you already suspected: your `copilot-setup-steps` ran first, then the
   agent took over. It's Actions all the way down.

While it works, note what fires automatically: your **CI workflow runs on the
agent's PR**. (If Actions workflows need approval for the `copilot` actor's
PRs, approve the run — the same "first-time contributor" gate from Part 1
applies to the agent. That's a feature.)

## 10.6 Review the PR like you mean it

When the draft flips to "ready for review" (or you open it while drafting):

- **Read the diff first**, acceptance criteria in the other window. Did it
  touch only `app/`? Did it add tests? Did it respect the no-dependencies
  rule from the instruction files?
- Check CI. Green means *your* definition of acceptable, from Part 1, holds.
- Now push back on something — even if the PR is good. Leave a review
  comment like: *"Also return the Node.js version in the payload, and cover
  it with a test."* Start the comment with `@copilot` if it's a plain
  comment rather than a review.
- Watch the agent respond with new commits. Iterating via review comments is
  the core skill of agent-assisted development: **you steer with reviews, not
  keystrokes**.

When satisfied: approve and merge. You just merged AI-authored code through
entirely human-owned controls.

> **If the agent goes sideways** (rare but instructive): comment what's
> wrong and let it self-correct, or close the PR and refine the issue. The
> failure mode costs you an Actions job and some premium requests — bounded,
> visible, recoverable. Compare that to an over-permissioned script from
> Lab 3's cautionary tales.

## 10.7 Governance: what your org must decide (instructor-led)

Before an org turns this on for real work, someone owns these dials:

| Control | Where | Default posture |
| --- | --- | --- |
| Enable/disable coding agent | Org → Copilot → Policies | Off until governance exists |
| Which repos may use it | Org Copilot policy (all/selected) | Selected repos, opt-in |
| Premium request budget | Org → Billing → Budgets | Set a budget **before** enablement, alert at 75% |
| What the agent can reach | Agent firewall (on by default) + custom allowlist | Keep on; extend allowlist per-repo, not org-wide |
| What merges | Branch protection / rulesets: required checks + ≥1 human review + no self-approval | Identical to human rules — that's the point |
| Secrets exposure | Actions/Agents environment secrets | Agent env gets **no** production secrets |
| Audit | Session logs + PR history + Actions logs | Review samples weekly at rollout |

Facilitator demo (org account): the Copilot policy page, a budget, and the
firewall settings. Attendees on personal repos: you saw the mechanics; the
dials are where platform teams live.

## Checkpoint

- [ ] `copilot-setup-steps.yml` ran green via `workflow_dispatch`
- [ ] Three `agent-task` issues exist; you assigned one to Copilot
- [ ] You opened the session log and found the corresponding Actions job
- [ ] CI ran on the agent's PR without any special-casing
- [ ] The agent revised its PR in response to your review comment
- [ ] Merged — with you, not the model, as the accountable approver

**Next:** [Lab 11 — Agentic Code Review & Autofix](11-agentic-code-review.md)
— you reviewed the agent; now agents review you.
