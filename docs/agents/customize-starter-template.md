This repo was cloned from https://github.com/michaeltroya/supa-next-starter and uses certain tooling that we want to customize.

## Initial Setup

1. Replace pnpm with bun
2. Replace husky with lefthook
3. Replace tsc with tsgo (@typescript/native-preview)
4. Replace prettier with biome
5. Configure @t3-oss/env-nextjs (https://env.t3.gg/docs/nextjs) and remove `hasEnvVars`
6. Create `src/config/constants.ts` to define constants. Add `export APP_NAME = "My App"` for stub.

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
- Create `commands/hello.ts` with this content:

  ```ts
  import { z } from 'zod'
  import { parser } from 'zod-opts'
   
  main()
  
  /**
  Example:
  bun commands/hello.ts --name John
  */
  async function main() {
    const params = parser()
      .options({
        name: { type: z.string() }
      })
      .parse()
   console.log(`Hello, ${params.name}!`)
  }
  ```

- Create .zed/settings.example.json with this content, then create .zed/settings.json based on it, then add .zed/settings.json to `.gitignore`. Content of .zed/settings.example.json:

  ```json
  {
    "formatter": {
      "external": {
        "command": "biome",
        "arguments": [
          "check",
          "--write",
          "--unsafe",
          "--stdin-file-path",
          "{buffer_path}"
        ]
      }
    },
    "lsp": {
      "json-language-server": {
        "settings": {
          "json": {
            "schemas": [
              {
                // Tell LSP to not check bun.lock so we don't get false positives in Project Diagnostics.
                "fileMatch": ["bun.lock"],
                "schema": {}
              }
            ]
          }
        }
      }
    }
  }
  ```
