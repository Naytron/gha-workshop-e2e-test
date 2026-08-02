# Org Assets (Facilitator / Instructor Demo)

Materials for the **organization-level** demos in Lab 4 — these features can't be exercised from an attendee's personal repository, so the facilitator shows them in a demo org.

## `workflow-templates/` — starter workflows

To make the starter template appear on every org repo's **Actions → New workflow** page:

1. In your demo **organization**, create a repository named exactly `.github` (public).
2. Copy the `workflow-templates/` folder from here into its root.
3. Open any other repo in the org → **Actions → New workflow** → the *Node CI (Org Starter)* card appears under "Workflows created by <org>". The `filePatterns` in the `.properties.json` makes it rank higher for repos containing a `package.json`.

## Other org demos (no assets needed — just screens to show)

- **Actions policies:** Org **Settings → Actions → General** — demonstrate *Allow \<org\> actions and reusable workflows only* plus the allowlist syntax (`actions/*`, `super-linter/super-linter@*`), and what a blocked action's failure looks like in a repo.
- **Org secrets/variables:** Org **Settings → Secrets and variables → Actions** — create one scoped to *selected repositories* and show it appearing (and not appearing) in repo settings.
- **Runner groups:** Org **Settings → Actions → Runner groups** — show group→repo access mapping (pairs with Lab 7).
