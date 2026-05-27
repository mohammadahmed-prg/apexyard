# Cycle 2 — US-2 (Discover leads) + US-3 (Enrich + score)

**Dates**: 2026-05-28 → 2026-06-07 (Thu → Sun, ~11 calendar days incl. one weekend)
**Linear cycle**: HOO Cycle 2
**Linear project**: [Hook Leads MVP v0.1](https://linear.app/hook-leads/project/hook-leads-mvp-v01-cb6af00da202)
**Capacity**: ~30 focused hours (solo, ~6 h/day × 5 days, weekend buffer)
**Status**: planned

---

## Goal

End Cycle 2 with a user able to click "Discover" on a saved ICP, get up to 100 Apollo-sourced leads asynchronously, see every lead's email verified and scored 0–100 against the ICP, and filter/sort the resulting list by classification (Reject / Cold / Warm / Hot). The discover → enrich → score loop runs end-to-end on a deployed Vercel build.

## Definition of Done

- [ ] User can run a discovery job from the dashboard; job survives navigating away
- [ ] Apollo API client + async job runner shipped (decisions captured as AgDRs first)
- [ ] `discovery_job` table migrated cleanly via `/migration`
- [ ] Email verification provider integrated; status populated on every lead
- [ ] Scoring rubric (30/25/15/20/10) implemented as pure functions; tested
- [ ] Classification (Reject/Cold/Warm/Hot) computed from score thresholds
- [ ] `/dashboard/leads` page sortable + filterable
- [ ] CI green on every PR (lint + typecheck + test + build); no test deferrals
- [ ] AgDRs written: async job runner + email verification provider pick
- [ ] All Cycle 2 GitHub issues closed
- [ ] US-2 / hook-leads#2 and US-3 / hook-leads#3 closed as Done

## Out of Cycle 2

- Email outreach sequences (US-4 — Cycle 3)
- Reply review + qualification (US-5 — Cycle 4)
- CSV / webhook handoff + Stripe (US-6 — Cycle 5)
- AI-powered re-ranking on top of the rule-based score (Cycle 6+; rubric is deterministic for MVP)
- Multi-ICP per workspace (FR-12; deferred to Phase 2)
- Apollo rate-limit + cost dashboarding (revisit if discovery job latency becomes user-visible)

---

## Task list

Twelve tickets across the two user stories, all filed in mohammadahmed-prg/hook-leads on 2026-05-27.

### US-2 — Lead discovery (children of hook-leads#2)

| ID | Title | Issue | Depends on | Effort |
|----|-------|-------|------------|--------|
| T-013 | Apollo API client (search + error handling) | [#36](https://github.com/mohammadahmed-prg/hook-leads/issues/36) | foundational | 2 h |
| T-014 | `discovery_job` table + migration — **run `/migration` first** | [#37](https://github.com/mohammadahmed-prg/hook-leads/issues/37) | foundational | 1 h |
| T-015 | Async job runner (Vercel Cron vs queue) — **AgDR required** | [#38](https://github.com/mohammadahmed-prg/hook-leads/issues/38) | T-014 | 3 h |
| T-016 | POST /api/discovery route | [#39](https://github.com/mohammadahmed-prg/hook-leads/issues/39) | T-013, T-014, T-015 | 2 h |
| T-017 | Lead persistence from Apollo response | [#40](https://github.com/mohammadahmed-prg/hook-leads/issues/40) | T-013, T-014, T-015, T-016 | 2 h |
| T-018 | Discovery UI (button + ICP picker + progress) | [#41](https://github.com/mohammadahmed-prg/hook-leads/issues/41) | T-016, T-017 | 4 h |
| T-019 | US-2 acceptance test + manual QA — **closes US-2** | [#42](https://github.com/mohammadahmed-prg/hook-leads/issues/42) | T-013–T-018 | 2 h |

### US-3 — Enrich + score (children of hook-leads#3)

| ID | Title | Issue | Depends on | Effort |
|----|-------|-------|------------|--------|
| T-020 | Email-verification provider integration — **AgDR required** | [#43](https://github.com/mohammadahmed-prg/hook-leads/issues/43) | T-017 | 3 h |
| T-021 | Scoring rubric (30/25/15/20/10) | [#44](https://github.com/mohammadahmed-prg/hook-leads/issues/44) | T-017 | 1 h |
| T-022 | Classification thresholds (Reject/Cold/Warm/Hot) | [#45](https://github.com/mohammadahmed-prg/hook-leads/issues/45) | T-021 | 1 h |
| T-023 | Lead list UI (sortable + filterable) | [#46](https://github.com/mohammadahmed-prg/hook-leads/issues/46) | T-017, T-021, T-022 | 4 h |
| T-024 | US-3 acceptance test + manual QA — **closes US-3 and Cycle 2** | [#47](https://github.com/mohammadahmed-prg/hook-leads/issues/47) | T-020–T-023 | 2 h |

**Effort total**: ~27 h in a 30 h budget. Slack reserved for the two AgDRs (T-015 + T-020) and the migration flow (T-014), which historically run over the estimate.

---

## Decisions to capture first

Three artefacts must land before the matching build ticket starts. The hooks enforce this — `require-agdr-for-arch-pr.sh` will block a PR adding a runner / provider dep without an AgDR; `require-migration-ticket.sh` will block edits to migration paths without the migration AgDR.

| ID | Decision | Trigger ticket | Hook that enforces |
|----|----------|----------------|--------------------|
| D-003 | Async job runner pick (Vercel Cron + DB queue vs Inngest vs Trigger.dev vs Vercel Background) | T-015 / #38 | `require-agdr-for-arch-pr.sh` on `package.json` dep adds |
| D-004 | Email-verification provider pick (NeverBounce vs ZeroBounce vs Hunter vs Million Verifier vs Reoon) | T-020 / #43 | `require-agdr-for-arch-pr.sh` on dep adds |
| D-005 | `discovery_job` migration AgDR (rollback, blast radius, observability) | T-014 / #37 | `require-migration-ticket.sh` on migration-path edits |

---

## Day-by-day plan

| Day | Date | Focus |
|-----|------|-------|
| Thu | 2026-05-28 | D-003 AgDR (job runner) + T-013 Apollo client |
| Fri | 2026-05-29 | D-005 migration AgDR via `/migration` + T-014 migration + T-015 runner |
| Sat | 2026-05-30 | Off |
| Sun | 2026-05-31 | Off |
| Mon | 2026-06-01 | T-016 POST /api/discovery + T-017 lead persistence |
| Tue | 2026-06-02 | T-018 discovery UI (full day) |
| Wed | 2026-06-03 | T-019 US-2 acceptance + close US-2; D-004 AgDR |
| Thu | 2026-06-04 | T-020 verification provider + T-021 scoring |
| Fri | 2026-06-05 | T-022 classification + T-023 lead list (start) |
| Sat | 2026-06-06 | T-023 finish + buffer |
| Sun | 2026-06-07 | T-024 US-3 acceptance + close US-3 + Cycle 2 retro |

---

## Risks for Cycle 2

| Risk | Mitigation |
|------|-----------|
| Apollo API credit burn during dev — every test run hits the live API | Stub/mock Apollo in Vitest; gate live calls behind `APOLLO_LIVE=1` env; cap MVP discovery at 100 leads per job per the PRD |
| Async job runner pick locks us into a vendor (Inngest / Trigger.dev) | AgDR (D-003) must compare cost at MVP scale + exit cost; prefer Vercel-native (Cron + DB queue) unless a third-party has a decisive edge |
| Email-verification accuracy varies wildly across providers | AgDR (D-004) should reference independent accuracy studies, not vendor self-claims; budget for a small live sample test before committing |
| Migration on a populated table (if Cycle 1 leads exist) | `discovery_job` is a new table; no FK changes to existing rows. Migration AgDR documents the rollback as `DROP TABLE` |
| Scoring rubric weights from the PRD don't match real lead distributions | Ship the deterministic rubric; instrument `lead.score` distribution and revisit thresholds in T-022's ticket comments before Cycle 3 |
| Discovery job state machine race conditions (multiple cron ticks picking up the same job) | T-015 AgDR must specify the dequeue lock strategy (e.g. `SELECT … FOR UPDATE SKIP LOCKED` if Postgres queue, or runner-native concurrency control) |

---

## Cross-references

| Where | What |
|-------|------|
| GitHub epic | mohammadahmed-prg/apexyard#3 (portfolio-level MVP) |
| GitHub user stories | mohammadahmed-prg/hook-leads#2 (US-2), mohammadahmed-prg/hook-leads#3 (US-3) |
| Linear project | Hook Leads MVP v0.1 |
| Linear US-2 / US-3 | HOO-9 / HOO-10 |
| PRD | `projects/hook-leads/prd-mvp.md` US-2 + US-3 |
| Foundational AgDR | `projects/hook-leads/agdr/AgDR-0001-data-provider-apollo-for-mvp.md` |
| AgDRs to write | D-003 (job runner), D-004 (email verifier), D-005 (discovery_job migration) |
| Cycle 1 artefacts this cycle depends on | `src/db/icp-snapshot.ts` (T-010), `src/lib/events.ts` (T-011), Vitest setup (T-012) |

---

## How tasks are tracked

- Each task is a GitHub issue under `mohammadahmed-prg/hook-leads` with prefix `[T-NNN]`, labelled `mvp`, `task`, `cycle-2`, and either `migration` (T-014) or `agdr` (T-015, T-020).
- **Workflow**: `/start-ticket <N>` → branch `feature/GH-N-...` → implement → PR → Rex auto-review → `/approve-design <N>` for UI PRs → `/approve-merge <N>` for explicit merge.
- **One ticket at a time** — complete fully before the next, same convention as Cycle 1.
- **PRs** target the matching GitHub task issue; parent user story (#2 / #3) closes when all its T-tasks close.
- Cycle is Done when `docs/qa/US-2-acceptance.md` and `docs/qa/US-3-acceptance.md` are both signed off and #2 + #3 are closed.
