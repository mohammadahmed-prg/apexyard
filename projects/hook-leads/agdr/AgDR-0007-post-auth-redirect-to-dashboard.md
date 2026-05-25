---
id: AgDR-0007
timestamp: 2026-04-29T13:35:00Z
agent: claude
model: claude-opus-4-7
trigger: user-prompt
status: executed
---

# Post-auth redirect target: `/dashboard`

> In the context of wiring Clerk's post-sign-in / post-sign-up landing for Hook Leads' MVP (T-005), facing the choice between sending authenticated users to a dedicated `/dashboard` route, leaving them on Clerk's default (the page they came from, or `/`), or computing context-aware deep-links per session, I decided to set `NEXT_PUBLIC_CLERK_SIGN_IN_FALLBACK_REDIRECT_URL=/dashboard` and `NEXT_PUBLIC_CLERK_SIGN_UP_FALLBACK_REDIRECT_URL=/dashboard`, accepting that `/dashboard` becomes a hardcoded convention for the MVP and that the marketing `/` page is no longer reachable to signed-in users without an explicit "Home" link.

## Context

- T-004 wired Clerk; `proxy.ts` protects every route except `/`, `/sign-in*`, `/sign-up*`.
- Hook Leads MVP has a single primary surface ("the app") and a marketing-style root `/`. Signed-in users have no purpose on `/`.
- Clerk honors `redirect_url` query params for deep-link returns regardless of the fallback URL — the fallback only fires when no return target was carried through the auth flow.
- "Ship fast, learn faster" (`onboarding.yaml`) — defer per-user / per-org routing complexity until Cycle 2+ when workspaces actually exist.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| **A. Fallback to `/dashboard`** (chosen) | Clear "where the app lives" anchor; matches user mental model after auth ("I just signed up, take me to the thing"); one env var per direction, trivial to change; signed-in users never land on a marketing page they can't act on | Hardcodes `/dashboard` into env config; needs revisiting when workspaces / orgs are introduced |
| B. Leave Clerk default (return to origin or `/`) | Zero config; honors deep-link intent automatically | Cold sign-ups land on `/` (marketing) and have to figure out how to enter the app; "I just made an account, now what?" friction is the worst friction in onboarding metrics |
| C. Context-aware redirect (compute per-session) | Most "correct" UX | Premature for an MVP with one app surface; needs a redirect resolver that doesn't exist yet; extra failure modes (e.g. resolver throws → user lands nowhere) |

## Decision

Chosen: **Option A — `/dashboard` fallback redirect**, because it's the simplest convention that gets new users into the app immediately, costs one env var, and Clerk's `redirect_url` query continues to handle deep-link returns automatically (so it doesn't break the deep-link case Option C is trying to solve).

Security note: Clerk only honors same-origin redirects in the fallback URL by design — no open-redirect risk introduced. The `NEXT_PUBLIC_` prefix is correct here (these are client-visible URLs, not secrets).

## Consequences

- `T-005` (#13) adds `src/app/dashboard/page.tsx` as the canonical post-auth landing.
- `.env.local.example` gains two new entries (`NEXT_PUBLIC_CLERK_SIGN_IN_FALLBACK_REDIRECT_URL`, `NEXT_PUBLIC_CLERK_SIGN_UP_FALLBACK_REDIRECT_URL`) so other devs / Vercel deploys pick up the convention.
- Marketing `/` becomes optional for signed-in users — they reach it only via an explicit "Home" link in the nav.
- When per-org / per-workspace routing arrives (post-MVP), this AgDR is superseded — replace fallback URLs with a redirect resolver that picks the user's last active workspace.

## Artifacts

- T-004 PR (#24, merged `c0c6dba`) — wired Clerk
- T-005 branch `feature/GH-13-base-layout-protected-routes` — applies this decision
- AgDR-0004 — foundation tech stack (Clerk chosen)
