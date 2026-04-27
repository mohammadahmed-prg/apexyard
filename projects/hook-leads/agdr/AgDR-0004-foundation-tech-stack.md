---
id: AgDR-0004
timestamp: 2026-04-27T10:59:12Z
agent: claude
model: claude-opus-4-7
trigger: user-prompt
status: executed
---

# Foundation tech stack: Next.js App Router + Drizzle + Neon + Clerk + Vercel

> In the context of starting Cycle 1 (Foundation + US-1) for Hook Leads MVP with a 30 h solo capacity and a "ship fast, learn faster" value, facing four entangled choices (routing, ORM, auth library, DB host) where each shapes serverless cold-start performance, build velocity, and operational surface, I decided on Next.js 15 App Router + Drizzle ORM + Neon Postgres + Clerk for auth + Vercel for hosting + Tailwind/shadcn-ui for styling, accepting Clerk's auth vendor lock-in (mitigated by free tier covering MVP scale and `clerk_user_id` as a portable FK throughout our schema) in exchange for ~4.5 h of reclaimed Cycle 1 capacity vs the originally planned NextAuth+Resend stack.

## Context

- Cycle 1 plan in `projects/hook-leads/cycles/cycle-01.md` budgets 28 h against a 30 h solo capacity. T-004 (auth) was originally 5 h — the largest single task. Auth choice has the biggest schedule lever in Cycle 1.
- Hook Leads runs on Vercel serverless. Cold-start performance and bundle size matter; ORM and auth library choices both feed into this.
- AgDRs 0001–0003 already commit Hook Leads to Apollo (data), user-mailbox OAuth (outreach sending), and Anthropic Claude (AI generation). This AgDR fills in the remaining foundation choices.
- Solo-founder context: "ship fast" stated value in `onboarding.yaml`; reduce ops surface where the trade-off is favourable.
- Future B2B SaaS with potential SSO / enterprise-customer asks: auth is critical infra and migration risk should be sized realistically, not dismissed.

## Options Considered

Four sub-decisions, presented as one because they need to fit each other.

### 1. Routing — App Router vs Pages Router

| Option | Pros | Cons |
|---|---|---|
| **App Router** | Default in Next.js 15; React Server Components + streaming + nested layouts; current tutorials/docs target it; AI tooling has stronger context | Steeper mental model for caching / RSC boundaries |
| Pages Router | Simpler, mature | A regression — community is migrating away |

### 2. ORM — Prisma vs Drizzle

| Option | Pros | Cons |
|---|---|---|
| Prisma | Most popular; mature; great DX; rich migration tooling | Heavy bundle; slower cold starts on Vercel serverless; needs Prisma Accelerate for serious serverless work |
| **Drizzle** | TypeScript-native schema (no DSL); tiny bundle; excellent serverless cold-start; native Neon driver; clean raw-SQL escape hatch | Smaller community; some advanced patterns less documented |

### 3. Auth — Clerk vs Auth.js v5 vs Lucia

| Option | Pros | Cons |
|---|---|---|
| **Clerk** | ~30 min setup vs ~5 h; pre-built sign-in / up UI; magic link, social, MFA, MFA recovery, account management out of box; free up to 10 k MAU; security defaults better than rolled-our-own; auth emails handled — no Resend deliverability work for Cycle 1 | Vendor lock-in for critical infra; profile data lives in Clerk; $25 + $0.02/MAU after free tier; future migration is non-trivial |
| Auth.js v5 (NextAuth) + Drizzle adapter + Resend magic link | Free; user data in your DB; industry-standard pattern; composes with Drizzle | ~5 h setup; email deliverability is your problem (DKIM, domain verify); edge-runtime gotchas; you maintain auth code over time |
| Lucia | Lightweight; full control | More glue code than Auth.js without enough speed gain to justify; smaller ecosystem |

### 4. DB host — Neon vs Vercel Postgres vs Supabase

| Option | Pros | Cons |
|---|---|---|
| **Neon** | Generous free tier (191 compute hrs/mo, 0.5 GB); database branching for Vercel preview deploys; native serverless driver; portable (no Vercel lock-in) | None significant at MVP scale |
| Vercel Postgres | Same engine as Neon under the hood; integrated billing | Smaller free tier; couples DB billing to Vercel |
| Supabase | All-in-one Postgres + auth + storage + realtime + edge functions | We're not using Supabase auth (Clerk picked) or its other modules; the all-in-one is overkill; smaller Postgres-only free tier |

## Decision

Chosen: **Next.js 15 App Router + Drizzle ORM + Neon Postgres + Clerk auth + Vercel hosting + Tailwind / shadcn-ui styling.**

Justification, sub-decision by sub-decision:

1. **App Router**: clear win. The community, docs, and AI tooling have all moved here. Picking Pages Router would be a regression.
2. **Drizzle**: a deliberate over-Prisma choice driven by serverless economics. Smaller bundle, faster cold starts, TypeScript-native schema, native Neon support. The Prisma DX advantage is real but eroded on Vercel where cold starts are user-visible. Schema-as-TypeScript keeps the entire stack in one type system, which helps a solo founder maintain everything in their head.
3. **Clerk**: the load-bearing trade-off in this AgDR. NextAuth would be ideologically purer (free, owns user data, composes with Drizzle) but costs ~5 h of Cycle 1 capacity to set up correctly with Resend, DKIM, edge-runtime sessions, and email deliverability. Clerk reclaims that 4–4.5 h for product work. The lock-in risk is bounded: `clerk_user_id` becomes the foreign key on every other table; if we ever need to migrate, we replace the auth provider behind a small adapter while keeping every other table's FK intact. The 10 k MAU free-tier ceiling is generous for a solo MVP and gives a clean signal point ("we're at PMF, time to revisit") rather than a surprise bill.
4. **Neon**: branching for preview deploys is a real productivity feature, not a nice-to-have. It makes schema changes safe to ship behind a preview URL without polluting prod data. Free tier covers MVP many times over.

## Consequences

- **Cycle 1 plan changes**:
  - T-004 (auth) drops from 5 h → ~30 min. Update HOO-19 / hook-leads#12 title and effort estimate.
  - **AgDR-0005 (transactional email) deferred** out of Cycle 1. Clerk handles auth emails. Hook Leads has no in-product transactional emails in MVP scope (billing receipts come from Stripe Checkout in a later cycle; no notifications until Phase 2). Revisit AgDR-0005 when an in-product transactional need actually surfaces.
  - Reclaimed ~4.5 h goes to buffer (more realistic than packing more tasks).
- **Schema shape**: `User` table replaced by per-feature tables keyed on `clerk_user_id` (string). No need to mirror Clerk's user records into our DB. Profile fields (name, email, avatar) come from Clerk's API or `useUser()` hook.
- **Local development**: Clerk requires a dev instance and a `.env.local` with publishable + secret keys. Document this in the project's README before T-004.
- **Domain & email**: no domain verification needed for auth. Saves a real chunk of setup time.
- **Security posture**: Clerk's security defaults (rate limiting, suspicious-login detection, automatic password compromise checks) come for free. A future `Security Auditor` activation should still review the integration before public launch — confirm session length, MFA enforcement policy, and webhook signature verification.
- **Cost over time**: free up to 10 k MAU. At 10 k → $25/mo flat + $0.02 per MAU above. By 50 k MAU we'd be at ~$1 k/mo on auth alone — at that scale the migration to Auth.js + Drizzle is justified, and we'd have the resources to do it deliberately.
- **Drizzle migration ergonomics**: Drizzle uses `drizzle-kit` for migrations. Less mature than Prisma's migrations but sufficient for our schema scale. Keep migrations in `drizzle/` directory; use `drizzle-kit push` for dev, `drizzle-kit migrate` for prod.
- **Neon connection pooling**: use Neon's pooled connection string for serverless functions; the unpooled one only for migrations. Document both URLs in `.env.local` template.
- **shadcn/ui**: not a separate decision — it's the de facto pairing with Tailwind for App Router projects, copies components into your repo (no runtime dependency), and avoids component-library lock-in. Worth using.

## Artifacts

- Cycle 1 plan: `projects/hook-leads/cycles/cycle-01.md` (will be updated to reflect T-004 effort change)
- PRD: `projects/hook-leads/prd-mvp.md`
- Tracking issue (Linear): HOO-14 (D-001)
- Tracking issue (GitHub): https://github.com/mohammadahmed-prg/hook-leads/issues/7
- Related decisions: AgDR-0001 (Apollo), AgDR-0002 (mailbox OAuth), AgDR-0003 (Anthropic Claude)
- Deferred: AgDR-0005 (transactional email) — out of Cycle 1, revisit when needed
