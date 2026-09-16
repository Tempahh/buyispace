# BUYI — Build Roadmap & Timeline
## Volume VI of the BUYI Engineering Documentation Suite
**Version:** 1.0 — Final Decision Freeze Baseline  
**Date:** 31 August 2026  
**Prepared by:** BUYIspace Technologies Ltd. — Engineering & Product  
**Classification:** Internal — Confidential

> This roadmap is grounded in the BUYI Programmer Master Build Document (Final Decision Freeze, 31 August 2026) and the full engineering documentation suite (Volumes I–V). Timeline assumes a 5-person founding team working at full capacity. Weeks are calendar weeks from Day 1 of the build.

---

## Table of Contents

1. [Team Structure & Responsibilities](#1-team-structure--responsibilities)
2. [Tooling & Infrastructure Plan](#2-tooling--infrastructure-plan)
3. [Timeline Overview](#3-timeline-overview)
4. [Phase 0 — Foundation (Weeks 1–3)](#4-phase-0--foundation-weeks-13)
5. [Phase 1 — One Real Protected Exchange (Weeks 4–10)](#5-phase-1--one-real-protected-exchange-weeks-410)
6. [Phase 2 — Harden Failure Paths (Weeks 11–14)](#6-phase-2--harden-failure-paths-weeks-1114)
7. [Phase 3 — Share & Earn (Weeks 15–17)](#7-phase-3--share--earn-weeks-1517)
8. [Phase 4 — Controlled Modular Pilots (Weeks 18–22)](#8-phase-4--controlled-modular-pilots-weeks-1822)
9. [Milestone Exit Tests](#9-milestone-exit-tests)
10. [Risk Register & Timeline Buffers](#10-risk-register--timeline-buffers)
11. [Resource & Cost Plan](#11-resource--cost-plan)

---

## 1. Team Structure & Responsibilities

The 5-person founding team maps directly to the BUYI build phases. Roles are not siloed — every engineer is expected to read and understand the domain model. The DDD Blueprint (Volume III) is the shared language.

---

### 🏗️ Founding Engineer / Solutions Architect (Shal or Technical Lead)
**Focus:** Exchange Engine, domain model correctness, infrastructure, unblocking the team.

**Responsibilities:**
- Own the Exchange aggregate, state machine, and the modular monolith architecture
- Design and enforce bounded context boundaries (no cross-module DB access)
- Set up cloud infrastructure (AWS/GCP), PostgreSQL, CI/CD pipeline, secrets management
- Integrate Kiro AI spec-driven development workflow across the team
- Build the append-only event log and optimistic locking foundation
- Code review on all money, state transition, and evidence logic
- Final sign-off on all release-blocking engineering tests (SRS §20)
- Pair program with backend developer on payment provider integration

**Owns:** Exchange module, Agreement module, shared domain kernel, database migrations, deployment pipeline

---

### ⚙️ Backend Developer — Domain & Integrations
**Focus:** Shield (payment), Movement (logistics), external provider integrations, background jobs.

**Responsibilities:**
- Implement the Shield module: PaymentIntent, ProtectedFundsRecord, webhook handler, SplitInstruction
- Build the payment provider ACL (Paystack/Flutterwave integration) with idempotency and signature verification
- Implement the Movement module: MovementJob, CustodyEvent, reverse movement
- Build background job engine: ReservationExpiryJob, ReviewWindowExpiryJob, SellerTimeoutJob, SettlementRetryJob
- Implement the Settlement module: ledger, payout execution, idempotent split retries
- Integrate logistics partner ACL (V1: manual or partner API)
- Implement webhook receiver for payment and KYC providers
- Build KYC provider ACL

**Owns:** Shield module, Movement module, Settlement module, background jobs, all external ACLs

---

### ⚙️ Backend Developer — Evidence, Check & Recovery
**Focus:** Item & Evidence module, Check (verification), Problem & Recovery, Admin, Notification.

**Responsibilities:**
- Implement ItemRecord aggregate: ItemSnapshot, ItemIdentity, EvidenceAsset with provenance
- Build pre-signed upload URL flow and server-side hash verification
- Implement Check module: CheckJob, VerifierAssignment, ChecklistVersion, ConflictOfInterestChecker
- Build the Recovery module: Problem, ResolutionVersion, Dispute, DisputeDecision
- Implement the Admin Command Centre: queues, full Exchange view, audited admin actions
- Build Notification module: template engine, SMS ACL (Termii), push notifications, delivery receipts
- Implement Trust & Behavior module: PromiseEvent recording

**Owns:** Item & Evidence module, Check module, Recovery module, Notification module, Admin module, Trust module

---

### 🖥️ Frontend Developer
**Focus:** Mobile-first React Native app, BUYI Link web view, Admin dashboard.

**Responsibilities:**
- Build the Exchange Timeline screen (the living centre of every active deal)
- Implement Review & Pay screen with Protection Map display
- Build Seller confirmation, handoff, and settlement status screens
- Build Verifier assignment, checklist, and evidence capture screens (camera + upload)
- Build carrier pickup/delivery confirmation screens with OTP capture
- Build Problem/recovery structured flow screens
- Build BUYI Link guest view (Next.js SSR — no auth required)
- Build Admin dashboard: queues, full Exchange view, admin action forms
- Build Your BUYI screen: active exchanges, history, earnings
- Implement warm light UI system (large text, restrained green, one primary action per screen)

**Owns:** React Native mobile app, Next.js web (BUYI Link + Admin)

---

### 👔 Product Manager / Designer
**Focus:** User journeys, Figma design system, operations coordination, partner liaison.

**Responsibilities:**
- Produce Figma wireframes and high-fidelity screens for every flow before frontend implementation
- Own the Protection Map copy and Truthful Language Law compliance across all screens
- Liaise with payment provider (Paystack/Flutterwave) for sandbox access, legal review timeline, and go-live requirements
- Coordinate with logistics partner for V1 zone definition, job API or manual workflow, and masked contact setup
- Coordinate with KYC provider for integration spec and threshold policy
- Manage sprint planning in Linear, write specs for each phase, translate Master Build Document into sprint tickets
- Run user testing with Computer Village buyers/sellers during Phase 1 pilot
- Own the verifier qualification programme: recruit, train, and onboard first verifier cohort
- Define the physical Phone Check SOP that maps to the digital checklist

**Owns:** Figma design system, Linear sprint board, partner relationships, verifier programme, user testing

---

## 2. Tooling & Infrastructure Plan

### Development Tools

| Tool | Purpose | Plan / Cost |
|---|---|---|
| **Kiro AI** | Spec-driven development, code generation from Volume II/III specs, agent hooks for lint/test on save | Pay-per-use via AWS Bedrock (~$3/1M input tokens) |
| **GitHub** | Version control, PR reviews, branch protection | Team plan ~$4/user/month |
| **Linear** | Sprint planning, ticket tracking, roadmap | Startup plan ~$8/user/month |
| **Figma** | UI design, prototyping, Dev Mode for handoff | Professional ~$12/editor/month |
| **Notion** | Internal docs, meeting notes, decision log | Plus ~$8/user/month |
| **Slack** | Team communication | Pro ~$7.25/user/month |

### Infrastructure

| Component | V1 Choice | Est. Monthly Cost |
|---|---|---|
| **Cloud** | AWS (Lagos region: af-south-1) | — |
| **Compute** | EC2 t3.medium (app server) | ~$30/month |
| **Database** | RDS PostgreSQL db.t3.medium, single-AZ | ~$60/month |
| **Blob Storage** | S3 (evidence files) + CloudFront CDN | ~$20/month |
| **Secrets** | AWS Secrets Manager | ~$5/month |
| **CI/CD** | GitHub Actions | Included in GitHub plan |
| **Monitoring** | CloudWatch + basic dashboards | ~$20/month |
| **Load Balancer** | AWS ALB | ~$20/month |
| **Total infra V1** | — | **~$155/month** |

### Payment & Comms

| Provider | Purpose | Cost |
|---|---|---|
| **Paystack** | Payment processing, escrow-style fund holding | Free integration; ~1.5% + ₦100 per transaction |
| **Termii** | SMS OTP + notifications | ~₦3–₦5 per SMS |
| **WhatsApp Business API** | Customer care (Phase 2+) | ~$0.01–$0.03 per conversation |

### AI Workflow

Every engineer uses Kiro against the spec documents in this suite. Standard workflow:
1. PM writes a Linear ticket referencing the relevant FR-XX requirement from Volume II
2. Engineer opens the ticket in Kiro, attaches the relevant SRS section and DDD module spec
3. Kiro generates the scaffold; engineer validates against invariants and adds tests
4. PostFileSave hook runs lint + type check automatically
5. PR review checks: does this implementation satisfy the FR acceptance criteria?

---

## 3. Timeline Overview

```
Week:  1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22
       ├────────────┤├──────────────────────────────────────┤├──────────────┤├──────┤├──────────────────────────┤
       PHASE 0       PHASE 1                                  PHASE 2        PH 3    PHASE 4
       Foundation    One Real Protected Exchange              Harden         Share   Controlled Modular Pilots
       (3 weeks)     (7 weeks)                                Failure Paths  & Earn  (5 weeks)
                                                              (4 weeks)      (3 wks)

KEY MILESTONES:
  Week 3  ✦ Foundation complete — no UI can create untracked money/state
  Week 7  ✦ First complete Exchange works in sandbox (internal only)
  Week 10 ✦ 10 end-to-end Exchanges completed — pilot-ready
  Week 14 ✦ 30 failure scenarios pass — hardened for real users
  Week 17 ✦ Share & Earn live — first commission paid
  Week 22 ✦ Modular pilots (Check-only, Fetch-only) operational
```

**Total to pilot-ready (Phase 0 + Phase 1):** ~10 weeks  
**Total to hardened V1 public launch:** ~14 weeks  
**Total to full V1 feature set:** ~22 weeks

---

## 4. Phase 0 — Foundation (Weeks 1–3)

**Objective:** Build the bedrock. No UI, no product visible to users yet. When Phase 0 is done, no action anywhere in the system can create untracked money or state change.

**Exit test:** A developer attempting to create a payment, move money, or change Exchange state via any path (API, background job, admin) without an Exchange record in the event log must receive an error. Zero untracked state changes.

---

### Week 1 — Infrastructure & Schema

**Founding Engineer / Architect:**
- [ ] Provision AWS environment (VPC, RDS PostgreSQL, S3 buckets, ALB, Secrets Manager)
- [ ] Set up GitHub repository with branch protection, PR template, and required reviewers
- [ ] Configure GitHub Actions CI: lint → type check → unit tests → integration tests → build
- [ ] Set up Kiro workspace with steering files pointing to SRS and DDD Blueprint
- [ ] Implement database migration runner (Flyway/Prisma Migrate); first migration: create `exchange` and `exchange_event` tables
- [ ] Implement `exchange_event` append-only enforcement: DB role with INSERT-only on `exchange_event`; no UPDATE/DELETE
- [ ] Implement `Money` value object (integer kobo, no floating point, currency-aware arithmetic)
- [ ] Implement base `DomainEventEnvelope` type and `DomainEventBus` interface

**Backend Developer — Domain & Integrations:**
- [ ] Scaffold modular monolith folder structure (all 12 module directories with domain/application/infrastructure/api subdirs)
- [ ] Implement `shared/` kernel: UserId, ExchangeId, Timestamp, IdempotencyKey value objects
- [ ] Implement PostgreSQL connection pool (PgBouncer config + application connection factory)
- [ ] Write migrations for: `app_user`, `term_version`, `acceptance`, `commitment`, `price_breakdown`
- [ ] Implement optimistic locking pattern (`version` column + WHERE clause in base repository)

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Write migrations for: `item_snapshot`, `item_identity`, `evidence_asset`, `checklist_version`
- [ ] Write migrations for: `problem`, `resolution_version`, `dispute`, `dispute_decision`
- [ ] Write migrations for: `admin_action`, `processed_event` (idempotency table)
- [ ] Implement S3 client utility with pre-signed URL generation and hash verification helpers
- [ ] Implement `EvidenceIntegrityService` stub (hash verify, decision lock)

**Frontend Developer:**
- [ ] Scaffold React Native project (Expo or bare workflow) with navigation structure
- [ ] Scaffold Next.js project for BUYI Link web view and Admin dashboard
- [ ] Configure design tokens: warm light palette, restrained green accent, font scale, spacing
- [ ] Build reusable base components: Button (one primary action), TextInput, Card, StatusBadge

**PM / Designer:**
- [ ] Complete all Figma wireframes for Phase 1 flows (Review & Pay, Exchange Timeline, Seller confirm, Check assignment, Carrier handoff, Delivery, Review, Problem)
- [ ] Write Linear tickets for all Phase 1 tasks with FR references
- [ ] Begin Paystack sandbox account setup and legal review checklist
- [ ] Identify and begin outreach to 3–5 candidate verifiers for Phone Check programme

---

### Week 2 — Exchange Engine & Agreement Core

**Founding Engineer / Architect:**
- [ ] Implement `Exchange` aggregate with full state machine (all 32 states, all valid transitions per SRS §16)
- [ ] Implement `StateTransitionEngine` domain service (configuration-driven, no if/else chains)
- [ ] Implement `CapabilityEngine` domain service (evaluates capability statuses from risk policy config)
- [ ] Implement `ExchangeRepository` (save with optimistic lock, findById, findByParty)
- [ ] Implement `ExchangeEventRepository` (append-only, sequence number generation with row-level lock)
- [ ] Write unit tests: every valid state transition, every invalid transition (must return specific error), capability evaluation
- [ ] Implement `CreateExchange` command handler

**Backend Developer — Domain & Integrations:**
- [ ] Implement `TermVersion` aggregate (immutable content, SHA-256 hash, versioning)
- [ ] Implement `Acceptance` entity and `AgreementService.recordAcceptance()`
- [ ] Implement `Commitment` entity with `CommitmentStatus` and `FailureReasonCode`
- [ ] Implement `PriceBreakdown` value object with sum validation invariant
- [ ] Implement `AgreementService.createInitialTermVersion()` and `createNewVersionForMaterialChange()`
- [ ] Implement `AcceptTerms` command handler with new TermVersion creation and Acceptance recording
- [ ] Write migrations for: `payment_intent`, `protected_funds_record`, `split_instruction`, `ledger_entry`, `refund`

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement `ItemRecord` aggregate: ItemSnapshot (immutable), ItemIdentity, EvidenceAsset (append-only)
- [ ] Implement `EvidenceAsset` entity with provenance fields and `isUsedInDecision` lock
- [ ] Implement `ItemRecordRepository` (no deleteEvidence method)
- [ ] Implement `ChecklistVersion` entity and admin endpoint to create/activate versions
- [ ] Write unit tests: ItemSnapshot immutability, EvidenceAsset append-only, hash invariant

**Frontend Developer:**
- [ ] Build Exchange Timeline screen shell (state display, event list, next action area)
- [ ] Build Review & Pay screen: price breakdown, Protection Map display, terms acceptance, reservation timer

**PM / Designer:**
- [ ] Deliver high-fidelity Figma screens: Review & Pay, Protection Map component, Exchange Timeline
- [ ] Complete Paystack sandbox onboarding; share test API keys with backend dev

---

### Week 3 — Identity, Event Bus & Foundation Integration Test

**Founding Engineer / Architect:**
- [ ] Implement in-process `DomainEventBus` (synchronous, post-commit publish)
- [ ] Wire all Week 2 aggregates to publish domain events via bus
- [ ] Implement `ExchangeLifecycleSaga` skeleton (state machine, listens for domain events)
- [ ] Write foundation integration test: create Exchange → accept terms → verify event log has correct sequence with no gaps
- [ ] Implement `ConflictOfInterestChecker` domain service
- [ ] Set up structured logging (JSON format, no PII in logs)

**Backend Developer — Domain & Integrations:**
- [ ] Implement `Person` aggregate (phone encrypted, KYCState, PayoutToken)
- [ ] Implement `CapabilityProfile` entity (verifier qualifications)
- [ ] Implement phone OTP authentication flow (Termii SMS + JWT issuance + refresh token rotation)
- [ ] Implement `KYCProviderACL` stub (configurable KYC state; thresholds not hard-coded)
- [ ] Implement `PaymentIntent` entity and `ShieldService.createPaymentIntent()`

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement `CheckJob` aggregate with verifier assignment, findings, and outcome invariants
- [ ] Implement `CheckAssignmentService` (eligible verifier selection, conflict check integration)
- [ ] Implement `Problem` aggregate with atomic settlement-block on open
- [ ] Implement `ResolutionVersion` entity with `MoneyEffect` value object
- [ ] Write unit tests: CheckOutcome cannot be PASS if mandatory fields missing; INCONCLUSIVE cannot become PASS; Problem.open() blocks settlement atomically

**Frontend Developer:**
- [ ] Build Seller confirmation screen (confirm fulfill, view agreed terms, cancel option)
- [ ] Build BUYI Link guest view skeleton (Next.js: item snapshot, price, protection scope)

**PM / Designer:**
- [ ] Deliver Figma screens: Seller confirmation, Verifier assignment, BUYI Link guest view
- [ ] Complete verifier SOP document (maps to digital checklist items in ChecklistVersion)
- [ ] Begin logistics partner outreach (V1 Lagos zone partner)

**✦ Phase 0 Exit Test (end of Week 3):**
- No API endpoint allows creation of a PaymentIntent without an Exchange in FUNDED state
- No Exchange state transition happens without an event appended to `exchange_event`
- `exchange_event.sequence_number` has no gaps for any Exchange created
- PriceBreakdown DB constraint fires correctly on invalid sums
- `isUsedInDecision` prevents evidence deletion

---

## 5. Phase 1 — One Real Protected Exchange (Weeks 4–10)

**Objective:** One end-to-end protected phone Exchange works correctly in sandbox, then with real providers, then with real users. Full flow: Buyer → Payment → Seller confirm → Phone Check → Fetch → Delivery → 24h Review → Settlement or Problem.

**Exit test:** 10 complete end-to-end Exchanges successfully settled in a controlled pilot environment. All 25 release-blocking tests pass.

---

### Week 4 — Payment Integration & Shield

**Founding Engineer / Architect:**
- [ ] Review and approve payment provider integration design against SRS FR-SH requirements
- [ ] Implement `reservation_window` atomicity: SELECT FOR UPDATE on inventory when confirming payment
- [ ] Implement payment grace period logic (configurable window while provider outcome pending)
- [ ] Write release-blocking test RBT-019: reservation expiry and payment success atomic resolution

**Backend Developer — Domain & Integrations:**
- [ ] Implement `PaymentProviderACL` (Paystack): createPaymentIntent, signature verification, webhook parsing
- [ ] Implement `payment_webhook_log` table and raw webhook storage (store before process)
- [ ] Implement webhook handler: signature verify → deduplicate (processed_event check) → parse → dispatch
- [ ] Implement `FundsFrozen` flow: `PaymentConfirmed` event → `Exchange.confirmPayment()` → FUNDED
- [ ] Implement `ProtectedFundsRecord` creation and FROZEN status
- [ ] Write release-blocking test RBT-001: duplicate payment webhook never creates duplicate funds

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement full evidence upload flow: `POST /evidence/upload-url` → S3 pre-signed URL → confirm endpoint → hash verify
- [ ] Implement evidence access: `GET /evidence/:id/url` → signed URL (1h for parties, 24h for admin)
- [ ] Wire S3 immutable bucket policy (no overwrite, no delete at storage level)
- [ ] Implement `EvidenceIntegrityService.verifyHash()` and nightly hash check job

**Frontend Developer:**
- [ ] Build payment screen: connects to Paystack SDK, handles payment events, shows reservation timer countdown
- [ ] Build funded state screen: "Payment received. Waiting for seller to confirm."
- [ ] Implement real-time polling on Exchange Timeline (5-second poll, sequence number change detection)

**PM / Designer:**
- [ ] Deliver Figma screens: Payment flow, funded state, reservation timer component
- [ ] Confirm Paystack sandbox payment flow end-to-end with test card

---

### Week 5 — Seller Confirm & Check Assignment

**Founding Engineer / Architect:**
- [ ] Implement `SellerConfirm` command handler with seller timeout configuration
- [ ] Implement `SellerTimeoutJob` (scheduled, configurable 12h default)
- [ ] Implement `CheckRequested` event → `CheckAssignmentService` → verifier assignment or `NO_VERIFIER`
- [ ] Write release-blocking test RBT-002: late seller confirmation after refund cannot reopen Exchange

**Backend Developer — Domain & Integrations:**
- [ ] Implement `AWAITING_SELLER` → `SELLER_CONFIRMED` → `AWAITING_CHECK` path in ExchangeLifecycleSaga
- [ ] Implement seller confirmation deadline enforcement and CANCELLED path with refund trigger
- [ ] Build `CommitmentOutcomeRecorded` event handler → Trust module PromiseEvent recording
- [ ] Implement `BehaviorRecord` and `PromiseEvent` entities in Trust module

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement full `CheckJob` lifecycle: assignment → verifier accepts → checklist execution → result submission
- [ ] Implement `SubmitCheckResult` command: validate mandatory evidence, enforce PASS invariants, emit `CheckResultSubmitted`
- [ ] Implement `MISMATCH` flow: create new `TermVersion`, emit `TermsChanged`, block progression until re-acceptance
- [ ] Write release-blocking test RBT-010: verifier conflict cannot submit result; RBT-011: missing evidence blocks PASS

**Frontend Developer:**
- [ ] Build Verifier screens: assignment detail, conflict declaration, checklist form, camera capture, video + photo upload, result submission
- [ ] Build Buyer MISMATCH screen: specific findings display, accept new terms / cancel options
- [ ] Build "Awaiting check" and "Check passed" states on Exchange Timeline

**PM / Designer:**
- [ ] Deliver Figma screens: Verifier full flow, MISMATCH decision screen, Check passed state
- [ ] Onboard first 2 verifiers; run dry-run Phone Check against test device
- [ ] Create first approved product listing (test phone) in admin

---

### Week 6 — Movement (Fetch) Integration

**Founding Engineer / Architect:**
- [ ] Implement `MovementAuthorized` event → `MovementDispatchService.createJob()`
- [ ] Implement pre-dispatch confirmation validation (all required fields gated before job creation)
- [ ] Implement `movement_value_limit` policy check blocking jobs above declared value cap
- [ ] Write release-blocking test RBT-020: movement above value limit blocked

**Backend Developer — Domain & Integrations:**
- [ ] Implement `LogisticsPartnerACL` (V1: manual confirmation via admin UI or partner API)
- [ ] Implement `ConfirmPickup` command: validate handoff evidence, update `current_custodian`, emit `PickupConfirmed`
- [ ] Implement masked contact routing (temporary masked number per job for carrier)
- [ ] Implement `carrier_selected_by` recording on every MovementJob creation

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement `ConfirmDelivery` command: validate OTP + photos required (GPS alone blocked), emit `DeliveryConfirmed`
- [ ] Implement `ReviewWindowOpened` emission and `review_window_opens_at` / `closes_at` computation
- [ ] Implement `SettlementEligibilitySaga`: schedule review window expiry check on `ReviewWindowOpened`
- [ ] Write release-blocking test RBT-004: invalid delivery proof (missing photos) does not start review timer
- [ ] Write release-blocking test RBT-005: delivery OTP emits receipt event only, not BuyerAccepted

**Frontend Developer:**
- [ ] Build Carrier screens: job detail, pickup OTP, handoff photo capture, delivery OTP, delivery confirmation
- [ ] Build Buyer delivery screen: "Your item is on the way" → "Item delivered — review open until [time]"
- [ ] Display active Protection Map on Exchange Timeline at all stages

**PM / Designer:**
- [ ] Confirm logistics partner V1 integration mode (API or manual ops entry)
- [ ] Define masked contact implementation with partner
- [ ] Deliver Figma screens: carrier flow, delivery confirmation, review window open state

---

### Week 7 — Review Window, Settlement & Problem Basics

**Founding Engineer / Architect:**
- [ ] Implement `ReviewWindowExpiryJob` with atomic Problem-open check before emitting `ReviewWindowExpiredNoProblem`
- [ ] Implement `SettlementEligibilityConfirmed` command → `SplitInstruction` creation
- [ ] Write release-blocking test RBT-003: Problem at 23h59m atomically blocks settlement
- [ ] Write release-blocking test RBT-022 & RBT-023: review expiry creates correct event, never BuyerConfirmed

**Backend Developer — Domain & Integrations:**
- [ ] Implement `SplitInstruction` creation with sum validation invariant
- [ ] Implement payout execution via `PaymentProviderACL` with idempotency keys
- [ ] Implement `SettlementRetryJob` with per-split status check (skip COMPLETED splits)
- [ ] Implement `LedgerEntry` append-only recording for every money movement
- [ ] Write release-blocking test RBT-007: settlement retry never double-pays

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement `OpenProblem` command: atomic Problem creation + `settlementBlocked = true` in single transaction
- [ ] Implement resolution options presentation (filtered by problem type + policy)
- [ ] Implement `ProposeResolution` and `AgreeResolution` command handlers
- [ ] Implement `ResolutionVersion` immutability after both parties agree

**Frontend Developer:**
- [ ] Build Review Window screen: inspect item, "Accept" button, "Report a Problem" button with countdown timer
- [ ] Build Done screen: outcome summary, factual history, settlement status — no fake trust score
- [ ] Build Problem opening screen: problem type selection, description, evidence upload

**PM / Designer:**
- [ ] Deliver Figma screens: review window, settlement settling/done state, problem opening flow
- [ ] Prepare first internal end-to-end test plan (all 5 team members play different roles)

---

### Week 8 — End-to-End Integration & Internal Testing

**Founding Engineer / Architect:**
- [ ] Run full end-to-end Exchange in sandbox: buyer → payment → seller confirm → check → fetch → delivery → review → settlement
- [ ] Fix all issues found; confirm all 25 release-blocking tests pass
- [ ] Write release-blocking test RBT-006: changed terms invalidate old acceptance
- [ ] Write release-blocking test RBT-008: evidence used in decision cannot be deleted
- [ ] Write release-blocking test RBT-009: custody cannot change without handoff evidence

**Backend Developer — Domain & Integrations:**
- [ ] Implement `DeliveryFeeRefunded` flow: pre-dispatch cancellation → automatic refund
- [ ] Implement `RefundSaga` (tracks RefundInitiated → RefundConfirmed, shows INITIATED status to user until CONFIRMED)
- [ ] Write release-blocking test RBT-021: refund shown as INITIATED until provider confirms

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement Notification module: template engine, all notification triggers from SRS FR-NT-002
- [ ] Implement SMS delivery via Termii ACL with idempotency keys
- [ ] Implement `DeliveryReceipt` logging for all notifications

**Frontend Developer:**
- [ ] Build Notification/activity feed in Your BUYI
- [ ] Build resolution proposal and agreement screens
- [ ] Polish Exchange Timeline: all 32 states have correct display label, correct next action, correct deadline display

**PM / Designer:**
- [ ] Conduct first internal end-to-end walkthrough — all 5 team members complete one Exchange
- [ ] Document all UX issues for resolution in Week 9
- [ ] Review all notification templates for Truthful Language Law compliance

---

### Week 9 — Admin Command Centre & Pilot Prep

**Founding Engineer / Architect:**
- [ ] Implement Admin Command Centre: queues (seller timeout, check assignment, movement exception, problems, disputes, settlement failures)
- [ ] Implement all `AdminAction` types with before/after state recording and immutability
- [ ] Write release-blocking tests RBT-016, RBT-017, RBT-018: admin cannot edit terms, delete evidence, or hide overrides
- [ ] Implement `EventSequenceGapDetected` integrity monitor (hourly job)
- [ ] Implement `EvidenceHashMismatchDetected` nightly job

**Backend Developer — Domain & Integrations:**
- [ ] Implement full admin Exchange view: all TermVersions, all evidence with provenance, custody timeline, money ledger, full event log
- [ ] Implement admin refund and partial refund flows (via domain logic, not direct DB)
- [ ] Implement reconciliation endpoint: ledger balance check per Exchange

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement Dispute escalation: `DisputeOpened` event, admin assignment queue
- [ ] Implement `RecordDisputeDecision` command: reasoning required, evidence locked, money effect executed
- [ ] Write release-blocking tests RBT-012: outside carrier cannot be BUYI-CONTROLLED; RBT-013: outside-origin cannot gain retroactive protection; RBT-014 & RBT-015: modular Exchanges work without fake states

**Frontend Developer:**
- [ ] Build Admin dashboard: queue views, Exchange detail view, admin action forms with reason fields
- [ ] Build Dispute decision screen (admin: evidence review, decision recording, reasoning input)
- [ ] Conduct mobile QA: test on low-end Android device on 3G network simulation

**PM / Designer:**
- [ ] Onboard 2 Computer Village sellers as approved suppliers with test listings
- [ ] Onboard 3 trusted buyer testers from network
- [ ] Prepare pilot launch plan: scope (5–10 Exchanges), monitoring plan, issue escalation path

---

### Week 10 — Pilot: 10 Real Exchanges

**Entire team:**
- [ ] Go live with payment provider sandbox → switch to live credentials (Paystack go-live checklist complete)
- [ ] Run 10 controlled end-to-end Exchanges with real Computer Village sellers and buyers (small amounts)
- [ ] Monitor: Exchange event log, payment webhooks, notification delivery, evidence hash integrity
- [ ] Resolve any production issues immediately (all hands)
- [ ] Confirm all 25 release-blocking tests still pass against production environment

**PM / Designer:**
- [ ] Collect structured feedback from all 10 pilot participants (buyers, sellers, verifiers, carrier)
- [ ] Prioritise top 5 issues for Phase 2 week 11 sprint

**✦ Phase 1 Exit Test (end of Week 10):**
- 10 complete end-to-end Exchanges worked correctly
- All 25 release-blocking tests pass in production environment
- Zero duplicate payment events, zero fabricated BuyerConfirmed events, zero settlement before evidence

---

## 6. Phase 2 — Harden Failure Paths (Weeks 11–14)

**Objective:** Every failure path works correctly. Refunds, retries, problem freezes, changed terms, return/reverse custody, admin decisions, and reconciliation all pass 30 dry-run failure scenarios.

**Exit test:** 30 structured failure scenarios pass. No failure path requires manual database intervention to resolve.

---

### Week 11 — Refund Paths & Changed Terms Hardening

**Founding Engineer / Architect:**
- [ ] Implement all cancellation paths with correct refund routing per `carrier_selected_by` and dispatch state
- [ ] Harden `TermsChanged` flow: re-acceptance enforcement, old TermVersion preservation, UI blocking
- [ ] Harden reservation expiry under load: stress test payment + expiry concurrency
- [ ] Failure scenarios: FS-001 (buyer cancels before payment), FS-002 (seller cancels after funding), FS-003 (reservation expires mid-payment)

**Backend Developer — Domain & Integrations:**
- [ ] Implement post-dispatch failed delivery cost attribution logic (per `carrier_selected_by`)
- [ ] Harden `SettlementRetryJob`: max retries, dead-letter queue, admin alert
- [ ] Implement `RefundFailed` handling: retry with backoff, admin escalation
- [ ] Failure scenarios: FS-004 (settlement fails at provider), FS-005 (refund fails at provider), FS-006 (partial payout — seller paid, BUYI payout fails)

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement full return (reverse custody) path: `ReturnSaga` → `ReturnJobCreated` → evidence at return handoff → `RefundInitiated`
- [ ] Harden Problem → Resolution → money effect execution path
- [ ] Failure scenarios: FS-007 (problem opened at 23h59m), FS-008 (buyer opens problem then goes silent), FS-009 (seller refuses return)

**Frontend Developer:**
- [ ] Build return initiation and reverse custody tracking screens
- [ ] Build all error states on payment screen (failed, expired, cancelled)
- [ ] Build "Terms have changed — please review and re-accept" screen

---

### Week 12 — Dispute, Admin Decisions & Evidence Integrity

**Founding Engineer / Architect:**
- [ ] Harden evidence integrity: verify all production evidence hashes, confirm nightly job runs correctly
- [ ] Harden event log integrity: run gap detection against all pilot Exchanges
- [ ] Failure scenarios: FS-010 (duplicate webhook from provider), FS-011 (webhook arrives out of order), FS-012 (provider times out during payout)

**Backend Developer — Domain & Integrations:**
- [ ] Implement full reconciliation report: every Exchange's expected settlement vs. actual ledger entries
- [ ] Implement `payment_webhook_log` cleanup policy (keep raw logs for 90 days, summarised indefinitely)
- [ ] Failure scenarios: FS-013 (ledger entries don't balance for an Exchange), FS-014 (payout sent but no webhook confirmation)

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement full Dispute → admin decision → money effect execution path end-to-end
- [ ] Harden `is_used_in_decision` lock: test admin attempt to delete locked evidence (must fail)
- [ ] Failure scenarios: FS-015 (admin tries to edit original terms), FS-016 (admin tries to delete evidence), FS-017 (dispute decision with no reasoning text — must fail)

**Frontend Developer:**
- [ ] Build admin dispute decision screen with full evidence viewer (video + photos + checklist)
- [ ] Add all admin action confirmation dialogs with required reason field
- [ ] Add reconciliation report view in admin

---

### Week 13 — Edge Cases & Modular Exchange Paths

**Founding Engineer / Architect:**
- [ ] Implement Check-only Exchange complete path (no FUNDED, no movement states)
- [ ] Implement Fetch-only Exchange complete path (no CHECK states)
- [ ] Failure scenarios: FS-018 (Check-only Exchange reaches DONE without FUNDED), FS-019 (Fetch-only Exchange reaches DONE without CHECK_PASSED), FS-020 (modular Exchange — verifier not available)

**Backend Developer — Domain & Integrations:**
- [ ] Implement `NO_VERIFIER` → admin queue → manual assignment path
- [ ] Implement seller-caused Check failure: wasted cost attribution, reason code, PromiseEvent recording
- [ ] Failure scenarios: FS-021 (seller not present for Check — attributable cost), FS-022 (verifier declares conflict after assignment), FS-023 (check inconclusive — honest outcome recording)

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement `INCONCLUSIVE` admin review path (not auto-cancelled; admin queue)
- [ ] Harden buyer cancellation after completed Check: Check fee non-refundable (unless BUYI materially failed)
- [ ] Failure scenarios: FS-024 (buyer cancels immediately after Check PASS — check fee kept), FS-025 (OTP expired at delivery — review timer not started)

**Frontend Developer:**
- [ ] Build `NO_VERIFIER` state display with estimated resolution time
- [ ] Build `INCONCLUSIVE` outcome screen: honest display of reason, next steps
- [ ] QA all 32 Exchange states on Exchange Timeline — every state must render correctly

---

### Week 14 — Final Hardening & 30 Failure Scenario Sign-Off

**Entire team:**
- [ ] Run all 30 failure scenarios in staging environment; document pass/fail for each
- [ ] Fix any remaining failures
- [ ] Performance test: 50 concurrent Exchanges in state `REVIEWING` with ReviewWindowExpiryJob running — no settlement fires incorrectly
- [ ] Security review: check all admin endpoints require elevated token; check all evidence URLs require auth
- [ ] Complete remaining failure scenarios: FS-026 (payment success after Exchange EXPIRED), FS-027 (settlement blocked — Problem opened — Resolution agreed — unblock — settle), FS-028 (return custody event missing evidence — blocked), FS-029 (Movement above value limit attempted), FS-030 (late seller re-confirm after auto-cancel — blocked)

**✦ Phase 2 Exit Test (end of Week 14):**
- All 30 failure scenarios pass without manual DB intervention
- Reconciliation report balances for all test Exchanges
- Admin cannot edit terms, delete evidence, or hide overrides (confirmed by test)

---

## 7. Phase 3 — Share & Earn (Weeks 15–17)

**Objective:** Approved earners can share BUYI Links with full attribution. Completed Exchanges pay the correct commission to the correct earner.

**Exit test:** A completed Exchange with an attribution-carrying BUYI Link pays commission to the correct earner and zero commission to any other party.

---

### Week 15 — Product Approval & BUYI Link

**Founding Engineer / Architect:**
- [ ] Implement `ProductApproval` aggregate in Distribution module
- [ ] Implement `ShareLink` entity with unique token generation
- [ ] Implement BUYI Link guest endpoint (`GET /api/v1/links/:token`): returns item snapshot, price, protection scope, seller facts — no auth required
- [ ] SSR rendering for BUYI Link in Next.js with Open Graph meta tags for WhatsApp/TikTok/Instagram previews

**Backend Developer — Domain & Integrations:**
- [ ] Implement `CommissionRule` value object (flat amount and percentage types)
- [ ] Implement `commission_preview_amount` computation at link generation time
- [ ] Implement attribution freeze handler: listens for `ExchangeFunded` → creates `Attribution` with `frozenAt = paymentConfirmedAt`
- [ ] Enforce: attribution cannot be created after payment; `Attribution` has UNIQUE constraint on `exchangeId`

**Frontend Developer:**
- [ ] Build Share & Earn screen: approved product list, commission preview, share button (WhatsApp deep link, copy link, SMS)
- [ ] Build BUYI Link landing page: item snapshot, Protection Map, price, "Complete this with BUYI" CTA
- [ ] Build earnings section in Your BUYI: pending and available commission balances

---

### Week 16 — Attribution & Commission Settlement

**Backend Developer — Domain & Integrations:**
- [ ] Implement `CommissionReleased` event handler: fires on `SettlementCompleted`, updates `Attribution.commissionStatus = AVAILABLE`
- [ ] Implement `CommissionCancelled` event handler: fires on `ExchangeCancelled`, updates status
- [ ] Add earner as a split recipient in `SplitInstruction` when `Attribution` is AVAILABLE at settlement time
- [ ] Implement `CommissionCancelled` on full refund path

**Backend Developer — Evidence, Check & Recovery:**
- [ ] Implement Notification templates: AttributionFrozen, CommissionReleased, CommissionCancelled
- [ ] Test: earner notified only after settlement — not on click, not on link view

**Frontend Developer:**
- [ ] Build commission status screens: "Commission pending settlement" / "Commission available"
- [ ] Build BUYI official promotion screen (manual promotion of selected approved products by ops team)

**PM / Designer:**
- [ ] Onboard first 5 Share & Earn participants; give them approved product links
- [ ] Confirm WhatsApp preview renders correctly for BUYI Link URLs

---

### Week 17 — Share & Earn Pilot & Sign-Off

**Entire team:**
- [ ] Run 5 Exchanges that originate from BUYI Links
- [ ] Confirm: attribution frozen at payment in all 5 cases; commission pays correctly on settlement; no commission on cancelled Exchanges
- [ ] Confirm: earner cannot see buyer's personal details or payment status — only commission status

**✦ Phase 3 Exit Test (end of Week 17):**
- Completed sale pays correct parties (seller + BUYI + earner) with correct amounts
- Attribution frozen at payment timestamp in all cases
- Zero commission paid for cancelled or refunded Exchanges

---

## 8. Phase 4 — Controlled Modular Pilots (Weeks 18–22)

**Objective:** Enable Check-only, Fetch-only (park-to-door), and selected outside-origin flows in controlled pilots. Operations can fulfill these without making a nationwide promise.

**Exit test:** Each modular Exchange type completes correctly without depending on capabilities not activated.

---

### Weeks 18–19 — Check-Only & Outside-Origin Foundations

- [ ] Enable `FF_CHECK_ONLY` feature flag; expose Check-only Exchange creation in UI (controlled cohort)
- [ ] Enable park-to-door Fetch (`FF_PARK_DOOR`): park name, waybill, release authority, package identity, declared value, destination all required before dispatch
- [ ] Implement outside-origin Exchange shell (`FF_OUTSIDE_ORIGIN`): `exchange_origin = OUTSIDE_ORIGIN` flag, explicit OUTSIDE BUYI classification on prior stages
- [ ] Confirm Protection Map correctly classifies prior payment as OUTSIDE BUYI on outside-origin Exchanges
- [ ] Write release-blocking test RBT-013 confirmation: outside-origin Exchange cannot gain retroactive payment protection at any admin action

### Weeks 20–21 — Modular Pilot Operations

- [ ] Run 5 Check-only Exchanges: buyer books independent phone check, Check PASS/MISMATCH/INCONCLUSIVE, DONE without FUNDED state
- [ ] Run 5 park-to-door Fetch Exchanges: parcel at pickup point, custody tracked, delivery confirmed, buyer reviews
- [ ] Confirm carrier can complete job without BUYI payment data being exposed
- [ ] Confirm BUYI Link works for outside-origin products (shows "Payment — outside BUYI" in Protection Map)

### Week 22 — Pilot Review & V1 Declaration

**Entire team:**
- [ ] Review all modular pilot outcomes; confirm no capability leakage between Exchange types
- [ ] Prepare V1 launch report: Exchange completion rate, verification accuracy, settlement correctness, problem resolution time
- [ ] Enable `FF_SHIELD_ONLY` for a single controlled test cohort (ARCHITECT NOW capability)
- [ ] Plan Phase 5 (open outside-origin, full capability combinations, risk engine) based on pilot learnings

**✦ Phase 4 Exit Test (end of Week 22):**
- Check-only Exchanges complete without FUNDED or DELIVERED states
- Fetch-only Exchanges complete without CHECK_PASSED state
- Operations can fulfill modular jobs without a national or nationwide promise

---

## 9. Milestone Exit Tests

| Milestone | Week | Test |
|---|---|---|
| **Foundation complete** | 3 | No UI action creates untracked money or state change; event log gaps = 0 |
| **First Exchange works** | 7 | One end-to-end Exchange settles correctly in sandbox |
| **Pilot ready** | 10 | 10 Exchanges complete; all 25 release-blocking tests pass |
| **Failure-hardened** | 14 | 30 failure scenarios pass; no manual DB intervention required |
| **Share & Earn live** | 17 | Completed sale pays correct parties; attribution frozen at payment |
| **Full V1** | 22 | All modular Exchange types work; each completes without fake states |

---

## 10. Risk Register & Timeline Buffers

| Risk | Probability | Impact | Mitigation | Buffer |
|---|---|---|---|---|
| **Paystack live go-live delayed** (legal review takes longer than expected) | Medium | High — blocks Phase 1 Week 10 pilot | Begin legal review checklist Week 1; use sandbox aggressively through Week 9; identify Flutterwave as backup | +1 week buffer in Week 10 |
| **No verifier available for pilot** | Low | Medium — blocks Check path | PM begins verifier recruitment Week 1; onboard 3 verifiers by Week 5; dry-run check Week 5 | Check is independent of payment — other paths can proceed |
| **Logistics partner integration slower than expected** | Medium | Medium — blocks Fetch path | V1 logistics ACL can be manual (ops enters handoff data); does not block end-to-end test | Manual ACL as fallback; API integration as parallel track |
| **Optimistic lock contention under load** | Low | High — silent data loss risk | Lock tested in Week 8 stress test; PgBouncer pool tuned; row-level lock on event sequence insert | Architecture prevents this by design; monitor in pilot |
| **Evidence file hash mismatch in production** | Very Low | Critical — dispute integrity | S3 immutable policy set Week 1; hash stored at upload; nightly check from Week 9 | Integrity alert fires immediately; admin queue |
| **Scope creep from "one more thing" requests** | High | High — delays everything | Strict scope gate discipline; ARCHITECT NOW / ENABLE LATER enforced in every sprint review; PM owns the gate | Feature flags exist for all deferred capabilities — no code needed |
| **Team member unavailable for 1+ weeks** | Medium | Medium | Founding Engineer is full-stack capable; modules have clean interfaces; any engineer can pick up any module's work from Volume III | +1 week buffer before each milestone exit test |

### Built-In Buffer Allocation

The 22-week timeline includes ~3 weeks of implicit buffer:
- Phase 1 has 7 weeks for work that a fully-green team could do in 5 — the extra 2 weeks absorbs provider integration friction
- Phase 2 has 4 weeks; the 30 failure scenarios can be tackled in 3 if Phase 1 issues were caught early
- Phase 4 has 5 weeks with room to slip 1 week without impacting the V1 declaration

If a milestone is at risk, the response is: **cut scope, not quality**. Defer a modular pilot variant; never ship a failure path untested.

---

## 11. Resource & Cost Plan

### Team Monthly Burn (Salaries excluded — tools + infrastructure only)

| Item | Monthly Cost (USD) |
|---|---|
| AWS infrastructure (compute, DB, S3, CDN, ALB) | ~$155 |
| GitHub Team | ~$20 |
| Linear Startup | ~$40 |
| Figma Professional (2 seats) | ~$24 |
| Notion Plus (5 seats) | ~$40 |
| Slack Pro (5 seats) | ~$37 |
| Kiro AI (usage-based, estimated) | ~$50 |
| Termii SMS (pilot volume ~5,000 SMS/month) | ~₦15,000 (~$10) |
| **Total tools + infra** | **~$376/month** |

### Payment Provider Economics (Paystack)

Per Exchange (example: ₦150,000 phone):
- Paystack fee: 1.5% + ₦100 = ₦2,350 (~$1.57)
- This is the buyer's payment processing cost, not BUYI's direct cost
- BUYI's `buyi_fee` is defined separately in `PriceBreakdown` and is a product/business decision

### Pilot Phase Estimate (Weeks 1–10)

| Category | Estimated Cost |
|---|---|
| Infrastructure (10 weeks) | ~$390 |
| Tools (10 weeks) | ~$565 |
| SMS (pilot volume) | ~₦50,000 (~$33) |
| **Total pilot burn (tools + infra)** | **~$988** |

Excluding team salaries, the technical cost to reach a working pilot is under $1,000. The primary cost is team time.

### Scaling Cost Inflection Points

| Trigger | Additional Cost |
|---|---|
| > 100 Exchanges/day | Add RDS read replica (~$60/month); scale EC2 to t3.large (~$25/month additional) |
| > 1,000 Exchanges/day | Extract Notification service; add Redis for job queue (~$30/month); upgrade compute |
| Evidence volume > 1TB | S3 cost scales at ~$23/TB/month; CloudFront data transfer ~$85/TB |

---

*End of Volume VI — Build Roadmap & Timeline*  
*BUYIspace Technologies Ltd. | Internal | Confidential*  
*Supersedes timeline suggestions in earlier roadmap documents*
