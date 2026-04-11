# Agent Tools

Essential tools that extend what an agent can do beyond reading and writing files. Configure these in your agent's MCP settings so they're available across projects.

## Browser control

Lets the agent open URLs, click, fill forms, take screenshots, and inspect the page — useful for verifying UI changes, testing flows, and debugging rendering issues.

**Primary:** `agent-browser`

**Alternative MCP:** `chrome` — connects to a running Chrome instance via Chrome DevTools Protocol

Use when:
- Verifying that a UI change looks correct before marking a task done
- Debugging a production issue that only reproduces in the browser
- Testing auth flows or multi-step forms end to end

## Device / simulator control

Lets the agent interact with an iOS or Android simulator — launch the app, tap, scroll, take screenshots, and read the screen state.

**Primary:** `agent-device`

**Alternative MCP:** `xcodebuildmcp` — wraps `xcodebuild` and `simctl` to build, install, and control iOS simulators (https://github.com/getsentry/XcodeBuildMCP)

Use when:
- Verifying a mobile UI change on the simulator
- Reproducing a crash or layout bug on a specific device/OS version
- Running a Maestro flow and inspecting the result

## GitHub

Lets the agent read and write GitHub resources — issues, pull requests, comments, CI status, file contents from any branch.

**MCP:** `github` (official GitHub MCP server)

Use when:
- Researching an open issue before starting work
- Checking CI failure logs on a pull request
- Reading code from another branch or repo for reference
- Posting a comment or updating a PR description

## Configuration

MCP servers are configured per-machine in your agent's global settings, or per-project in `.mcp.json` at the repo root. Global configuration is preferred for these tools since they're useful in every project.

### Claude Code (`~/.claude/settings.json`)

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-token>"
      }
    },
    "chrome": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    },
    "xcodebuildmcp": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest", "mcp"]
    }
  }
}
```

### Codex (`~/.codex/config.json`)

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-token>"
      }
    }
  }
}
```

## Summary

| Tool | Purpose | Primary | Alternative MCP |
|------|---------|---------|-----------------|
| Browser control | Verify UI, test flows | `agent-browser` | `chrome` |
| Simulator control | Verify mobile UI, debug on device | `agent-device` | `xcodebuildmcp` |
| GitHub | Research issues, read PRs, check CI | — | `github` |
