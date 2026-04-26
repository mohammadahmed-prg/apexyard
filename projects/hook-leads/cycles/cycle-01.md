# Cycle 1 — Foundation + US-1 (Define an ICP)

**Dates**: 2026-04-27 → 2026-05-03 (Mon → Sun)
**Linear cycle**: HOO Cycle 1
**Linear project**: [Hook Leads MVP v0.1](https://linear.app/hook-leads/project/hook-leads-mvp-v01-cb6af00da202)
**Capacity**: ~30 focused hours (solo, ~6 h/day × 5 days, weekend buffer)
**Status**: planned

---

## Goal

End Cycle 1 with a deployed Next.js app on Vercel, magic-link auth working, and a paying-feature-style ICP form (`US-1`) that persists ICPs to Postgres. Foundation + first user story shipped.

## Definition of Done

- [ ] App deployed to Vercel (preview + production environments wired)
- [ ] Auth: user can sign up via magic-link email, sign in, sign out
- [ ] User can create, edit, list, and delete one or more ICPs through a form
- [ ] ICP setup p50 ≤ 15 minutes (instrumented event, baseline captured)
- [ ] CI green on every PR (lint + typecheck + test + build)
- [ ] AgDR-0004 (foundation tech stack) + AgDR-0005 (transactional email) written and committed
- [ ] All Cycle 1 Linear issues moved to Done; matching GitHub issues closed
- [ ] HOO-8 / hook-leads#1 (US-1) closed as Done

## Out of Cycle 1

- Stripe / billing (Cycle 7)
- Apollo data integration / lead discovery (Cycle 2)
- Email outreach + Claude (Cycle 4–5)
- Reply inbox (Cycle 6)
- CSV / webhook handoff (Cycle 7)
- Marketing site / Product Hunt prep (Cycle 8)

---

## Task list

Two pre-Build decisions, seven foundation tasks, five US-1 build tasks. **14 items total.**

### Decisions (must come first)

| ID | Title | Effort | Output |
|----|-------|--------|--------|
| D-001 | AgDR-0004 — Foundation tech stack: App Router, ORM (Prisma vs Drizzle), auth lib (NextAuth vs Lucia), DB host (Neon vs Vercel Postgres vs Supabase) | 1.5 h | `projects/hook-leads/agdr/AgDR-0004-*.md` |
| D-002 | AgDR-0005 — Transactional email provider for magic-link auth (Resend recommended) | 0.5 h | `projects/hook-leads/agdr/AgDR-0005-*.md` |

### Foundation

| ID | Title | Depends on | Effort |
|----|-------|------------|--------|
| T-001 | Init Next.js 15 + TypeScript + Tailwind in `workspace/hook-leads/` | D-001 | 1 h |
| T-002 | Database provisioning — Neon Postgres (free tier) project + connection string in `.env` | T-001 | 1 h |
| T-003 | Prisma init + base schema (`User`, `ICP`, `Lead` skeleton) + first migration | T-002 | 2 h |
| T-004 | Auth scaffold — NextAuth.js with Resend magic-link adapter; `User` table wired | T-003, D-002 | 5 h |
| T-005 | Base layout + protected routes + sign-in / sign-out flow + minimal nav | T-004 | 2 h |
| T-006 | Vercel project + production deploy + env config (DB url, Resend key, NextAuth secret) | T-005 | 1 h |
| T-007 | GitHub Actions CI — `lint + typecheck + test + build` (matches `onboarding.yaml` required_checks) | T-001 | 1 h |

### US-1 — Define an ICP (children of HOO-8 / hook-leads#1)

| ID | Title | Depends on | Effort |
|----|-------|------------|--------|
| T-008 | ICP form UI — single page, all fields per PRD US-1 ACs | T-005 | 4 h |
| T-009 | ICP CRUD API routes — POST / GET / PUT / DELETE with auth guard | T-003 | 3 h |
| T-010 | ICP versioning — `ICPSnapshot` table + capture-on-sequence-run (referenced by Cycle 2 work) | T-009 | 2 h |
| T-011 | Setup-time instrumentation — emit `icp.setup.completed` event with duration, log to Vercel Analytics or simple DB row | T-008 | 1 h |
| T-012 | US-1 acceptance test + manual QA — automated test for AC, manual walkthrough against PRD ACs | T-008 / T-009 / T-010 / T-011 | 2 h |

**Effort total**: ~26 hours of build + 2 hours of decisions = **28 h** in a 30 h budget. Buffer for unknowns built in.

---

## Day-by-day plan

| Day | Date | Focus |
|-----|------|-------|
| Mon | 2026-04-27 | D-001, D-002, T-001 (init), T-002 (DB) |
| Tue | 2026-04-28 | T-003 (Prisma + schema), T-004 (auth start) |
| Wed | 2026-04-29 | T-004 (auth finish), T-005 (layout + protected routes) |
| Thu | 2026-04-30 | T-006 (Vercel deploy), T-007 (CI), T-008 start (ICP form) |
| Fri | 2026-05-01 | T-008 finish, T-009 (ICP API) |
| Sat | 2026-05-02 | T-010 (versioning), T-011 (instrumentation) |
| Sun | 2026-05-03 | T-012 (QA), buffer, cycle close |

---

## Risks for Cycle 1

| Risk | Mitigation |
|------|-----------|
| NextAuth + magic-link setup eats more than 5 h (Resend domain verification, DKIM, callback URLs) | Bail out to GitHub OAuth as fallback if magic link blocks > 1 day; capture in AgDR-0005 |
| Prisma + Neon connection-pooling weirdness on Vercel serverless | Use Neon's serverless driver; documented in AgDR-0004 |
| ICP form UX is the user's first impression — risk of over-investing in design vs. shipping | Time-box T-008 to 4 h; ship plain Tailwind form, polish in Cycle 2 if needed |
| Gate: Tech Design (`require_technical_design: false` in `onboarding.yaml`) — not blocking, but AgDR-0004 covers it | None — by design |

---

## Cross-references

| Where | What |
|-------|------|
| GitHub epic | mohammadahmed-prg/apexyard#3 (portfolio-level) |
| GitHub user story | mohammadahmed-prg/hook-leads#1 (US-1) |
| Linear project | Hook Leads MVP v0.1 |
| Linear US-1 | HOO-8 |
| PRD | `projects/hook-leads/prd-mvp.md` US-1 |
| AgDRs to write | 0004, 0005 |

---

## How tasks are tracked

- **Each task gets a Linear issue** in Cycle 1 (HOO-XX), labelled `mvp` and either `agdr` (decisions) or `user-story` (build). US-1 build tasks are children of HOO-8.
- **Each task gets a matching GitHub issue** in `mohammadahmed-prg/hook-leads`, prefix `[T-NNN]`, with the Linear ID in the body for cross-reference.
- **One ticket at a time** — work the active ticket via `/start-ticket`; complete fully before the next.
- **PRs** target the matching GitHub task issue; the parent user story (hook-leads#1) closes when its T-tasks all close.
