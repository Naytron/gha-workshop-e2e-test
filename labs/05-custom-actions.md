# Lab 5 — Building Custom Actions

**Time:** ~60 minutes · **Deck module:** Building Actions · demo checkpoint 4
**Goal:** run, read, and extend all three action types — composite, JavaScript, and Docker — and know when to reach for each.

This repo ships three working scaffolds in [`actions/`](../actions):

| Type | Folder | Runs as | Startup | Best for |
| --- | --- | --- | --- | --- |
| Composite | `actions/hello-composite` | steps inside *your* job | instant | bundling repeated step sequences |
| JavaScript | `actions/hello-javascript` | Node process on the runner | fast | logic, API calls, cross-platform |
| Docker | `actions/hello-docker` | container built at job time | slow (image build) | any language/toolchain, pinned OS deps; **Linux runners only** |

## 5.1 Run all three

Create `.github/workflows/try-actions.yml`. Local actions are referenced by **path**, which requires checkout first:

```yaml
name: Try Custom Actions
on: workflow_dispatch

permissions:
  contents: read

jobs:
  try-them-all:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1

      - name: Composite
        id: composite
        uses: ./actions/hello-composite
        with:
          name: ${{ github.actor }}

      - name: JavaScript
        id: js
        uses: ./actions/hello-javascript
        with:
          name: ${{ github.actor }}

      - name: Docker
        id: docker
        uses: ./actions/hello-docker
        with:
          name: ${{ github.actor }}

      - name: Collect the outputs
        run: |
          echo "composite said: ${{ steps.composite.outputs.greeting }}"
          echo "javascript said: ${{ steps.js.outputs.greeting }}"
          echo "docker said:     ${{ steps.docker.outputs.greeting }}"
```

Run it and compare the step durations — the Docker step pays an image-build tax before one line of your script runs. Note the JavaScript step's **annotation** on the run summary (that's the `::notice::` workflow command in `index.js`).

## 5.2 Read the metadata

Open each `action.yml` side by side. Every action — every one on the Marketplace too — is defined by this one file:

- `inputs:` / `outputs:` — the action's API. Composite actions must *map* outputs from a step (`value: ${{ steps.x.outputs.y }}`); JS/Docker actions write to `$GITHUB_OUTPUT` at runtime.
- `runs.using:` — `composite`, `node24`, or `docker`. This is the whole difference between the three types.
- In `index.js`, see how inputs arrive as `INPUT_NAME` env vars and outputs are appended to the `$GITHUB_OUTPUT` file. The [Actions Toolkit](https://github.com/actions/toolkit) (`@actions/core`) wraps exactly this plumbing — we skipped it here so there's no build/bundle step, but use it for real actions.

## 5.3 Extend one

Pick your favorite and make these changes (composite is the gentlest start):

1. Add an input `shout` (default `"false"`). When `"true"`, the greeting comes out UPPERCASED.
   *Careful:* action inputs are **always strings** — compare against `'true'`, don't expect a boolean.
2. Add a second output `greeted-at` containing a timestamp.
3. Update `try-actions.yml` to pass `shout: "true"` and print both outputs.

<details>
<summary>Composite hints</summary>

```yaml
inputs:
  shout:
    description: "Uppercase the greeting"
    default: "false"
```

```bash
if [ "${{ inputs.shout }}" = "true" ]; then
  greeting=$(echo "$greeting" | tr '[:lower:]' '[:upper:]')
fi
echo "greeted-at=$(date -u +%FT%TZ)" >> "$GITHUB_OUTPUT"
```

</details>

Solution workflow: [`solutions/05-use-custom-actions.yml`](../solutions/05-use-custom-actions.yml)

## 5.4 Sharing an action for real (read + discuss)

You just used path references (`./actions/...`), which work within one repo. To share:

- Move the action to **its own public repo** with `action.yml` at the root; consumers write `uses: your-org/your-action@v1`.
- Tag releases (`v1.2.3`) **and** maintain a moving major tag (`v1`) — that's the convention users expect; security-conscious consumers will pin your commit SHA instead.
- Optionally publish to the Marketplace (a checkbox in the release flow once `action.yml` has `name`, `description`, `branding`).
- Private sharing without publishing: repo **Settings → Actions → Access** can allow other repos in the org/enterprise to use it.

## 5.5 Stretch goals

- One-off scripting without building an action at all: try [`actions/github-script`](https://github.com/actions/github-script) —
  ```yaml
      - uses: actions/github-script@3a2844b7e9c422d3c10d287c895573f7108da1b3 # v9.0.0
        with:
          script: core.notice(`This repo has ${(await github.rest.repos.get(context.repo)).data.stargazers_count} stars`)
  ```
- Convert `hello-javascript` to use `@actions/core` properly: `npm init`, install the toolkit, and note that you'd now need to commit `node_modules` or bundle with `ncc` — the classic JS-action tradeoff.
- Give `hello-docker` a real tool: install `jq` in the Dockerfile and emit a JSON output.

---

✅ **Done when:** all three action types ran green in one job, and your extended action passes `shout` and returns `greeted-at`.

Next: [Lab 6 — Migrating to GitHub Actions](06-migration.md)
