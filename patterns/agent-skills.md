# Agent Skills

Skills extend your agent's behavior beyond what it does by default. Unlike MCP tools, which add new capabilities (browser control, GitHub access, device automation), skills shape _how_ the agent thinks, communicates, and approaches work. Same model, same tools: different instruction set.

## Two kinds of skills

**Domain skills (specific)** are tuned for a specific type of work. A frontend skill knows component structure, accessibility patterns, and animation conventions. A React Native skill knows the new architecture, Expo quirks, and production gotchas. You load it once at the start of a session and stop repeating yourself every time you ask a question.

**Behavioral skills (generic)** apply across any task, regardless of domain. They change things like output verbosity, how the agent reasons through decisions, or how it reviews code. These are the ones worth trying first because they pay off in every session, not just when you're working in a particular part of the codebase.

## Where to start

If you're working in a specific area, find a domain skill that matches:

- Frontend: `emil-design-engineering` covers component structure, accessibility, animation, and form patterns
- React Native: `react-native-best-practices` covers the new architecture, Expo, and production patterns
- Security: search for skills around auth, secrets, and threat modeling

Then layer in behavioral skills. The one worth trying immediately is `caveman`.

## Caveman

It sounds ridiculous, but try it:

```
/caveman
```

The idea is simple: drop all the filler — pleasantries, hedging, unnecessary transitions — and keep everything technical. Before caveman, you get responses that start with "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by..." After caveman, you get "Token expiry check uses `<` not `<=`. Fix:" followed by the code.

Same fix. The code block is untouched. You just skipped the preamble.

The claimed token reduction is around 75% on prose. Whether that matters for your bill is secondary to whether the output is easier to read and act on. Subjectively, sessions feel faster because there's less to skim through before getting to the part that matters.

Caveman has intensity levels if you want to dial it up or down (`/caveman lite`, `/caveman full`, `/caveman ultra`), and it backs off automatically for destructive operations or multi-step sequences where a fragment could be misread. Turn it off anytime with `stop caveman`.

## Where to find skills

Some places to browse and install skills are [skillsllm.com](https://skillsllm.com) and [skills.sh](https://skills.sh). Both are community-driven directories where people publish skills for common workflows, and either one is a reasonable starting point when you're looking for something specific: a skill for a framework you use, a code review style you prefer, or a communication mode that fits how you work.

If you can't find what you need, you can write your own. A skill is just a markdown file with a prompt, so the barrier is low once you have a clear idea of the behavior you want.

## Building an inventory over time

Skills are loaded per-session. They don't persist automatically. The practical approach is to start a session, invoke whatever skill fits the work, and notice whether it's actually helping. If a skill saves you effort consistently across multiple sessions, add it to your default session setup.

Over time you end up with a small inventory: one or two behavioral skills that you load every time because they apply everywhere, and a few domain skills you reach for depending on which part of the codebase you're in.

## When a skill is the wrong tool

Skills are prompt-level changes and are only active for the current session. They are not the right place for things that should always apply:

- **Project conventions** belong in `CLAUDE.md` at the repo root, where the agent reads them automatically without you having to remember to invoke anything
- **Capabilities** (calling APIs, controlling a browser, interacting with GitHub) require MCP tools, not skills; see [agent-tools.md](./agent-tools.md)
- **Language-level patterns** belong in the codebase itself and in documentation the agent can read, not in a skill you have to re-load each session

The cleaner mental model: skills shape behavior per-session, `CLAUDE.md` shapes behavior per-project, and MCP tools add new capabilities altogether.

## Summary

| Type       | Example                       | Effect                                               |
| ---------- | ----------------------------- | ---------------------------------------------------- |
| Domain     | `emil-design-engineering`     | Frontend conventions, accessibility patterns         |
| Domain     | `react-native-best-practices` | RN/Expo production heuristics                        |
| Behavioral | `caveman`                     | Compressed output, faster to read                    |
| Behavioral | `grill-me`                    | Stress-tests a plan by forcing every decision branch |
| Behavioral | `review-branch-diff`          | Opinionated code review against a base branch        |

If you're not sure where to start, load `caveman` and see if you like the output style. It's low-risk, applies to everything, and you can turn it off with two words.
