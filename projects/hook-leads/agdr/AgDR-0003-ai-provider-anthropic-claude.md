---
id: AgDR-0003
timestamp: 2026-04-26T17:50:03Z
agent: claude
model: claude-opus-4-7
trigger: user-prompt
status: executed
---

# AI provider: Anthropic Claude (Sonnet 4.6 + Haiku 4.5) with prompt caching

> In the context of Hook Leads needing an LLM provider for personalized cold-outreach email generation where reply rate (≥25% target) is gated by writing quality and ICP context is reused across every lead in a sequence, facing the trade-off between OpenAI's broader ecosystem and Anthropic's stronger persuasive-writing reputation and superior prompt-caching economics, I decided to standardise on Anthropic Claude — Sonnet 4.6 for outreach generation, Haiku 4.5 for cheap background tasks, with prompt caching enabled by default — abstracted behind an `LLMProvider` interface, accepting Anthropic's smaller ecosystem and lack of fine-tuning in exchange for better default tone and dramatically lower per-lead cost on the actual access pattern.

## Context

- Outreach generation (US-4 / FR-6 in `projects/hook-leads/prd-mvp.md`) is the single highest-leverage AI surface in MVP — every email goes through it, and reply rate is gated almost entirely by tone and personalization quality.
- The access pattern is "many leads share one ICP context": for a sequence of N leads, the ICP profile (~1.5k tok), user-author voice description (~500 tok), and outreach guidelines (~500 tok) are identical across all N generations. Only the per-lead profile (~300 tok) and the per-step variant change. This is the textbook fit for prompt caching.
- Latency budget is generous — the sequence runner is asynchronous, sending happens on the user's mailbox throttle (50/day) regardless of generation speed. Optimising for cost-per-quality, not latency.
- Cost ceiling per AgDR-0001: total external API spend per active user must allow a $49/mo plan with ≥60% margin, so AI sits inside a ~$15/user/mo all-external-APIs budget alongside the Apollo data spend.
- Phase 2 features in `idea.md` Module 6 (AI Qualification Bot) and a possible LLM-assisted pain-match input to FR-4 (scoring) will reuse the same provider — so the choice is not just about MVP outreach copy, it's about the foundational LLM dependency for the company.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| **A. Anthropic Claude (Sonnet 4.6 + Haiku 4.5, prompt caching on)** | Strong reputation for nuanced, human-sounding writing — directly improves the ≥25% reply-rate target; prompt caching cuts ~90% of the cost on the reused ICP / voice / guidelines portion of every prompt, which is the dominant token cost in this workload; clean two-tier model story (Sonnet for quality-sensitive generation, Haiku for cheap background tasks like reply-intent classification); robust tool use for the future qualification bot; strong instruction-following for persona prompts | Smaller ecosystem of community tooling than OpenAI; no fine-tuning option (must rely on prompting + caching); flagship tier slightly pricier per uncached token |
| B. OpenAI (GPT-4o-mini default + GPT-4.1 for hard tasks) | Most ubiquitous SDK and ecosystem; GPT-4o-mini is the cheapest entry tier on the market; structured outputs / JSON mode is excellent for parsing; fine-tuning available if a custom voice model is ever justified; biggest ecosystem of plug-ins, evals, and observability tools | Cold-outreach community widely reports OpenAI outputs as formulaic ("As an AI", overuse of em-dashes, cliché openings), which directly damages reply-rate metrics on this exact use case; prompt-caching support is weaker and less aggressive than Anthropic's, eroding the cost advantage on the actual ICP-reuse access pattern |
| C. Multi-provider (Claude + GPT behind an abstraction layer, route by task) | No vendor lock-in; provider-outage resilience; can route OpenAI's structured outputs to parsing tasks and Claude's writing to outreach | 2× integration and key-management cost upfront; premature optimisation for an 8-week MVP; harder to tune prompts when callers can't assume model-specific quirks; we'd be paying complexity tax before validating the core loop |
| D. Open-source via Together / Groq / self-host (Llama 3.x or similar) | Cheapest at scale; no vendor lock-in; runs locally if needed for privacy posture | Quality gap on persuasive cold-email writing is meaningful and reply-rate-impacting; ops overhead even when accessed via hosted providers; eats engineering time better spent on the core product loop; punts the cost-optimisation decision to a later, less risky moment |

## Decision

Chosen: **Anthropic Claude — Sonnet 4.6 as the default model for outreach generation, Haiku 4.5 for cheap background tasks (reply-intent classification, summarisation, cheap structured extraction), with Anthropic's prompt caching enabled by default on the reused ICP / voice / guidelines portions of every prompt. All callers go through a single `LLMProvider` interface so a second provider can be added in Phase 2 without touching application code.**

Justification:

1. **Quality is the metric**: Reply rate is the load-bearing success metric for the whole product. The community signal on cold-email writing quality favours Claude consistently. We are optimising for the metric that determines whether MVP succeeds at all.
2. **Prompt caching matches our access pattern almost exactly**: Hook Leads regenerates content within a stable ICP / voice / guideline scope across many leads. Anthropic's prompt caching cuts ~90% off the reused-prefix tokens, which is where the bulk of token spend would otherwise go. This flips the per-token cost comparison in Anthropic's favour for the actual workload, not the abstract benchmark.
3. **Two-tier model story is clean**: Sonnet 4.6 where quality matters, Haiku 4.5 where it doesn't. No need for a third provider to get a cheap-tier model.
4. **Provider abstraction is cheap to build now and expensive to retrofit later**: the `LLMProvider` interface costs maybe a day of engineering and removes lock-in panic. Doing it now sets the right shape for Phase 2.
5. **Multi-provider from day 1 is the wrong shape for MVP**: 2× the surface area before we've validated whether the core loop converts. Build the interface; populate it with one provider.

Accepted trade-offs:

- We give up access to fine-tuning. If a strong case for fine-tuning emerges post-MVP (e.g. a single user's voice that prompts can't capture), this AgDR is revisited and either OpenAI is added behind the same interface or we explore Anthropic's eventual fine-tuning offering.
- Smaller ecosystem of evals / observability tooling than OpenAI. Acceptable for solo MVP scale; revisit if it bites.

## Consequences

- **Build (week 2–3)**: Implement `LLMProvider` interface with one Anthropic-backed implementation. Use the official `@anthropic-ai/sdk`. Wire prompt caching for the ICP / voice / guidelines block on every outreach generation call. Document the cache-key shape (per-user-per-ICP-per-voice, invalidates on edit).
- **Cost model**: Per-lead generation cost is dominated by the per-lead profile (~300 tok input + ~150 tok output) once the cached prefix is ignored. At Sonnet 4.6 pricing this lands well inside the $15/user/mo external-API ceiling even at full sequence volume — provided caching is actually engaged. Engaging it is a build-time correctness concern, not a runtime decision.
- **Persona prompting**: Outreach generation prompt should accept user-supplied "voice" examples (3–5 of their own previous emails) and produce copy that mirrors that voice. This is part of the cached prefix — changing voice invalidates the cache for that user, which is acceptable because voice changes are rare.
- **Phase 2 Qualification Bot**: Will use the same `LLMProvider` interface, with Haiku 4.5 as the default model for reply classification (cheap, fast, sufficient quality for the task). No new provider decision required.
- **Observability**: Log prompt token count, cached token count, output token count, and per-call latency. Cache-hit rate is a core operational health metric — monitor it; a sudden drop indicates a regression in how prefixes are constructed.
- **Provider abstraction discipline**: Every LLM call goes through `LLMProvider`. No direct `@anthropic-ai/sdk` imports outside the implementation file. This is a code-review enforceable rule — Rex should flag violations in PRs.
- **Lock-in posture**: Real but bounded. Migrating to a second provider later is a contained engineering task once the interface exists. The risk is acceptable for MVP.
- **Privacy / data handling**: Outreach generation sends lead PII (name, title, company) and ICP / voice context to Anthropic's API. Confirm Anthropic's data-handling terms are compatible with Hook Leads' privacy commitments before public launch — security review item.

## Artifacts

- PRD: `projects/hook-leads/prd-mvp.md` (US-4, FR-6, Open Question 3)
- Idea draft: `projects/hook-leads/idea.md` (Module 5, Module 6)
- Tracking issue: https://github.com/mohammadahmed-prg/apexyard/issues/2
- Related decisions: `AgDR-0001-data-provider-apollo-for-mvp.md`, `AgDR-0002-outreach-via-user-mailbox-oauth.md`
- Anthropic SDK: `@anthropic-ai/sdk` (Node.js)
