---
id: AgDR-0006
timestamp: 2026-04-27T11:39:07Z
agent: claude
model: claude-opus-4-7
trigger: user-prompt
status: executed
---

# Design-review policy for solo-founder Hook Leads MVP — tiered

> In the context of running ApexYard's design-review merge gate (`require-design-review-for-ui.sh`) on a solo founder MVP where the same person wears both the engineering and design hats, facing the choice between always-ceremony (run `/approve-design` on every UI PR including pure scaffolds), full-bypass (disable the gate), or a tiered approach, I decided on a tiered policy where pure-scaffold PRs skip the gate via a `scaffold-only:`-prefixed manual marker and all PRs with hand-written UI run `/approve-design`, accepting the per-PR judgment cost in exchange for keeping the design-marker signal meaningful and the audit trail complete.

## Context

- ApexYard's design-review hook fires on any PR touching `src/app/**`, `src/components/**`, or styling files. It exists to make design approval a discrete, auditable per-PR moment with a HEAD-SHA-bound marker.
- The hook's mental model assumes a separate UI Designer role. Hook Leads is solo (Rafat = founder + engineer + designer), so "review" is self-review — a real activity, but not a second pair of eyes.
- AgDR-0006 is the policy-level decision; it's separate from any individual PR's approval. PR #21 (T-001 scaffold) prompted writing this AgDR, but the policy applies to every future Hook Leads PR.
- "Ship fast, learn faster" is a stated value (`onboarding.yaml`) — friction matters. So does intentional design — Hook Leads' reply rate target depends on a credible product feel, which depends on consistent UI decisions.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| **A. Tiered: pure-scaffold PRs touch marker with `scaffold-only:` prefix; all hand-written UI runs `/approve-design`** | Marker signal stays meaningful (every real UI change is reviewed); audit trail is complete; honest about where review adds value (intentional design) vs ceremony (boilerplate); the `scaffold-only:` prefix makes bypass visible and grep-able | Requires per-PR judgment ("is this scaffold or hand-written?"); founder must self-discipline to actually pause when running `/approve-design` |
| B. Full bypass — disable `require-design-review-for-ui.sh` in `.claude/settings.json` | Fastest; matches solo reality | Loses audit trail entirely; if a designer joins or Hook Leads is reviewed later, no design history; reverses the framework's safety stance unilaterally; harder to undo than to never disable in the first place |
| C. Always run `/approve-design` — no scaffold exception | Maximum ceremony and auditability | Performative on a `create-next-app` boilerplate update; degrades the marker's meaning on real PRs (the "approval" doesn't carry information); over time encourages reflexive `/approve-design` without actually pausing |
| D. Narrow `.ui_paths` in `.claude/project-config.json` to exclude scaffold patterns | Granular, per-project config | Drifts from upstream apexyard maintenance; the glob is brittle (`shadcn add` writes to `src/components/ui/**` which is the same path as hand-written UI); pushes per-PR judgment into glob maintenance |

## Decision

Chosen: **Option A — tiered policy.**

Justification:

1. The marker exists to be meaningful. If every PR gets one regardless of whether real design decisions were made, the marker no longer signals "this UI was reviewed" — it signals "this PR went through the gate." That's a worse audit trail than not having the gate at all.
2. Pure-scaffold work (create-next-app outputs, `npx shadcn add` outputs, dependency upgrades) involves zero design decisions on the founder's part. Treating those as design moments is theatre.
3. The `scaffold-only:` prefix in the marker file makes every bypass visible and post-hoc auditable — anyone reviewing the project history can grep for `scaffold-only:` and see exactly which PRs skipped review. That is qualitatively different from full bypass.
4. The judgment cost ("is this scaffold or hand-written?") is real but bounded. The default rule is simple: if the diff is unmodified or near-unmodified output of a tool, it's scaffold. If you wrote any of it yourself, it's hand-written.
5. The discipline of running `/approve-design` only when there's a real design decision keeps the founder honest — the activation moment is the point, not the marker file itself.

## How to apply

### Pure-scaffold PR — touch marker manually

Use cases:

- Initial `create-next-app` scaffold output
- `npx shadcn add <component>` outputs (component not yet customised)
- Dependency upgrades that touch styling files only via lockfile changes
- ESLint / Prettier / Tailwind config-only changes
- CI workflow updates

Procedure:

```bash
PR=21
SHA=$(gh pr view "$PR" --repo mohammadahmed-prg/hook-leads --json headRefOid --jq '.headRefOid')
{ echo "scaffold-only: <one-line reason>"; echo "$SHA"; } > "$(git rev-parse --show-toplevel)/.claude/session/reviews/${PR}-design.approved"
```

The first line is human-readable context; the second line is the SHA the hook checks. This is the bypass record.

### Hand-written UI PR — run `/approve-design <pr>`

Use cases:

- Any new component the founder writes by hand (even if it imports shadcn primitives)
- Edits to `src/app/page.tsx` or any route's UI beyond unmodified scaffold
- Edits to `src/app/layout.tsx` that change visible structure or fonts
- Style changes in `globals.css` beyond what `shadcn init` produced
- New flows, new screens, new modals, new forms

The `/approve-design` skill activates the UI Designer role, makes the founder consciously evaluate the design (even if briefly), and records the marker.

### Edge cases

- **Mixed PR (scaffold + hand-written)** — treat as hand-written. Run `/approve-design`. The presence of any hand-written UI cross the threshold.
- **README / docs / non-UI markdown** — not a UI change. Hook does not fire on these paths.
- **Future designer joins** — this AgDR is superseded. Replace with the standard ApexYard design-review flow.

## Consequences

- **PR #21 specifically**: `src/app/page.tsx` is hand-written (I replaced the `create-next-app` boilerplate with a Hook Leads landing). By this policy, `/approve-design 21` is the right path. Doing that next.
- **Future Hook Leads PRs**: every UI PR follows this policy. The judgment cost lives on the PR author (the founder), not on the merge gate.
- **Scaffold marker convention** — `scaffold-only: <reason>` first line, SHA second line — makes bypass auditable. A future security or design audit can `grep -r "scaffold-only:" .claude/session/reviews/` (if they're checked into a sibling private repo for retention) and see every bypass.
- **Discipline drift risk**: the policy only works if the founder actually pauses when running `/approve-design`. If `/approve-design` becomes reflexive, this policy degrades to Option C (always-run, performative). Mitigation: review this AgDR quarterly; if the cadence of "real" `/approve-design` invocations dropped to zero, that's a signal to either fix the discipline or bring in a separate designer.
- **Audit trail file lifecycle**: `.claude/session/reviews/` is gitignored — markers are per-machine. To preserve the design-decision history long-term, periodically copy meaningful `<pr>-design.approved` markers (or just the design notes from `/approve-design`) into a tracked artifact. Not addressing this in MVP scope.
- **Cycle 1 process impact**: foundation tasks T-001..T-007 are mostly scaffold (touch marker). T-008 ICP form UI onward is hand-written (`/approve-design`).

## Artifacts

- Policy applies to: all PRs in `mohammadahmed-prg/hook-leads`
- First application: PR https://github.com/mohammadahmed-prg/hook-leads/pull/21 (T-001 scaffold) — running `/approve-design 21`
- Related: ApexYard `require-design-review-for-ui.sh` hook, `.claude/skills/approve-design/SKILL.md`
- Cycle 1 plan: `projects/hook-leads/cycles/cycle-01.md`
