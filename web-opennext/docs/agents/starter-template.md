This repo was cloned from https://github.com/michaeltroya/supa-next-starter and uses certain tooling that we want to customize.

## Initial Setup

1. Replace pnpm with bun
2. Replace husky with lefthook
3. Replace tsc with tsgo (@typescript/native-preview)
4. Replace prettier with biome
5. Configure @t3-oss/env-nextjs (https://env.t3.gg/docs/nextjs) and remove `hasEnvVars`
6. Create `src/config/constants.ts` to define constants. Add `export APP_NAME = "My App"` for stub

## Install npm packages

Use bun (`bun i <package_name>`) and install these packages:

- file-saver
- es-toolkit
- react-hook-form
- @hookform/resolvers
- react-error-boundary
- date-fns
- ky
- sonner
- vaul
- zod
- zod-opts
- type-fest
- p-limit
- p-queue
- nuqs
- zod-form-data
- server-only
- saas-maker
- ahooks
- motion
- @icons-pack/react-simple-icons
- lucide-animated
- @tanstack/react-query
- @legendapp/state

## Update package.json

Add these scripts:

- "lint": "biome check"
- "lint:fix": "biome check --write --unsafe"
- "check": "bun run --parallel type-check lint"
- "fix": "bun run --parallel type-check lint:fix"
- "type-check": "tsgo"

## Additional Tasks

- Replace axios with ky
- Create `AGENTS.md` in project's root: understand the codebase structure and common pattern and include it in the file. Highlight the tech stack: bun, biome, nextjs, tailwind, shadcn, zod, lucide-react (for icons).

## Icons and animation

- `lucide-react` — general UI icons (already in supa-next-starter)
- `lucide-animated` — animated variants of lucide icons (https://lucide-animated.com)
- `@icons-pack/react-simple-icons` — brand SVG icons (GitHub, Twitter, Stripe, etc.)
- `motion` — animation library (https://motion.dev); replaces framer-motion

## Data fetching and state

- `@tanstack/react-query` — async data fetching, caching, and server state
- `@legendapp/state` — global/shared state management; fine-grained reactivity

## Toast and drawers

- `sonner` — toast notifications (already included above)
- `vaul` — bottom sheet / drawer for web (already included above)
