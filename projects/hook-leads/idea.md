# Hook Leads — Idea Draft

> Captured via `/idea` on 2026-04-26 as IDEA-001. This is the raw idea
> document, not a spec. Run `/write-spec IDEA-001` to turn it into a PRD.

## 1. Overview

### Brief Description

**Hook Leads** is an integrated SaaS platform for extracting potential customers (Leads), aggregating their data from multiple sources, matching them against the user's ICP (Ideal Customer Profile), automatically and intelligently communicating with them, then qualifying and delivering them as sales-ready leads to the sales team.

### The Platform Aims to Replace:

- Traditional lead extraction tools
- Separate email outreach tools
- A large portion of the work done by SDR teams

---

## 2. Target Users

- B2B SaaS companies
- Marketing and sales agencies
- In-house sales teams
- Founders and entrepreneurs

---

## 3. User Journey

1. Create an account
2. Define ICP (Ideal Customer Profile)
3. Set search criteria
4. Extract and aggregate leads
5. Evaluate and match against ICP
6. Automated outreach and qualification
7. Receive qualified, sales-ready leads

---

## 4. Core System Modules

### Module 1: ICP Management

**Objective:** Enable the user to accurately define the ideal customer for use in discovery and qualification.

**Inputs:**
- Industry
- Job Titles
- Company Size (Min / Max)
- Location
- Decision Maker (Yes / No)
- Pain Points (free text)
- Budget Range
- Buying Triggers

**Outputs:**
- ICP Profile ID
- Matching rules used in all subsequent stages

---

### Module 2: Lead Discovery Engine

**Objective:** Search for leads matching the ICP from various sources.

**Data Sources:**
- LinkedIn
- Google Search
- Google Map
- Official company websites
- Public profiles

**Search Criteria:**
- Industry
- Job title
- Keywords
- Geographic location
- Company size

**Outputs:**
- List of Raw Leads

---

### Module 3: Data Aggregation & Enrichment

**Objective:** Aggregate lead data from multiple sources into a single unified profile.

**Data Collected:**
- Full name
- Job title
- Company name
- Company location
- LinkedIn URL
- Email (Verified / Unverified)
- WhatsApp / Phone (if available)

**Lead Status:**
- Enriched
- Partial
- Failed

---

### Module 4: Lead Scoring & ICP Matching

**Objective:** Measure how well each lead matches the user's ICP.

**Scoring Mechanism:**
- Job Title Match: 0–30
- Industry Match: 0–25
- Company Size Match: 0–15
- Pain Match: 0–20
- Activity / Signals: 0–10

**Outputs:**
- Final Score (0–100)
- Classification:
  - Reject
  - Cold
  - Warm
  - Hot

---

### Module 5: Outreach Automation

**Objective:** Communicate with qualified leads through personalized, non-intrusive messages.

**Channels:**
- Email
- WhatsApp
- LinkedIn

**Features:**
- AI-powered smart message generation
- Multi-stage sequences
- Timing and interval control
- Geographic timezone awareness

**Rules:**
- No outreach to leads classified as Reject
- Outreach limited to Warm and Hot leads

---

### Module 6: AI Qualification Bot

**Objective:** Automatically qualify leads and convert them into sales-ready prospects.

**Example Qualification Questions:**
- Are you currently facing problem X?
- How is it being handled now?
- Do you have decision-making authority?
- What is the expected timeframe for a solution?
- Is this company B2B?

**Response Analysis:**
- NLP Classification
- Intent Detection
- Automatic score updates

**Outputs:**
- Qualified Lead
- Not Qualified
- Nurturing

---

### Module 7: CRM & Lead Handoff

**Objective:** Deliver qualified leads to the sales team or external systems.

**Integrations:**
- CRM Systems
- Slack
- Email, WhatsApp, and Telegram Notifications
- Webhooks

---

## 5. Dashboards

### User Dashboard
- Total number of leads
- Number of qualified leads
- Reply Rate
- Conversion Rate

### Lead Page
- Complete profile
- Conversation history
- Score progression

---

## 6. Roles & Permissions

- Admin
- User
- Viewer

---

## 7. Proposed Tech Stack

**Backend**
- Python or Node.js

**Frontend**
- Next.js

**Database**
- PostgreSQL
- Vector Database (Pinecone or Weaviate)

**Automation**
- n8n

**AI**
- GPT Models + Embeddings

---

## 8. Non-Functional Requirements

- Scalability
- Security and data protection
- GDPR compliance
- Monitoring and Logging
- Rate Limits handling

---

## 9. MVP Scope (Phase 1)

- ICP Management
- Lead Discovery from LinkedIn only
- Email Outreach
- Basic Scoring
- Manual review for qualification

## 10. Out of MVP (Later phases)

- WhatsApp Automation
- Full AI Qualification
- Intent Data
- Additional integrations

---

## 11. Success Metrics

- Data Accuracy: no less than 75%
- Reply Rate: no less than 25%
- Qualified Leads: no less than 15%
