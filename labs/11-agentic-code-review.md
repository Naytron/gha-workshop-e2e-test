# Lab 11 — Agentic Code Review & Autofix

**Time:** ~50 minutes · **Part 2 module:** Agents on the review side
**Goal:** put AI on the *other* side of the pull request — Copilot code review for first-pass feedback, CodeQL to find a planted vulnerability, and Copilot Autofix to remediate it — while keeping humans as the accountable reviewers.

> **Entitlements:** Copilot seat (code review uses premium requests). CodeQL
> + Copilot Autofix are free on **public repos**; private repos need GitHub
> Advanced Security / GitHub Code Security. If your workshop copy is private
> and unentitled, do 11.1–11.2 hands-on and watch 11.3–11.4 as the
> facilitator demo.

## 11.1 Request a review from Copilot

Use the PR your coding agent opened in Lab 10 (or any open PR — rerun
`scripts/seed-issues.sh` and assign another issue if you merged everything).

1. On the PR: **Reviewers → Copilot**.
2. In under a minute, Copilot posts a review: summary comment plus inline
   comments, some with one-click **suggested changes**.
3. Triage its comments exactly as you'd triage a human's: apply the good
   ones (commit suggestions directly), push back on the debatable ones,
   resolve the noise. **It's a reviewer, not a gate** — it cannot approve,
   and its comments don't block merging unless your rules say so.

If this is the Lab 10 PR, savor the moment: an AI teammate wrote the code,
a different AI surface reviewed it, and a human — you — arbitrates. That
division of labor is the shape of the next decade of code review.

### Tune the reviewer

The same instruction files from Lab 10 steer review:
`.github/copilot-instructions.md` applies here too, and you can add
path-scoped review guidance later (`.github/instructions/*.instructions.md`)
— e.g., "in `app/src/**`, flag any new runtime dependency as a blocker."

Orgs can make Copilot review **automatic** on every PR via repository
rulesets (instructor demo if org access is available: ruleset → require
Copilot code review). Pair it with Lab 3's branch protection so the human
review requirement never goes away.

## 11.2 Plant a real vulnerability

Time to give the scanners something worth finding. From your repo root, on a
clean tree:

```bash
bash scripts/plant-flaw.sh
```

The script creates branch `lab11/reflected-input`, adds an `/echo` endpoint
to `app/src/server.js`, and opens a PR. Read the diff in the PR — it
reflects `?message=` straight into an HTML response:

```js
const message = url.searchParams.get("message") ?? "";
res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
res.end(`<h1>You said:</h1><p>${message}</p>`);
```

Classic reflected XSS (CWE-79): `/echo?message=<script>...</script>` executes
in any visitor's browser. The kind of thing that sails through a tired
human review at 4:55pm on a Friday.

## 11.3 Let CodeQL find it

Copy the scanning workflow into place on your default branch:

```bash
cp solutions/11-codeql.yml .github/workflows/codeql.yml
git add .github/workflows/codeql.yml
git commit -m "Add CodeQL scanning"
git push
```

Read it before you push — it's a plain Actions workflow, every line Part 1
vocabulary: `pull_request` + `push` + weekly `schedule` triggers,
`security-events: write` (the one new permission — it uploads findings), a
concurrency group, SHA-pinned `github/codeql-action` steps.

> Alternative: repo **Settings → Advanced Security → Code scanning → Set
> up** offers *default setup*, which needs no workflow file at all. We use
> the workflow so you can see and version the machinery; default setup is
> the right answer for fleet-wide rollout.

Now open the Lab 11 PR. The `pull_request` trigger scans the head branch;
in a few minutes the PR checks show a **Code scanning** failure annotating
the exact line, tagged with the CWE. Also browse **Security → Code
scanning** to see the alert's home.

## 11.4 Let Copilot Autofix remediate it

On the code-scanning alert (in the PR check or the Security tab):

1. Look for **Generate fix** / the suggested fix panel — Copilot Autofix
   reads the alert, the data flow, and the surrounding code, then proposes a
   patch with an explanation.
2. Expect something reasonable: HTML-escaping the input, or returning
   `text/plain`. **Read it critically** — is it the fix *you'd* write? Does
   it break the (nonexistent) tests? Autofix is a strong first draft, not an
   oracle.
3. Apply it (commit to the PR branch), watch CodeQL re-scan, and see the
   alert close when the check goes green.

Then decide the PR's fate like a human: this endpoint was planted homework —
close the PR and delete the branch, or merge the *fixed* version if you want
`/echo` to live on properly escaped.

## 11.5 The full loop, named

Zoom out — across Labs 10 and 11 you've built a review lattice:

| Layer | Actor | Catches |
| --- | --- | --- |
| CI (Lab 2) | deterministic | broken behavior |
| CodeQL (this lab) | deterministic analysis | known vulnerability classes |
| Copilot code review | AI | style, logic smells, missed edge cases |
| Copilot Autofix | AI | remediation drafts for scanner findings |
| **You** | human | judgment, intent, accountability |

Notice what's *not* here: nothing merges on AI say-so. The deterministic
layers gate; the AI layers advise and draft; the human decides. When someone
proposes "let the AI auto-merge its own fixes," this table is the argument
you draw on the whiteboard.

## Checkpoint

- [ ] Copilot reviewed a PR; you applied at least one suggested change and
      rejected (with a reason) at least one comment
- [ ] `plant-flaw.sh` PR is open and you can explain the vulnerability
- [ ] CodeQL flagged the flaw on the PR with the right line + CWE
- [ ] Autofix proposed a remediation; you evaluated it before applying
- [ ] Alert closed after the fix; PR dispatched (closed or merged fixed)

**Next:** [Lab 12 — Continuous AI](12-continuous-ai.md) — agents stop
waiting for you to trigger them.
