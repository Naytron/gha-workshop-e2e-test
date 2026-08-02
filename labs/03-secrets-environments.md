# Lab 3 — Secrets, Environments, and the GITHUB_TOKEN

**Time:** ~45 minutes · **Deck module:** Environments & Secrets · demo checkpoint 2
**Goal:** store secrets at the right scope, gate a deployment behind an approval, and right-size workflow permissions.

> [!IMPORTANT]
> Environment **protection rules** (required reviewers, wait timers) require a **public** repository on free plans. If your copy is private and you can't make it public, pair up with a neighbor whose repo is public for section 3.3 — the rest works everywhere.

## 3.1 Secret scopes

Secrets can live at three levels, and the most specific wins:

| Scope | Set where | Visible to |
| --- | --- | --- |
| Organization | Org settings (can be limited to selected repos) | many repos — *instructor demo* |
| Repository | Settings → Secrets and variables → Actions | every workflow in this repo |
| Environment | Settings → Environments → *name* | only jobs targeting that environment |

Create a repository secret now:

1. **Settings → Secrets and variables → Actions → New repository secret**
2. Name: `DEMO_API_KEY`, value: anything memorable (it's not a real key).
3. Note the tab next to Secrets: **Variables** — same scoping, but *not* masked and readable in the UI. Config goes in variables; credentials go in secrets.

Now prove masking works. Create `.github/workflows/secrets-demo.yml`:

```yaml
name: Secrets Demo
on: workflow_dispatch

permissions:
  contents: read

jobs:
  show-masking:
    runs-on: ubuntu-latest
    steps:
      - name: Use the secret
        env:
          API_KEY: ${{ secrets.DEMO_API_KEY }}   # pass via env, not inline
        run: |
          echo "The key is $API_KEY"
          echo "Key length: ${#API_KEY}"
```

Run it. The value prints as `***` — GitHub masks known secret values in logs. The length still prints, which is your hint that **masking is a safety net, not a security boundary**: don't `echo` secrets, don't write them to files or artifacts, and never `set -x` around them.

## 3.2 Create environments

1. **Settings → Environments → New environment** → name it `staging`. No protection rules.
2. Create another named `production`:
   - ✅ **Required reviewers** → add yourself (in class: add your neighbor and approve each other's deploys).
   - Add an **environment secret** `DEPLOY_TARGET` with value `https://prod.example.com`.
3. Add a `DEPLOY_TARGET` secret to `staging` too, value `https://staging.example.com`.

## 3.3 A gated deployment workflow

Create `.github/workflows/deploy.yml` — a *simulated* deploy (no cloud account needed; Lab 8 turns this into a real container publish):

```yaml
name: Deploy
on: workflow_dispatch

permissions:
  contents: read

concurrency:
  group: deploy
  cancel-in-progress: false   # never cancel a half-finished deploy

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com   # shows as a link on the run page
    steps:
      - name: Simulated deploy
        env:
          TARGET: ${{ secrets.DEPLOY_TARGET }}
        run: echo "Deploying to $TARGET (staging)"

  deploy-production:
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment:
      name: production
      url: https://prod.example.com
    steps:
      - name: Simulated deploy
        env:
          TARGET: ${{ secrets.DEPLOY_TARGET }}
        run: echo "Deploying to $TARGET (production)"
```

Run it and watch: `deploy-staging` completes, then the run **pauses** — *production* waits for a reviewer. Approve it (or have your neighbor approve) and watch it finish. Check **Settings → Environments → production** afterward: the deployment history is recorded there.

Same secret name, different value per environment — the job's `environment:` decides which one `secrets.DEPLOY_TARGET` resolves to.

Solution: [`solutions/03-deploy-gated.yml`](../solutions/03-deploy-gated.yml)

## 3.4 The GITHUB_TOKEN

Every job gets an automatic, short-lived installation token: `secrets.GITHUB_TOKEN` (also exposed as `github.token`). It expires when the job ends.

- [ ] Open **Settings → Actions → General → Workflow permissions**. Is your repo default *read and write* or *read repository contents*? Set it to **Read repository contents permissions** — then workflows must *ask* for write access explicitly:

```yaml
permissions:
  contents: read
  issues: write     # only what this workflow actually needs
```

- [ ] Try it: make a workflow with `permissions: contents: read` attempt `gh issue create` (the `gh` CLI is preinstalled on runners and honors `GH_TOKEN`):

```yaml
      - name: File an issue
        env:
          GH_TOKEN: ${{ github.token }}
        run: gh issue create --repo "$GITHUB_REPOSITORY" --title "Hello from Actions" --body "Filed by run ${{ github.run_id }}"
```

It fails with a 403. Add `issues: write` to `permissions:` and re-run — now it works. Delete the test issue after. **This ask-for-what-you-need pattern is the single highest-value security habit in Actions.**

## 3.5 Stretch goals

- Add a **wait timer** (e.g., 1 minute) to `production` and observe the forced delay.
- Restrict which **branches** can deploy to `production` (environment setting → deployment branches).
- Read about [OpenID Connect](https://docs.github.com/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect) — how cloud deploys work with *no stored cloud secrets at all*. If you have an Azure/AWS sandbox, this is the modern replacement for pasting credentials into secrets.

---

✅ **Done when:** a deploy run paused for approval, staging and production printed different targets, and your 403→fixed permissions experiment worked.

Next: [Lab 4 — Sharing workflows and caching](04-sharing-and-caching.md)
