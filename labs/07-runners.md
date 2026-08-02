# Lab 7 — Runners: Hosted and Self-Hosted

**Time:** ~45 minutes · **Deck module:** Runners · demo checkpoint 5
**Goal:** understand the hosted runner fleet, register a real self-hosted runner, route a job to it, and know the security rules that come with it.

## 7.1 GitHub-hosted runners

Everything you've run so far used `runs-on: ubuntu-latest` — a fresh, ephemeral VM per job.

- [ ] Images: `ubuntu-latest`, `windows-latest`, `macos-latest` (plus pinned versions like `ubuntu-24.04`). What's preinstalled? The runner-images manifests list everything: [github.com/actions/runner-images](https://github.com/actions/runner-images).
- [ ] Add a quick job to any workflow with `runs-on: windows-latest` and `run: Get-ChildItem Env: | Select-Object -First 5` — same YAML, different OS (note: default shell on Windows is PowerShell).
- [ ] **Larger runners** (more cores/RAM, GPU, static IPs) exist for Team/Enterprise plans and are picked with custom labels — *instructor demo / discussion*.
- [ ] Billing: public repos = free hosted minutes; private repos = a monthly included quota, then per-minute (Windows 2×, macOS 10× the Linux rate). That macOS multiplier is why teams reserve mac runners for the jobs that truly need them.

## 7.2 Register a self-hosted runner

You'll run a real runner agent and send it a job. **Use a Codespace** (recommended — nothing touches your machine) or any Linux/macOS box or container you control.

> [!WARNING]
> Golden rule first: **never attach a self-hosted runner to a public repository.** Anyone who can trigger a workflow (e.g., by opening a pull request from a fork) may get code running on *your* machine. GitHub-hosted runners are safe for public repos because they're destroyed after every job; your laptop is not. For this lab, create a **separate private repo** (e.g., `runner-playground`) in your account — it keeps the lab safe even though your workshop repo is public.

1. Create the private repo `runner-playground`, then open a Codespace on any repo (or a local terminal).
2. In `runner-playground`: **Settings → Actions → Runners → New self-hosted runner** → pick **Linux x64**. GitHub shows a personalized download + configure script — it looks like:

   ```bash
   mkdir actions-runner && cd actions-runner
   curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/vX.Y.Z/actions-runner-linux-x64-X.Y.Z.tar.gz
   tar xzf actions-runner-linux-x64.tar.gz
   ./config.sh --url https://github.com/YOU/runner-playground --token XXXX   # short-lived registration token
   ./run.sh
   ```

   (Helper: [`scripts/runner-setup.sh`](../scripts/runner-setup.sh) wraps the download/unpack part; the `config.sh` token must still come from *your* settings page.)
3. During `config.sh`, accept the defaults but add a custom **label** when prompted: `workshop`.
4. `./run.sh` — the terminal now says `Listening for Jobs`. Check **Settings → Actions → Runners**: your runner is green/Idle.

Now target it. In `runner-playground`, create `.github/workflows/self-hosted.yml`:

```yaml
name: Self-Hosted Test
on: workflow_dispatch

permissions:
  contents: read

jobs:
  where-am-i:
    runs-on: [self-hosted, linux, workshop]   # ALL labels must match
    steps:
      - run: |
          echo "Hello from $(hostname)"
          echo "User: $(whoami)"
          uname -a
      - run: ls -la $GITHUB_WORKSPACE   # ⚠️ files persist here between jobs!
```

Run it and watch the job stream into your terminal. That `ls` step is the point: **self-hosted runners are not ephemeral by default** — the workspace, tool caches, and anything a previous job left behind are still there. Clean up or use ephemeral runners for anything security-sensitive.

Solution copy: [`solutions/07-self-hosted.yml`](../solutions/07-self-hosted.yml)

Routing rules worth remembering:

- `runs-on: [self-hosted, linux, workshop]` = AND of all labels. No matching **online** runner → the job queues (forever, until a 24h timeout — set `timeout-minutes`!).
- Runners can be registered at **repo, org, or enterprise** level; org/enterprise runners are shared via **runner groups** that control which repos may use them — *instructor demo*.
- Stop your runner (`Ctrl+C`), re-run the workflow, and watch the job sit in *Queued* — this is the #1 self-hosted support ticket. Then remove the runner: `./config.sh remove --token <token from settings>` (and delete `runner-playground` if you like).

## 7.3 Scaling beyond one runner (read + discuss)

One `./run.sh` in a terminal doesn't scale. The production patterns:

- **Ephemeral runners** (`--ephemeral`): take one job, then deregister — pair with automation that replaces them; this restores hosted-like isolation.
- **[Actions Runner Controller (ARC)](https://docs.github.com/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller)**: Kubernetes operator that autoscales ephemeral runner pods based on queued jobs. This is the standard answer for "self-hosted at scale".
- Or skip the fleet entirely: **larger hosted runners** give you bigger machines with zero infrastructure to patch.

> Discussion: what would push *your* team to self-hosted — network access to internal systems, cost, GPUs, compliance? What's the hidden cost you'd take on?

## 7.4 Stretch goals

- Re-register the runner with `--ephemeral` and watch it vanish from the runners page after one job.
- Run the runner in Docker instead of the shell (search: `ghcr.io` runner images) and discuss Docker-in-Docker implications for container builds.
- Read the [self-hosted runner security hardening guide](https://docs.github.com/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#hardening-for-self-hosted-runners) — list the top three mitigations for a hypothetical internal runner fleet.

---

✅ **Done when:** your runner appeared in Settings → Runners, ran a routed job you watched live, and you removed it afterward.

Next: [Lab 8 — The CI/CD capstone](08-ci-cd-capstone.md)
