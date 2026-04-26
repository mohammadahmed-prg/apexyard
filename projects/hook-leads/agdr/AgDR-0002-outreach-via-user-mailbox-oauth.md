---
id: AgDR-0002
timestamp: 2026-04-26T17:48:01Z
agent: claude
model: claude-opus-4-7
trigger: user-prompt
status: executed
---

# Outreach sending: user-connected mailboxes via OAuth (Gmail + Outlook)

> In the context of Hook Leads needing a cold-outreach delivery path that respects sender AUPs, protects deliverability across a multi-tenant SaaS, and supports inbound reply parsing for FR-7, facing the fact that mainstream transactional ESPs (Resend, Postmark, Mailgun transactional) explicitly prohibit cold outreach in their AUPs and SES would pool all users on Hook Leads' shared reputation, I decided to require users to connect their own Gmail or Outlook mailbox via OAuth and send through their account using the Gmail API and Microsoft Graph API, accepting the integration cost and per-mailbox sending limits as the price of long-term deliverability and AUP compliance.

## Context

- Hook Leads' core product loop ends in cold-outreach email — this is the primary value-delivery channel for MVP per `projects/hook-leads/prd-mvp.md` US-4 / FR-5–7.
- Cold outreach is a regulated and AUP-restricted workload distinct from transactional email: shared transactional ESPs (Resend, Postmark) explicitly prohibit it in their Acceptable Use Policies. Using them for outreach would result in account termination within weeks.
- Industry-standard cold-outreach SaaS (Smartlead, Instantly, Lemlist) all use the user-connected-mailbox pattern for the same reasons — it's the proven shape for this product category.
- FR-7 requires reply detection + auto-pause; replies need to land somewhere we can read them programmatically.
- 8-week solo-founder timeline — integration cost matters, but a wrong choice here is unrecoverable (an AUP-terminated account or a poisoned shared IP pool).
- Transactional emails inside the product (magic-link auth, billing receipts, in-app notifications) are a separate, smaller decision — out of scope for this AgDR.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| **A. User-connected Gmail / Outlook (OAuth + Gmail API / Microsoft Graph API)** | Sending uses the user's own domain and reputation, isolating us from any single user's bad behaviour; no AUP violation (user is sending from their own account); replies land natively in the user's inbox, making FR-7 a simple Gmail/Graph poll or push subscription; no IP warmup or shared-pool reputation management on Hook Leads' side; industry-standard pattern (Smartlead, Instantly, Lemlist, Apollo's own outreach) — proven shape | OAuth integration cost (~1.5 weeks of build for both providers); per-mailbox safe-sending cap ~50/day for cold outreach (Gmail Workspace allows 2k/day but cold-outreach best practice is far lower); user must own a Google Workspace or Outlook/M365 account; Hook Leads doesn't directly control deliverability outcomes |
| B. Amazon SES (shared sending infrastructure) | Cheapest option ($0.10/1k); SES does not prohibit cold outreach if CAN-SPAM/GDPR compliant; scales effectively infinitely; programmatic from day 1 | All Hook Leads users share Hook Leads' SES reputation — one careless user blacklists every other user's deliverability; replies go to an SES inbound endpoint, not the user's inbox (degrades FR-7 UX and trust); SES sandbox + production-access approval friction; IP warmup + ongoing reputation monitoring becomes a permanent operational burden |
| C. Cold-outreach platform API (Smartlead / Instantly / Lemlist API) | They handle IP warmup, mailbox rotation, deliverability tuning, sending throttle as a managed service | Pricing is $30–99/mo per connected mailbox per user, which alone destroys the $49/mo plan economics; reduces Hook Leads to a thin wrapper on top of an existing outreach product, eroding the differentiation argument vs the user just buying the platform directly |
| D. Postmark / Resend / Mailgun transactional plans | Excellent developer experience; trivial integration; strong transactional deliverability | **Acceptable Use Policy violation** — Postmark and Resend explicitly prohibit cold outreach / sales prospecting; Mailgun transactional plans have similar restrictions; using them for outreach is account-termination risk on a short fuse, not a long-term option |

## Decision

Chosen: **Option A — user-connected Gmail and Outlook mailboxes via OAuth, sending through Gmail API and Microsoft Graph API.**

Justification:

1. It is the only option that is simultaneously AUP-compliant for cold outreach, resilient to per-user bad behaviour (each user's mailbox is independent), and economically viable at the $49/mo plan price point.
2. It matches the proven product shape for cold-outreach SaaS — every serious player in the category (Smartlead, Instantly, Lemlist, Apollo, even HubSpot Sales) routes through user-connected mailboxes for cold outreach. Deviating would be an unforced error.
3. Reply handling (FR-7) becomes simpler, not harder — replies arrive in the user's existing inbox where they expect them, and Hook Leads reads them via the same API used for sending.
4. The integration cost is real but bounded (~1.5 weeks for both providers). It is a one-time spend that protects the product economics and AUP posture for the life of the company.

The accepted trade-offs are explicit:
- Users without a Google Workspace or Outlook/M365 account cannot use Hook Leads for sending in MVP. Documented as a hard prerequisite at signup.
- Per-mailbox safe-sending cap is ~50/day for cold outreach. Multi-mailbox rotation per user (sending from 2–3 connected mailboxes to scale daily volume) is a Phase 2 feature, not MVP.
- We do not control deliverability outcomes — the user's domain reputation, SPF/DKIM/DMARC setup, and content quality drive results. Hook Leads must educate users on this and surface deliverability signals (bounce rate, spam-flag rate) prominently in the UI.

## Consequences

- **Build (week 1–2)**: OAuth flows for Google + Microsoft, mailbox connection UI, secure token storage with refresh handling. Tokens are PII-adjacent and must be encrypted at rest — security posture documented in a follow-up AgDR if needed.
- **FR-5 (sequence delivery)**: Sequence runner respects per-mailbox throttle (configurable, default ≤50/day), warmup curve for newly connected mailboxes (start at 10/day, ramp over 2 weeks), and timezone-aware send windows.
- **FR-7 (reply detection)**: Implemented via Gmail history API + Microsoft Graph subscriptions. Reply parsing extracts the sender, body, and Hook Leads-issued tracking ID from the original sent message thread. Auto-pause is triggered on first reply.
- **Operational**: No shared SES / ESP reputation to manage; no IP warmup on Hook Leads' side. Reduces ongoing ops surface meaningfully for a solo founder.
- **Onboarding**: Hard prerequisite — user must connect at least one Gmail or Outlook mailbox before the first sequence can launch. ICP-creation flow is unaffected; sequence-creation flow gates on mailbox connection.
- **Security**: OAuth refresh tokens are high-value secrets. Encrypted at rest with a per-tenant key, rotated quarterly. A future Security Auditor activation should sign off on the storage design before public launch.
- **Pricing**: Plan tiers can later be differentiated by number of connected mailboxes (1 mailbox = $49, 3 mailboxes = $99, etc.) — pricing decision not made here, but the architecture supports it cleanly.
- **Scope explicitly excluded**: Transactional email inside the product (magic-link auth, billing receipts, in-app notifications) is not covered by this decision. A follow-up AgDR will choose a transactional ESP (likely Resend — compliant use, strong Next.js DX) once that need is concretely scoped.

## Artifacts

- PRD: `projects/hook-leads/prd-mvp.md` (US-4, FR-5, FR-6, FR-7)
- Idea draft: `projects/hook-leads/idea.md` (Module 5)
- Tracking issue: https://github.com/mohammadahmed-prg/apexyard/issues/2
- Related decision: `projects/hook-leads/agdr/AgDR-0001-data-provider-apollo-for-mvp.md`
- Follow-up AgDR (pending): transactional email provider for in-product emails
