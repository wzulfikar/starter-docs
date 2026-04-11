# package.json Scripts

Standard script names used across all projects. Keeping these consistent means muscle memory transfers between repos and agents always know how to operate a project without reading docs first.

## Scripts

### `bun dev`

Start the project in development mode with hot reload.

What this maps to depends on the platform:

| Platform | Command behind `dev` |
|----------|---------------------|
| Web (Next.js) | `next dev` |
| Desktop (Wails) | `wails dev` |
| Expo (iOS/Android) | typically an alias — see below |

For a **monorepo-style project** where a mobile app has a companion web app in `web/`:

```json
{
  "scripts": {
    "dev": "cd web && next dev",
    "ios": "expo run:ios",
    "android": "expo run:android"
  }
}
```

`bun dev` always means "start the primary web interface". Platform-specific launchers get their own named script (`ios`, `android`, `wails`).

---

### `bun type-check`

Run the type checker across the whole project.

```json
{ "type-check": "tsgo" }
```

Uses `tsgo` (`@typescript/native-preview`). Never `tsc` directly.

---

### `bun check`

Run formatter and linter. Does not auto-fix — just reports.

```json
{ "check": "biome check" }
```

For auto-fix:

```json
{ "fix": "biome check --write --unsafe" }
```

---

### `bun test:all`

Run all tests in the project. If the repo has split test runners (e.g. `bun test` for unit tests and `jest` for React Native component tests), this script runs both:

```json
{
  "test": "bun test",
  "test:native": "jest",
  "test:all": "bun run --parallel test test:native"
}
```

**Does not include slow tests** — no e2e (Playwright, Cypress) and no mobile UI tests (Maestro). Those run in CI or on demand:

```json
{
  "test:e2e": "playwright test",
  "test:maestro": "maestro test flows/"
}
```

---

### `bun run build`

Run the default build for the repo.

```json
{ "build": "next build" }          // web
{ "build": "wails build" }         // desktop
{ "build": "expo export" }         // expo (static/web export)
```

Note: use `bun run build` not `bun build` — `bun build` is Bun's bundler command, not the project's build script.

---

### `bun deploy`

Deploy the web app. Runs after a successful build.

```json
{ "deploy": "wrangler pages deploy .next" }   // Cloudflare via OpenNext
{ "deploy": "vercel --prod" }                  // Vercel
```

Should be non-interactive (no prompts). Credentials come from env vars or CI secrets.

---

### `bun ota`

Send an over-the-air update without going through a full build + store submission.

| Platform | What it does |
|----------|--------------|
| Mobile (Expo) | `eas update --branch production` |
| Desktop | Custom solution per project (e.g. upload a binary delta to a CDN, notify the app to pull it) |

```json
{ "ota": "eas update --branch production" }
```

Desktop OTA is project-specific — document the actual command in that project's `AGENTS.md`.

---

## Full reference

```json
{
  "scripts": {
    "dev": "<platform-specific dev command>",
    "build": "<platform-specific build command>",
    "deploy": "<platform-specific deploy command>",
    "ota": "<platform-specific OTA command>",
    "type-check": "tsgo",
    "check": "biome check",
    "fix": "biome check --write --unsafe",
    "test": "bun test",
    "test:all": "bun run --parallel test <other-test-runner>",
    "test:e2e": "<e2e runner> (on-demand only)"
  }
}
```

When setting up a new project, always wire up all of these even if some are no-ops initially. An agent operating the project should be able to run `bun check`, `bun type-check`, and `bun test:all` without reading further docs.
