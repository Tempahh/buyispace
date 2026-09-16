# BUYI — Financial Implications Document
## Volume VII of the BUYI Engineering Documentation Suite
**Version:** 1.1 — NGN Primary  
**Date:** 31 August 2026  
**Prepared by:** BUYIspace Technologies Ltd. — Engineering & Product  
**Classification:** Internal — Confidential

> **Currency convention:** All figures are stated in Nigerian Naira (₦) as the primary currency. USD equivalents are shown in parentheses as reference only, at a working rate of **₦1,600 per $1 USD**. Update this rate whenever the document is revised — NGN/USD is volatile. All budgeting, approvals, and spending decisions should be made in ₦.

> This is a living document. Update it whenever a provider contract is signed, a rate is confirmed, or the exchange rate moves significantly.

---

## Table of Contents

1. [Cost Summary — All Phases](#1-cost-summary--all-phases)
2. [Infrastructure — AWS](#2-infrastructure--aws)
3. [Development & Engineering Tools](#3-development--engineering-tools)
4. [Payment Provider — Paystack / Flutterwave](#4-payment-provider--paystack--flutterwave)
5. [Communications — SMS, OTP & Notifications](#5-communications--sms-otp--notifications)
6. [Identity & KYC Provider](#6-identity--kyc-provider)
7. [AI Development Tools](#7-ai-development-tools)
8. [Design & Collaboration Tools](#8-design--collaboration-tools)
9. [Security & Compliance](#9-security--compliance)
10. [Open / Provider-Dependent Costs](#10-open--provider-dependent-costs)
11. [Per-Exchange Unit Economics](#11-per-exchange-unit-economics)
12. [Break-Even & Revenue Model](#12-break-even--revenue-model)
13. [12-Month Budget Projection (₦)](#13-12-month-budget-projection-)
14. [Cost Optimisation Notes](#14-cost-optimisation-notes)
15. [Financial Risks & Mitigations](#15-financial-risks--mitigations)
16. [Appendix A — ₦ Reference Card](#16-appendix-a---reference-card)
17. [Appendix B — Provider Contacts](#17-appendix-b--provider-contacts)

---

## 1. Cost Summary — All Phases

All figures are **monthly** unless stated otherwise. Exchange-based costs are per transaction.

### 1.1 Phase Cost Overview (₦/month)

| Category | Pilot (Wks 1–10) | V1 Live | At 500 Exch/day | At 2,000 Exch/day |
|---|---|---|---|---|
| AWS Infrastructure | ₦241,600 | ₦411,200 | ₦832,000 | ₦2,240,000 |
| Development & Engineering Tools | ₦403,200 | ₦403,200 | ₦403,200 | ₦448,000 |
| AI Development Tools | ₦80,000 | ₦80,000 | ₦80,000 | ₦160,000 |
| Design & Collaboration Tools | ₦273,600 | ₦273,600 | ₦273,600 | ₦273,600 |
| SMS / Notifications | ₦16,000 | ₦56,000 | ₦296,000 | ₦1,152,000 |
| KYC Provider | ₦0 (sandbox) | ₦80,000–₦320,000 | ₦320,000–₦800,000 | ₦1,280,000–₦3,200,000 |
| Security (AWS WAF + GuardDuty) | ₦0 | ₦32,000 | ₦48,000 | ₦80,000 |
| Payment Provider fees | Pass-through | Pass-through | Pass-through | Pass-through |
| **Total excl. salaries** | **~₦1,014,400/mo** | **~₦1,336,000–₦1,576,000/mo** | **~₦2,252,800–₦2,732,800/mo** | **~₦5,633,600–₦7,553,600/mo** |
| **USD equiv. (ref. only)** | *~$634/mo* | *~$835–$985/mo* | *~$1,408–$1,708/mo* | *~$3,521–$4,721/mo* |

> Payment provider fees (Paystack) are pass-through costs collected from the buyer as part of the PriceBreakdown. They appear in unit economics (Section 11) but are not a direct BUYI operating expense line.

### 1.2 One-Time Setup Costs (₦)

| Item | ₦ Amount | USD Equiv. | Timing |
|---|---|---|---|
| Nigerian fintech legal review (fund holding structure) | ₦800,000–₦3,200,000 | ~$500–$2,000 | Weeks 1–8 |
| NDPR data protection compliance & NITDA registration | ₦160,000–₦800,000 | ~$100–$500 | Week 3 |
| TablePlus database management licence | ₦142,400 | ~$89 | Week 1 |
| Domain name registration (buyi.app or equivalent) | ₦16,000–₦48,000 | ~$10–$30/yr | Week 1 |
| **Total one-time setup (mid estimate)** | **~₦1,500,000–₦4,500,000** | *~$938–$2,813* | Weeks 1–8 |

---

## 2. Infrastructure — AWS

BUYI targets **AWS af-south-1 (Cape Town)** — the closest AWS region to Lagos with production-grade SLAs. If AWS announces a Nigeria region during V1, plan a migration for latency and NDPR data residency advantages.

### 2.1 Compute

| Service | Spec | Pilot ₦/mo | V1 Live ₦/mo | Notes |
|---|---|---|---|---|
| **EC2 App Server** | t3.medium — 2 vCPU, 4GB RAM | ₦48,000 | ₦48,000 | Single instance; modular monolith |
| **EC2 upgrade** | t3.large — 2 vCPU, 8GB RAM | — | +₦25,600 | When pilot load grows |
| **Auto Scaling (Phase 2+)** | 2–3 × t3.large | — | — | ~₦160,000+/mo when activated |

### 2.2 Database

| Service | Spec | Pilot ₦/mo | V1 Live ₦/mo | Notes |
|---|---|---|---|---|
| **RDS PostgreSQL** | db.t3.medium, single-AZ, 100GB gp3 | ₦96,000 | ₦96,000 | Primary database |
| **RDS Read Replica** | db.t3.medium | — | +₦88,000 | Add when admin queries impact writes |
| **RDS Multi-AZ** | Standby in 2nd AZ | — | +₦88,000 | **Add before live funds — not optional** |
| **RDS Automated Backup** | 30-day retention | Included | Included | Point-in-time recovery enabled |

> ⚠️ **RDS Multi-AZ (₦88,000/mo) must be active before Week 10 live launch.** A database failover mid-settlement is a critical incident. This cost is non-negotiable once real funds flow.

### 2.3 Storage & CDN

| Service | Spec | Pilot ₦/mo | V1 Live ₦/mo | Notes |
|---|---|---|---|---|
| **S3 Standard** | Evidence files — videos + photos | ₦8,000 | ₦40,000 | ~100GB evidence/month at V1 |
| **S3 per GB** | ₦36.80/GB/month (~$0.023) | — | — | Scales linearly with evidence volume |
| **S3 Glacier** | Archive evidence >3 years old | — | ₦1,600–₦4,800 | ₦6.40/GB/month (~$0.004) |
| **CloudFront CDN** | Static assets + signed evidence URL delivery | ₦16,000 | ₦24,000 | ~500GB data transfer/month |
| **S3 Request costs** | GET/PUT for evidence uploads | ₦3,200 | ₦8,000 | Based on upload volume estimate |

### 2.4 Networking & Security

| Service | Spec | Pilot ₦/mo | V1 Live ₦/mo | Notes |
|---|---|---|---|---|
| **Application Load Balancer** | 1 ALB, HTTPS termination | ₦28,800 | ₦28,800 | Required — no direct EC2 exposure |
| **AWS Secrets Manager** | 10–20 secrets | ₦6,400 | ₦9,600 | ₦640/secret/mo + API call costs |
| **ACM SSL Certificate** | 1 cert | Free | Free | Included with ALB |
| **Route 53** | 1 hosted zone + DNS queries | ₦3,200 | ₦3,200 | Domain routing |
| **AWS WAF** | Web Application Firewall | — | ₦16,000 | Activate before public launch |
| **VPC / NAT Gateway** | 1 NAT Gateway for private subnets | ₦8,000 | ₦8,000 | Outbound internet access |
| **AWS GuardDuty** | Threat detection | — | ₦12,800–₦24,000 | Activate before Week 10 live |

### 2.5 Monitoring & Logs

| Service | Spec | Pilot ₦/mo | V1 Live ₦/mo | Notes |
|---|---|---|---|---|
| **CloudWatch Logs** | Application + access logs | ₦8,000 | ₦19,200 | ~50GB logs/month at V1 |
| **CloudWatch Metrics** | Custom business metrics (50) | ₦8,000 | ₦12,800 | Critical for Exchange integrity alerts |
| **CloudWatch Alarms** | 20 alarms | ₦3,200 | ₦3,200 | ₦160/alarm/month |
| **CloudWatch Dashboards** | 2 dashboards | ₦4,800 | ₦4,800 | ₦4,800/dashboard/month |

### 2.6 AWS Monthly Totals (₦)

| Phase | ₦/month | USD equiv. |
|---|---|---|
| **Pilot (Weeks 1–10)** | **₦241,600** | *~$151* |
| **V1 Live (post Week 10 + Multi-AZ + WAF + GuardDuty)** | **₦411,200** | *~$257* |
| **At 500 Exchanges/day** | **₦832,000** | *~$520* |
| **At 2,000 Exchanges/day** | **₦2,240,000** | *~$1,400* |

---

## 3. Development & Engineering Tools

Fixed monthly costs — do not scale with transaction volume.

### 3.1 Engineering Tools

| Tool | Purpose | Plan | ₦/month | USD equiv. |
|---|---|---|---|---|
| **GitHub** | Version control, CI/CD, PR reviews, branch protection | Team — 5 users | ₦32,000 | *~$20* |
| **Linear** | Sprint planning, roadmap, ticket tracking | Startup — 5 users | ₦64,000 | *~$40* |
| **Sentry** | Error tracking, performance monitoring, alerts | Team plan | ₦41,600 | *~$26* |
| **TablePlus** | Database management and query tool | One-time licence | ₦0/mo (₦142,400 one-time) | *$0/mo ($89 one-time)* |
| **Kiro AI** | Spec-driven development, code gen from SRS/DDD | Pay-per-use via AWS Bedrock | ₦80,000 | *~$50 est.* |

### 3.2 Engineering Tools Monthly Total

| Phase | ₦/month | USD equiv. |
|---|---|---|
| All phases | **₦217,600/month** | *~$136* |
| One-time (TablePlus) | **₦142,400** | *~$89* |

---

## 4. Payment Provider — Paystack / Flutterwave

This is the most financially material integration. All fees are per-transaction and are **pass-through costs** — they are collected from the buyer as part of the Exchange PriceBreakdown, not a direct BUYI operating expense. However, they are critical to unit economics and fee structure decisions.

### 4.1 Paystack (Primary Recommendation for V1)

**Integration:** Free  
**Sandbox:** Free  

| Transaction Type | Fee (₦) | Notes |
|---|---|---|
| Local card / bank transfer / USSD | 1.5% of amount + ₦100 | **Capped at ₦2,000 per transaction** |
| International card | 3.9% + ₦100 | Not needed for V1 |
| Bank transfer payout (settlement) | ₦10–₦50 per transfer | Depends on destination bank |
| Full refund | No additional fee | Provider refunds collection fee |
| Failed transaction | No charge | Charged on success only |

**Example — ₦150,000 phone Exchange (full CHECK + SHIELD + FETCH):**

| Component | ₦ Amount | Notes |
|---|---|---|
| Item price | ₦150,000 | Agreed Exchange value |
| BUYI platform fee (2% example) | ₦3,000 | Included in buyer's total |
| Phone Check fee | ₦3,500 | Buyer-facing fee |
| Delivery fee | ₦3,000 | Buyer-facing fee |
| **Total buyer pays** | **₦159,500** | Before Paystack collection fee |
| Paystack collection fee | ₦2,000 | Capped at 1.5% + ₦100 |
| Paystack payout — seller | ₦10–₦50 | Bank transfer |
| Paystack payout — BUYI fee | ₦10–₦50 | Bank transfer |
| **Total Paystack cost this Exchange** | **₦2,020–₦2,100** | Funded by buyer's payment |

### 4.2 Flutterwave (Backup)

| Transaction Type | Fee | Notes |
|---|---|---|
| Local NGN card / bank | 1.4% (no flat fee) | Lower on large amounts; no cap stated |
| Bank transfer payout | ₦10–₦100 | Tier-dependent |
| Chargeback exposure | Contract-dependent | Review before signing |

**Recommendation:** Paystack for V1 — stronger Nigeria sandbox documentation and cleaner legal review track record for startups. Keep Flutterwave credentials ready as backup.

### 4.3 Legal Review Requirements Before Live Funds

| Requirement | Responsible | Deadline |
|---|---|---|
| Paystack business CAC verification | PM + Founder | Week 1–2 |
| BVN-linked KYC for payout recipients | Paystack-handled | At seller onboarding |
| Fund holding / escrow legal structure review | Legal counsel + Paystack | Weeks 4–8 |
| Settlement schedule agreement | PM + Paystack | Weeks 6–8 |
| Chargeback policy review | PM + Paystack | Before Week 10 |
| AML / KYC threshold confirmation | Paystack compliance team | Before Week 10 |

> ⚠️ **Hard gate:** BUYI must not move live customer funds until Nigerian fintech legal counsel and Paystack approve the fund holding structure. Budget ₦800,000–₦3,200,000 in legal fees (see Section 9.3) for this review. Do not skip it.

### 4.4 Paystack Fees at Scale (Monthly Estimates)

| Monthly Exchange Volume | Avg Exchange Value | Est. Monthly Paystack Fees (₦) | USD equiv. |
|---|---|---|---|
| 10 Exchanges | ₦150,000 | ₦21,000 | *~$13* |
| 100 Exchanges | ₦150,000 | ₦210,000 | *~$131* |
| 500 Exchanges | ₦150,000 | ₦1,050,000 | *~$656* |
| 1,000 Exchanges | ₦150,000 | ₦2,100,000 | *~$1,313* |
| 5,000 Exchanges | ₦150,000 | ₦10,500,000 | *~$6,563 — negotiate enterprise rate* |
| 10,000 Exchanges | ₦150,000 | ₦21,000,000 | *~$13,125 — volume rate essential* |

Negotiate a Paystack enterprise rate when monthly GMV exceeds ₦500,000,000 (~$313k). Most providers offer 0.9–1.2% at that tier.

---

## 5. Communications — SMS, OTP & Notifications

### 5.1 Termii (Primary — Nigeria Native)

**Why Termii over Twilio:** Termii has direct relationships with MTN, Airtel, Glo, and 9mobile. Bills in NGN — no FX exposure on SMS costs.

| Message Type | Rate (₦) | Notes |
|---|---|---|
| OTP SMS | ₦3–₦5 per SMS | DND-exempt transactional route |
| Standard notification SMS | ₦3–₦5 per SMS | Transactional route |
| WhatsApp (via Termii) | Session-based | Phase 2+ |

**SMS events per Exchange (full CHECK + SHIELD + FETCH):**

| Event | Recipient(s) | SMS Count |
|---|---|---|
| Login / auth OTP | Buyer | 1 |
| Payment confirmed | Buyer | 1 |
| Seller funded notification | Seller | 1 |
| Verifier assignment | Verifier | 1 |
| Check result | Buyer + Seller | 2 |
| Pickup confirmed | Buyer | 1 |
| Delivery OTP | Buyer | 1 |
| Review window open | Buyer | 1 |
| Settlement confirmed | Seller | 1 |
| **Average total per Exchange** | — | **~10 SMS** |
| **Add 20% for cancelled / failed Exchanges** | — | +2 SMS avg |
| **Effective total per Exchange incl. failures** | — | **~12 SMS** |

**SMS cost per Exchange:** 12 × ₦4 (mid-rate) = **₦48 per Exchange**

| Monthly Exchange Volume | Monthly SMS Cost (₦) | USD equiv. |
|---|---|---|
| 10 (pilot) | ₦480 | *~$0.30* |
| 100 | ₦4,800 | *~$3* |
| 500 | ₦24,000 | *~$15* |
| 1,000 | ₦48,000 | *~$30* |
| 5,000 | ₦240,000 | *~$150* |
| 10,000 | ₦480,000 | *~$300* |

### 5.2 Firebase Cloud Messaging (Push Notifications)

**Cost:** Free up to 1,000,000 messages/day — not a cost factor at any foreseeable BUYI scale.

Push is the primary channel for in-app users. SMS is the fallback for users without the app installed or with notifications disabled.

### 5.3 WhatsApp Business API (Phase 2+)

Not required for V1. Activate for customer care from Phase 2.

| Conversation Type | Rate (₦) | Notes |
|---|---|---|
| Service (user-initiated) | ₦16–₦24/conversation | 24-hour window |
| Utility (transactional) | ₦9.60–₦14.40/conversation | Settlement alerts, etc. |
| Marketing | ₦40–₦64/conversation | Not needed for V1 |
| **Free tier** | **First 1,000 conversations/month free** | Covers entire pilot period |

**Phase 2 estimate at 500 Exchanges/month:** ~500 support conversations = ₦8,000–₦12,000/month. Negligible.

### 5.4 Transactional Email (AWS SES)

For admin alerts and internal engineering notifications only — not user-facing.

| Provider | Rate | Est. Monthly Cost (₦) |
|---|---|---|
| **AWS SES** | ₦160 per 1,000 emails (~$0.10) | ₦160–₦480/month |

---

## 6. Identity & KYC Provider

KYC thresholds are **OPEN / PROVIDER-DEPENDENT** per the Master Build Document. Do not hard-code any threshold or budget a fixed KYC spend until the provider contract is confirmed and the threshold schedule is agreed with Paystack.

### 6.1 Nigerian KYC Provider Options

| Provider | Service | Cost (₦) | Notes |
|---|---|---|---|
| **Smile Identity** | NIN, BVN, face match, driver's licence | ₦480–₦2,400/verification (~$0.30–$1.50) | Widest Nigeria coverage |
| **Prembly (IdentityPass)** | BVN, NIN, CAC verification | ₦50–₦300/check | NGN billing — no FX risk |
| **Youverify** | KYC, AML, address verification | Quote-based | Enterprise pricing |
| **Paystack Identity** | Basic BVN check | Likely included in Paystack contract | **Confirm before signing** |

### 6.2 V1 KYC Strategy

- Use Paystack's built-in BVN verification as the baseline (cost: ₦0 if included in contract)
- Integrate Prembly as the secondary provider for enhanced KYC on high-value Exchanges (threshold TBD with Paystack)
- KYC is triggered by provider thresholds — BUYI does not independently trigger verification except where required by policy

### 6.3 KYC Cost Estimates (₦/month)

| Scenario | ₦ Per Verification | Monthly Volume | Monthly Cost (₦) |
|---|---|---|---|
| BVN check via Paystack (confirm) | ₦0 (if included) | All new users | ₦0 |
| Prembly NIN + BVN | ₦150–₦300 | 100 new users/month | ₦15,000–₦30,000 |
| Smile Identity NIN | ₦480 | 100 verifications | ₦48,000 |
| High-value enhanced KYC (Smile) | ₦1,600–₦2,400 | 20 high-value Exchanges | ₦32,000–₦48,000 |
| **V1 estimate (blended)** | — | — | **₦80,000–₦320,000/month** |

**At scale (1,000 new users/month):** ₦480,000–₦2,400,000/month. Plan for this before opening public registration.

---

## 7. AI Development Tools

### 7.1 Kiro AI — AWS Bedrock

Primary development acceleration. Engineers use Kiro against the SRS, DDD Blueprint, and Event Catalog to generate, review, and refine code.

**Billing:** Pay-per-use via AWS Bedrock.

| Model | Input tokens (₦/1M) | Output tokens (₦/1M) | Notes |
|---|---|---|---|
| Claude 3.5 Sonnet | ₦4,800 (~$3.00) | ₦24,000 (~$15.00) | Primary model — code gen, reviews |
| Claude 3 Haiku | ₦400 (~$0.25) | ₦2,000 (~$1.25) | Fast tasks, lint hooks, PR summaries |

**Estimated monthly usage (5-engineer team, 20 working days):**

| Usage type | Volume | Cost (₦) |
|---|---|---|
| Input tokens (15M tokens/month) | 15M × ₦4,800/1M | ₦72,000 |
| Output tokens (6M tokens/month) | 6M × ₦24,000/1M | ₦144,000 |
| **Aggressive usage total** | | **₦216,000/month** |
| **Conservative usage (focused)** | | **₦80,000–₦112,000/month** |

### 7.2 Supporting AI Tools

| Tool | Purpose | Plan | ₦/month | USD equiv. |
|---|---|---|---|---|
| **GitHub Copilot** | Inline code completion (3 engineers) | Individual × 3 | ₦91,200 | *~$57* |
| **ChatGPT Team** | Research + documentation (PM) | Team × 1 user | ₦40,000 | *~$25* |

### 7.3 AI Tools Monthly Total

| Scenario | ₦/month | USD equiv. |
|---|---|---|
| Conservative (Kiro focused use only) | ₦80,000 | *~$50* |
| Full stack (Kiro + Copilot + ChatGPT) | ₦211,200–₦347,200 | *~$132–$217* |
| **Recommended budget** | **₦211,200/month** | *~$132* |

---

## 8. Design & Collaboration Tools

### 8.1 Design

| Tool | Purpose | Plan | ₦/month | USD equiv. |
|---|---|---|---|---|
| **Figma** | UI/UX design, prototyping, Dev Mode handoff | Professional — 2 editor seats | ₦38,400 | *~$24* |
| Viewer seats (engineers) | View + inspect designs | Included in Professional | ₦0 | — |

### 8.2 Project Management

| Tool | Purpose | Plan | ₦/month | USD equiv. |
|---|---|---|---|---|
| **Linear** | Sprint planning, tickets, roadmap | Startup — 5 users | ₦64,000 | *~$40* |
| **Notion** | Docs, decision log, SOPs, meeting notes | Plus — 5 users | ₦64,000 | *~$40* |

### 8.3 Communication

| Tool | Purpose | Plan | ₦/month | USD equiv. |
|---|---|---|---|---|
| **Slack** | Team communication, async standups | Pro — 5 users | ₦59,600 | *~$37.25* |
| **Google Workspace** | Email, calendar, Drive (shared docs) | Business Starter — 5 users | ₦48,000 | *~$30* |
| **Loom** | Async video, demo recordings, QA evidence | Starter — 5 users | ₦0 (free tier) | — |

### 8.4 Design & Collaboration Monthly Total

| Category | ₦/month | USD equiv. |
|---|---|---|
| Design (Figma) | ₦38,400 | *~$24* |
| Project management (Linear + Notion) | ₦128,000 | *~$80* |
| Communication (Slack + Google) | ₦107,600 | *~$67* |
| **Total** | **₦274,000/month** | *~$171* |

---

## 9. Security & Compliance

### 9.1 Included in AWS (₦0 Additional Cost)

| Service | What it covers |
|---|---|
| AWS IAM | Role-based access; app role has INSERT-only on `exchange_event` |
| AWS Secrets Manager | All provider keys, JWT signing key, DB credentials |
| ACM SSL/TLS Certificate | HTTPS on all endpoints (bundled with ALB) |
| VPC Security Groups | Network-level firewall; no direct DB exposure to internet |
| S3 Bucket Policies | Immutable evidence storage; object versioning; delete blocked at storage level |
| AWS CloudTrail | Full AWS API audit log (90 days free; extend to S3 for longer retention) |

### 9.2 Additional Security — Pre-Public Launch

| Tool | Purpose | ₦/month | USD equiv. |
|---|---|---|---|
| **AWS WAF** | Web Application Firewall — rate limiting, SQL injection, XSS | ₦16,000 + ₦960/1M req | *~$10 base* |
| **AWS GuardDuty** | Threat detection on AWS account and CloudTrail | ₦12,800–₦24,000 | *~$8–$15* |
| **Snyk** | Dependency vulnerability scanning in CI/CD | ₦0 (open source free tier) | *$0* |
| **Total additional security** | | **₦28,800–₦40,960/month** | *~$18–$26* |

**Activate WAF and GuardDuty no later than Week 9 — before any real funds flow.**

### 9.3 Compliance — One-Time Costs (₦)

| Item | ₦ Low Estimate | ₦ High Estimate | Timing | Notes |
|---|---|---|---|---|
| Nigerian fintech legal review (fund holding / escrow structure) | ₦800,000 | ₦3,200,000 | Weeks 2–8 | **Hard gate — must complete before live funds** |
| NDPR compliance (privacy policy, DPA, NITDA registration) | ₦160,000 | ₦800,000 | Week 3 | Required for any data processing |
| CAC business registration (if not done) | ₦50,000 | ₦150,000 | Week 1 | Required for Paystack business account |
| Legal review of verifier contractor agreements | ₦80,000 | ₦300,000 | Week 4 | Before onboarding first verifiers |
| Legal review of logistics partner agreement | ₦80,000 | ₦300,000 | Week 5 | Before any live deliveries |
| **One-time legal/compliance total** | **₦1,170,000** | **₦4,750,000** | — | Budget ₦2,500,000 as working estimate |

### 9.4 Recurring Compliance Costs (₦/year)

| Item | ₦/year | Notes |
|---|---|---|
| NITDA annual data processor registration renewal | ₦100,000 | NDPR requirement |
| Legal retainer (ongoing contract / dispute advice) | ₦240,000–₦600,000 | Optional but recommended once live |
| Annual security audit (Phase 2+) | ₦400,000–₦1,600,000 | Before any significant scale |

---

## 10. Open / Provider-Dependent Costs

These items are explicitly **OPEN / PROVIDER-DEPENDENT** in the Master Build Document. Do not hard-code values, make promises to users, or include these as fixed budget lines until the relevant contract is confirmed.

| Item | Status | Financial Action Required |
|---|---|---|
| **KYC threshold amounts** | OPEN / PROVIDER-DEPENDENT | Get threshold schedule from Paystack compliance before Week 10. Budget ₦80,000–₦320,000/month as placeholder. |
| **Carrier liability cap** | OPEN / PROVIDER-DEPENDENT | Review carrier contract before Movement goes live. Carrier determines declared-value coverage limit — this sets `movement_value_limit` in config. |
| **Transit protection insurance premium** | LATER / PROVIDER-DEPENDENT | No cost in V1. Architecture fields only. Zero budget. |
| **Stale inventory expiry rule** | OPEN | No direct cost — policy decision. Do not hard-code. |
| **Changed terms response window** | OPEN | No direct cost — policy decision. |
| **Paystack fund holding / settlement fees** | OPEN (in legal review) | Direct cost = legal fees already in Section 9.3. Provider settlement fees confirmed post-review. |
| **WhatsApp Business API pricing** | Variable | First 1,000 conversations/month free. Budget ₦16,000–₦32,000/month from Phase 2 onwards. |

---

## 11. Per-Exchange Unit Economics

Full cost model for a single Exchange to inform fee structure decisions.

### 11.1 Direct Cost Per Exchange (₦)

Calculated at two volumes: 100 Exchanges/month (early V1) and 1,000 Exchanges/month (growth stage).

| Cost Item | 100 Exch/mo (₦/exch) | 1,000 Exch/mo (₦/exch) | Type |
|---|---|---|---|
| AWS infrastructure (spread) | ₦4,112 | ₦411 | Fixed ÷ volume |
| Dev + AI + design tools (spread) | ₦7,032 | ₦703 | Fixed ÷ volume |
| SMS — 12 messages @ ₦4 | ₦48 | ₦48 | Variable |
| Push notifications | ₦0 | ₦0 | Free (FCM) |
| KYC — triggered for new users (est.) | ₦800 | ₦240 | Semi-variable |
| Evidence storage — ~5MB/Exchange | ₦160 | ₦160 | Variable |
| Paystack collection fee (₦150k Exchange) | ₦2,000 | ₦2,000 | Pass-through |
| Paystack payout fees (2 transfers) | ₦80–₦100 | ₦80–₦100 | Pass-through |
| Verifier payment (Check Exchanges only) | ₦2,000–₦3,000 | ₦2,000–₦3,000 | Direct operating cost |
| Carrier cost (Fetch Exchanges only) | ₦1,500–₦3,500 | ₦1,500–₦3,500 | Direct operating cost |
| **Infra + tools cost only (no verifier/carrier)** | **₦12,152** | **₦1,562** | — |
| **Full cost incl. verifier + carrier + provider fees** | **₦17,732–₦20,752** | **₦7,142–₦10,162** | — |

> At 100 Exchanges/month the fixed cost per Exchange is high — this is expected and normal for a pilot. The model becomes viable at 500+ Exchanges/month when fixed costs are sufficiently spread.

### 11.2 Revenue Per Exchange (₦)

BUYI earns revenue from three sources per Exchange. Exact fee amounts are a business decision — these are illustrative at current market reference points.

| Revenue Stream | Low (₦) | Mid (₦) | High (₦) | Notes |
|---|---|---|---|---|
| Platform fee (2% of ₦150k) | ₦2,000 | ₦3,000 | ₦5,000 | Included in `buyi_fee` in PriceBreakdown |
| Phone Check fee margin (fee minus verifier pay) | ₦1,500 | ₦2,000 | ₦3,000 | Check fee charged: ₦3,500–₦6,000; verifier paid: ₦2,000–₦3,000 |
| Delivery fee margin (fee minus carrier cost) | ₦500 | ₦1,000 | ₦2,000 | Delivery fee charged: ₦2,500–₦5,000; carrier paid: ₦1,500–₦3,500 |
| **Total revenue per Exchange** | **₦4,000** | **₦6,000** | **₦10,000** | Before operating costs |

**Gross margin per Exchange at 1,000 Exchanges/month:**

| Metric | ₦ Amount |
|---|---|
| Average revenue per Exchange (mid) | ₦6,000 |
| Average direct cost per Exchange (mid) | ₦8,652 (incl. verifier + carrier + provider) |
| **Gross margin** | **-₦2,652 at 1,000/mo (not yet profitable on direct costs alone)** |

> This is expected at early volume. Profitability comes from:
> 1. Fee structure optimisation (increase platform fee or Check fee margin)
> 2. Volume scale (fixed costs spread over more Exchanges)
> 3. Carrier rate negotiation (reduce direct carrier cost)
> 4. Verifier rate stabilisation as the programme matures

**Gross margin at 5,000 Exchanges/month (₦ per Exchange):**

| Metric | ₦ Amount |
|---|---|
| Revenue (mid) | ₦6,000 |
| Infra + tools spread | ₦282 |
| SMS + storage + KYC | ₦248 |
| Verifier (mid) | ₦2,500 |
| Carrier (mid) | ₦2,500 |
| Paystack fees | ₦2,100 |
| **Total direct cost** | **₦7,630** |
| **Gross margin** | **-₦1,630 per Exchange — improving** |

At approximately **₦8,000–₦8,500 in average revenue per Exchange**, the model crosses to positive gross margin at scale. This is achievable by raising the platform fee slightly or increasing Check fee.

---

## 12. Break-Even & Revenue Model

### 12.1 Infra + Tools Break-Even Only (₦/month)

| Exchange Volume / Month | Monthly Fixed Cost (₦) | Required Revenue to Cover (₦) | Required Revenue/Exchange |
|---|---|---|---|
| 10 | ₦1,014,400 | ₦1,014,400 | ₦101,440 — not viable |
| 50 | ₦1,014,400 | ₦1,014,400 | ₦20,288 |
| 100 | ₦1,048,000 | ₦1,048,000 | ₦10,480 |
| 300 | ₦1,060,000 | ₦1,060,000 | ₦3,533 — approaching viable |
| 500 | ₦1,088,000 | ₦1,088,000 | ₦2,176 |
| 1,000 | ₦1,400,000 | ₦1,400,000 | ₦1,400 — comfortable |

At **300 Exchanges/month** at the mid revenue estimate (₦6,000/Exchange), BUYI generates ₦1,800,000 against ₦1,060,000 in fixed costs — infra and tools are covered.

### 12.2 Salary-Inclusive Break-Even (₦/month)

Using illustrative market rates for Lagos senior engineers — replace with actuals.

| Role | Illustrative Monthly Salary (₦) |
|---|---|
| Founding Engineer / Architect | ₦800,000 |
| Backend Developer — Domain & Integrations | ₦300,000 |
| Backend Developer — Evidence & Check | ₦300,000 |
| Frontend Developer | ₦300,000 |
| PM / Designer | ₦250,000 |
| **Total team salaries** | **₦1,950,000/month** |

| Monthly burn component | ₦ Amount |
|---|---|
| Team salaries | ₦1,950,000 |
| Infrastructure + tools + AI (pilot) | ₦1,014,400 |
| KYC (V1 estimate) | ₦160,000 |
| SMS (at 300 Exchanges/month) | ₦14,400 |
| **Total monthly burn (pilot scale)** | **₦3,138,800/month** |

**Salary-inclusive break-even:**
- Monthly burn: ₦3,138,800
- Revenue per Exchange (mid): ₦6,000
- **Break-even volume: ~524 Exchanges/month (~17 Exchanges/day)**

17 Exchanges/day at Computer Village, Lagos is a credible target within 4–6 months of pilot launch — Computer Village processes thousands of transactions daily.

**At ₦8,500 revenue per Exchange (optimised fee structure):**
- Break-even: ~369 Exchanges/month (~12 Exchanges/day)

### 12.3 Runway Projection (₦)

With an illustrative seed budget of **₦50,000,000** (not including salary commitments deferred by founder):

| Phase | Monthly Burn (₦) | Months of Runway |
|---|---|---|
| Pilot (Wks 1–10) — salaries deferred | ₦1,014,400 | ~49 months (tools/infra only) |
| V1 live — full salaries | ₦3,138,800 | ~16 months |
| V1 live — at 300 Exchanges/mo revenue | ₦3,138,800 – ₦1,800,000 = ₦1,338,800 net | ~37 months |
| V1 live — at 524 Exchanges/mo (break-even) | ₦0 net | Indefinite |

---

## 13. 12-Month Budget Projection (₦)

Month 1 = Week 1 of build. All figures in ₦.

| Mo | Phase | AWS (₦) | Tools + AI (₦) | Design/Collab (₦) | SMS (₦) | KYC (₦) | Legal/One-time (₦) | **Total ₦/mo** |
|---|---|---|---|---|---|---|---|---|
| 1 | Phase 0 | 241,600 | 217,600 | 274,000 | 1,600 | 0 | 2,500,000 | **3,234,800** |
| 2 | Phase 0/1 | 241,600 | 217,600 | 274,000 | 3,200 | 0 | 0 | **736,400** |
| 3 | Phase 1 | 241,600 | 217,600 | 274,000 | 8,000 | 80,000 | 500,000 (NDPR) | **1,321,200** |
| 4 | Phase 1 | 241,600 | 217,600 | 274,000 | 16,000 | 80,000 | 0 | **829,200** |
| 5 | Phase 1 | 241,600 | 217,600 | 274,000 | 24,000 | 80,000 | 0 | **837,200** |
| 6 | Phase 1 live | 411,200 | 217,600 | 274,000 | 32,000 | 160,000 | 0 | **1,094,800** |
| 7 | Phase 2 | 411,200 | 217,600 | 274,000 | 48,000 | 160,000 | 0 | **1,110,800** |
| 8 | Phase 2 | 411,200 | 217,600 | 274,000 | 64,000 | 160,000 | 0 | **1,126,800** |
| 9 | Phase 2/3 | 411,200 | 217,600 | 274,000 | 80,000 | 200,000 | 0 | **1,182,800** |
| 10 | Phase 3 | 411,200 | 217,600 | 274,000 | 128,000 | 240,000 | 0 | **1,270,800** |
| 11 | Phase 4 | 411,200 | 217,600 | 274,000 | 192,000 | 240,000 | 0 | **1,334,800** |
| 12 | Phase 4 | 411,200 | 217,600 | 274,000 | 296,000 | 320,000 | 0 | **1,518,800** |
| **TOTAL** | | **₦4,085,600** | **₦2,611,200** | **₦3,288,000** | **₦892,800** | **₦1,520,000** | **₦3,000,000** | **₦15,397,600** |

**12-month total (tools + infra + legal, excluding salaries): ₦15,397,600 (~$9,624)**

### 13.1 Salary-Inclusive 12-Month Total (₦)

| Component | ₦ Amount |
|---|---|
| Tools + infra + legal (above) | ₦15,397,600 |
| Team salaries — 12 months @ ₦2,950,000/mo | ₦35,400,000 |
| **Total 12-month burn** | **₦50,797,600** (~$31,748) |

> At a ₦50,000,000 seed budget, the team operates for approximately 12 months before needing revenue to be self-sustaining. With ≥300 Exchanges/month from Month 6 onwards, the practical runway extends to 18–24 months.

---

## 14. Cost Optimisation Notes

### 14.1 AWS (₦ Savings Available)

| Opportunity | Monthly Saving (₦) | When to Apply |
|---|---|---|
| EC2 Reserved Instances (1-year commitment) | ~₦16,800 (35% on compute) | After Month 3 with stable load |
| RDS Reserved Instances (1-year) | ~₦28,800 (30% on DB) | After pilot confirms DB size |
| S3 Intelligent-Tiering for evidence | ~₦8,000–₦16,000 | After Month 6 with evidence accumulation |
| CloudFront origin shield (reduce S3 requests) | ~₦3,200–₦6,400 | After launch with measurable traffic |
| **Total AWS savings if fully applied** | **~₦56,800–₦68,000/month** | — |

### 14.2 Tools (₦ Savings Available)

| Opportunity | Monthly Saving (₦) | Note |
|---|---|---|
| Consolidate Notion into GitHub Wiki | ₦64,000 | Acceptable for small team; loses Notion's flexibility |
| Remove Slack; use Discord free tier | ₦59,600 | Reduces integration quality; not recommended |
| Switch to Linear only (drop Notion) | ₦64,000 | Linear's docs are adequate for V1 |
| Kiro only — drop GitHub Copilot | ₦91,200 | Feasible; 1–2 week adjustment period |
| **Maximum tool savings if aggressively cut** | **~₦278,800/month** | Would compromise team productivity |
| **Recommended conservative cuts** | **₦64,000–₦128,000/month** | Drop Notion or Copilot, not both |

### 14.3 Provider Negotiations (₦ Savings at Scale)

| Opportunity | When | Expected Saving |
|---|---|---|
| Paystack volume rate (1.0% vs 1.5%) | Above ₦500M GMV/month | ₦750–₦1,500 per ₦150k Exchange |
| Termii bulk SMS contract | After Month 3 of live operation | ₦1.50–₦2.00/SMS reduction (~37% saving) |
| Smile Identity volume discount | After Month 6 | ₦200–₦280/verification reduction |
| WhatsApp Business tiered pricing | Above 1,000 conversations/month | ~15% per-conversation reduction |

### 14.4 Free Tiers to Maximise

| Service | Free Allowance | Duration |
|---|---|---|
| Firebase (FCM push notifications) | 1,000,000 messages/day | Indefinite |
| WhatsApp Business API | 1,000 conversations/month | Indefinite |
| AWS Free Tier | EC2 750h + RDS 750h + S3 5GB | 12 months from account creation |
| GitHub Actions | 2,000 CI/CD minutes/month | Indefinite on Team plan |
| Sentry | 5,000 errors/month | Indefinite on free plan |
| Snyk | Unlimited open-source scanning | Indefinite |

> **Tip:** Create the AWS account at the start of Week 1 but run all local development against LocalStack (free AWS emulator) for the first 4–6 weeks. This preserves most of the 12-month AWS Free Tier for the pilot period.

---

## 15. Financial Risks & Mitigations

| Risk | Potential ₦ Impact | Mitigation |
|---|---|---|
| **Paystack legal review delays live launch** | ₦640,000–₦960,000/month burn without revenue | Begin legal review Week 1; set hard deadline of Week 8; Flutterwave as backup |
| **AWS S3 costs spike — large evidence videos** | ₦80,000–₦320,000 unexpected monthly overrun | Enforce max video duration (2 min) at upload; compress aggressively; set AWS budget alarm |
| **AWS costs spike due to misconfiguration** | ₦800,000–₦8,000,000 unexpected bill | Set 4-tier AWS Budget alerts (80%, 100%, 120%, 200% of estimate) from Week 1 |
| **SMS costs spike due to notification duplication bug** | ₦80,000–₦320,000/month overrun | Deduplicate at Notification module; per-Exchange SMS budget cap in code |
| **KYC provider bills for failed verifications** | ₦80,000–₦160,000/month overrun | Negotiate: charge on success only; implement retry cap in KYCProviderACL |
| **NGN/USD depreciation increases tool costs** | ₦200,000–₦800,000/month increase | Maintain USD reserve for tool payments; review annually; consider NGN-billed alternatives |
| **Verifier pay escalates with demand** | ₦200,000–₦500,000/month overrun at scale | Set maximum verifier pay in contract; build verifier pool depth to maintain competitive rates |
| **Logistics carrier rate increase** | ₦150,000–₦400,000/month overrun | Negotiate fixed-rate SLA with V1 partner; multi-partner from Phase 4 for pricing leverage |
| **Chargeback volume exceeds expectation** | 1–3% of monthly GMV at risk | Strong evidence trail (photos, OTP, checklist) is BUYI's primary chargeback defence; Paystack dispute management |
| **Legal fees exceed estimate** | ₦1,000,000–₦5,000,000 overrun | Get fixed-fee legal quotes; scope engagements tightly; use a fintech-specialist firm |
| **Team member departure** | ₦500,000–₦2,000,000 recruitment + delay cost | Module boundaries (DDD Blueprint) mean any engineer can pick up any module; documentation reduces key-person dependency |

### 15.1 AWS Budget Alerts — Week 1 Setup (Required)

Set these in AWS Budgets before any infrastructure is provisioned:

| Alert | Threshold | Action |
|---|---|---|
| Alert 1 | Monthly cost > ₦320,000 | Email to Founder + Architect |
| Alert 2 | Monthly cost > ₦480,000 | Email + Slack to full team |
| Alert 3 | Monthly cost > ₦800,000 | Email + Slack + immediate investigation |
| Alert 4 | S3 storage > 500GB | Investigate evidence upload patterns |
| Alert 5 | Data transfer > 1TB | Check for CloudFront misconfiguration |
| Alert 6 | EC2 CPU > 85% avg | Application server may need vertical scaling |

### 15.2 Monthly Financial Review Agenda

From Week 10 (first live Exchange) onwards, hold a 30-minute monthly financial review:

1. **AWS cost** — line-item actual vs. budget; flag any anomalies
2. **SMS volume** — cost per Exchange trending (target: ≤₦50 per Exchange)
3. **KYC volume** — verifications triggered vs. new user count
4. **Tools** — any unused seats or downgrade opportunities
5. **Payment provider** — GMV processed; provider fees total; any chargebacks this month
6. **Verifier & carrier costs** — actual vs. estimate; per-Exchange trending
7. **Revenue** — Exchanges settled × BUYI fee; total revenue this month
8. **Net burn** — total costs minus revenue; months of runway remaining
9. **Next month forecast** — based on Exchange pipeline and planned volume

---

## 16. Appendix A — ₦ Reference Card

Print this card. Use it for day-to-day budget decisions.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BUYI FINANCIAL REFERENCE — NGN PRIMARY
Reference rate: ₦1,600 = $1 USD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MONTHLY FIXED COSTS
──────────────────────────────────────────
AWS (pilot)                    ₦241,600
AWS (V1 live + Multi-AZ + WAF) ₦411,200
Dev tools (GitHub, Linear, Sentry) ₦217,600
Design + Collab tools          ₦274,000
AI tools (Kiro + Copilot)      ₦211,200
──────────────────────────────────────────
TOTAL (pilot, no salaries)     ₦1,014,400
TOTAL (V1 live, no salaries)   ₦1,336,000
TOTAL (V1 live + salaries)     ₦4,286,000

VARIABLE COSTS PER EXCHANGE
──────────────────────────────────────────
SMS (12 messages @ ₦4 avg)     ₦48
Evidence storage (~5MB)        ₦160
KYC (new users only, est.)     ₦800
Paystack collection (₦150k)    ₦2,000 (capped)
Paystack payout (2 transfers)  ₦80–₦100
Verifier payment (Check only)  ₦2,000–₦3,000
Carrier payment (Fetch only)   ₦1,500–₦3,500

REVENUE (ILLUSTRATIVE)
──────────────────────────────────────────
Platform fee (2% of ₦150k)     ₦3,000
Check fee margin               ₦1,500–₦3,000
Delivery fee margin            ₦500–₦2,000
Total mid-estimate             ₦6,000 per Exchange

BREAK-EVEN
──────────────────────────────────────────
Infra + tools only:            ~80 Exchanges/month
Salary-inclusive:              ~690 Exchanges/month
                               (~23 Exchanges/day)

ONE-TIME SETUP
──────────────────────────────────────────
Legal (fintech + NDPR + contracts) ₦1,170,000–₦4,750,000
TablePlus licence              ₦142,400
Domain registration            ₦16,000–₦48,000

12-MONTH TOTAL (no salaries)   ₦15,397,600
12-MONTH TOTAL (with salaries) ₦50,797,600
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 17. Appendix B — Provider Contacts

| Provider | Website | Purpose | Status |
|---|---|---|---|
| **Paystack** | paystack.com/developers | Payment processing, fund holding, KYC | Sandbox — begin live onboarding Week 1 |
| **Flutterwave** | developer.flutterwave.com | Backup payment provider | Not yet contacted |
| **Termii** | termii.com | SMS, OTP delivery | Account setup — Week 1 |
| **Prembly (IdentityPass)** | prembly.com | BVN/NIN KYC verification | Account setup — Week 3 |
| **Smile Identity** | smileidentity.com | Enhanced KYC (face match, NIN) | Account setup — Week 3 |
| **AWS** | aws.amazon.com/console | All infrastructure | Account creation — Week 1 |
| **Firebase** | firebase.google.com | FCM push notifications | Account setup — Week 2 |
| **Termii / WhatsApp** | termii.com | WhatsApp Business API — Phase 2+ | Phase 2 activation |
| **Logistics partner** | TBD — Computer Village zone | V1 movement, Lagos zone | PM outreach — Week 1 |
| **Fintech legal counsel** | TBD — Nigerian fintech specialist | Fund holding structure review | Engage — Week 1 |
| **NITDA** | nitda.gov.ng | NDPR data processor registration | Submit — Week 3 |

---

*End of Volume VII — Financial Implications Document*  
*BUYIspace Technologies Ltd. | Internal | Confidential*  
*All costs are estimates. Verify with providers before contracting. NGN rate of ₦1,600/USD used throughout — update on revision.*


---

## 18. Final Total Cost Summary — By Category

All figures in ₦. USD shown in parentheses at ₦1,600/$1 reference rate. Monthly figures are averages within each phase. One-time costs are stated separately.

---

### 18.1 Monthly Operating Costs by Category (₦)

| # | Category | Pilot Mo 1–5 (₦/mo) | V1 Live Mo 6–10 (₦/mo) | Growth Mo 11–12 (₦/mo) | At 500 Exch/day (₦/mo) | At 2,000 Exch/day (₦/mo) |
|---|---|---|---|---|---|---|
| 1 | AWS Infrastructure | ₦241,600 | ₦411,200 | ₦411,200 | ₦832,000 | ₦2,240,000 |
| 2 | Development & Engineering Tools | ₦217,600 | ₦217,600 | ₦217,600 | ₦217,600 | ₦217,600 |
| 3 | Design & Collaboration Tools | ₦274,000 | ₦274,000 | ₦274,000 | ₦274,000 | ₦274,000 |
| 4 | AI Development Tools (Kiro + Copilot) | ₦211,200 | ₦211,200 | ₦211,200 | ₦211,200 | ₦320,000 |
| 5 | SMS / OTP Notifications (Termii) | ₦16,000 | ₦56,000 | ₦244,000 | ₦1,152,000 | ₦4,608,000 |
| 6 | KYC / Identity Verification | ₦0 | ₦160,000 | ₦280,000 | ₦800,000 | ₦3,200,000 |
| 7 | Security (WAF + GuardDuty) | ₦0 | ₦32,000 | ₦40,960 | ₦48,000 | ₦80,000 |
| 8 | Email (AWS SES — admin/ops only) | ₦480 | ₦480 | ₦480 | ₦800 | ₦1,600 |
| 9 | WhatsApp Business API | ₦0 | ₦0 | ₦16,000 | ₦32,000 | ₦80,000 |
| 10 | Team Salaries (5 people, illustrative) | ₦2,950,000 | ₦2,950,000 | ₦2,950,000 | ₦4,500,000 | ₦7,000,000 |
| | **Total excl. salaries** | **₦960,880** | **₦1,362,480** | **₦1,695,440** | **₦3,567,600** | **₦11,021,200** |
| | **Total incl. salaries** | **₦3,910,880** | **₦4,312,480** | **₦4,645,440** | **₦8,067,600** | **₦18,021,200** |
| | **USD equiv. excl. salaries** | *~$601* | *~$852* | *~$1,060* | *~$2,230* | *~$6,888* |
| | **USD equiv. incl. salaries** | *~$2,444* | *~$2,695* | *~$2,904* | *~$5,042* | *~$11,263* |

---

### 18.2 One-Time & Setup Costs (₦)

| # | Item | ₦ Low | ₦ Mid (Budget) | ₦ High | USD equiv. (mid) | Timing |
|---|---|---|---|---|---|---|
| 1 | Nigerian fintech legal review (fund holding / escrow) | ₦800,000 | ₦1,600,000 | ₦3,200,000 | *~$1,000* | Weeks 2–8 |
| 2 | NDPR compliance & NITDA registration | ₦160,000 | ₦400,000 | ₦800,000 | *~$250* | Week 3 |
| 3 | CAC business registration | ₦50,000 | ₦100,000 | ₦150,000 | *~$63* | Week 1 |
| 4 | Verifier contractor legal agreements | ₦80,000 | ₦180,000 | ₦300,000 | *~$113* | Week 4 |
| 5 | Logistics partner agreement review | ₦80,000 | ₦180,000 | ₦300,000 | *~$113* | Week 5 |
| 6 | TablePlus database tool licence | ₦142,400 | ₦142,400 | ₦142,400 | *~$89* | Week 1 |
| 7 | Domain name registration (1 year) | ₦16,000 | ₦32,000 | ₦48,000 | *~$20* | Week 1 |
| | **Total one-time costs** | **₦1,328,400** | **₦2,634,400** | **₦4,940,400** | *~$1,646* | — |

---

### 18.3 12-Month Cumulative Total by Category (₦)

Based on actual monthly profile in Section 13 plus one-time costs.

| # | Category | 12-Month Total (₦) | USD equiv. |
|---|---|---|---|
| 1 | AWS Infrastructure | ₦4,085,600 | *~$2,554* |
| 2 | Development & Engineering Tools | ₦2,611,200 | *~$1,632* |
| 3 | Design & Collaboration Tools | ₦3,288,000 | *~$2,055* |
| 4 | AI Development Tools | ₦2,534,400 | *~$1,584* |
| 5 | SMS / Notifications | ₦892,800 | *~$558* |
| 6 | KYC / Identity Verification | ₦1,520,000 | *~$950* |
| 7 | Security (WAF + GuardDuty) | ₦368,640 | *~$230* |
| 8 | Email (AWS SES) | ₦6,240 | *~$4* |
| 9 | WhatsApp (Phase 2 onwards) | ₦96,000 | *~$60* |
| 10 | One-time setup costs (mid estimate) | ₦2,634,400 | *~$1,647* |
| | **Subtotal — tools, infra & setup (no salaries)** | **₦18,037,280** | *~$11,273* |
| 11 | Team salaries — 12 months × ₦2,950,000 | ₦35,400,000 | *~$22,125* |
| | **GRAND TOTAL — 12 months (tools + infra + salaries)** | **₦53,437,280** | *~$33,398* |

---

### 18.4 Per-Exchange Cost Summary (₦)

Full breakdown of what each Exchange costs and generates at three volume points.

| # | Cost / Revenue Item | 100 Exch/mo (₦) | 1,000 Exch/mo (₦) | 5,000 Exch/mo (₦) |
|---|---|---|---|---|
| | **COSTS PER EXCHANGE** | | | |
| 1 | Fixed infra + tools (spread) | ₦11,144 | ₦1,114 | ₦223 |
| 2 | SMS (12 messages avg) | ₦48 | ₦48 | ₦48 |
| 3 | Evidence storage (~5MB) | ₦160 | ₦160 | ₦160 |
| 4 | KYC (new users, est.) | ₦800 | ₦240 | ₦96 |
| 5 | Paystack collection fee (₦150k Exchange) | ₦2,000 | ₦2,000 | ₦2,000 |
| 6 | Paystack payout (2 transfers) | ₦90 | ₦90 | ₦90 |
| 7 | Verifier payment (Phone Check) | ₦2,500 | ₦2,500 | ₦2,500 |
| 8 | Carrier payment (Lagos delivery) | ₦2,500 | ₦2,500 | ₦2,500 |
| | **Total cost per Exchange** | **₦19,242** | **₦8,652** | **₦7,617** |
| | | | | |
| | **REVENUE PER EXCHANGE (mid estimate)** | | | |
| 9 | Platform fee (2% of ₦150k) | ₦3,000 | ₦3,000 | ₦3,000 |
| 10 | Phone Check margin | ₦2,000 | ₦2,000 | ₦2,000 |
| 11 | Delivery fee margin | ₦1,000 | ₦1,000 | ₦1,000 |
| | **Total revenue per Exchange** | **₦6,000** | **₦6,000** | **₦6,000** |
| | | | | |
| | **GROSS MARGIN PER EXCHANGE** | **-₦13,242** | **-₦2,652** | **-₦1,617** |
| | **Margin %** | **-221%** | **-44%** | **-27%** |
| | *Note: at ₦8,500 revenue/Exchange* | *-₦10,742* | *-₦152* | *+₦883* |

> Positive gross margin per Exchange is reached at approximately **₦8,500–₦9,000 average revenue per Exchange** at 5,000 Exchanges/month. This is achievable by optimising the platform fee (2.5–3%) and Check fee margin (₦3,000+) as volume grows and the verifier programme matures.

---

### 18.5 Break-Even Summary (₦)

| Break-Even Scenario | Monthly Exchanges Required | Daily Exchanges Required |
|---|---|---|
| Cover infra + tools only (no salaries) | ~300 Exchanges/month | ~10/day |
| Cover infra + tools + salaries (full burn) | ~690 Exchanges/month | ~23/day |
| Achieve positive gross margin per Exchange | ~5,000 Exchanges/month | ~167/day |
| Full operational profitability (all costs) | ~1,200 Exchanges/month at ₦8,500 revenue | ~40/day |

> 23 Exchanges/day at Computer Village, Lagos — a market processing thousands of transactions daily — is a credible 4–6 month post-pilot target. 40 Exchanges/day (full profitability) is a credible 9–12 month target.

---

*End of Section 18 — Final Total Cost Summary*  
*BUYIspace Technologies Ltd. | Internal | Confidential*
