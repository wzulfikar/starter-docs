# Encrypted Secrets in Git

The standard advice is to never commit secrets. This pattern challenges that — with a concrete trade-off: commit an **encrypted** secrets file so the team always has a single source of truth for what secrets exist and when they change.

## The trade-off

| | Gitignored `.env` only | Encrypted `.env.secrets` in git |
|---|---|---|
| New collaborator onboarding | "Ask someone for all the keys" | Get the key file once, pull the repo |
| Adding a new secret | Tell everyone manually or update a wiki | `bun secrets:edit`, commit — teammates see the diff |
| Secret rotation visibility | None | Git history shows when it happened |
| Risk if key is leaked | None | All secrets exposed |

**Best for:** private repos, small teams, projects where the overhead of a secrets manager isn't justified yet.

## File conventions

```
.env              ← plaintext, gitignored — your actual local environment
.env.secrets      ← encrypted, git-tracked — the team's shared secrets
.env.secrets.key  ← the encryption key, gitignored — shared once, out-of-band
```

`.env` is still where your app reads values at runtime. `.env.secrets` is the encrypted record of what those values should be. Collaborators decrypt it to see what to put in their `.env`.

## Setup

Install the library:

```bash
bun add -D node-credentials
```

Initialize the encrypted file:

```bash
npx node-credentials init --path .env.secrets
```

This creates `.env.secrets` (encrypted) and `.env.secrets.key` (the key). Add the key file to `.gitignore` immediately:

```bash
# .gitignore
.env
.env.secrets.key
```

Commit the encrypted file:

```bash
git add .env.secrets
git commit -m "chore: init encrypted secrets file"
```

Share `.env.secrets.key` with your team out-of-band — a password manager, an encrypted Slack DM, or a 1Password shared vault. This is a one-time step per collaborator.

## package.json scripts

```json
{
  "scripts": {
    "secrets:edit": "EDITOR=nano node-credentials edit --path .env.secrets",
    "secrets:view": "node-credentials decrypt --path .env.secrets && cat .env.secrets ; node-credentials encrypt --path .env.secrets"
  }
}
```

Use `secrets:edit` for all changes — it decrypts to a temp buffer in your editor, then re-encrypts when you save and exit. The encrypted file on disk is never left in a plaintext state.

## Editing secrets

When you need to add, update, or remove a secret:

```bash
bun secrets:edit
```

This opens the decrypted contents in your `$EDITOR`. Edit the values, save, and exit. The file is re-encrypted automatically. Then commit:

```bash
git add .env.secrets
git commit -m "chore: add PLUNK_SECRET_KEY"
```

Teammates pulling the branch will see the commit in `git log` and know a new secret was added — even before they decrypt it.

## Onboarding a new collaborator

1. They clone the repo (`.env.secrets` is already there)
2. You share `.env.secrets.key` with them out-of-band
3. They place the key file at the project root
4. They run `bun secrets:edit` to open the decrypted contents, copy the values they need into their `.env`, then close the editor

No wiki to check, no "what env vars does this project need?" Slack thread. The encrypted file is the documentation.

## Picking up a new secret a teammate added

When you pull and see `.env.secrets` changed in the diff:

1. Run `bun secrets:edit`
2. Find the new key (it'll be obvious — it's a new line)
3. Copy the value to your `.env`
4. Close the editor

The git diff tells you a change happened. The edit command tells you what changed. Your `.env` gets updated.

## What goes in `.env.secrets`

Any secret that every developer needs locally:

```
SUPABASE_URL=https://xyz.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
PLUNK_SECRET_KEY=sk_...
TRIGGER_SECRET_KEY=tr_...
AUTUMN_SECRET_KEY=sk_...
```

Do **not** store environment-specific production secrets here (those live in your deployment platform's secret manager — Cloudflare Workers secrets, Railway, etc.). This file is for local development.

## Key rotation

If the key is ever compromised:

```bash
# Decrypt with old key
NODE_MASTER_KEY=$(cat .env.secrets.key) npx node-credentials decrypt --path .env.secrets

# Re-init with a new key
npx node-credentials init --path .env.secrets

# Commit the re-encrypted file, share the new key with the team
```

Rotation is a manual step — keep it in mind before choosing this pattern for high-compliance environments.
