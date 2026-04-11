# Meta Starter

A curated inventory of code patterns, tooling choices, and architectural decisions accumulated from real projects. When starting a new project, point your AI agent here — it will interview you and decide what to include.

## The idea

This is a **subtractive** approach to project setup: everything you've ever used is in this repo. When you start a new project, the agent reads this inventory, interviews you about what you need, and removes what doesn't apply. You end up with exactly what fits — nothing more.

## How to use

1. Start a new project (clone a framework starter, `git init`, whatever)
2. Tell your agent: *"Check my meta-starter at `~/meta-starter` and set up this project"*
3. The agent reads `AGENTS.md`, introduces itself, and interviews you
4. Based on your answers it picks the right template and drops optional features you don't need
5. You get a working, opinionated project ready to build on

## Templates

| Template | Platform | Framework |
|----------|----------|-----------|
| `web-opennext/` | Web | Next.js + OpenNext (Cloudflare) |
| `mobile-expo/` | iOS / Android | Expo + React Native |
| `desktop-wails/` | Desktop | Go + Wails |

## Common stack

These apply across all templates:

- **TypeScript** + **tsgo** (`@typescript/native-preview`) for type checking
- **Bun** for runtime, package manager, and test runner
- **Biome** for linting and formatting (replaces eslint + prettier)
- **Lefthook** for git hooks (replaces husky)
- **Tailwind** + **ShadCN** for styling (web/desktop), **mgcrea/react-native-tailwind** for mobile
- **ky** for HTTP requests
- **Zod** for schema validation
- **type-fest** for type utilities
- **Lucide** for icons

## Optional features (decided per project)

- **Supabase** — auth and database
- **Autumn** — billing and payments
- **Rate limiting** — for public-facing APIs
