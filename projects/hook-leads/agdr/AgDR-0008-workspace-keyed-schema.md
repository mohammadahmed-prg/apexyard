---
id: AgDR-0008
timestamp: 2026-04-29T19:30:00Z
agent: claude
model: claude-opus-4-7
trigger: user-prompt
status: executed
---

# Workspace-keyed schema with single-user UX (defer team UI to Phase 2)

> In the context of Hook Leads' MVP scope, where the founder confirmed the long-term vision includes team collaboration (marketing manager + lead-gen manager + sales ops working in one place) but the current PRD scopes the MVP as single-user, facing the choice between deferring all multi-tenant work to Phase 2 (single-user schema today, painful migration later), shipping Clerk Organizations now (~1 week of work, blocks Cycle 1, validates teams before validating the core loop), or designing the schema to be workspace-keyed today while keeping the UX single-user, I decided on the third option, accepting a small one-time schema cost (~1-2 hours) and the discipline of always passing `workspace_id` through queries in exchange for never having to re-key historical data when the team UI ships.

## Context

- The original AgDR-0004 (foundation tech stack) and the PRD (FR-10) explicitly scoped the MVP as **single-user**, with multi-tenant teams listed as out-of-scope.
- T-003 (PR #23, merged `70c4d55`) implemented the schema with `clerk_user_id` (text FK) on every domain table — `icp`, `icp_snapshot`, `lead`.
- The founder revisited the tenancy decision and confirmed teams *are* in the long-term vision (Phase 2+), specifically for B2B sales teams ≤10 people who want one shared workspace per company rather than separate accounts.
- AgDR-0004's "ship fast" principle still applies — the question is what's the cheapest hedge against a known future requirement.
- ApexYard's migration gate (`require-migration-ticket.sh`) requires a labelled ticket + matching migration AgDR before any schema-edit can proceed. This AgDR captures the **why**; the migration AgDR (forthcoming) will capture the **how / rollback**.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| **A. Defer everything to Phase 2** (current state before this AgDR) | Zero work today; matches the PRD as written; preserves Cycle 1 momentum | Painful migration later: every historical row needs a `workspace_id` backfill, plus a multi-row-per-user case if a user "becomes" multiple workspaces; the longer we wait, the more tables there are to migrate |
| B. Ship Clerk Organizations + team UI now | Validates the team use case from day 1; users can invite colleagues immediately; matches the founder's stated long-term vision earliest | Adds ~1 week to Cycle 1; introduces invite/role/switcher UI before the core loop is validated; couples MVP success metrics to a use case (teams) that wasn't in the original validation thesis; pricing model needs to change before US-1 ships |
| **C. Schema is workspace-keyed today; UX stays single-user** (chosen) | Tiny one-time cost; preserves Cycle 1 sequencing; auto-creates a personal workspace per user on first sign-in (invisible to the user); when team UI ships in Phase 2, only the invite/role/switcher work remains — no historical re-keying | Adds discipline: every query needs `workspace_id`; "current workspace" must always be available server-side (initially trivial since there's only one per user); slightly higher mental overhead in code review for the rest of MVP |
| D. Use Clerk Organizations under the hood, no team UI | Uses Clerk's primitives directly | Clerk Orgs is a billable feature past ~100 orgs; over-couples to Clerk for a reversible decision; auto-creating a Clerk org per user is awkward against Clerk's mental model |

## Decision

Chosen: **Option C — workspace-keyed schema, single-user UX**, because:

1. **The cheapest hedge against a known future requirement.** The founder has stated teams are in the long-term vision. Designing the schema for it now costs ~1-2 hours; retrofitting it later costs days plus a data migration with edge cases.
2. **Doesn't change the MVP validation thesis.** The user-visible product stays single-user; success metrics, onboarding, and the core loop don't move.
3. **Decouples from Clerk's primitives.** "Workspace" is *our* concept (a row in *our* DB), not Clerk's. If we ever leave Clerk or want a different team model, the schema is already independent.
4. **Migration story is small and self-contained.** One new `workspaces` table, one `workspace_id` FK on each domain table, a backfill that creates one workspace per existing user (currently zero, since no production data exists yet — even cheaper to do *now* than after T-006 deploys to Vercel).

This decision **modifies AgDR-0004's tenancy assumption** — AgDR-0004 noted "no `users` table … key everything on `clerk_user_id`" and that's still true at the user level. The change is at the *ownership* level: domain rows now belong to a workspace, not directly to a Clerk user. The personal-workspace pattern keeps the single-user UX honest while leaving the door open.

This decision also requires a **PRD amendment** to FR-10 ("Single-user account for MVP" → "Single-user UX, workspace-keyed schema; team UI deferred to Phase 2") — captured as a separate task in the same cycle.

## Consequences

- T-003's schema gets amended via a fresh migration (new ticket + migration AgDR via `/migration`). The amendment lands **before T-006 (Vercel deploy)** so the first production deploy already runs against the workspace-keyed shape.
- Every Cycle 1+ query that currently filters by `clerkUserId` needs to also resolve and filter by `workspaceId`. For the MVP this is mechanical — every user has exactly one workspace — but the discipline starts now.
- A user-creation hook (Clerk webhook or first-request lazy-create) will create a personal workspace on sign-up. Implementation deferred to the migration ticket.
- When team UI ships (Phase 2), the schema is already correct — only invite, role, and switcher UI work remains.
- Pricing model can stay per-user for the MVP; switch to per-seat-per-workspace in Phase 2 without schema changes.

## Artifacts

- AgDR-0004 — foundation tech stack (modified by this AgDR's tenancy assumption)
- T-003 PR #23 — original schema (`clerk_user_id` everywhere)
- PRD FR-10 amendment — separate task, same cycle
- Migration ticket + migration AgDR — produced by `/migration` (forthcoming)
