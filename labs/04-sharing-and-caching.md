# Lab 4 — Sharing Workflows, Policies, and Caching

**Time:** ~45 minutes · **Deck module:** Managing Workflows & Actions · demo checkpoint 3
**Goal:** extract a reusable workflow, understand org-level distribution and control, and make CI measurably faster with caching.

## 4.1 Reusable workflows (`workflow_call`)

Your `ci.yml` from Lab 2 and the capstone in Lab 8 both need "set up Node, install, test". Instead of copy-paste, extract it.

Create `.github/workflows/reusable-build.yml`:

```yaml
name: Reusable Build
on:
  workflow_call:            # this workflow only runs when another workflow calls it
    inputs:
      node-version:
        type: string
        default: "24.x"
      upload-artifact:
        type: boolean
        default: false
    outputs:
      artifact-name:
        description: "Name of the uploaded dist artifact"
        value: ${{ jobs.build.outputs.artifact-name }}

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: app
    outputs:
      artifact-name: ${{ steps.meta.outputs.name }}
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7.0.0
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci
      - run: npm test
      - run: npm run build
      - id: meta
        run: echo "name=dist-node-${{ inputs.node-version }}" >> "$GITHUB_OUTPUT"
      - name: Upload dist
        if: inputs.upload-artifact
        uses: actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1
        with:
          name: ${{ steps.meta.outputs.name }}
          path: app/dist/
```

Then a small caller, `.github/workflows/use-reusable.yml`:

```yaml
name: Use Reusable
on: workflow_dispatch

permissions:
  contents: read

jobs:
  call-build:
    uses: ./.github/workflows/reusable-build.yml   # same-repo reference
    with:
      node-version: "24.x"
      upload-artifact: true
```

Run it and notice how the called workflow's jobs render *inside* the caller's run graph. Download the artifact from the run's **Summary** page.

Key facts:

- Callers reference reusable workflows as `owner/repo/.github/workflows/file.yml@ref` (cross-repo) or `./.github/workflows/file.yml` (same repo, same commit).
- A reusable workflow receives **typed inputs and secrets** — callers pass `secrets:` explicitly, or `secrets: inherit`.
- **Reusable workflow** = whole jobs, has its own runner(s), can't be mixed into your steps. **Composite action** (Lab 5) = a bundle of *steps* injected into *your* job. Pick per use case.
- Nesting is allowed (a reusable can call another reusable — up to 10 levels; keep it shallow).

Solutions: [`solutions/04-reusable-build.yml`](../solutions/04-reusable-build.yml), [`solutions/04-caller.yml`](../solutions/04-caller.yml)

## 4.2 Starter workflows and policies — *instructor demo* 🎓

These are organization features; watch the demo (or explore the assets in [`org-assets/`](../org-assets) if you have an org to play in):

- **Starter workflow templates:** a `.github` repository in the org with `workflow-templates/*.yml` + `*.properties.json` makes your templates appear in every repo's *Actions → New workflow* page, alongside GitHub's own. See [`org-assets/workflow-templates/`](../org-assets/workflow-templates/).
- **Actions policies:** Org settings → Actions → General can restrict repos to *GitHub-owned actions only*, or *GitHub-owned + a curated allowlist* (e.g., `super-linter/super-linter@*`). This is how platform teams keep the Marketplace supply chain in check.
- **Required workflows / rulesets** can force a workflow (say, a security scan) to pass in every repo in the org.

> Discussion: which of the three would your team adopt first, and what would it break?

## 4.3 Caching dependencies

Every `npm ci` in your runs so far downloaded packages from scratch — runners are ephemeral. The cache action fixes that.

Add caching to your `ci.yml` `test` job **manually first**, to see the moving parts:

```yaml
      - name: Cache npm downloads
        uses: actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9 # v6.1.0
        with:
          path: ~/.npm
          key: npm-${{ runner.os }}-${{ hashFiles('app/package-lock.json') }}
          restore-keys: |
            npm-${{ runner.os }}-
```

- `key` — exact-match identity for the cache entry. `hashFiles(...)` ties it to the lockfile: change dependencies → new key → fresh cache.
- `restore-keys` — prefix fallbacks when the exact key misses (stale-but-useful cache).
- Run CI **twice**. First run: `Cache not found…` and a *Post* step saves it. Second run: `Cache restored from key…`. Compare the `npm ci` durations in both runs.

Then simplify: `actions/setup-node` has caching built in — replace the manual block with:

```yaml
      - uses: actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7.0.0
        with:
          node-version: ${{ matrix.node-version }}
          cache: npm
          cache-dependency-path: app/package-lock.json
```

Cache facts worth knowing: ~10 GB per repo with least-recently-used eviction after 7 days of no access; caches are scoped to a branch plus its base branch (a PR can read `main`'s cache, but not a sibling PR's); **never cache secrets** — anyone who can open a PR can potentially read a cache. Cache = speed hint (may vanish anytime); **artifact** = a run *output* you keep (test reports, `dist/`, binaries).

> Honest note: this app has zero runtime dependencies, so the absolute savings here are seconds. On a real project with a big `node_modules`, this same pattern routinely cuts minutes per run — the *mechanics* are identical.

## 4.4 Stretch goals

- Rewrite Lab 2's `ci.yml` `test` job to call `reusable-build.yml` per matrix Node version.
- Add a second cache for `app/dist` keyed on `github.sha` and discuss why caching *build output* is usually the wrong tool (vs. artifacts).
- Skim [`actions/cache` docs](https://github.com/actions/cache) for the `save`/`restore` split actions — when would you save a cache even on failure?

---

✅ **Done when:** the caller ran the reusable workflow and produced an artifact, and you observed a cache miss → cache hit pair of runs.

Next: [Lab 5 — Building custom actions](05-custom-actions.md)
