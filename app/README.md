# actions-workshop-app

A deliberately tiny Node.js HTTP service — the CI/CD target for every lab in this workshop.

- **Zero npm dependencies.** `npm ci` completes in about a second, keeping workflow runs fast and your Actions minutes intact.
- **Tests** use the built-in `node:test` runner: `npm test`
- **Build** stamps version + commit metadata into `dist/`: `npm run build`
- **Run locally:** `npm start` then visit `http://localhost:3000/?name=Mona` and `http://localhost:3000/health`
- **Container:** `docker build -t workshop-app .` — multi-stage, non-root, healthchecked (see [Dockerfile](Dockerfile)).

Requires Node.js 22 or newer.

Lab 2 PR test.
