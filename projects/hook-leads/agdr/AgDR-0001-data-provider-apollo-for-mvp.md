---
id: AgDR-0001
timestamp: 2026-04-26T17:45:16Z
agent: claude
model: claude-opus-4-7
trigger: user-prompt
status: executed
---

# Data provider: Apollo.io for Hook Leads MVP

> In the context of Hook Leads MVP needing one external provider for ICP-based lead discovery, enrichment, and email verification on an 8-week solo-founder timeline, facing a hard cost ceiling that allows ~$15/user/mo of external API spend at a $49/mo plan with ≥60% margin, I decided to use **Apollo.io** as the sole data provider for v0.1, accepting Apollo's resale-of-contact-data ToS risk pending a commercial-terms review before public launch.

## Context

- MVP must satisfy PRD `FR-2` (ICP-based discovery), `FR-3` (email verification), and most enrichment fields in Module 3 of `projects/hook-leads/idea.md`, with a single external integration to keep the 8-week build tractable for one engineer.
- Solo founder cost ceiling: ~$15/user/mo of total external API spend at the $49/mo plan to keep ≥60% gross margin.
- Hook Leads is downstream of the data provider — quality, latency, and ToS terms of the chosen provider become Hook Leads' constraints.
- Public launch (week 8, target 2026-06-24) requires confidence in the legal posture of redisplaying provider contact data to paying users.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| **Apollo.io** | One API covers discovery + enrichment + verification; 270M+ B2B contact database; native ICP-shaped filters (industry / title / company size / location / seniority); pricing tiers with API access start ~$49–99/mo; documented webhook + bulk job patterns; familiar to target users (already used by many B2B SaaS founders) | ToS restricts reselling / redisplaying contact data — partner / commercial review required before charging end users; rate limits on lower tiers; data quality varies for non-US SMB; competitive overlap (Apollo itself sells outreach) |
| Clay | Best-in-class multi-source aggregator (Apollo + LinkedIn proxies + Hunter + Snov, etc.); strong AI enrichment templates | $149–349/mo; credit-based pricing burns very fast at MVP volumes; primarily a no-code product, API access is secondary; reselling on top destroys the $49/mo margin |
| Lusha | High-quality direct dials and EU coverage; GDPR-focused; clean API | Enrichment-of-known-names rather than ICP-based discovery — fails the core FR-2 requirement; expensive per credit at MVP volumes |
| Hunter.io | Excellent email find + verification; simple API; founder-friendly pricing (~$49/mo) | Not a discovery tool — requires an input list of companies/people; fails FR-2 on its own; would force a second provider integration to satisfy discovery |
| Multi-source (Apollo + Hunter + custom layer) | Best data coverage; no single point of failure; pricing flexibility | ~4× the integration effort, billing reconciliation across vendors, deduplication logic, and abstraction layer all blow the 8-week timeline; wrong shape for an MVP that hasn't validated the core loop |

## Decision

Chosen: **Apollo.io as the sole external data provider for MVP v0.1**, because it is the only single-provider option that simultaneously satisfies discovery (FR-2), enrichment (Module 3), and verification (FR-3) at a cost compatible with a $49/mo plan and a solo-founder integration timeline. The multi-source approach is correct long-term but wrong for MVP — premature complexity that delays validating whether the ICP-scoring + AI-outreach loop converts at all.

The ToS resale risk is real and is the primary trade-off. Mitigation:

1. **Commercial review before public launch (week 8)** — review Apollo's API terms, contact partnerships@apollo.io if needed, and confirm Hook Leads' use case is permitted. If not, escalate to a partner agreement or fall back to the multi-source plan.
2. During the closed beta (weeks 6–8, 10 hand-picked founders, no public traffic), the legal posture is lower risk because users are essentially co-developers, not paying customers.
3. Document the fallback plan: if Apollo says no, swap discovery to a compliant alternative (e.g. People Data Labs, ZoomInfo API, or a multi-source layer over Hunter + Snov + Clearbit-equivalents).

## Consequences

- **Build**: Hook Leads has exactly one external data integration to write, drastically reducing the API-client / billing / dedup surface area for MVP.
- **Operational**: Apollo rate limits and credit consumption become a per-user cost line; needs metering and a per-user credit cap to prevent margin runaway.
- **Legal**: Hard dependency on a single provider's ToS — adds a week-7 task to confirm commercial terms before public launch, and a contingency branch in the roadmap if Apollo declines.
- **Product**: Some lead types (especially non-US SMB and very early-stage companies) may have weaker data; the lead-list UI must surface confidence / verification state per field so users aren't surprised by gaps.
- **Future flexibility**: The data-source layer must be implemented behind an interface (e.g. `LeadDiscoveryProvider`, `EnrichmentProvider`) so swapping or adding providers post-MVP is a contained change. This is itself a Tech Design item, not a separate AgDR.
- **Cost model**: Sets the upper bound on plan pricing. If Apollo's per-credit cost moves Hook Leads above the $15/user/mo ceiling at expected discovery volumes, the $49/mo plan must be revised.

## Artifacts

- PRD: `projects/hook-leads/prd-mvp.md` (FR-2, FR-3, Open Question 1)
- Idea draft: `projects/hook-leads/idea.md` (Modules 2–3)
- Tracking issue: https://github.com/mohammadahmed-prg/apexyard/issues/2
- Follow-up task: commercial terms review before week 8 (to be added to the Hook Leads MVP epic when created)
