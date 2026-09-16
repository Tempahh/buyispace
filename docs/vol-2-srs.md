# BUYI — Software Requirements Specification (SRS)
## Volume II of the BUYI Engineering Documentation Suite
**Version:** 1.0 — Final Decision Freeze Baseline  
**Date:** 31 August 2026  
**Prepared by:** BUYIspace Technologies Ltd. — Engineering  
**Classification:** Internal — Confidential  
**Authority:** Derived from the BUYI Programmer Master Build Document (Final Decision Freeze, 31 August 2026) and Volume I PRD. Where conflict exists, the Master Build Document governs.

---

## Table of Contents

1. [Introduction & Scope](#1-introduction--scope)
2. [System Overview](#2-system-overview)
3. [Functional Requirements — Exchange Engine](#3-functional-requirements--exchange-engine)
4. [Functional Requirements — Agreement & Terms](#4-functional-requirements--agreement--terms)
5. [Functional Requirements — Identity & Trust](#5-functional-requirements--identity--trust)
6. [Functional Requirements — Item & Evidence](#6-functional-requirements--item--evidence)
7. [Functional Requirements — Shield (Payment Protection)](#7-functional-requirements--shield-payment-protection)
8. [Functional Requirements — Check (Verification)](#8-functional-requirements--check-verification)
9. [Functional Requirements — Movement (FETCH)](#9-functional-requirements--movement-fetch)
10. [Functional Requirements — Problem & Recovery](#10-functional-requirements--problem--recovery)
11. [Functional Requirements — Settlement](#11-functional-requirements--settlement)
12. [Functional Requirements — Share & Earn / Distribution](#12-functional-requirements--share--earn--distribution)
13. [Functional Requirements — Notifications](#13-functional-requirements--notifications)
14. [Functional Requirements — Admin](#14-functional-requirements--admin)
15. [Data Model Specification](#15-data-model-specification)
16. [Exchange State Machine — Full Specification](#16-exchange-state-machine--full-specification)
17. [API Design Principles & Contract Sketches](#17-api-design-principles--contract-sketches)
18. [Integration Requirements](#18-integration-requirements)
19. [Non-Functional Requirements (Engineering Detail)](#19-non-functional-requirements-engineering-detail)
20. [Release-Blocking Engineering Tests](#20-release-blocking-engineering-tests)
21. [Appendix — Enumerations & Constants](#21-appendix--enumerations--constants)

---

## 1. Introduction & Scope

### 1.1 Purpose

This document specifies the software requirements for the BUYI V1 platform. It translates the product requirements from Volume I (PRD) into precise, testable engineering requirements. Each requirement carries a unique identifier, priority level, and traceability to the governing source.

### 1.2 Scope

This SRS covers the complete V1 system: the Exchange Engine, capability modules (Check, Shield, Fetch), Agreement/Terms, Identity, Evidence, Settlement, Problem/Recovery, Share & Earn, Notifications, and Admin. It covers server-side system behaviour, data model, state machine, API contracts, and integration requirements.

It does not specify UI implementation details (covered in Volume VI — UI/UX Specification) or infrastructure provisioning (covered in Volume IV).

### 1.3 Requirement Priority Levels

| Level | Label | Meaning |
|---|---|---|
| P0 | CRITICAL | Release-blocking. System must not ship without this. |
| P1 | HIGH | Required for V1 pilot. Must be present at pilot launch. |
| P2 | MEDIUM | Required before public launch. Not pilot-blocking. |
| P3 | LOW | Desirable for V1. May be deferred to early post-launch. |

### 1.4 Traceability

Requirements trace to:
- **MBD** — Master Build Document section
- **PRD** — Volume I PRD section or feature spec

### 1.5 Definitions

See Volume I Section 17 (Glossary) for all domain term definitions.

---

## 2. System Overview

### 2.1 Architecture Philosophy

BUYI V1 is a **modular monolith**. All bounded contexts (Exchange, Agreement, Identity, Item, Evidence, Shield, Movement, Settlement, Recovery, Distribution, Trust, Notification) are separate logical modules within a single deployable application. They communicate through well-defined internal interfaces and domain events, not direct cross-module database queries.

This architecture is selected to:
- Allow rapid V1 development without distributed-systems overhead
- Preserve clean module boundaries for future service extraction
- Enable a single deployment with clear responsibility separation

### 2.2 Technology Constraints

| Constraint | Requirement |
|---|---|
| Database | Relational (PostgreSQL recommended). Append-only event log alongside relational tables. |
| Money storage | Integer kobo (int64). Explicit currency field. Never floating point. |
| Event log | Separate `exchange_events` table; every consequential transition appended; nothing deleted |
| Idempotency | All consequential state transitions and payment operations must be idempotent |
| Concurrency | Optimistic locking or database-level row locking for all state transitions |
| Timezone | All timestamps stored in UTC. Display in WAT (UTC+1) for Nigeria. |
| API style | RESTful JSON API. Versioned (`/api/v1/`). Command-based mutations. |
| Authentication | JWT-based session tokens. Refresh token rotation. |
| File storage | Blob storage with CDN. Evidence files: immutable after submission. |
| Payment | Licensed provider SDK/webhook integration. No BUYI-owned payment rail. |

### 2.3 Bounded Context Map

```
┌─────────────────────────────────────────────────────────┐
│                    EXCHANGE ENGINE                       │
│  (State machine • Capability orchestration • Events)    │
└────────┬────────┬────────┬────────┬────────┬────────────┘
         │        │        │        │        │
    ┌────▼──┐ ┌───▼───┐ ┌──▼───┐ ┌─▼────┐ ┌─▼───────┐
    │AGRMT  │ │SHIELD │ │CHECK │ │MOVE  │ │RECOVERY │
    │Terms  │ │Payment│ │Verif.│ │Fetch │ │Problem  │
    │Commit.│ │Funds  │ │Evid. │ │Custody│ │Dispute  │
    └───────┘ └───────┘ └──────┘ └──────┘ └─────────┘
         │        │        │        │        │
    ┌────▼────────▼────────▼────────▼────────▼────────┐
    │              SETTLEMENT ENGINE                   │
    │     Ledger • Payout • Refund • Split             │
    └──────────────────────────────────────────────────┘
         │
    ┌────▼──────┐  ┌──────────┐  ┌────────────┐
    │ IDENTITY  │  │DISTRIBTN │  │NOTIFICATION│
    │ KYC/Trust │  │Share/Earn│  │ Templates  │
    └───────────┘  └──────────┘  └────────────┘
```

---

## 3. Functional Requirements — Exchange Engine

### FR-EX-001 — Exchange Creation
**Priority:** P0 | **Source:** MBD §4, §5

Every supported BUYI job must create an Exchange record before any money, evidence, or state change occurs. An Exchange cannot be created in an invalid initial state.

**Required fields at creation:**
- `exchange_id` (UUID, system-generated)
- `exchange_origin` (ENUM: `BUYI_SUPPLY` | `OUTSIDE_ORIGIN` | `PRIVATE_DEMAND`)
- `market` (default: `NG`)
- `currency` (default: `NGN`)
- `category` (e.g. `PHONE`)
- `risk_policy_version` (references active policy at creation time)
- `capability_statuses` (map of capability → status for this Exchange)
- `current_state` (initial: `DRAFT`)
- `parties` (at minimum one initiating party)
- `created_at` (UTC timestamp)

**Invariants:**
- No Exchange is created without a `risk_policy_version` reference
- `exchange_id` is globally unique and immutable after creation
- `exchange_origin` is immutable after creation

---

### FR-EX-002 — Append-Only Event Log
**Priority:** P0 | **Source:** MBD §4, §6 (Exchange Truth Law, Evidence Integrity Law)

Every consequential transition must append a record to `exchange_events`. No event is ever deleted or updated.

**Event record fields:**
- `event_id` (UUID)
- `exchange_id` (FK)
- `event_type` (ENUM — see Section 21)
- `actor_id` (user/system/admin who caused the event)
- `actor_role` (BUYER | SELLER | VERIFIER | CARRIER | SYSTEM | ADMIN)
- `payload` (JSON — event-specific data)
- `created_at` (UTC timestamp, server-assigned)
- `sequence_number` (monotonically increasing per Exchange)

**Invariant:** `sequence_number` must never have gaps within an Exchange. If a gap is detected, it is treated as a data integrity error.

---

### FR-EX-003 — State Machine Enforcement
**Priority:** P0 | **Source:** MBD §5

State transitions must be enforced server-side. The client cannot set Exchange state directly.

All valid transitions are defined in Section 16. Any attempt to transition to an invalid next state must return an error with a specific reason code. The attempted transition must be logged (as a failed attempt event) but must not mutate state.

---

### FR-EX-004 — Capability Status Management
**Priority:** P0 | **Source:** MBD §3, §14 (Capability Activation Law)

Each Exchange carries a `capability_statuses` map. Valid statuses per capability: `REQUIRED` | `RECOMMENDED` | `REQUESTED` | `UNAVAILABLE` | `NOT_NEEDED`.

Rules:
- Capability statuses are evaluated at Exchange creation based on `risk_policy_version`, `category`, `market`, and `exchange_origin`
- A user may request an optional capability, raising its status from `NOT_NEEDED` to `REQUESTED`
- Risk policy may elevate `REQUESTED` or `RECOMMENDED` to `REQUIRED` — this cannot be overridden by user
- A `REQUIRED` capability that is `UNAVAILABLE` blocks Exchange creation
- State transitions are gated: a transition requiring a capability that is `NOT_NEEDED` or `UNAVAILABLE` is blocked

---

### FR-EX-005 — Modular Exchange Completion
**Priority:** P0 | **Source:** MBD §14

A Check-only Exchange must reach a valid terminal state (`DONE` or `CANCELLED`) without requiring `FUNDED`, `SELLER_CONFIRMED`, `READY_TO_MOVE`, `PICKED_UP`, `IN_TRANSIT`, or `DELIVERED` states.

A Fetch-only Exchange must reach a valid terminal state without requiring `FUNDED`, `CHECKING`, `CHECK_PASSED`, or any Shield-related states.

The state machine must support modular paths. States irrelevant to the activated capabilities are skipped, not faked.

---

### FR-EX-006 — Exchange Parties
**Priority:** P0 | **Source:** MBD §4

An Exchange has one or more `ExchangeParty` records, each with:
- `party_id`
- `exchange_id`
- `user_id`
- `role` (BUYER | SELLER | VERIFIER | CARRIER | RESELLER | OBSERVER)
- `obligations` (list of active Commitment IDs for this party)
- `joined_at`

A party's role is specific to this Exchange. The same user can be BUYER in one Exchange and SELLER in another (Human Capability Law).

---

### FR-EX-007 — Exchange Timeline View
**Priority:** P0 | **Source:** MBD §11

The system must provide an Exchange Timeline endpoint that returns:
- Current state (with human-readable label)
- Ordered list of all past events with actor, type, timestamp, and display description
- Active party obligations and deadlines
- Current next actions available (keyed by party role)
- Active Problem summary (if any)
- Protection Map classification for each stage

This is a read model (projection), assembled from the event log. It must not be the aggregate itself.

---

### FR-EX-008 — Reservation & Payment Grace Period
**Priority:** P0 | **Source:** MBD §6

Reservation begins at the payment stage (state: `PAYMENT_PENDING`), not at BUY NOW tap or at `BUYER_REVIEWING`.

Default reservation window: **10 minutes**.

If a payment attempt has started before reservation expiry, a short configurable **payment grace period** is supported while the provider outcome is pending. This window is not indefinite — it must have a maximum duration.

After reservation expiry (and grace period if applicable), if no successful payment event is received, the Exchange returns to `BUYER_REVIEWING` or is cancelled (depending on policy) and inventory is released.

Payment success and reservation expiry must resolve **atomically** to prevent the same unique item from being sold twice.

---

### FR-EX-009 — Exchange Expiry & Abandonment
**Priority:** P1 | **Source:** MBD §5

Exchanges in `DRAFT` state must be expired after a configurable abandonment period. Expired drafts must release any associated inventory reservations.

Abandoned Exchanges in `AWAITING_SELLER` must trigger seller timeout handling after the configurable window (default 12h).

---

## 4. Functional Requirements — Agreement & Terms

### FR-AG-001 — Term Version Creation
**Priority:** P0 | **Source:** MBD §4 (Agreement Versioning Law)

Every Exchange must have a linked `TermVersion` at the point of buyer commitment.

`TermVersion` fields:
- `term_version_id` (UUID)
- `exchange_id`
- `version_number` (monotonically increasing per Exchange; starts at 1)
- `content` (full agreed terms — immutable JSON or text blob)
- `content_hash` (SHA-256 of content — for integrity verification)
- `created_at`
- `created_by` (actor who triggered this version — SYSTEM for initial; SYSTEM or party for renegotiation)
- `supersedes_version_id` (FK to previous version if this is a renegotiation)

**Invariants:**
- `content` and `content_hash` are immutable after creation
- No version is deleted
- Admin cannot edit `content` of any TermVersion

---

### FR-AG-002 — Acceptance Recording
**Priority:** P0 | **Source:** MBD §4

Every material acceptance by a party must create an `Acceptance` record:
- `acceptance_id` (UUID)
- `term_version_id`
- `party_id`
- `accepted_at` (UTC)
- `acceptance_method` (e.g. `EXPLICIT_UI_ACTION`, `OTP_CONFIRMATION`)
- `ip_address` (for legal record)

An Exchange cannot progress past `BUYER_REVIEWING` without a recorded Acceptance for the current TermVersion from the Buyer.

---

### FR-AG-003 — Material Change Handling
**Priority:** P0 | **Source:** MBD §4 (Agreement Versioning Law)

A material change (e.g. price change after MISMATCH, seller proposes different item) must:
1. Create a new `TermVersion` (version_number increments)
2. Invalidate the previous Acceptance for all affected parties
3. Block Exchange progression until the affected party(ies) accept the new version
4. Preserve the old TermVersion — it must remain readable and unmodified
5. Emit a `TermsChanged` domain event

The definition of "material change" is encoded in policy, not hardcoded per scenario.

---

### FR-AG-004 — Commitment Recording
**Priority:** P0 | **Source:** MBD §4 (Commitment Law)

Each party's obligations in an Exchange are represented as `Commitment` records:
- `commitment_id` (UUID)
- `exchange_id`
- `party_id` (the party bearing this commitment)
- `commitment_type` (ENUM — e.g. `FULFILL_ORDER`, `PROVIDE_ITEM_AS_DESCRIBED`, `PAY_AMOUNT`, `COMPLETE_CHECK`, `DELIVER_ITEM`, `RETURN_ITEM`)
- `description`
- `due_at` (deadline, if applicable)
- `status` (`ACTIVE` | `MET` | `FAILED` | `WAIVED`)
- `failure_reason_code` (if FAILED — must reference specific reason, not vague blame)

Problems must reference a specific `commitment_id`.

---

### FR-AG-005 — Price Breakdown
**Priority:** P0 | **Source:** MBD §4

Every Exchange Agreement must include a structured `PriceBreakdown`:
- `item_price` (int64, kobo)
- `check_fee` (int64, kobo — 0 if Check not activated)
- `delivery_fee` (int64, kobo — 0 if Fetch not activated)
- `buyi_fee` (int64, kobo)
- `total_buyer_pays` (int64, kobo — sum of all above)
- `seller_receives` (int64, kobo — after BUYI fee)
- `currency` (always `NGN` for V1)

All values must be non-negative. `total_buyer_pays` must equal the sum of components. This is validated server-side before the Exchange proceeds.

---

## 5. Functional Requirements — Identity & Trust

### FR-ID-001 — User / Person Record
**Priority:** P0 | **Source:** MBD §4

Every authenticated BUYI user has a `User` record:
- `user_id` (UUID)
- `phone_number` (hashed + encrypted; E.164 format)
- `display_name`
- `kyc_state` (`UNVERIFIED` | `BASIC` | `ENHANCED` | `REJECTED`)
- `payout_destination_token` (provider-assigned token; never raw bank details in BUYI DB)
- `created_at`
- `account_status` (`ACTIVE` | `SUSPENDED` | `RESTRICTED`)

Roles (Buyer, Seller, Verifier) are not stored on the User record. They are Exchange-specific.

---

### FR-ID-002 — KYC State
**Priority:** P1 | **Source:** MBD §6, §10 (KYC threshold: OPEN/PROVIDER-DEPENDENT)

KYC thresholds are not hard-coded. They are driven by provider policy configuration.

The system must support configurable KYC gate checks on:
- Payment amount (trigger enhanced KYC above provider threshold)
- Payout amount
- Cumulative transaction volume

The `kyc_state` field must be updated by verified events from the KYC provider, not by user self-report.

The system must block payment or payout if the user's current `kyc_state` is below the required level for the transaction.

---

### FR-ID-003 — Payout Destination
**Priority:** P0 | **Source:** MBD §4

BUYI never stores raw bank account numbers or card numbers. Payout destination is stored as a provider-issued token (`payout_destination_token`). The token references the seller's registered account in the provider's system.

---

### FR-ID-004 — Verifier Conflict of Interest Check
**Priority:** P0 | **Source:** MBD §7

Before confirming a verifier assignment, the system must check:
- The assigned verifier is not the Buyer of this Exchange
- The assigned verifier is not the Seller of this Exchange
- The assigned verifier is not a recorded known associate of either party (per admin-maintained association records)
- The verifier has not been directly paid by either party outside of BUYI in a configurable recent period

If any check fails, the assignment is blocked. The verifier may also self-declare a conflict, which immediately blocks the assignment and triggers reassignment.

---

### FR-ID-005 — Basic Behavior Events
**Priority:** P1 | **Source:** MBD §4, §8 (Behavior domain)

The system must record factual behavior events for every consequential Exchange outcome:
- `PromiseEvent` fields: `user_id`, `exchange_id`, `event_type` (`PROMISE_MADE` | `PROMISE_KEPT` | `PROMISE_BROKEN`), `commitment_type`, `outcome_reason`, `completion_quality`, `recorded_at`

No public behavior score is computed or exposed in V1. Events are stored for internal use, risk policy, and future Trust Engine views.

---

## 6. Functional Requirements — Item & Evidence

### FR-IE-001 — Item Snapshot
**Priority:** P0 | **Source:** MBD §4 (Item domain, Proof Follows Object Law)

Every Exchange involving a physical item must have an `ItemSnapshot` record created at the time of listing/agreement:
- `item_snapshot_id` (UUID)
- `exchange_id`
- `category` (`PHONE` for V1)
- `make`, `model`, `storage`, `colour`, `variant`
- `described_condition` (ENUM: `NEW` | `LIKE_NEW` | `GOOD` | `FAIR` | `PARTS_ONLY`)
- `described_accessories` (list)
- `repairs_disclosed` (text — seller must disclose known repairs)
- `listed_price` (int64, kobo)
- `snapshot_at` (UTC — immutable after creation)
- `snapshot_hash` (SHA-256 of snapshot content)

The ItemSnapshot is immutable. It represents what was described at the time of agreement.

---

### FR-IE-002 — Item Identity
**Priority:** P0 | **Source:** MBD §4, §7 (Proof Follows Object Law)

Physical item identity is recorded in `ItemIdentity`:
- `item_identity_id` (UUID)
- `exchange_id`
- `item_snapshot_id`
- `identity_type` (`IMEI` | `SERIAL` | `SEAL_ID` | `PACKAGE_ID` | `CATEGORY_OTHER`)
- `identity_value` (encrypted at rest)
- `recorded_at`
- `recorded_by` (verifier_id or system)
- `recording_stage` (the Exchange state at which this was recorded)

For phones: IMEI is the primary identity. Recording IMEI is "where lawful" — this field must be gated by a market-level legal configuration flag before being made mandatory.

Multiple ItemIdentity records may exist for one item (IMEI + serial, for example).

---

### FR-IE-003 — Evidence Asset
**Priority:** P0 | **Source:** MBD §4, §10 (Evidence Provenance Law, Evidence Integrity Law)

Every piece of evidence is an `EvidenceAsset`:
- `evidence_asset_id` (UUID)
- `exchange_id`
- `item_identity_id` (FK — evidence attaches to item, not just Exchange)
- `stage` (Exchange state at which evidence was captured)
- `evidence_type` (`VIDEO` | `PHOTO` | `OTP_CONFIRMATION` | `DOCUMENT` | `CHECKLIST_RESULT`)
- `file_reference` (storage URL/key — never the raw file in DB)
- `file_hash` (SHA-256 of file at upload time)
- `captured_at` (timestamp from capture device — validated against server time)
- `uploaded_at` (server UTC timestamp)
- `captured_by` (user_id)
- `capturer_role` (VERIFIER | CARRIER | BUYER | SELLER | SYSTEM)
- `checklist_version_id` (FK if evidence is checklist-related)
- `coarse_location` (optional lat/long rounded to ~1km precision)
- `access_policy` (`EXCHANGE_PARTIES` | `ADMIN_ONLY` | `DISPUTE_REVIEWERS`)
- `is_used_in_decision` (boolean — set to true when referenced in a ResolutionVersion or admin Decision)

**Invariants:**
- `file_hash` is computed server-side on upload and stored. If the file is later tampered with, hash mismatch is detectable.
- Evidence used in a decision (`is_used_in_decision = true`) cannot be deleted by any actor including admin.
- Corrections do not overwrite: a corrected evidence submission creates a new `EvidenceAsset` with a reference to the superseded record.

---

### FR-IE-004 — Checklist Version
**Priority:** P0 | **Source:** MBD §7

Phone Check evidence references a specific `ChecklistVersion`:
- `checklist_version_id` (UUID)
- `category` (`PHONE`)
- `version_number`
- `items` (structured list of check items with pass/fail/NA options)
- `active_from`, `active_until`
- `created_by`

A completed Check report references the exact `checklist_version_id` used. Checklist versions are immutable after activation.

---

### FR-IE-005 — Evidence Integrity Validation
**Priority:** P0 | **Source:** MBD §15 (release-blocking)

The system must validate at all evidence-dependent state transitions:
- Required evidence fields are present and non-null
- File hash is verifiable (file not corrupted)
- Evidence timestamp is within an acceptable window relative to the stage it covers
- Verifier conflict-of-interest check passed before any check evidence is accepted
- Missing mandatory evidence fields prevent a PASS outcome

---

## 7. Functional Requirements — Shield (Payment Protection)

### FR-SH-001 — Payment Intent
**Priority:** P0 | **Source:** MBD §4, §6

When an Exchange reaches `PAYMENT_PENDING`, the system creates a `PaymentIntent`:
- `payment_intent_id` (UUID)
- `exchange_id`
- `amount` (int64, kobo)
- `currency`
- `provider_reference` (provider-assigned ID)
- `idempotency_key` (UUID, system-generated, sent with every provider call)
- `status` (`PENDING` | `SUCCEEDED` | `FAILED` | `CANCELLED` | `EXPIRED`)
- `created_at`
- `resolved_at`

The `idempotency_key` is used for all provider calls related to this PaymentIntent. The same key must be sent on retries.

---

### FR-SH-002 — Payment Webhook Handling
**Priority:** P0 | **Source:** MBD §15 (release-blocking)

Payment provider webhooks must be:
1. Received and stored raw (append to `payment_webhook_log` before processing)
2. Signature-verified before processing
3. Deduplicated using the provider's event ID — a duplicate webhook must not create duplicate state changes
4. Processed idempotently: if a `PaymentReceived` event is replayed for an already-FUNDED Exchange, it must be a no-op (not an error, not a double-fund)

`ProtectedFundsRecord` is created only once per Exchange per successful payment event:
- `protected_funds_id` (UUID)
- `exchange_id`
- `payment_intent_id`
- `amount` (int64, kobo)
- `currency`
- `status` (`FROZEN` | `RELEASED` | `REFUNDED` | `PARTIALLY_REFUNDED`)
- `frozen_at`
- `released_at`

---

### FR-SH-003 — Reservation Atomicity
**Priority:** P0 | **Source:** MBD §6, §15

Payment success and reservation expiry must be resolved atomically using a database-level transaction with appropriate locking. Under no condition may the same unique-inventory item be double-sold.

Implementation approach:
- Inventory row locked (SELECT FOR UPDATE) when processing payment success
- If reservation has expired: payment is rejected; provider refund triggered; Exchange returns to BUYER_REVIEWING or CANCELLED
- If reservation still valid: payment confirmed; Exchange transitions to FUNDED; inventory marked RESERVED

---

### FR-SH-004 — Protected Funds Freeze
**Priority:** P0 | **Source:** MBD §5, §6

On `FUNDED`, the `ProtectedFundsRecord.status` = `FROZEN`. Frozen funds must not be released until:
- Settlement eligibility conditions are met (see FR-SET), AND
- No Problem with `blocks_settlement = true` is open

A Problem opened at any time before settlement — including at 23h59m into the review window — must atomically block settlement. This is enforced by checking `Problem` records within the same transaction as settlement eligibility evaluation.

---

### FR-SH-005 — Delivery Fee Handling
**Priority:** P0 | **Source:** MBD §6

The base delivery fee is captured before dispatch. It is a component of the `PriceBreakdown` and paid at the same time as the item price.

If an Exchange is cancelled before carrier acceptance/dispatch and no provider cost has been incurred:
- Delivery fee is refunded automatically
- Refund triggers a `DeliveryFeeRefunded` event

If cancelled after dispatch, the cost allocation follows `carrier_selected_by` and attributable cause (buyer / seller / BUYI / carrier). The system must record the attributable cause before processing any post-dispatch cancellation refund.

---

## 8. Functional Requirements — Check (Verification)

### FR-CH-001 — Verifier Assignment
**Priority:** P0 | **Source:** MBD §7

When Exchange enters `AWAITING_CHECK`, the system creates a verifier assignment job. The assignment process:
1. Selects a qualified verifier from the approved pool (category-qualified, not conflicted)
2. Runs conflict of interest checks (FR-ID-004)
3. Sends assignment with: Exchange reference, item identity, location, checklist version, deadline
4. Records assignment in `VerifierAssignment` table
5. If no verifier is available: Exchange transitions to `NO_VERIFIER` state; admin notified

---

### FR-CH-002 — Check Execution & Evidence Capture
**Priority:** P0 | **Source:** MBD §7

During `CHECKING` state, the verifier:
1. Confirms item identity against `ItemSnapshot` (model, IMEI/serial)
2. Executes checklist per `ChecklistVersion`
3. Captures required evidence:
   - Continuous short video (minimum duration configurable per checklist)
   - Required stills (quantity per checklist)
   - Timestamp (validated against server time — cannot be backdated)
   - Coarse location (optional, where appropriate)
4. Records all findings per checklist item
5. Submits outcome

Evidence upload must complete before outcome submission is accepted.

---

### FR-CH-003 — Check Outcome
**Priority:** P0 | **Source:** MBD §7

Valid outcomes: `PASS` | `MISMATCH` | `INCONCLUSIVE`

Rules:
- `PASS`: All mandatory checklist items met; evidence complete; item identity confirmed; no findings inconsistent with described condition
- `MISMATCH`: One or more material findings differ from described condition. Must include `mismatch_details` (structured list of specific discrepancies)
- `INCONCLUSIVE`: Sufficient evidence cannot be obtained (e.g. activation lock cannot be cleared, item unavailable). Must include `inconclusive_reason`
- `INCONCLUSIVE` is never forced to `PASS`. The system must enforce this.
- Missing mandatory evidence fields block `PASS` submission — returns validation error

Check report is immutable after submission. A new check requires a new assignment.

---

### FR-CH-004 — Post-Check Flows
**Priority:** P0 | **Source:** MBD §5, §7

After `CHECK_PASSED`:
- Exchange transitions to `READY_TO_MOVE` (if Fetch capability active) or relevant next state
- Buyer notified with check summary and evidence access link

After `MISMATCH`:
- Exchange transitions to `MISMATCH` state
- Buyer receives specific findings
- Buyer options: (a) accept changed terms → new TermVersion created → re-acceptance required → `READY_TO_MOVE`, (b) cancel → refund initiated, (c) policy may allow other configured options

After `INCONCLUSIVE`:
- Exchange transitions to `MISMATCH` state (or a dedicated INCONCLUSIVE state if policy supports)
- Admin review triggered
- Buyer informed honestly: "Check was inconclusive — [reason]"

---

### FR-CH-005 — Check Fee & Seller Failure
**Priority:** P0 | **Source:** MBD §7, §10

Check fee is non-refundable to buyer after completed Check unless BUYI or the Check process materially failed.

If seller causes failure after verifier dispatch (e.g. item not available, seller refuses access):
- `attributable_failure_reason` code recorded on the Exchange event
- Seller bears applicable wasted Check cost
- System records as `PROMISE_BROKEN` behavior event for the seller

---

## 9. Functional Requirements — Movement (FETCH)

### FR-MV-001 — Movement Job Creation
**Priority:** P0 | **Source:** MBD §8

Movement job (`MovementJob`) is created when Exchange reaches `READY_TO_MOVE`:
- `movement_job_id` (UUID)
- `exchange_id`
- `carrier_id` (assigned logistics partner)
- `carrier_selected_by` (`BUYI` | `BUYER` | `SELLER` | `MUTUAL`)
- `pickup_location` (structured address)
- `delivery_location` (structured address)
- `item_identity_id` (FK)
- `declared_value` (int64, kobo)
- `release_authority` (who authorises release of item at pickup)
- `status` (`PENDING` | `DISPATCHED` | `PICKED_UP` | `IN_TRANSIT` | `DELIVERED` | `FAILED` | `RETURNED`)
- `created_at`

Movement above the supported provider/declared-value limit is blocked. The system checks declared_value against `movement_value_limit` in the policy configuration before creating the job.

---

### FR-MV-002 — Pre-Dispatch Confirmation
**Priority:** P0 | **Source:** MBD §8

For park-to-door flows, the system must confirm all of the following before dispatch:
- Collectible job exists (item is ready and available)
- Waybill/reference recorded
- Release authority confirmed
- Package description and identity recorded
- Declared value recorded
- Destination and contact details present (masked contact provided to carrier)

Any missing field blocks dispatch and returns a specific validation error.

---

### FR-MV-003 — Custody Handoff Recording
**Priority:** P0 | **Source:** MBD §8, §13 (Custody Law)

Every material handoff records a `CustodyEvent`:
- `custody_event_id` (UUID)
- `movement_job_id`
- `exchange_id`
- `event_type` (`PICKUP` | `INTERMEDIATE_HANDOFF` | `DELIVERY` | `FAILED_ATTEMPT` | `RETURN_PICKUP` | `RETURN_DELIVERY`)
- `releaser_id`
- `receiver_id`
- `current_custodian_id` (updated to receiver after successful handoff)
- `timestamp`
- `proof_method` (`OTP` | `PHOTO` | `SIGNATURE` | `NONE`)
- `evidence_asset_ids` (list — photos, OTP confirmation)
- `item_condition_note` (optional)

`current_custodian` on the `MovementJob` is updated only after a CustodyEvent is recorded with sufficient evidence.

GPS coordinates alone do not constitute delivery proof. GPS may be recorded as supplemental metadata but must not be the sole `proof_method` for a custody transfer.

---

### FR-MV-004 — Delivery Evidence & Review Trigger
**Priority:** P0 | **Source:** MBD §5, §15 (release-blocking)

Delivery OTP confirms receipt by the buyer. It does NOT constitute buyer acceptance of item condition.

On delivery:
1. Carrier captures delivery OTP from buyer
2. Carrier submits delivery confirmation with photos
3. System validates: OTP valid + photos present
4. `CustodyEvent` recorded (type: `DELIVERY`)
5. Exchange transitions to `DELIVERED`
6. 24-hour review window opens: `review_window_opens_at` = now, `review_window_closes_at` = now + 24h
7. Buyer notified: "Item delivered. You have 24 hours to check and raise any problem."

Invalid delivery proof (missing photos, OTP mismatch, expired OTP) does not trigger the review window. The Exchange remains in `IN_TRANSIT` and admin is alerted.

---

### FR-MV-005 — Masked Contact Access
**Priority:** P1 | **Source:** MBD §8

Carriers must be able to call buyer or seller through a BUYI-masked number. Raw phone numbers must not be exposed to carriers. The system provides a temporary masked routing number per movement job.

---

### FR-MV-006 — Reverse Movement (Return)
**Priority:** P0 | **Source:** MBD §9, §20 (Reverse Custody Law)

A return is a controlled custody path. A `ReverseMovementJob` is created when a resolution requiring return is accepted:
- All fields equivalent to `MovementJob`
- `direction` = `RETURN`
- `return_authorisation_id` (references ResolutionVersion that authorised the return)

Return custody follows the same handoff evidence requirements as forward movement. Item condition at return handoff is documented. Refund is initiated after sufficient return evidence — not before.

---

## 10. Functional Requirements — Problem & Recovery

### FR-PR-001 — Problem Opening
**Priority:** P0 | **Source:** MBD §9, §18 (Problem Freeze Law)

A Problem can be opened by the Buyer during the review window, or by BUYI/admin at any stage where a commitment has failed.

`Problem` record:
- `problem_id` (UUID)
- `exchange_id`
- `commitment_id` (specific Commitment alleged to have failed)
- `problem_type` (ENUM: `WRONG_ITEM` | `CONDITION_MISMATCH` | `DAMAGED` | `INCOMPLETE` | `NOT_DELIVERED` | `LATE_DELIVERY` | `OTHER`)
- `description` (text)
- `evidence_asset_ids` (evidence submitted with problem)
- `reporter_id`
- `reporter_role`
- `blocks_settlement` (boolean — computed from problem_type and policy)
- `status` (`OPEN` | `RESOLVED` | `ESCALATED` | `DISPUTED` | `CLOSED`)
- `opened_at`

On `Problem.opened_at`, the system must atomically:
1. Create the Problem record
2. Set `ProtectedFundsRecord.settlement_blocked = true` (if `blocks_settlement = true`)
3. Emit `ProblemOpened` domain event
4. Notify both parties

This must be a single database transaction. A Problem opened at 23h59m into the review window must still block auto-settlement.

---

### FR-PR-002 — Resolution Options
**Priority:** P0 | **Source:** MBD §9

Available resolution options (presented to parties after Problem is opened):
- `CONTINUE` — buyer accepts item as-is; settlement proceeds
- `CORRECTION` — seller provides missing accessory or corrects a specific issue
- `REPLACEMENT` — seller provides a replacement item (new Exchange may be required)
- `PARTIAL_REFUND` — agreed price reduction; partial release to seller and partial to buyer
- `RETURN_AND_REFUND` — full return and full refund
- `MORE_TIME` — deadline extension agreed
- `RELEASE` — buyer elects to release settlement despite problem (documented waiver)
- `ESCALATE` — formal Dispute

Available options are filtered by problem type, Exchange state, and policy.

---

### FR-PR-003 — Resolution Version
**Priority:** P0 | **Source:** MBD §9

When parties agree on a resolution:
1. `ResolutionVersion` is created:
   - `resolution_version_id` (UUID)
   - `problem_id`
   - `exchange_id`
   - `resolution_type` (from options above)
   - `money_effect` (structured: refund amount, release amount, currency — in integer kobo)
   - `deadline` (UTC — for time-sensitive resolutions like corrections)
   - `agreed_by_buyer_at`, `agreed_by_seller_at`
   - `created_at`
   - `content_hash`
2. ResolutionVersion is immutable after both parties agree
3. `ProblemOpened` event is superseded by `ResolutionAgreed` event
4. Money effect is executed per the resolution terms

---

### FR-PR-004 — Dispute Escalation
**Priority:** P0 | **Source:** MBD §9

If structured resolution fails, the Problem escalates to a `Dispute`:
- `dispute_id` (UUID)
- `problem_id`
- `exchange_id`
- `evidence_review_required` (boolean)
- `assigned_admin_id`
- `status` (`OPEN` | `IN_REVIEW` | `DECIDED` | `APPEALED`)
- `opened_at`

Admin reviews all evidence. Decision is recorded in `DisputeDecision`:
- `decision_id` (UUID)
- `dispute_id`
- `outcome` (`FULL_REFUND_BUYER` | `FULL_RELEASE_SELLER` | `PARTIAL` | `NO_ACTION`)
- `reasoning` (required text — not optional)
- `actor_id` (admin)
- `decided_at`

Evidence referenced in the decision has `is_used_in_decision` set to `true` and becomes undeletable.

---

### FR-PR-005 — Post-Settlement Issues
**Priority:** P1 | **Source:** MBD §9

Settlement closing the payment cycle does not prevent:
- Agreed seller warranty claims (handled outside Shield)
- Consumer rights claims (applicable law)
- Fraud investigation
- Later-discovered evidence review

These do not automatically reopen settled protected funds. They require admin review and must have a documented policy/legal basis before any money movement.

---

## 11. Functional Requirements — Settlement

### FR-SET-001 — Settlement Eligibility
**Priority:** P0 | **Source:** MBD §5, §6, §16 (Settlement Law, Review Law)

Settlement eligibility for a standard full-Exchange (CHECK + SHIELD + FETCH) requires ALL of:
1. Exchange is in `REVIEWING` state and review window has expired with no blocking Problem, OR buyer has explicitly accepted (`BUYER_ACCEPTED` event)
2. No `Problem` with `blocks_settlement = true` is open
3. Required delivery evidence is present and valid
4. `ProtectedFundsRecord.status` = `FROZEN` (not already released or refunded)

The system evaluates eligibility atomically. It does not rely on a scheduler alone — eligibility must also be re-checked at any point that could affect it (Problem opened, evidence invalidated).

---

### FR-SET-002 — Review Window Expiry
**Priority:** P0 | **Source:** MBD §5, §15 (release-blocking)

When the review window closes with no Problem and no explicit buyer acceptance:
1. System records `ReviewWindowExpiredNoProblem` event (NOT `BuyerAccepted` or `BuyerConfirmed`)
2. Exchange transitions to `REVIEW_EXPIRED`
3. Settlement eligibility is evaluated
4. If eligible, `SETTLING` state entered

No fabricated buyer-confirmed event is created. The distinction between "buyer accepted" and "buyer did nothing" is preserved permanently in the event log.

---

### FR-SET-003 — Settlement Instruction
**Priority:** P0 | **Source:** MBD §4, §6

Settlement creates a `SplitInstruction`:
- `split_instruction_id` (UUID)
- `exchange_id`
- `protected_funds_id`
- `splits`: list of `{ recipient_id, recipient_type (SELLER|BUYI|EARNER), amount_kobo, currency, payout_destination_token }`
- `idempotency_key` (UUID — used for provider payout call)
- `status` (`PENDING` | `PROCESSING` | `COMPLETED` | `FAILED`)
- `created_at`

All amounts in splits must sum to `ProtectedFundsRecord.amount`. Validated before instruction is sent.

---

### FR-SET-004 — Idempotent Payout
**Priority:** P0 | **Source:** MBD §15 (release-blocking)

Settlement retry must never pay an already-successful recipient twice.

Implementation:
- Each split within a `SplitInstruction` has its own `payout_status` field
- Before retrying a payout, check `payout_status` for each recipient
- Only `PENDING` or `FAILED` splits are retried
- `COMPLETED` splits are skipped on retry
- Provider is called with the same `idempotency_key` on retries; provider-side deduplication is the second line of defence

---

### FR-SET-005 — Refund Processing
**Priority:** P0 | **Source:** MBD §6, §15

Refund status is not shown as complete until the provider confirms the refund.

`Refund` record:
- `refund_id` (UUID)
- `exchange_id`
- `payment_intent_id`
- `amount` (int64, kobo)
- `reason_code`
- `status` (`INITIATED` | `PROVIDER_CONFIRMED` | `FAILED`)
- `provider_refund_reference`
- `initiated_at`, `confirmed_at`

The Exchange event log records `RefundInitiated` and `RefundConfirmed` as separate events. The user sees "Refund in progress" until `PROVIDER_CONFIRMED`. Never show "Refunded" on `INITIATED`.

---

### FR-SET-006 — Ledger
**Priority:** P0 | **Source:** MBD §4

Every money movement creates `LedgerEntry` records:
- `ledger_entry_id` (UUID)
- `exchange_id`
- `ledger_account_id`
- `entry_type` (`DEBIT` | `CREDIT`)
- `amount` (int64, kobo)
- `currency`
- `reference_id` (PaymentIntent, SplitInstruction, or Refund ID)
- `recorded_at`

The ledger is append-only. No ledger entry is ever deleted or updated.

---

## 12. Functional Requirements — Share & Earn / Distribution

### FR-DI-001 — Product Approval
**Priority:** P0 | **Source:** MBD §12

Only approved products may be listed in BUYI supply and have BUYI Links generated. Product approval is an admin action. Unapproved products cannot be shared or sold.

`ProductApproval` record:
- `product_approval_id` (UUID)
- `item_snapshot_id`
- `approved_by` (admin_id)
- `approved_at`
- `status` (`PENDING` | `APPROVED` | `SUSPENDED` | `WITHDRAWN`)
- `buyer_price` (int64, kobo — controlled price; earner cannot modify)
- `commission_rule_id` (FK)

---

### FR-DI-002 — BUYI Link Generation
**Priority:** P0 | **Source:** MBD §12

A BUYI Link is generated by an authenticated user for an approved product:
- `share_link_id` (UUID)
- `product_approval_id`
- `earner_id` (user_id of the sharer)
- `link_token` (short unique slug)
- `commission_rule_id`
- `commission_preview_amount` (int64, kobo — shown to earner before sharing)
- `created_at`
- `expires_at` (optional)

The BUYI Link URL is: `buyi.app/l/{link_token}`

Anyone following the link sees the exact item snapshot, seller facts, price, protection scope, and Check options — without signing in.

---

### FR-DI-003 — Attribution
**Priority:** P0 | **Source:** MBD §12

Attribution (`Attribution` record) is frozen at the moment payment is confirmed (state: `FUNDED`):
- `attribution_id` (UUID)
- `exchange_id`
- `share_link_id`
- `earner_id`
- `commission_rule_id`
- `frozen_at` (= payment confirmation timestamp)
- `commission_status` (`PENDING` | `AVAILABLE` | `CANCELLED`)
- `commission_amount` (int64, kobo — calculated at freeze time per CommissionRule)

Attribution cannot be changed after `frozen_at`. If a different BUYI Link is clicked after payment, the later click creates no attribution.

---

### FR-DI-004 — Commission Release
**Priority:** P0 | **Source:** MBD §12

Commission status transitions:
- `PENDING` → `AVAILABLE`: when the underlying Exchange reaches `DONE` (settlement complete)
- `PENDING` → `CANCELLED`: when the underlying Exchange is `REFUNDED` (full refund) or `CANCELLED`
- No commission is released for partial cancellations until the partial outcome is determined

Commission earnings in `AVAILABLE` status are included in the earner's `SplitInstruction` at settlement.

---

## 13. Functional Requirements — Notifications

### FR-NT-001 — Notification System
**Priority:** P1 | **Source:** MBD §4

Every notification is a `Notification` record:
- `notification_id` (UUID)
- `exchange_id` (nullable for non-Exchange notifications)
- `recipient_id`
- `channel` (`IN_APP` | `SMS` | `PUSH`)
- `template_id` (FK to `MessageTemplate`)
- `template_variables` (JSON)
- `status` (`PENDING` | `SENT` | `FAILED` | `DELIVERED`)
- `sent_at`, `delivered_at`

Delivery receipts are logged. Failed notifications are queued for retry with exponential backoff.

---

### FR-NT-002 — Notification Triggers
**Priority:** P1 | **Source:** MBD §11

Notifications must fire on the following state transitions. Each notification must state: what happened, what it means for the recipient, and what (if anything) they need to do next.

| State Transition | Recipients Notified |
|---|---|
| FUNDED | Seller |
| AWAITING_SELLER timeout warning | Seller |
| SELLER_CONFIRMED | Buyer |
| AWAITING_CHECK | Verifier (assignment) |
| CHECK_PASSED | Buyer, Seller |
| MISMATCH | Buyer (with findings) |
| READY_TO_MOVE | Logistics partner (job created) |
| PICKED_UP | Buyer, Seller |
| DELIVERED | Buyer (review window open) |
| REVIEW_EXPIRED | Buyer, Seller |
| PROBLEM opened | Both parties |
| ResolutionVersion agreed | Both parties |
| SETTLING | Both parties |
| DONE | Both parties |
| REFUNDED (PROVIDER_CONFIRMED) | Buyer |

---

### FR-NT-003 — Notification Language
**Priority:** P1 | **Source:** MBD §11

Notifications must not use blanket "Verified", "Delivered" (as a buyer-acceptance signal), "Guaranteed", or "Refunded" (before provider confirmation).

Every notification template is reviewed for Truthful Language Law compliance before deployment.

---

## 14. Functional Requirements — Admin

### FR-AD-001 — Admin Queue System
**Priority:** P0 | **Source:** MBD §16

Admin must have a queue management interface exposing separate queues:
1. Seller timeout cases
2. Payment reconciliation items
3. Check assignment failures (NO_VERIFIER state)
4. Movement exceptions
5. Open Problems
6. Returns in progress
7. Disputes awaiting decision
8. Settlement failures requiring manual intervention

Each queue item shows: Exchange summary, current state, last event, time in queue, assigned admin (if any).

---

### FR-AD-002 — Admin Exchange View
**Priority:** P0 | **Source:** MBD §16

Admin must be able to view the complete Exchange record:
- Full Agreement history (all TermVersions and Acceptances)
- Item identity and snapshots
- Evidence provenance for all EvidenceAssets
- Full custody timeline (all CustodyEvents)
- Complete money ledger (all LedgerEntries, PaymentIntents, Refunds)
- All Notifications sent and their delivery status
- Full event log (all exchange_events in sequence)

---

### FR-AD-003 — Admin Actions
**Priority:** P0 | **Source:** MBD §16

Permitted admin actions (each must produce an immutable `AdminAction` record):

| Action | Description |
|---|---|
| FREEZE_EXCHANGE | Prevent any further state transitions |
| RELEASE_SETTLEMENT | Manually trigger settlement after review |
| INITIATE_REFUND | Full or partial refund |
| CANCEL_EXCHANGE | Cancel with reason |
| ESCALATE_DISPUTE | Move Problem to Dispute queue |
| REASSIGN_VERIFIER | Reassign Check job |
| REASSIGN_CARRIER | Reassign movement job |
| APPLY_USER_RESTRICTION | Suspend or restrict user account |
| RELEASE_USER_RESTRICTION | Lift restriction |
| RECORD_DECISION | Record Dispute decision with reasoning |

`AdminAction` record:
- `admin_action_id` (UUID)
- `admin_id`
- `authorization_level` (role-based)
- `action_type`
- `exchange_id` (or user_id for user-level actions)
- `reason` (required text)
- `before_state` (JSON snapshot of relevant state before action)
- `after_state` (JSON snapshot after action)
- `performed_at`

**Invariants:**
- No admin action directly modifies the database for money or state. All actions go through the same domain logic as user-initiated transitions, but with an admin actor.
- Admin cannot delete evidence or hide overrides.
- Admin cannot edit original TermVersion content.

---

## 15. Data Model Specification

### 15.1 Core Tables

```sql
-- EXCHANGE
exchange (
  exchange_id         UUID PRIMARY KEY,
  exchange_origin     VARCHAR(32) NOT NULL,   -- ENUM: BUYI_SUPPLY | OUTSIDE_ORIGIN | PRIVATE_DEMAND
  market              VARCHAR(8)  NOT NULL DEFAULT 'NG',
  currency            VARCHAR(8)  NOT NULL DEFAULT 'NGN',
  category            VARCHAR(32) NOT NULL,
  current_state       VARCHAR(64) NOT NULL,
  risk_policy_version VARCHAR(64) NOT NULL,
  capability_statuses JSONB       NOT NULL,   -- { "CHECK": "REQUIRED", "SHIELD": "REQUIRED", "FETCH": "REQUIRED" }
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
)

-- EXCHANGE EVENTS (append-only)
exchange_event (
  event_id            UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  event_type          VARCHAR(64) NOT NULL,
  sequence_number     BIGINT      NOT NULL,
  actor_id            UUID,
  actor_role          VARCHAR(32),
  payload             JSONB,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (exchange_id, sequence_number)
)

-- EXCHANGE PARTY
exchange_party (
  party_id            UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  user_id             UUID        NOT NULL REFERENCES app_user(user_id),
  role                VARCHAR(32) NOT NULL,   -- BUYER | SELLER | VERIFIER | CARRIER | RESELLER
  joined_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
)

-- TERM VERSION
term_version (
  term_version_id     UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  version_number      INT         NOT NULL,
  content             JSONB       NOT NULL,
  content_hash        VARCHAR(64) NOT NULL,   -- SHA-256
  created_at          TIMESTAMPTZ NOT NULL,
  created_by          UUID,
  supersedes_version_id UUID      REFERENCES term_version(term_version_id),
  UNIQUE (exchange_id, version_number)
)

-- ACCEPTANCE
acceptance (
  acceptance_id       UUID PRIMARY KEY,
  term_version_id     UUID        NOT NULL REFERENCES term_version(term_version_id),
  party_id            UUID        NOT NULL REFERENCES exchange_party(party_id),
  accepted_at         TIMESTAMPTZ NOT NULL,
  acceptance_method   VARCHAR(32) NOT NULL,
  ip_address          INET
)

-- COMMITMENT
commitment (
  commitment_id       UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  party_id            UUID        NOT NULL REFERENCES exchange_party(party_id),
  commitment_type     VARCHAR(64) NOT NULL,
  description         TEXT,
  due_at              TIMESTAMPTZ,
  status              VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
  failure_reason_code VARCHAR(64)
)

-- PRICE BREAKDOWN
price_breakdown (
  price_breakdown_id  UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL UNIQUE REFERENCES exchange(exchange_id),
  item_price          BIGINT      NOT NULL CHECK (item_price >= 0),
  check_fee           BIGINT      NOT NULL DEFAULT 0,
  delivery_fee        BIGINT      NOT NULL DEFAULT 0,
  buyi_fee            BIGINT      NOT NULL DEFAULT 0,
  total_buyer_pays    BIGINT      NOT NULL,
  seller_receives     BIGINT      NOT NULL,
  currency            VARCHAR(8)  NOT NULL DEFAULT 'NGN',
  CHECK (total_buyer_pays = item_price + check_fee + delivery_fee + buyi_fee)
)

-- ITEM SNAPSHOT
item_snapshot (
  item_snapshot_id    UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  category            VARCHAR(32) NOT NULL,
  make                VARCHAR(128),
  model               VARCHAR(128) NOT NULL,
  storage             VARCHAR(32),
  colour              VARCHAR(64),
  described_condition VARCHAR(32) NOT NULL,
  described_accessories JSONB,
  repairs_disclosed   TEXT,
  listed_price        BIGINT      NOT NULL,
  snapshot_at         TIMESTAMPTZ NOT NULL,
  snapshot_hash       VARCHAR(64) NOT NULL
)

-- ITEM IDENTITY
item_identity (
  item_identity_id    UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  item_snapshot_id    UUID        NOT NULL REFERENCES item_snapshot(item_snapshot_id),
  identity_type       VARCHAR(32) NOT NULL,   -- IMEI | SERIAL | SEAL_ID | PACKAGE_ID
  identity_value      TEXT        NOT NULL,   -- encrypted at rest
  recorded_at         TIMESTAMPTZ NOT NULL,
  recorded_by         UUID,
  recording_stage     VARCHAR(64) NOT NULL
)

-- EVIDENCE ASSET
evidence_asset (
  evidence_asset_id   UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  item_identity_id    UUID        REFERENCES item_identity(item_identity_id),
  stage               VARCHAR(64) NOT NULL,
  evidence_type       VARCHAR(32) NOT NULL,
  file_reference      TEXT        NOT NULL,
  file_hash           VARCHAR(64) NOT NULL,
  captured_at         TIMESTAMPTZ NOT NULL,
  uploaded_at         TIMESTAMPTZ NOT NULL,
  captured_by         UUID        NOT NULL,
  capturer_role       VARCHAR(32) NOT NULL,
  checklist_version_id UUID       REFERENCES checklist_version(checklist_version_id),
  coarse_location     POINT,
  access_policy       VARCHAR(32) NOT NULL DEFAULT 'EXCHANGE_PARTIES',
  is_used_in_decision BOOLEAN     NOT NULL DEFAULT FALSE
)

-- PAYMENT INTENT
payment_intent (
  payment_intent_id   UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  amount              BIGINT      NOT NULL CHECK (amount > 0),
  currency            VARCHAR(8)  NOT NULL,
  provider_reference  TEXT,
  idempotency_key     UUID        NOT NULL UNIQUE,
  status              VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  created_at          TIMESTAMPTZ NOT NULL,
  resolved_at         TIMESTAMPTZ
)

-- PROTECTED FUNDS RECORD
protected_funds_record (
  protected_funds_id  UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL UNIQUE REFERENCES exchange(exchange_id),
  payment_intent_id   UUID        NOT NULL UNIQUE REFERENCES payment_intent(payment_intent_id),
  amount              BIGINT      NOT NULL,
  currency            VARCHAR(8)  NOT NULL,
  status              VARCHAR(32) NOT NULL DEFAULT 'FROZEN',
  settlement_blocked  BOOLEAN     NOT NULL DEFAULT FALSE,
  frozen_at           TIMESTAMPTZ NOT NULL,
  released_at         TIMESTAMPTZ
)

-- MOVEMENT JOB
movement_job (
  movement_job_id     UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  carrier_id          UUID        NOT NULL,
  carrier_selected_by VARCHAR(16) NOT NULL,   -- BUYI | BUYER | SELLER | MUTUAL
  pickup_location     JSONB       NOT NULL,
  delivery_location   JSONB       NOT NULL,
  item_identity_id    UUID        NOT NULL REFERENCES item_identity(item_identity_id),
  declared_value      BIGINT      NOT NULL,
  release_authority   JSONB       NOT NULL,
  current_custodian_id UUID,
  status              VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  created_at          TIMESTAMPTZ NOT NULL
)

-- CUSTODY EVENT
custody_event (
  custody_event_id    UUID PRIMARY KEY,
  movement_job_id     UUID        NOT NULL REFERENCES movement_job(movement_job_id),
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  event_type          VARCHAR(32) NOT NULL,
  releaser_id         UUID,
  receiver_id         UUID,
  new_custodian_id    UUID,
  timestamp           TIMESTAMPTZ NOT NULL,
  proof_method        VARCHAR(32) NOT NULL,
  evidence_asset_ids  UUID[],
  item_condition_note TEXT,
  gps_lat             DECIMAL(9,6),
  gps_lng             DECIMAL(9,6)
)

-- PROBLEM
problem (
  problem_id          UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  commitment_id       UUID        NOT NULL REFERENCES commitment(commitment_id),
  problem_type        VARCHAR(64) NOT NULL,
  description         TEXT        NOT NULL,
  evidence_asset_ids  UUID[],
  reporter_id         UUID        NOT NULL,
  reporter_role       VARCHAR(32) NOT NULL,
  blocks_settlement   BOOLEAN     NOT NULL DEFAULT TRUE,
  status              VARCHAR(32) NOT NULL DEFAULT 'OPEN',
  opened_at           TIMESTAMPTZ NOT NULL
)

-- RESOLUTION VERSION
resolution_version (
  resolution_version_id UUID PRIMARY KEY,
  problem_id          UUID        NOT NULL REFERENCES problem(problem_id),
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  resolution_type     VARCHAR(64) NOT NULL,
  money_effect        JSONB       NOT NULL,   -- { refund_amount, release_amount, currency }
  deadline            TIMESTAMPTZ,
  agreed_by_buyer_at  TIMESTAMPTZ,
  agreed_by_seller_at TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL,
  content_hash        VARCHAR(64) NOT NULL
)

-- SPLIT INSTRUCTION
split_instruction (
  split_instruction_id UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  protected_funds_id  UUID        NOT NULL REFERENCES protected_funds_record(protected_funds_id),
  splits              JSONB       NOT NULL,   -- array of { recipient_id, type, amount_kobo, payout_destination_token }
  idempotency_key     UUID        NOT NULL UNIQUE,
  status              VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  created_at          TIMESTAMPTZ NOT NULL
)

-- LEDGER ENTRY (append-only)
ledger_entry (
  ledger_entry_id     UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL REFERENCES exchange(exchange_id),
  ledger_account_id   UUID        NOT NULL,
  entry_type          VARCHAR(8)  NOT NULL CHECK (entry_type IN ('DEBIT','CREDIT')),
  amount              BIGINT      NOT NULL CHECK (amount > 0),
  currency            VARCHAR(8)  NOT NULL DEFAULT 'NGN',
  reference_id        UUID        NOT NULL,
  reference_type      VARCHAR(32) NOT NULL,
  recorded_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
)

-- SHARE LINK
share_link (
  share_link_id       UUID PRIMARY KEY,
  product_approval_id UUID        NOT NULL,
  earner_id           UUID        NOT NULL REFERENCES app_user(user_id),
  link_token          VARCHAR(32) NOT NULL UNIQUE,
  commission_rule_id  UUID        NOT NULL,
  commission_preview_amount BIGINT NOT NULL,
  created_at          TIMESTAMPTZ NOT NULL,
  expires_at          TIMESTAMPTZ
)

-- ATTRIBUTION
attribution (
  attribution_id      UUID PRIMARY KEY,
  exchange_id         UUID        NOT NULL UNIQUE REFERENCES exchange(exchange_id),
  share_link_id       UUID        NOT NULL REFERENCES share_link(share_link_id),
  earner_id           UUID        NOT NULL,
  commission_rule_id  UUID        NOT NULL,
  frozen_at           TIMESTAMPTZ NOT NULL,
  commission_status   VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  commission_amount   BIGINT      NOT NULL
)

-- ADMIN ACTION (append-only)
admin_action (
  admin_action_id     UUID PRIMARY KEY,
  admin_id            UUID        NOT NULL,
  authorization_level VARCHAR(32) NOT NULL,
  action_type         VARCHAR(64) NOT NULL,
  exchange_id         UUID        REFERENCES exchange(exchange_id),
  target_user_id      UUID        REFERENCES app_user(user_id),
  reason              TEXT        NOT NULL,
  before_state        JSONB       NOT NULL,
  after_state         JSONB       NOT NULL,
  performed_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
```

---

## 16. Exchange State Machine — Full Specification

### 16.1 State Transition Table

| From State | To State | Trigger | Guard Conditions |
|---|---|---|---|
| DRAFT | PUBLISHED | Admin/seller publishes listing | Item snapshot complete; price breakdown valid |
| DRAFT | CANCELLED | Timeout / user cancels | — |
| BUYER_REVIEWING | PAYMENT_PENDING | Buyer accepts terms | Valid Acceptance recorded; reservation window not expired |
| BUYER_REVIEWING | DECLINED | Buyer declines | — |
| BUYER_REVIEWING | EXPIRED | Reservation window expires with no payment start | — |
| PAYMENT_PENDING | FUNDED | Verified provider payment event received | Idempotent check; reservation not yet expired; unique inventory atomic lock |
| PAYMENT_PENDING | BUYER_REVIEWING | Payment failed or cancelled | — |
| PAYMENT_PENDING | EXPIRED | Reservation + grace period expired | No pending payment attempt |
| FUNDED | AWAITING_SELLER | Payment confirmed | — |
| AWAITING_SELLER | SELLER_CONFIRMED | Seller confirms ability to fulfill | Within confirmation window |
| AWAITING_SELLER | CANCELLED | Seller timeout; seller declines | Refund initiated |
| SELLER_CONFIRMED | AWAITING_CHECK | Check capability REQUIRED/REQUESTED | Verifier pool available |
| SELLER_CONFIRMED | NO_VERIFIER | Check capability required but no verifier available | Admin notified |
| SELLER_CONFIRMED | READY_TO_MOVE | Check NOT_NEEDED; Fetch capability active | — |
| SELLER_CONFIRMED | READY_FOR_HANDOFF | No Fetch; personal pickup configured | — |
| SELLER_CONFIRMED | CANCELLED | Seller cancels | Refund initiated |
| AWAITING_CHECK | CHECKING | Verifier assigned and confirmed | Conflict check passed |
| AWAITING_CHECK | NO_VERIFIER | No qualified verifier | Admin queue |
| AWAITING_CHECK | CANCELLED | Buyer cancels | Check fee non-refundable if verifier dispatched |
| CHECKING | CHECK_PASSED | Verifier submits PASS outcome | All mandatory evidence present; no conflicts |
| CHECKING | MISMATCH | Verifier submits MISMATCH or INCONCLUSIVE | Findings recorded |
| MISMATCH | TERMS_CHANGED | Buyer accepts new terms after mismatch | New TermVersion created and accepted |
| MISMATCH | CANCELLED | Buyer cancels after mismatch | Refund per policy |
| MISMATCH | READY_TO_MOVE | Policy allows proceed with noted mismatch | Buyer documented acknowledgement |
| CHECK_PASSED | READY_TO_MOVE | Fetch capability active | Movement job can be created |
| CHECK_PASSED | READY_FOR_HANDOFF | Personal pickup; no Fetch | — |
| READY_TO_MOVE | PICKED_UP | Carrier confirms pickup with evidence | Pre-dispatch confirmation complete; handoff evidence valid |
| READY_TO_MOVE | CANCELLED | Cancellation before dispatch | Delivery fee refundable if no provider cost |
| PICKED_UP | IN_TRANSIT | Carrier updates status | Custody event recorded |
| PICKED_UP | PROBLEM | Problem reported after pickup | Settlement frozen |
| IN_TRANSIT | DELIVERED | Valid delivery evidence received | OTP + photos; not OTP alone |
| IN_TRANSIT | PROBLEM | Problem reported in transit | Settlement frozen |
| DELIVERED | REVIEWING | Valid receipt evidence present | Review window opened |
| DELIVERED | PROBLEM | Problem reported immediately on delivery | Settlement frozen |
| REVIEWING | BUYER_ACCEPTED | Buyer explicitly accepts | Within review window |
| REVIEWING | REVIEW_EXPIRED | Review window closes with no action | No Problem open |
| REVIEWING | PROBLEM | Problem opened before review window closes | Atomically freezes settlement |
| BUYER_ACCEPTED | SETTLING | Settlement eligibility confirmed | No blocking Problem |
| REVIEW_EXPIRED | SETTLING | Settlement eligibility confirmed | No blocking Problem |
| PROBLEM | RESOLVED | Resolution agreed by both parties | ResolutionVersion created |
| PROBLEM | DISPUTED | Resolution fails or policy requires escalation | Dispute created |
| RESOLVED | SETTLING | Resolution requires partial/full settlement | Money effect defined |
| RESOLVED | DONE | Resolution completes without further money movement | — |
| DISPUTED | DECIDED | Admin decision recorded | — |
| DECIDED | REFUNDED | Decision: full refund | Provider confirms |
| DECIDED | SETTLING | Decision: release or partial | — |
| DECIDED | PARTIAL | Decision: partial refund + partial release | — |
| SETTLING | DONE | Settlement completed; provider confirms | All split payouts confirmed |
| SETTLING | SETTLEMENT_FAILED | Provider failure | Retry queue; admin alert |
| SETTLEMENT_FAILED | SETTLING | Retry approved | Idempotent retry |

### 16.2 Terminal States

`DONE` | `REFUNDED` | `CANCELLED` | `DECLINED` | `EXPIRED`

No transitions out of terminal states except via admin action (e.g. re-investigation with documented policy basis).

### 16.3 Modular State Path Examples

**Check-only Exchange:**
`DRAFT → SELLER_CONFIRMED → AWAITING_CHECK → CHECKING → CHECK_PASSED → DONE`

**Fetch-only (park-to-door):**
`DRAFT → READY_TO_MOVE → PICKED_UP → IN_TRANSIT → DELIVERED → REVIEWING → REVIEW_EXPIRED → DONE`

---

## 17. API Design Principles & Contract Sketches

### 17.1 Principles

- All mutations are expressed as Commands, not PATCH state updates
- State is never set by the client directly
- Every mutating endpoint is idempotent via client-supplied idempotency key header (`X-Idempotency-Key`)
- All responses include the Exchange event sequence number so clients can detect missed events
- Errors return a structured body: `{ "error_code": "TERM_VERSION_NOT_ACCEPTED", "message": "...", "detail": {} }`
- Pagination on list endpoints: cursor-based
- Authentication: `Authorization: Bearer <jwt>`

### 17.2 Core Command Endpoints

```
POST   /api/v1/exchanges                     — CreateExchange
POST   /api/v1/exchanges/:id/accept-terms    — AcceptTerms
POST   /api/v1/exchanges/:id/fund            — (internal/webhook — not direct user call)
POST   /api/v1/exchanges/:id/seller-confirm  — SellerConfirm
POST   /api/v1/exchanges/:id/cancel          — CancelExchange
POST   /api/v1/exchanges/:id/check/submit    — SubmitCheckResult (verifier)
POST   /api/v1/exchanges/:id/movement/confirm-pickup  — ConfirmPickup (carrier)
POST   /api/v1/exchanges/:id/movement/confirm-delivery — ConfirmDelivery (carrier)
POST   /api/v1/exchanges/:id/accept          — BuyerAccept
POST   /api/v1/exchanges/:id/problems        — OpenProblem
POST   /api/v1/exchanges/:id/problems/:pid/resolve — ProposeResolution
POST   /api/v1/exchanges/:id/problems/:pid/agree-resolution — AgreeResolution
```

### 17.3 Core Query Endpoints

```
GET    /api/v1/exchanges/:id/timeline        — Exchange Timeline (projection)
GET    /api/v1/exchanges/:id/protection-map  — Protection Map for this Exchange
GET    /api/v1/exchanges/:id/terms/current   — Current TermVersion
GET    /api/v1/exchanges/:id/evidence        — Evidence list for Exchange
GET    /api/v1/users/:id/exchanges           — User's Exchange list (paginated)
GET    /api/v1/users/:id/earnings            — Earner's pending/available commissions
```

### 17.4 Webhook Endpoint

```
POST   /api/v1/webhooks/payment              — Payment provider webhook (signature-verified)
```

All webhooks: raw body logged before processing; signature verified; idempotency enforced.

### 17.5 BUYI Link (Guest Access)

```
GET    /api/v1/links/:token                  — View item snapshot + offer (no auth required)
```

Returns: item snapshot, buyer price, protection scope options, seller facts. Does not expose seller contact details or IMEI.

---

## 18. Integration Requirements

### 18.1 Payment Provider

**Requirements:**
- IR-PAY-1: Provider must support licensed NGN payment processing (cards, bank transfer, USSD)
- IR-PAY-2: Provider must support webhook notifications with HMAC signature verification
- IR-PAY-3: Provider must support idempotency keys on payment and payout calls
- IR-PAY-4: Provider must support refunds and partial refunds
- IR-PAY-5: Provider must support split payouts (seller + BUYI fee in one instruction) or sequential payouts
- IR-PAY-6: Provider must supply KYC/AML threshold policy before production go-live
- IR-PAY-7: Provider must confirm legal structure for fund holding between payment and settlement

**BUYI behaviour:**
- No live fund flows until provider + Nigerian fintech legal review complete
- Raw bank details never stored in BUYI database — provider token only
- All provider calls use idempotency keys

### 18.2 KYC Provider

**Requirements:**
- IR-KYC-1: Provider supplies identity verification result via webhook or API callback
- IR-KYC-2: KYC state in BUYI DB is updated only from verified provider event — never user self-report
- IR-KYC-3: KYC thresholds are configuration values from provider policy, not hard-coded

### 18.3 SMS / Notification Provider

**Requirements:**
- IR-SMS-1: Provider supports Nigerian phone numbers (E.164 format)
- IR-SMS-2: Delivery receipts are available and logged
- IR-SMS-3: Supports OTP delivery with configurable expiry

### 18.4 Blob Storage (Evidence Files)

**Requirements:**
- IR-STR-1: Storage provider must offer minimum 99.999999999% durability
- IR-STR-2: Files must be accessible via signed URLs with configurable expiry (not public by default)
- IR-STR-3: Files are immutable after upload — no overwrite of existing file
- IR-STR-4: Server must verify file hash on upload and store hash in `evidence_asset.file_hash`

### 18.5 Logistics Partner

**Requirements:**
- IR-LOG-1: V1 partner is a single approved, licensed Lagos-zone provider — not an open marketplace
- IR-LOG-2: Partner must support job creation via API (or manual with digital confirmation)
- IR-LOG-3: Partner must support masked contact numbers for buyer/seller
- IR-LOG-4: Partner must support OTP delivery confirmation
- IR-LOG-5: Partner must declare maximum declared-value coverage — this drives `movement_value_limit` config

---

## 19. Non-Functional Requirements (Engineering Detail)

### 19.1 Data Integrity

- NFR-DI-1: All Exchange state transitions use optimistic locking (`version` column on `exchange` table, incremented on each update). Concurrent update conflicts return HTTP 409.
- NFR-DI-2: All money arithmetic uses `int64` (kobo). No floating-point used anywhere in financial calculation paths.
- NFR-DI-3: Database constraints enforce `total_buyer_pays = item_price + check_fee + delivery_fee + buyi_fee` on `price_breakdown`.
- NFR-DI-4: `exchange_event.sequence_number` has a UNIQUE constraint per `exchange_id`. Gaps are a data integrity alert.
- NFR-DI-5: Evidence files are write-once in storage. The `file_hash` mismatch between stored hash and current file is treated as a critical integrity failure, logged, and alerted.

### 19.2 Idempotency

- NFR-ID-1: All payment operations carry an `idempotency_key`. Duplicate calls with the same key return the original result, not an error and not a duplicate operation.
- NFR-ID-2: State transitions are idempotent: if the Exchange is already in the target state when the command arrives, the command is a no-op (returns current state, no new event).
- NFR-ID-3: Settlement split retries skip already-COMPLETED splits. Idempotency key is sent to provider on every payout call.

### 19.3 Security

- NFR-SEC-1: JWT tokens expire in 15 minutes. Refresh tokens use rotation (old refresh token invalidated on use).
- NFR-SEC-2: IMEI and other identity values encrypted at rest (AES-256 or equivalent). Encryption key managed separately from database.
- NFR-SEC-3: Payment webhook endpoint verifies provider HMAC signature on every request. Requests with invalid signatures return 401 and are logged.
- NFR-SEC-4: Evidence files are not publicly accessible. Access via signed URL only. Signed URLs expire in configurable time (default: 1 hour for exchange parties, 24 hours for admin).
- NFR-SEC-5: Admin actions require a separate elevated-privilege token, distinct from the user access token.
- NFR-SEC-6: All inputs are validated and sanitised before persistence. SQL queries use parameterised statements only — no dynamic SQL with user input.
- NFR-SEC-7: Rate limiting on all public endpoints. Payment endpoints have stricter limits.

### 19.4 Observability

- NFR-OBS-1: Every Exchange state transition emits a structured log entry with: `exchange_id`, `from_state`, `to_state`, `actor`, `timestamp`, `duration_ms`.
- NFR-OBS-2: Every payment webhook received emits a log entry with: `provider`, `event_type`, `provider_event_id`, `processing_result`, `duration_ms`.
- NFR-OBS-3: Settlement operations emit metrics: `settlement.initiated`, `settlement.completed`, `settlement.failed`, `settlement.retried`.
- NFR-OBS-4: An alert fires if `exchange_event.sequence_number` gap is detected.
- NFR-OBS-5: An alert fires if `evidence_asset.file_hash` mismatch is detected.
- NFR-OBS-6: An alert fires if a Problem is opened within 10 minutes of a settlement instruction being created.

---

## 20. Release-Blocking Engineering Tests

These tests must pass before V1 pilot launch. Each maps directly to a requirement.

| Test ID | Description | Source |
|---|---|---|
| RBT-001 | Duplicate payment webhook never creates duplicate ProtectedFundsRecord or payout | FR-SH-002, FR-SET-004 |
| RBT-002 | Late seller confirmation after refund/cancellation cannot reopen the Exchange | FR-EX-003 |
| RBT-003 | Problem opened at 23h59m into review window atomically blocks settlement | FR-SH-004, FR-PR-001 |
| RBT-004 | Invalid delivery proof (missing photos, OTP mismatch) does not start review timer | FR-MV-004 |
| RBT-005 | Delivery OTP creates receipt evidence event, not BuyerAccepted event | FR-MV-004, FR-SET-002 |
| RBT-006 | Changed terms create new TermVersion and invalidate old Acceptance | FR-AG-003 |
| RBT-007 | Settlement retry never pays an already-COMPLETED split recipient twice | FR-SET-004 |
| RBT-008 | Evidence with is_used_in_decision=true cannot be deleted by any actor | FR-IE-003 |
| RBT-009 | Custody cannot transition without a valid CustodyEvent with required evidence | FR-MV-003 |
| RBT-010 | Verifier with declared conflict cannot submit Check result | FR-ID-004, FR-CH-003 |
| RBT-011 | Missing mandatory evidence fields block CHECK_PASSED submission | FR-IE-005, FR-CH-003 |
| RBT-012 | Outside-carrier stage cannot be classified as BUYI-CONTROLLED | FR-MV-003 |
| RBT-013 | An already-paid outside-origin deal cannot gain retroactive payment protection | FR-EX-001 |
| RBT-014 | Check-only Exchange reaches DONE without FUNDED or DELIVERED states | FR-EX-005 |
| RBT-015 | Fetch-only Exchange reaches DONE without CHECK_PASSED state | FR-EX-005 |
| RBT-016 | Admin cannot edit TermVersion content | FR-AG-001, FR-AD-003 |
| RBT-017 | Admin cannot delete EvidenceAsset | FR-IE-003, FR-AD-003 |
| RBT-018 | Admin cannot hide AdminAction records | FR-AD-003 |
| RBT-019 | Reservation expiry and payment success resolve atomically (no double inventory sale) | FR-EX-008, FR-SH-003 |
| RBT-020 | Movement above declared-value limit is blocked | FR-MV-001 |
| RBT-021 | Refund status shown as INITIATED until provider confirms — not COMPLETED | FR-SET-005 |
| RBT-022 | Review window expiry creates ReviewWindowExpiredNoProblem, not BuyerAccepted | FR-SET-002 |
| RBT-023 | Buyer silence during review window does not create a fabricated BuyerConfirmed event | FR-SET-002 |
| RBT-024 | PriceBreakdown component sum must equal total_buyer_pays (DB constraint) | FR-AG-005 |
| RBT-025 | Exchange event sequence_number gaps trigger integrity alert | NFR-DI-4 |

---

## 21. Appendix — Enumerations & Constants

### Exchange States
`DRAFT` | `PUBLISHED` | `BUYER_REVIEWING` | `PAYMENT_PENDING` | `FUNDED` | `AWAITING_SELLER` | `SELLER_CONFIRMED` | `AWAITING_CHECK` | `NO_VERIFIER` | `CHECKING` | `CHECK_PASSED` | `MISMATCH` | `READY_TO_MOVE` | `READY_FOR_HANDOFF` | `PICKED_UP` | `IN_TRANSIT` | `DELIVERED` | `REVIEWING` | `BUYER_ACCEPTED` | `REVIEW_EXPIRED` | `PROBLEM` | `RESOLVED` | `DISPUTED` | `DECIDED` | `SETTLING` | `SETTLEMENT_FAILED` | `DONE` | `REFUNDED` | `PARTIAL` | `CANCELLED` | `DECLINED` | `EXPIRED`

### Exchange Origin
`BUYI_SUPPLY` | `OUTSIDE_ORIGIN` | `PRIVATE_DEMAND`

### Capability Names
`CHECK` | `SHIELD` | `FETCH` | `REVIEW` | `SETTLEMENT`

### Capability Statuses
`REQUIRED` | `RECOMMENDED` | `REQUESTED` | `UNAVAILABLE` | `NOT_NEEDED`

### Carrier Selected By
`BUYI` | `BUYER` | `SELLER` | `MUTUAL`

### Check Outcomes
`PASS` | `MISMATCH` | `INCONCLUSIVE`

### Item Conditions
`NEW` | `LIKE_NEW` | `GOOD` | `FAIR` | `PARTS_ONLY`

### Problem Types
`WRONG_ITEM` | `CONDITION_MISMATCH` | `DAMAGED` | `INCOMPLETE` | `NOT_DELIVERED` | `LATE_DELIVERY` | `OTHER`

### Resolution Types
`CONTINUE` | `CORRECTION` | `REPLACEMENT` | `PARTIAL_REFUND` | `RETURN_AND_REFUND` | `MORE_TIME` | `RELEASE` | `ESCALATE`

### Evidence Types
`VIDEO` | `PHOTO` | `OTP_CONFIRMATION` | `DOCUMENT` | `CHECKLIST_RESULT`

### Custody Event Types
`PICKUP` | `INTERMEDIATE_HANDOFF` | `DELIVERY` | `FAILED_ATTEMPT` | `RETURN_PICKUP` | `RETURN_DELIVERY`

### Proof Methods
`OTP` | `PHOTO` | `SIGNATURE` | `COMBINED`

### KYC States
`UNVERIFIED` | `BASIC` | `ENHANCED` | `REJECTED`

### Commission Status
`PENDING` | `AVAILABLE` | `CANCELLED`

### Open Policy Items (DO NOT HARD-CODE)
- KYC threshold amounts — OPEN / PROVIDER-DEPENDENT
- Carrier liability cap — OPEN / PROVIDER-DEPENDENT
- Stale inventory expiry period — OPEN (3-day / 48h-nudge rule to be confirmed)
- Changed terms response window — OPEN (exact rule to be recovered/approved)
- Transit protection premium — LATER / PROVIDER-DEPENDENT

---

*End of Volume II — Software Requirements Specification*  
*Next: Volume III — Domain-Driven Design Blueprint*  
*BUYIspace Technologies Ltd. | Internal | Confidential*
