# Recommended Services

A curated stack optimized for generous free tiers — you can go from zero to a production app with team collaboration before spending a dollar. Each service was chosen because its free tier is genuinely useful, not crippled.

## Cloudflare

Handles everything at the infrastructure layer.

**What it covers:**
- **Hosting** — static pages (Pages) and Next.js apps via [OpenNext](https://opennext.js.org/cloudflare) on Workers
- **CDN + DDoS** — global edge network included on all plans, no configuration required
- **WAF** — web application firewall with managed rulesets on free plan
- **Rate limiting** — Workers-level rate limiting via the Rate Limiting API or `cloudflare:workers` bindings
- **Cron** — Workers Cron Triggers for scheduled tasks (up to 5 on free plan)
- **Email routing** — forward email from your domain to any inbox, free
- **Domain registration** — at-cost pricing, no markup over ICANN fees

**Free tier highlights:** 100k Workers requests/day, unlimited Pages builds, unlimited static sites, email routing free.

**Next.js on Cloudflare:** Use the `@opennextjs/cloudflare` adapter. This compiles your Next.js app to run on Workers + Assets instead of Node.js, so you get the same edge performance as Pages with full SSR and API routes.

```ts
// wrangler.jsonc
{
  "name": "my-app",
  "compatibility_date": "2025-01-01",
  "compatibility_flags": ["nodejs_compat"]
}
```

```ts
// open-next.config.ts
import type { OpenNextConfig } from "@opennextjs/cloudflare"

const config: OpenNextConfig = {
  default: { override: { wrapper: "cloudflare-node" } },
}

export default config
```

## Supabase

Covers the entire data layer so you don't need to run your own Postgres or build auth from scratch.

**What it covers:**
- **Auth** — email/password, magic links, OAuth (Google, GitHub, etc.), phone OTP, session management, JWTs
- **PostgreSQL** — managed Postgres with row-level security, extensions, and the Supabase client for direct queries
- **Realtime** — subscribe to database changes over WebSockets; built on Postgres logical replication

**Free tier highlights:** 2 active projects, 500 MB database, 50k monthly active users, 50 MB file storage. Enough for an early-stage product with real users.

**Env vars needed:**
```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>  # server-side only
```

Use the anon key in the browser/client. Use the service role key only in server-side code where you need to bypass row-level security.

## Plunk

Handles both transactional emails (receipts, password resets, notifications) and marketing campaigns from a single platform.

**What it covers:**
- **Transactional email** — send via REST API; ideal for triggered emails from your app
- **Campaigns** — broadcast emails to segments of your user list from the dashboard

**Free tier highlights:** 3,000 emails/month free, no credit card required.

**HTML emails:** Use [react-email](https://react.email) to build transactional email templates as React components. Render them to HTML with `@react-email/render` before sending:

```tsx
// src/emails/welcome.tsx
import { Html, Body, Heading, Text } from "@react-email/components"

export function WelcomeEmail({ name }: { name: string }) {
  return (
    <Html>
      <Body>
        <Heading>Welcome, {name}</Heading>
        <Text>Thanks for signing up.</Text>
      </Body>
    </Html>
  )
}
```

```ts
// src/lib/plunk.ts
import ky from "ky"
import { render } from "@react-email/render"

const plunk = ky.create({
  prefixUrl: "https://api.useplunk.com/v1",
  headers: {
    Authorization: `Bearer ${process.env.PLUNK_SECRET_KEY}`,
  },
})

export async function sendTransactionalEmail(params: {
  to: string
  subject: string
  body: string  // pass rendered HTML from react-email
}) {
  return plunk.post("send", { json: params }).json<{ success: boolean }>()
}

export async function trackEvent(params: {
  event: string
  email: string
  data?: Record<string, unknown>
}) {
  return plunk.post("track", { json: params }).json<{ success: boolean }>()
}
```

Call site — render the component to HTML, then send:

```ts
import { render } from "@react-email/render"
import { WelcomeEmail } from "@/emails/welcome"
import { sendTransactionalEmail } from "@/lib/plunk"

await sendTransactionalEmail({
  to: user.email,
  subject: "Welcome aboard",
  body: await render(<WelcomeEmail name={user.name} />),
})
```

**Env vars needed:**
```
PLUNK_SECRET_KEY=<secret-key>
```

## Trigger.dev

Runs background work outside the request/response cycle. Use it for anything that's too slow, too unreliable, or too long-running to do inline.

**What it covers:**
- **Async background jobs** — offload work that shouldn't block the user (sending emails, processing uploads, calling slow third-party APIs)
- **User-generated schedules** — let users define their own recurring tasks (e.g. "run this report every Monday at 9am") using Trigger's schedule API
- **Durable execution** — automatic retries, cancellation, and run history built in

**Free tier highlights:** Free for development; production free tier covers a meaningful number of runs per month for early-stage apps.

**Usage pattern:**

```ts
// src/trigger/send-weekly-report.ts
import { schedules } from "@trigger.dev/sdk/v3"

export const weeklyReport = schedules.task({
  id: "weekly-report",
  run: async (payload) => {
    const { userId } = payload.externalId  // attach your user's ID when registering
    // ... generate and send report
  },
})
```

Register a user-defined schedule from your app:

```ts
import { schedules } from "@trigger.dev/sdk/v3"

// Called when the user sets up their schedule in the UI
await schedules.create({
  task: "weekly-report",
  cron: "0 9 * * 1",          // user-chosen cadence
  externalId: user.id,         // ties the schedule to this user
  timezone: user.timezone,
})
```

**Env vars needed:**
```
TRIGGER_SECRET_KEY=<secret-key>
```

## Autumn

Handles billing and usage tracking so you can monetize without building a payment system from scratch. Sits on top of Stripe — Autumn manages the plan logic and usage metering; Stripe handles the actual money movement.

**What it covers:**
- **Billing** — subscription plans, one-time charges, free trials, plan upgrades/downgrades
- **Usage tracking** — metered billing based on what your users actually consume (API calls, seats, storage, etc.)
- **Entitlement checks** — ask Autumn if a user is allowed to do something based on their plan

**Free tier highlights:** Free to use; you only pay Stripe's standard processing fees when you charge customers.

**Usage pattern:**

```ts
// src/lib/autumn.ts
import Autumn from "autumn-js"

export const autumn = new Autumn({
  secretKey: process.env.AUTUMN_SECRET_KEY!,
})
```

Check entitlement before a gated action:

```ts
const allowed = await autumn.check({
  customerId: user.id,
  featureId: "api-calls",
})

if (!allowed.access) {
  return Response.json({ error: "Upgrade required" }, { status: 402 })
}
```

Report usage after the action:

```ts
await autumn.track({
  customerId: user.id,
  featureId: "api-calls",
  delta: 1,
})
```

**Env vars needed:**
```
AUTUMN_SECRET_KEY=<secret-key>
```

## Sanity

Headless CMS for structured content. The `sanity-studio` folder lives in your repo so schema changes are version-controlled and reviewable like any other code. Once the studio is deployed, editors can manage content from the Sanity dashboard without touching the codebase.

**What it covers:**
- **Structured content** — define schemas in code; content is stored and served via Sanity's CDN (GROQ queries or GraphQL)
- **Local studio** — run the Sanity Studio locally to iterate on schemas and preview content before publishing
- **Hosted studio** — deploy the studio to `your-project.sanity.studio` so non-technical editors can manage content directly from the Sanity dashboard

**Workflow:**
- Schema lives in `sanity-studio/` and is tracked in Git — schema changes go through normal code review
- Run `npm run dev` inside `sanity-studio/` to develop schemas locally
- Deploy schema + studio with `npx sanity deploy` when changes are ready
- Editors then use the hosted dashboard; no local setup required for content editing

**Env vars needed:**
```
SANITY_PROJECT_ID=<project-id>
SANITY_DATASET=production
SANITY_API_TOKEN=<api-token>  # server-side reads of draft content; public reads don't need this
```

**Fetching content:**
```ts
// src/lib/sanity.ts
import { createClient } from "@sanity/client"

export const sanity = createClient({
  projectId: process.env.SANITY_PROJECT_ID!,
  dataset: process.env.SANITY_DATASET ?? "production",
  apiVersion: "2024-01-01",
  useCdn: true,  // set to false when you need fresh data server-side
})
```

```ts
// Example GROQ query
const posts = await sanity.fetch(`*[_type == "post"] | order(publishedAt desc) {
  _id,
  title,
  slug,
  publishedAt,
}`)
```

**Free tier highlights:** Generous free plan — 3 users, 2 datasets, 500k API requests/month, 10 GB bandwidth.

## local-tunnel

Exposes a local HTTP server to the public internet over a secure tunnel — useful for testing webhooks, sharing a dev build, or connecting local services to third-party APIs that require a real URL.

```bash
npx localtunnel --port 3000
# → https://your-random-subdomain.loca.lt
```

Request a stable subdomain so the URL doesn't change between sessions:

```bash
npx localtunnel --port 3000 --subdomain my-app-dev
# → https://my-app-dev.loca.lt
```

**Alternatively:** [ngrok](https://ngrok.com) is a popular alternative with a dashboard, request inspector, and persistent subdomains on paid plans.

```bash
ngrok http 3000
# → https://abc123.ngrok-free.app
```

Both tools serve the same purpose — pick whichever fits your workflow. `localtunnel` requires no account; `ngrok` requires a free account but offers more features (request replay, TLS termination config, etc.).

---

## Summary

| Service | Role | Free tier |
|---------|------|-----------|
| Cloudflare | Hosting, CDN, WAF, cron, email routing, domains | 100k Workers req/day, unlimited Pages |
| Supabase | Auth, PostgreSQL, realtime | 2 projects, 500 MB DB, 50k MAU |
| Plunk | Transactional + campaign email | 3,000 emails/month |
| Trigger.dev | Background jobs, user schedules | Free for dev; generous production tier |
| Autumn | Billing, usage tracking | Free (Stripe fees only when charging) |
| Sanity | Headless CMS, structured content | 3 users, 500k API req/month, 10 GB bandwidth |
| local-tunnel / ngrok | Expose local server to the internet | local-tunnel: free, no account; ngrok: free tier available |
