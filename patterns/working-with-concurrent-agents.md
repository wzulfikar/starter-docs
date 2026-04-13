# Working with Concurrent Agents

Running multiple agents at once can multiply your output but it's easy to lose track. This pattern keeps you anchored.

## The problem

When you spin up 3-4 agents simultaneously, the original intent lives only in your chat history. If an agent asks a clarifying question, or you need to context-switch, you've lost the thread.

## The pattern

**1. Start goal-based**

Write what you want to fix or build, in plain language:

```
- fix login not working
- add dark mode to settings screen
- write tests for the auth service
```

**2. Expand each goal into an agent-ready prompt**

Translate each goal into a prompt the agent can act on without ambiguity:

```
In home screen, the login button should open login screen but now it does nothing.
Check LoginButton component and trace why the onPress handler is not firing.
```

**Key: store the expanded prompt in your todo app (e.g. Todoist), not the chat.** Paste it into the agent from there.

**3. Run agents concurrently**

Paste each prompt into a separate agent. Let them work. You're safe because the source of truth is in your todo app, not the chat window.

**4. Review and close**

When an agent finishes, review the diff, then tick the task in your todo app.

## Why it works

- Todo app is persistent; chat history is not
- Expanded prompt = shared context between you and the agent, stored outside the agent
- Reviewing before ticking forces a deliberate checkpoint, not just "agent said done"

## Capacity

3-4 concurrent agents is a practical ceiling before review overhead outpaces the parallelism benefit. Beyond that, completed work piles up faster than you can verify it.
