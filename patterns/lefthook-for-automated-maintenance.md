# Lefthook for Automated Maintenance

Automate code quality checks as git hooks using [lefthook](https://lefthook.dev).
Applies to any project in this repo: web, mobile, desktop.

## Why lefthook over husky

- Single binary, no Node.js dependency — works in Go projects too (desktop-wails)
- Runs jobs in parallel by default
- Supports `{staged_files}` so pre-commit only touches files you actually changed
- No shell scripts needed, config is just YAML

## The pattern

Two hooks, two distinct jobs:

| Hook | Runs | Why |
|------|------|-----|
| `pre-commit` | biome check on staged files only | Fast — catches formatting/lint issues before they land |
| `pre-push` | tsgo (full type-check) + bun test | Slower — only runs when sharing code with others |

Keeping them separate means `git commit` stays instant while `git push` is the safety net.

## lefthook.yml

```yaml
pre-commit:
  parallel: true
  jobs:
    - run: bun fix {staged_files}
      glob: "*.{ts,tsx}"

pre-push:
  parallel: true
  jobs:
    - run: bun type-check
      glob: "*.{ts,tsx}"

    - run: bun test
      glob: "*.{ts,tsx}"
```

`bun fix` runs `biome check --write --unsafe` on the staged files only — it auto-fixes what it can, so you rarely see failures.

`bun type-check` runs `tsgo` across the whole project.

## Required package.json scripts

These script names are assumed by the lefthook.yml above:

```json
{
  "scripts": {
    "type-check": "tsgo",
    "lint": "biome check",
    "lint:fix": "biome check --write --unsafe",
    "fix": "biome check --write --unsafe"
  }
}
```

## Installation

```bash
# Install lefthook
bun add -D lefthook

# Register the git hooks (run once per repo clone)
bunx lefthook install
```

Add `lefthook install` to your project's setup instructions so new contributors get the hooks automatically.

## Platform notes

- **web-opennext** and **mobile-expo**: config above applies as-is
- **desktop-wails**: frontend uses the same config; for the Go backend, add a separate job to `pre-push` if needed:

  ```yaml
  pre-push:
    jobs:
      - run: bun type-check
        glob: "*.{ts,tsx}"
      - run: go build ./...
        glob: "*.go"
  ```
