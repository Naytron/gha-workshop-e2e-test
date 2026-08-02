// A dependency-free JavaScript action.
//
// Real-world JavaScript actions almost always use the Actions Toolkit
// (@actions/core, @actions/github) — e.g. core.getInput("name") and
// core.setOutput("greeting", ...). We skip it here so the action runs
// straight from the repo with no `npm install` / bundling step, and so you
// can see the plumbing the toolkit hides:
//
//   - every input arrives as an INPUT_<UPPERCASED NAME> environment variable
//   - outputs are appended to the file that $GITHUB_OUTPUT points at
//   - "::notice::" style workflow commands create annotations

const { appendFileSync } = require("node:fs");

const name = process.env.INPUT_NAME || "world";
const greeting = `Hello, ${name}, from a JavaScript action!`;

console.log(greeting);

// Workflow command → shows up as an annotation on the run summary page
console.log(`::notice title=hello-javascript::${greeting}`);

// This is what core.setOutput() does under the hood
appendFileSync(process.env.GITHUB_OUTPUT, `greeting=${greeting}\n`);
