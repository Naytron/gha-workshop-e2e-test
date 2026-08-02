# Lab 2 — Events and Workflow Syntax

**Time:** ~60 minutes · **Deck module:** Workflow Syntax (advanced) · covers the material behind demo checkpoint 1
**Goal:** author a real CI workflow from scratch using events, filters, a matrix, job dependencies, conditionals, and expressions.

The app you'll build against lives in [`app/`](../app) — a tiny Node.js service with tests (`npm test`) and a build (`npm run build`). Zero dependencies, so runs are fast and cheap.

## 2.1 Events — more than push

Skim these trigger patterns. You'll use several in the workflow you write below.

```yaml
on:
  push:
    branches: [main]
    paths-ignore: ["**.md", "labs/**"]   # docs changes shouldn't burn CI minutes
  pull_request:
    branches: [main]
  schedule:
    - cron: "0 6 * * 1-5"               # 06:00 UTC, weekdays. Always UTC!
  workflow_dispatch:                    # manual button, with typed inputs
    inputs:
      log-level:
        description: "Verbosity"
        type: choice
        options: [info, debug]
        default: info
```

Facts worth remembering:

- `schedule` uses **POSIX cron, in UTC**, and fires on the **default branch** only. High-load times (top of the hour) can delay scheduled runs.
- `workflow_dispatch` inputs arrive in the `inputs` context (`${{ inputs.log-level }}`).
- Filters (`branches`, `paths`, `tags`) exist for `push`/`pull_request` — use them to control cost and noise.
- A workflow that only contains `pull_request` will **not** run when you push straight to a branch with no PR open — a very common "why didn't it run?" cause.

## 2.2 Author `ci.yml`

Create `.github/workflows/ci.yml` **from scratch** (resist copying the solution). Requirements:

1. **Triggers:** `push` to `main` (ignoring `**.md` paths), `pull_request` targeting `main`, and `workflow_dispatch`.
2. **A `test` job** that:
   - runs on `ubuntu-latest` with a **matrix** of Node versions `22.x` and `24.x`
   - checks out the code, sets up Node with `actions/setup-node` using the matrix value
   - runs `npm ci` then `npm test` in the `app` folder (tip: set a job-level
     `defaults.run.working-directory: app` instead of repeating it per step)
   - has a `timeout-minutes` of `5` — never let a hung job eat the 6-hour default
3. **A `build` job** that:
   - runs **only after** `test` succeeds (`needs: test`)
   - runs **only on pushes to main**, not on PRs:
     `if: github.event_name == 'push' && github.ref == 'refs/heads/main'`
   - runs `npm ci` and `npm run build` in `app/`
   - prints the produced build metadata: `cat dist/src/build-info.json`
4. **Top-level hardening** (habits from day one):
   ```yaml
   permissions:
     contents: read
   concurrency:
     group: ci-${{ github.ref }}
     cancel-in-progress: true
   ```
   `concurrency` cancels the previous run when you push again — watch it happen by pushing twice quickly.

Commit to `main`, watch it run, then open a small PR (edit `app/README.md` on a branch) and confirm: `test` runs on the PR, `build` is **skipped**.

Compare with [`solutions/02-ci.yml`](../solutions/02-ci.yml) when done.

## 2.3 Expressions and functions — scavenger hunt

Add one throwaway step to your `test` job, run it, then read your own answers in the logs:

```yaml
- name: Expression playground
  run: |
    echo "1. ${{ contains(github.repository, 'workshop') }}"
    echo "2. ${{ format('Run #{0} attempt {1}', github.run_number, github.run_attempt) }}"
    echo "3. ${{ startsWith(github.ref, 'refs/heads/') && 'branch' || 'not a branch' }}"
    echo "4. hashFiles: ${{ hashFiles('app/package-lock.json') }}"
```

- `hashFiles()` returns a hash of files matching a pattern — this becomes the cache key in Lab 4.
- The `&&`/`||` chain is the closest thing expressions have to a ternary operator.
- Status functions `success()`, `failure()`, `always()`, `cancelled()` control post-steps:

```yaml
- name: Report failure
  if: failure()          # runs only when an earlier step failed
  run: echo "Something above me broke"
```

Delete the playground step before moving on (keep the workflow clean), or move it to a separate `workflow_dispatch`-only workflow if you want to keep experimenting.

## 2.4 Know the limits

A few platform numbers that bite people in real projects (current values in the
[usage limits docs](https://docs.github.com/actions/reference/usage-limits-billing-and-administration)):

| Limit | Value |
| --- | --- |
| Job execution time | 6 h (hosted) |
| Workflow run duration | 35 days max |
| Matrix size | 256 jobs per workflow run |
| Concurrent jobs | plan-dependent (free: 20) |

Your `timeout-minutes: 5` from step 2.2 exists because of that first row.

## 2.5 Stretch goals

- Add a `schedule` trigger and use `github.event_name == 'schedule'` to add a "nightly" label to the run name (`run-name:`).
- Give `workflow_dispatch` a boolean input `skip-build` and make the `build` job honor it.
- Exclude one matrix combination with `matrix.exclude`, or add `fail-fast: false` and break one Node version on purpose to see the difference.

---

✅ **Done when:** `ci.yml` is green on `main`, the matrix ran two jobs, your PR ran only `test`, and a re-push cancelled the in-flight run.

Next: [Lab 3 — Secrets and environments](03-secrets-environments.md)
