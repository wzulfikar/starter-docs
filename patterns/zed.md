# Zed Editor Setup

Zed supports project-level settings via `.zed/settings.json`. Commit this file to the repo so every contributor gets the same formatter behaviour automatically — no manual editor setup required.

## Auto-format on save with Biome

Zed formats on save by default. To make it use Biome instead of its built-in formatter, set an external formatter:

```json
// .zed/settings.json
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
  }
}
```

Zed pipes the file content through stdin. The `--stdin-file-path {buffer_path}` flag tells Biome what file type it's dealing with (so it applies the right rules) without reading from disk — the actual formatting happens on the in-memory buffer.

`--write --unsafe` applies auto-fixes including opinionated ones. This matches what `bun fix` does in the lefthook pre-commit hook, so the editor and the git hook are always in sync.

## Suppress bun.lock schema warnings

Zed's JSON language server tries to validate `bun.lock` against a schema and warns when it can't find one. Suppress it with an empty schema match:

```json
{
  "formatter": { ... },
  "lsp": {
    "json-language-server": {
      "settings": {
        "json": {
          "schemas": [
            {
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

## Full settings.json

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

## Notes

- Commit `.zed/settings.json` — it's project-level config, not personal preference
- Biome must be installed in the project (`bun add -D @biomejs/biome`) for the formatter command to resolve
- This config pairs with the lefthook pre-commit hook: both run `biome check --write --unsafe`, so there are no surprises between saving in the editor and committing
