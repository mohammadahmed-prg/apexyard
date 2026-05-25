# PRD: Hook Leads — MVP (v0.1)

**Status**: Draft
**Author**: Rafat (Product Manager)
**Created**: 2026-04-26
**Last Updated**: 2026-04-26
**Idea ref**: IDEA-001 (`projects/ideas-backlog.md`, draft `projects/hook-leads/idea.md`)
**Tracking issue**: mohammadahmed-prg/apexyard#2

---

## Overview

### Problem Statement

B2B founders and small sales teams (≤10 people) lose hours every week stitching together lead extraction tools, enrichment APIs, and email outreach platforms — then doing manual qualification on top. Each tool is a partial solution, the data is inconsistent, and most leads that reach the founder's inbox aren't actually a fit. The pain is acute for early-stage SaaS founders who do sales themselves and can't afford an SDR.

Hook Leads collapses discovery → enrichment → ICP scoring → outreach → qualification into one flow, run by AI on top of compliant data sources, so a solo founder can spend an hour setting up an ICP and receive sales-ready replies instead of a pile of raw contacts.

### Target User

**Primary (MVP)**: B2B SaaS **founders and early-stage sales teams (≤10 people)** — selling to other businesses, doing their own outbound, comfortable with light tech setup, budget in the $50–300/mo range.

**Secondary (Phase 2+, out of MVP)**: Marketing / sales agencies, in-house enterprise sales teams.

Rationale for the narrow MVP segment: closest to the founder building it (faster feedback), easier to reach via Twitter / LinkedIn, simpler buying decision, no need for white-label / SSO / multi-seat / advanced integrations on day 1.

### Goals

1. **Time-to-first-qualified-reply ≤ 24h** from finishing ICP setup
2. **ICP setup completed in ≤ 15 minutes** by a non-technical founder
3. **MVP shipped in 8 weeks** from PRD approval, iterating in 1-week cycles
4. **Reply rate ≥ 25%** on outreach sequences (matches Section 11 of the idea draft)
5. **Qualified-lead rate ≥ 15%** of all leads contacted

### Non-Goals (Out of MVP)

- WhatsApp / Telegram / LinkedIn DM channels (email only for MVP)
- Full AI-driven qualification bot (manual review for MVP)
- CRM integrations beyond a CSV export + webhook
- Vector DB for intent / signals (Phase 2)
- Multi-tenant teams **UI** (invite, roles, workspace switcher) — deferred to Phase 2; schema is already workspace-keyed per **AgDR-0008**
- Custom domains, white-label
- Self-serve billing portal (Stripe Checkout link is enough for MVP)

### Success Metrics

| Metric | Target | How Measured |
|--------|--------|--------------|
| Time-to-first-qualified-reply | ≤ 24h after ICP setup | Internal event log |
| ICP setup completion time | ≤ 15 min p50 | Frontend timing event |
| Reply rate | ≥ 25% | Email service webhook (replies / sent) |
| Qualified-lead rate | ≥ 15% | Manual reviewer marks lead as qualified / total contacted |
| Data accuracy (email deliverability) | ≥ 75% | Bounce rate from email provider |
| MVP ship date | 8 weeks from PRD approval | GitHub milestone |
| Activated users (week 4 post-launch) | ≥ 10 paying | Stripe |

---

## User Stories

### US-1: Define an ICP
> As a founder, I want to define my ideal customer profile in a guided form, so that the system knows who to find and qualify.

**Acceptance Criteria**:
- [ ] Form captures: industry, job titles (multi-select), company size range, location, decision-maker flag, free-text pain points, optional buying triggers
- [ ] ICP saved to my account; I can edit and version it
- [ ] At least one ICP required before I can run discovery
- [ ] Setup p50 ≤ 15 minutes (instrumented)

### US-2: Discover leads matching the ICP
> As a founder, I want to run a discovery job against my ICP, so that I get a list of matching prospects without operating a scraper.

**Acceptance Criteria**:
- [ ] I click "Discover" and select an ICP
- [ ] The system uses a third-party data provider (see Open Question 1) to return up to 100 leads per job in MVP
- [ ] Each raw lead has: name, job title, company, company size, location, source URL
- [ ] Job runs async; I see progress and can leave the page
- [ ] Failures show a clear retry / contact-support state

### US-3: Enrich and score leads against my ICP
> As a founder, I want each discovered lead enriched with verified contact data and scored 0–100 against my ICP, so that I prioritize the right ones.

**Acceptance Criteria**:
- [ ] Email verification runs on every lead (verified / unverified / failed status)
- [ ] Score uses the rubric from the idea draft (job title 30 / industry 25 / company size 15 / pain 20 / signals 10)
- [ ] Classification: Reject / Cold / Warm / Hot, computed from score thresholds
- [ ] Lead list is sortable and filterable by score and classification

### US-4: Run an email outreach sequence to Warm + Hot leads
> As a founder, I want to send a multi-step, personalized email sequence to Warm and Hot leads, so that I generate replies without manual sending.

**Acceptance Criteria**:
- [ ] I author a 3-step sequence with delays (e.g. day 0, day 3, day 7)
- [ ] AI generates the per-lead personalized body using the lead's profile
- [ ] I can preview and approve before send for the first sequence (safety rail)
- [ ] Sequence respects timezone of the lead's location (send between 8–11am local)
- [ ] Reject-classified leads cannot be added to a sequence (enforced server-side)
- [ ] Replies pause the sequence automatically

### US-5: Manually review replies and mark as qualified
> As a founder, I want to see all replies in one inbox-like view and mark each as Qualified / Not Qualified / Nurture, so that the qualified ones flow to my CRM workflow.

**Acceptance Criteria**:
- [ ] Replies aggregated across leads, newest first
- [ ] One-click classification per reply
- [ ] Qualified leads appear in an exportable list (CSV) and trigger an outbound webhook
- [ ] Score updates persist; lead history shows the score progression

### US-6: Export qualified leads / fire a webhook
> As a founder, I want qualified leads to land in my CRM via webhook or CSV, so that I can act on them in my existing workflow.

**Acceptance Criteria**:
- [ ] CSV export of qualified leads with all enriched fields
- [ ] Configurable outbound webhook URL with HMAC signature
- [ ] Webhook fires on qualification, with retry on 5xx (3 attempts, exponential backoff)

### Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Discovery returns zero leads | Show "no matches" with hint to broaden ICP; do not charge / consume credit |
| Email verifier marks all leads as unverified | Block sequence start; surface error to user |
| Provider API down | Job marked failed; user can retry in 30m |
| User edits ICP mid-sequence | Existing sequence continues with old ICP snapshot; new discoveries use new ICP |
| Reply contains "unsubscribe" / "stop" | Auto-mark Reject, suppress address globally for that user account |
| GDPR deletion request | Soft-delete + 30-day hard-delete cron; webhook to admin |

---

## Requirements

### Functional Requirements

| ID | Requirement | Priority | Notes |
|----|-------------|----------|-------|
| FR-1 | ICP CRUD | Must | One ICP per user is fine for MVP; multiple is Should |
| FR-2 | Lead discovery against third-party provider | Must | See Open Question 1 — provider AgDR required before Build |
| FR-3 | Email verification per lead | Must | Hunter / NeverBounce / ZeroBounce |
| FR-4 | ICP scoring engine 0–100 | Must | Server-side, idempotent, replayable |
| FR-5 | 3-step email sequence with delays | Must | |
| FR-6 | AI-generated personalized email body | Must | OpenAI or Anthropic — model choice = AgDR |
| FR-7 | Reply detection + auto-pause | Must | Inbound email parsing via webhook |
| FR-8 | Manual qualification UI | Must | MVP: human-in-the-loop, not the AI bot |
| FR-9 | CSV export + outbound webhook | Must | Webhook signed with HMAC-SHA256 |
| FR-10 | Auth (email + magic link or OAuth) | Must | Single-user UX for MVP; schema workspace-keyed (auto-created personal workspace per user) per AgDR-0008. Team UI is Phase 2. |
| FR-11 | Stripe checkout for paid plan | Must | One $49/mo plan to start; Should = annual |
| FR-12 | Multiple ICPs per account | Should | |
| FR-13 | A/B test outreach copy | Could | Phase 2 |
| FR-14 | Vector DB for intent signals | Could | Phase 2 |

### Non-Functional Requirements

| Category | Requirement | Target |
|----------|-------------|--------|
| Performance | Lead-list page load | ≤ 2s for 100 leads |
| Performance | Discovery job throughput | ≥ 100 leads / 5 min |
| Security | Auth | Magic link or Google OAuth |
| Security | Webhook payload signing | HMAC-SHA256 with per-user secret |
| Compliance | GDPR deletion | Soft + hard delete within 30 days |
| Compliance | CAN-SPAM / opt-out | Unsubscribe link in every email |
| Reliability | Sequence delivery | 99% of scheduled steps delivered within 1h of target |
| Observability | Error tracking | Sentry on backend + frontend |
| Observability | Event log | All discovery / score / send / reply events logged with user_id |

---

## Design

### User Flow

```
[Sign up + magic link]
    |
    v
[ICP setup wizard] ─ ≤ 15 min ─┐
    |                          |
    v                          |
[Save ICP] ────────────────────┘
    |
    v
[Run discovery] ──> [Provider returns leads] ──> [Verify + enrich] ──> [Score]
    |
    v
[Lead list, sorted by score]
    |
    v
[Author 3-step sequence] ──> [Preview + approve first send]
    |
    v
[Sequence runs] ──> [Replies arrive] ──> [Inbox view]
    |
    v
[Manual classify: Qualified / Not / Nurture]
    |
    v
[Qualified ──> CSV + webhook]
```

### Wireframes / Mockups

To be produced by the UI Designer role activation post-PRD approval. Key screens:
- ICP setup wizard
- Lead list (sortable, filterable)
- Sequence author + preview
- Reply inbox + qualification action

---

## Technical Notes

### Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| Third-party lead data provider (Apollo / Clay / Lusha / Hunter) | External | **Pending AgDR** | Tech Lead |
| Email-sending infra (Resend / Postmark / SES) | External | Pending AgDR | Tech Lead |
| Email verification (Hunter / NeverBounce) | External | Pending AgDR | Tech Lead |
| AI provider (OpenAI / Anthropic) | External | Pending AgDR | Tech Lead |
| Stripe | External | Ready | Rafat |
| n8n | Internal automation | Ready | Rafat |
| Vercel + Postgres | Hosting | Ready | Rafat |

### Technical Constraints

- Solo founder — keep operational surface area small. No Kubernetes, no custom infra. Vercel + managed Postgres + n8n for workflows.
- Cost ceiling: external API spend per active user must allow a $49/mo plan with ≥ 60% margin.
- AgDRs required before Build for: data provider choice, email-sending provider, AI provider, scoring rubric implementation.

---

## Launch Plan

### Rollout Strategy

- [x] Beta program first — 10 hand-picked B2B SaaS founders (Twitter / personal network), free for 4 weeks in exchange for feedback
- [ ] Public launch on Product Hunt + Twitter at week 8
- [ ] Phased rollout: 10 → 25 → 50 → open

---

## Open Questions

| # | Question | Owner | Status | Resolution |
|---|----------|-------|--------|------------|
| 1 | Which third-party data provider for MVP? Apollo, Clay, Lusha, Hunter, multi-source? | Tech Lead | Open — AgDR | Decision before Build |
| 2 | Which email-sending provider (Resend / Postmark / SES)? | Tech Lead | Open — AgDR | Decision before Build |
| 3 | Which AI provider for outreach generation (OpenAI / Anthropic)? | Tech Lead | Open — AgDR | Decision before Build |
| 4 | Pricing tiers beyond the single $49/mo plan? | Rafat | Open | Defer until 25 paying users |
| 5 | Custom domain for sending vs shared? | Tech Lead | Open | Likely shared for MVP, custom in Phase 2 |
| 6 | LinkedIn discovery in MVP, or pure provider data? | Rafat | **Decided: provider data only** | LinkedIn direct = post-MVP |

---

## Timeline

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| PRD Approved | 2026-04-28 | Draft |
| Provider + email + AI AgDRs | 2026-05-03 | Pending |
| Tech Design (Tech Lead) | 2026-05-05 | Pending |
| Build kickoff | 2026-05-06 | — |
| Alpha (internal use, 1 ICP, ≤ 50 leads) | 2026-05-20 (week 4) | — |
| Beta (10 hand-picked founders) | 2026-06-10 (week 6) | — |
| MVP launch (Product Hunt + public) | 2026-06-24 (week 8) | — |

---

## Approvals

| Role | Name | Date | Status |
|------|------|------|--------|
| Product Manager | Rafat | 2026-04-26 | Author |
| Head of Product | Rafat | | Pending self-review |
| Tech Lead | Rafat | | Pending |
| Head of Design | n/a (solo) | | — |
