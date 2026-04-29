# Hook Leads — Roadmap

Owner: Rafat (founder + Head of Product)
Last updated: 2026-04-29
Source of truth for phase ordering. Individual cycles are tracked in `projects/hook-leads/cycles/cycle-NN.md`. PM-level scope decisions are tracked as AgDRs.

---

## Phase 1 — MVP v0.1 (Cycle 1 → Cycle 6)

**Goal**: Validate the discover → enrich → outreach → qualify loop end-to-end with one paying customer, then ten.

**Status**: In progress (Cycle 1, week of 2026-04-27).

| Cycle | Theme | Tickets |
|-------|-------|---------|
| **1 — Foundation + US-1 (in progress)** | Project scaffold, Clerk auth, dashboard, ICP CRUD | T-001…T-012 (#9–#20), #26 (workspace migration) |
| **2 — US-2 + US-3** | Apollo lead discovery, ICP scoring | TBD |
| **3 — US-4** | Email outreach sequences (mailbox OAuth + Claude) | TBD |
| **4 — US-5** | Manual reply review + qualification UI | TBD |
| **5 — US-6 + Stripe** | CSV export + signed outbound webhook + paid plan | TBD |
| **6 — Hardening + launch** | Monitoring, error tracking, runbooks, public landing | TBD |

**Phase 1 success metric**: ≥10 paying users at week 4 post-launch (per PRD § Success Metrics).

---

## Phase 2 — Teams (Cycle 7+)

**Goal**: Convert validated single-user customers into team workspaces. Targets B2B sales teams ≤10 people who want shared ICPs, lead lists, and outreach without per-user duplication.

**Status**: Backlog.

| Item | Owner | Est. cycles | Tracker |
|------|-------|-------------|---------|
| **Epic — Multi-tenant: Teams + Roles** | TBD | 2–3 cycles | [#28](https://github.com/mohammadahmed-prg/hook-leads/issues/28) |
| └ US-7 Workspace switcher + active-workspace context | — | 0.5 cycle | _at Phase 2 kick-off_ |
| └ US-8 Invite teammates by email | — | 0.5 cycle | _at Phase 2 kick-off_ |
| └ US-9 Roles + permissions (Owner / Editor / Viewer) | — | 0.5–1 cycle | _at Phase 2 kick-off_ |
| └ US-10 Per-seat billing | — | 0.5 cycle | _at Phase 2 kick-off_ |
| └ US-11 Activity feed / audit log | — | 0.5 cycle | _at Phase 2 kick-off_ |

**Trigger to start Phase 2**: Phase 1 reaches ≥10 paying users *and* ≥3 of them request team access. (Validate demand before building.)

**Foundation already in place** (don't have to be re-done at Phase 2 kick-off):
- Workspace-keyed schema → AgDR-0008, AgDR-0009, merged via #26
- Clerk Organizations available natively (no auth refactor needed)
- `ensureWorkspaceForUser()` server helper that becomes "resolve active workspace for user" with a one-line change

---

## Phase 3+ — Deferred / parking lot

| Item | Why parked | Tracker |
|------|------------|---------|
| WhatsApp / Telegram / LinkedIn DM channels | Email is enough to validate the loop; multi-channel is a Phase 2/3 conversion play | — |
| Vector DB for intent / signals | Cycle 4–5 telemetry will tell us whether this moves a metric | — |
| CRM integrations beyond CSV + webhook | Webhook is generic enough for Zapier / n8n bridges; native integrations only after we know which CRMs customers use | — |
| Custom domains / white-label | Agency tier feature, not founder tier | — |
| Self-serve billing portal | Stripe Checkout link is enough until customer count >50 | — |
| AI-driven qualification bot (full automation) | Current MVP is human-in-the-loop. Automation only makes sense once we have qualification data to learn from | — |
| SSO / SAML / SCIM | Enterprise feature; only after Phase 2 teams are paying and asking | — |
| Custom roles beyond Owner / Editor / Viewer | Enterprise; gated on real demand from Phase 2 customers | — |
| Cross-workspace data sharing | Speculative; revisit if requested | — |

---

## Decision log (PM-level)

These shape the roadmap and are sticky across phases:

| AgDR | Decision | Phase impact |
|------|----------|--------------|
| AgDR-0001 | Apollo for MVP data | Phase 1 only — re-evaluate at Phase 2 |
| AgDR-0002 | Outreach via user mailbox OAuth | Phase 1+ |
| AgDR-0003 | Anthropic Claude for AI generation | Phase 1+ |
| AgDR-0004 | Foundation tech stack (Next.js 16 + Clerk + Drizzle + Neon) | All phases |
| AgDR-0006 | Solo design-review policy | Phase 1 only — replaced when designer joins |
| AgDR-0007 | Post-auth redirect to /dashboard | Phase 1; Phase 2 swaps for "active workspace" landing |
| **AgDR-0008** | **Workspace-keyed schema, single-user UX (defer team UI to Phase 2)** | **Phase 1 → Phase 2 hinge** |
| AgDR-0009 | Migration plan for workspace schema | Phase 1 (delivered via #26) |
| AgDR-0010 | Auto-run drizzle-kit migrate during Vercel build | Phase 1 (applied at T-006) |
