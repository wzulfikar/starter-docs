# Meta Starter

A curated inventory of code patterns, tooling choices, and architectural decisions accumulated from real projects. When starting a new project, point your AI agent here; it will interview you and decide what to include.

## The idea

This is a **subtractive** approach to project setup: everything you've ever used is in this repo. When you start a new project, the agent reads this inventory, interviews you about what you need, and removes what doesn't apply. You end up with exactly what fits; nothing more.

## Setup (one time)

Clone to a fixed location on your machine:

```bash
git clone https://github.com/wzulfikar/meta-starter ~/meta-starter
```

## Using with Claude Code

Symlink the slash command so it's available globally:

```bash
ln -s ~/meta-starter/.claude/commands/meta-starter.md ~/.claude/commands/meta-starter.md
```

Then in any new project folder, open Claude Code and run:

```
/meta-starter
```

Claude reads the command, opens `~/meta-starter/AGENTS.md`, introduces itself as meta-starter, and interviews you.

## Using with Codex

Codex doesn't have slash commands, but you can add a shell function to your `~/.zshrc` or `~/.bashrc`:

```bash
meta-starter() {
  codex "$(cat ~/meta-starter/AGENTS.md)"
}
```

Then in any new project folder:

```bash
meta-starter
```

Codex receives the full AGENTS.md as its instruction and starts the interview.

## Templates

| Template         | Platform      | Framework                       |
| ---------------- | ------------- | ------------------------------- |
| `web-opennext/`  | Web           | Next.js + OpenNext (Cloudflare) |
| `mobile-expo/`   | iOS / Android | Expo + React Native             |
| `desktop-wails/` | Desktop       | Go + Wails                      |

## Common stack

These apply across all templates:

- **TypeScript** + **tsgo** (`@typescript/native-preview`) for type checking
- **Bun** for runtime, package manager, and test runner
- **Biome** for linting and formatting (replaces eslint + prettier)
- **Lefthook** for git hooks (replaces husky)
- **Tailwind** + **ShadCN** for styling (web/desktop), **mgcrea/react-native-tailwind** for mobile
- **ky** for HTTP requests
- **@tanstack/react-query** for async data fetching and server state
- **@legendapp/state** for global/shared state management
- **Zod** for schema validation
- **es-toolkit** for utility functions (replaces lodash)
- **type-fest** for type utilities
- **Lucide** for icons, **react-simple-icons** for brand logos
- **motion** for animations

## Optional features (decided per project)

- **Supabase**: auth and database
- **Autumn**: billing and payments
- **Rate limiting**: for public-facing APIs
