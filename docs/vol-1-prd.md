# BUYI — Product Requirements Document (PRD)
## Volume I of the BUYI Engineering Documentation Suite
**Version:** 1.0 — Final Decision Freeze Baseline  
**Date:** 31 August 2026  
**Prepared by:** BUYIspace Technologies Ltd. — Engineering & Product  
**Classification:** Internal — Confidential  
**Authority:** This document derives from and is subordinate to the BUYI Programmer Master Build Document (Final Decision Freeze, 31 August 2026). Where conflict exists, the Master Build Document governs.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Product Philosophy & Principles](#2-product-philosophy--principles)
3. [Problem Statement & Market Opportunity](#3-problem-statement--market-opportunity)
4. [Target Users & Personas](#4-target-users--personas)
5. [Product Goals & Success Metrics](#5-product-goals--success-metrics)
6. [Product Overview — What BUYI Is](#6-product-overview--what-buyi-is)
7. [Front Doors & Information Architecture](#7-front-doors--information-architecture)
8. [The Six Engines](#8-the-six-engines)
9. [Capability Model](#9-capability-model)
10. [User Journeys](#10-user-journeys)
11. [Feature Specifications](#11-feature-specifications)
12. [UX Principles & Design Language](#12-ux-principles--design-language)
13. [Non-Functional Requirements](#13-non-functional-requirements)
14. [Release Roadmap & Scope Gates](#14-release-roadmap--scope-gates)
15. [Risks & Mitigations](#15-risks--mitigations)
16. [Compliance & Legal Boundaries](#16-compliance--legal-legal-boundaries)
17. [Appendix — Glossary](#17-appendix--glossary)

---

## 1. Executive Summary

### 1.1 Vision

BUYI exists to make exchanges between people complete — not just initiated.

In most peer-to-peer or semi-formal commerce, a deal is "made" when two parties agree a price. What actually happens after that — custody of the item, confirmation of condition, protection of payment, resolution of failure — is left to chance, social pressure, or expensive intermediaries. BUYI replaces that uncertainty with a structured, evidence-backed Exchange that is transparent to both parties and recoverable when things go wrong.

### 1.2 Mission

Turn something people want to make happen into a structured Exchange, then coordinate the supported agreement, protection, evidence, checking, movement and recovery needed to complete it.

### 1.3 Public Simplicity Statement

**Make it happen.**

### 1.4 Outside-Origin Behaviour

Found something anywhere? Complete it with BUYI.

### 1.5 Founding Context

- **Pilot category:** Used phones and selected electronics
- **Pilot geography:** Computer Village, Lagos, Nigeria
- **Architecture:** Nigeria-first, global-ready underneath
- **V1 milestone:** One real, complete, protected phone Exchange — then ten, then one hundred

### 1.6 What BUYI Is Not

BUYI does not compete on escrow, logistics, verification, AI, wallets, or generic "trust" language alone. Those are capabilities. The Exchange is the permanent product core and the source of truth.

BUYI is not:
- A marketplace whose product is listings
- A logistics company whose product is movement
- An escrow whose product is funds holding
- A verification service whose product is certificates
- A social commerce platform whose product is content

BUYI is an **Exchange Completion Network**.

---

## 2. Product Philosophy & Principles

The following principles are the product translation of the BUYI Operating Constitution (Section 1 of the Master Build Document). They govern every product decision, screen design, feature trade-off, and engineering choice.

### P1 — Exchange-First
Every meaningful BUYI job becomes an Exchange. An Exchange is the unit of truth. Features exist to serve Exchanges; they do not exist for their own sake.

*Engineering implication:* No feature may create money, state, or evidence outside an Exchange record.

### P2 — Anywhere-Origin
A deal can begin anywhere — in a WhatsApp chat, at a market stall, on Instagram, on a rival platform. BUYI can enter the deal at the point where a supported stage still needs to happen. BUYI does not require that it was present from the first message.

*Engineering implication:* The origin of an Exchange (`exchange_origin`) must be recorded. BUYI never claims to protect stages that occurred before it entered.

### P3 — No Retroactive Protection
BUYI never claims to protect an event that happened before BUYI entered and recorded that stage. If payment was made outside BUYI before BUYI was involved, that payment is not BUYI-protected.

*Engineering implication:* The system must not display "payment protected" language for outside-origin payments unless a compliant protection structure has been activated for a future stage.

### P4 — Modular Capability
An Exchange activates only the capabilities it requires. Check, Shield, and Fetch are independent and combinable. An Exchange does not need all three to be valid.

*Engineering implication:* State transitions must be capability-aware. A Check-only Exchange must reach a valid terminal state without requiring fake payment or movement states.

### P5 — Capability Activation
Each capability carries a status: **Requested, Recommended, Required, Unavailable,** or **Not Needed**. Risk policy may override user preference and escalate a capability from Requested to Required.

*Engineering implication:* The capability activation model must be driven by policy, not hardcoded if/else logic.

### P6 — Exchange Truth
BUYI records what was wanted, agreed, committed, evidenced, what happened, how recovery worked, and how the Exchange ended. The record is permanent and append-only.

*Engineering implication:* Every consequential transition is server-validated, idempotent, and append-only. No silent overwrites.

### P7 — Agreement Versioning
Accepted terms never change silently. A material change creates a new immutable TermVersion and requires explicit re-acceptance by the relevant party.

*Engineering implication:* Old acceptances are preserved. New terms must be presented and re-accepted before the Exchange can continue.

### P8 — Commitment Specificity
Failures are diagnosed by the specific commitment not satisfied. Vague blame ("something went wrong") is not permitted.

*Engineering implication:* Every Problem references a specific Commitment and a specific reason code.

### P9 — Proof Follows the Object
Evidence attaches to the specific item — IMEI or serial number for phones, seal/package ID for parcels. Evidence is not generic; it is item-specific and stage-specific.

*Engineering implication:* EvidenceAsset records must link to an ItemIdentity and a stage, not just to an Exchange.

### P10 — Evidence Provenance & Integrity
Evidence records who created it, when, for which item, at which stage, and under which checklist version. Evidence used to progress an Exchange cannot be deleted or silently overwritten. Corrections create new evidence events.

### P11 — Risk-Proportional Proof
Require only the proof that risk justifies. Higher-value or higher-risk Exchanges require stronger evidence. Lower-risk or historically reliable parties may receive appropriately lighter friction where policy permits.

### P12 — Custody Is Earned
Physical custody changes only after sufficient handoff evidence. BUYI records custody only when it has that evidence.

### P13 — Responsibility Has Boundaries
BUYI claims responsibility only for stages it controls or explicitly covers. Every stage in an Exchange is classified as BUYI-CONTROLLED, BUYI-OBSERVED, or OUTSIDE BUYI.

### P14 — Settlement Follows Evidence
Money does not release because a screen says Delivered. Settlement eligibility requires agreed conditions, required evidence, and no blocking Problem.

### P15 — Review Is Earned by Evidence
The buyer review window opens only after sufficient receipt/delivery evidence for the fulfillment method in use.

### P16 — Recovery Is Engineered
Failure and recovery are part of the Exchange Engine. They are not improvised support conversations. Every failure path has a structured resolution.

### P17 — Roles Are Temporary
People are not permanently "Buyers" or "Sellers." Roles are temporary responsibilities assumed for a specific Exchange. Capabilities are unlocked separately.

### P18 — Truthful Language
BUYI never uses blanket "Verified," "Fully Protected," "Delivered," "Refunded," "Guaranteed," or "Held" language unless the exact evidence and legal structure supports each claim.

*UX implication:* State the fact — "Identity confirmed," "Item checked on [date]," "IMEI matched," "Pickup confirmed." Never use generic trust badges.

### P19 — Earned Responsibility
BUYI begins by doing one useful part of an Exchange correctly and earns the right to handle more through repeated successful outcomes.

### P20 — Concentration Before Breadth
Build capability depth in one zone and category before expanding geographically. Lagos and used phones come before Nigeria and before global.

---

## 3. Problem Statement & Market Opportunity

### 3.1 The Core Problem

Used goods commerce in Nigeria — and across most of Africa's informal economy — operates on unstructured trust. The typical flow is:

1. Buyer and seller find each other (WhatsApp, Instagram, market visit, referral)
2. They negotiate price informally
3. Buyer pays (bank transfer, cash) before or after inspecting the item
4. Item is handed over or sent
5. If anything goes wrong — wrong item, hidden fault, non-delivery, fraud — there is no structured recovery path

The result is that both parties carry enormous risk. Buyers fear fraud and misrepresented items. Sellers fear payment reversal or non-payment. Both parties know this and it raises friction, depresses prices, and limits the size of transactions that feel "safe enough" to complete.

### 3.2 Why Existing Solutions Fail

| Existing approach | Why it fails |
|---|---|
| "Send me the money first, I'll send the phone" | No protection for buyer |
| "Come inspect at Computer Village" | No proof of condition; no recovery if fault found later |
| WhatsApp escrow (informal) | No legal standing; no evidence; dependent on a trusted middleman who may not always be available |
| Formal escrow services | Expensive, slow, not built for sub-₦200k consumer transactions at volume |
| Logistics companies | Handle movement only; no agreement, no check, no recovery |
| Verification services | Handle check only; no custody, no payment protection |
| Generic marketplace platforms | Focus on listing and discovery; do not handle post-agreement execution |

No single existing product coordinates agreement + evidence + custody + payment + recovery into one structured Exchange.

### 3.3 The Opportunity

Computer Village, Lagos is one of the largest used electronics markets in Africa. It processes tens of thousands of device transactions monthly. The trust problem is universally recognised by buyers and sellers alike.

The addressable problem is not niche. It is the infrastructure layer that used-goods commerce is missing.

Beyond Computer Village: the model applies to any category where items have meaningful value, condition matters, and both parties are strangers or semi-strangers. Used cars, appliances, property rent deposits, agricultural inputs — these all share the same structural trust problem.

BUYI's starting position is narrow by design (phones, Lagos) and expansible by architecture.

### 3.4 BUYI's Structural Advantage

BUYI's advantage is not a single feature. It is the combination:

- Agreement that is version-controlled and immutable
- Evidence that is item-specific, stage-specific, and provenance-stamped
- Payment that is held and released by conditions — not by a timer or a clicked button
- Movement that records custody at every handoff
- Recovery that is engineered into the Exchange, not bolted on after failure

No competitor has built this combination for consumer used-goods transactions at the price point and trust context of the Nigerian informal economy.

---

## 4. Target Users & Personas

### 4.1 The Buyer

**Who they are:**  
A person who wants to acquire a used phone or electronic device. They may be shopping on their own (searching supply directly on BUYI), or they may have found a deal elsewhere (WhatsApp group, referral, Instagram post) and want to complete it safely.

**Goals:**
- Get the item they were shown, in the condition described
- Not lose money to fraud or misrepresentation
- Know the deal is being handled — not have to chase

**Pain points:**
- Fear of paying and receiving the wrong item or a broken item
- No way to independently verify condition before committing money
- No recovery path if something goes wrong after payment
- Feels like they're always the vulnerable party in the transaction

**Motivations:**
- Saving money vs buying new
- Finding specific models / configurations
- Speed (Computer Village can fulfill in hours)

**Key behaviour:**
- Likely mobile-first
- WhatsApp-native — accustomed to completing deals via messaging
- Will share a BUYI link if it makes a deal feel safer

**What BUYI must do for them:**
- Show exactly what is being protected and what is not (Protection Map)
- Give them a way to check the item independently (Phone Check)
- Hold their money until the evidence justifies release
- Give them a structured path to raise a problem, not just a support inbox

---

### 4.2 The Seller

**Who they are:**  
An individual, small dealer, or informal reseller at Computer Village or equivalent location. Selling used phones or selected electronics. May be an approved supplier on BUYI's platform, or a private individual facilitated through the outside-origin flow (ARCHITECT NOW / ENABLE LATER).

**Goals:**
- Get paid, quickly
- Not have money withheld unfairly after legitimate fulfillment
- Build a reputation that makes future sales faster

**Pain points:**
- Buyers who pay, receive the item, then dispute or reverse the payment
- Slow informal settlement processes
- No record of what was agreed; verbal deals lead to "he said / she said" disputes

**Motivations:**
- Faster settlement than current informal methods
- Access to buyers who wouldn't otherwise trust an unknown seller
- A record that proves they fulfilled correctly

**What BUYI must do for them:**
- Give them a clear view of what they need to do and by when
- Settle their payment as soon as conditions are met — no artificial delays
- Give them an attributable dispute resolution if a problem is raised

---

### 4.3 The Verifier

**Who they are:**  
An independent, trained individual who inspects a phone or device against a BUYI checklist. They are not the buyer, seller, reseller, a known associate, or directly paid by any of the above.

**Goals:**
- Complete the assigned check accurately and on time
- Record the evidence in the format required
- Report the true outcome (PASS / MISMATCH / INCONCLUSIVE) without pressure

**Pain points:**
- Being pressured by sellers to record a PASS when findings are inconclusive
- Incomplete or ambiguous checklist instructions
- Assignments that lack clear item identity information

**What BUYI must do for them:**
- Assign them with full item identity and context
- Give them a structured, category-specific checklist
- Capture continuous short video + required stills + timestamp + coarse location
- Allow them to declare conflict of interest and refuse an assignment
- Never force uncertainty into a PASS

---

### 4.4 The Logistics Partner (Movement)

**Who they are:**  
An approved, licensed logistics partner operating in the V1 Lagos zone. Not an open rider marketplace or unvetted courier.

**Goals:**
- Receive clear job details (pickup location, item identity, declared value, destination)
- Complete movement with appropriate evidence at each handoff
- Get compensated for completed jobs

**Pain points:**
- Incomplete pickup instructions
- Items not ready at agreed pickup time (wasted dispatch)
- Unclear package identity leading to wrong-item pickups

**What BUYI must do for them:**
- Confirm collectible job exists before dispatch
- Provide complete job: park/address, waybill/reference, release authority, package description and identity, declared value, destination, contacts
- Record custody at each material handoff
- Provide masked contact access so the carrier can reach parties without exposing personal numbers

---

### 4.5 Customer Support / Admin

**Who they are:**  
Internal BUYI staff who manage exceptions, Problems, disputes, settlements, and operations.

**Goals:**
- Resolve Problems quickly with full context
- Audit any Exchange completely — agreement history, evidence, custody, money ledger
- Take authorised actions that are fully logged

**What BUYI must do for them:**
- Queue exceptions by type (seller timeout, Check assignment, movement exception, Problem, dispute, settlement failure)
- Expose full Exchange history: agreement versions, item identity, evidence provenance, custody timeline, ledger
- Only allow authorised overrides with actor, level, reason, before/after, and immutable event
- Never allow direct database edits for money or state corrections

---

## 5. Product Goals & Success Metrics

### 5.1 V1 Primary Goals

| Goal | Description |
|---|---|
| G1 — Complete one real Exchange | One end-to-end protected phone Exchange works correctly |
| G2 — Failure paths handled | Refund, Problem freeze, changed terms, return all work correctly |
| G3 — Evidence is trustworthy | Evidence cannot be deleted, faked, or used outside the Exchange it was captured for |
| G4 — Settlement is correct | Money reaches the right party at the right time and never pays twice |
| G5 — Share & Earn works | Attribution freezes correctly; commission pays on settlement |

### 5.2 Success Metrics (Pilot)

| Metric | Definition | V1 Target |
|---|---|---|
| Exchange completion rate | Exchanges reaching DONE or REFUNDED / PARTIAL with evidence | > 85% |
| Verification accuracy | Checks reported as PASS where later dispute confirms condition matched | Track; baseline TBD |
| Settlement correctness | Settlements with zero double-payment or under-payment incidents | 100% |
| Problem resolution time | Median time from Problem opened to RESOLVED | < 48 hours |
| Delivery-to-review conversion | Deliveries where sufficient evidence triggers review window | 100% |
| False buyer-confirmed events | Review-window-expired events incorrectly recorded as buyer acceptance | 0 |
| Duplicate payment events | Payment webhooks that create duplicate protected funds | 0 |
| Share & Earn attribution accuracy | Completed Exchanges where correct attribution is recorded at payment | 100% |

### 5.3 Out of Scope for V1

- Nationwide Check or FETCH operations
- Open carrier marketplace
- Store builder
- Livestream commerce
- Social feed
- Loans, credit, Ajo/group buying
- Cars, property, agro categories
- Cross-border transactions
- Blockchain
- Paid transit insurance product
- Public advanced behavior score

---

## 6. Product Overview — What BUYI Is

### 6.1 The Exchange Completion Network

BUYI turns something people want to make happen — acquiring a phone, completing a deal found online, sending something across the city — into a **structured Exchange** that:

1. Records what was agreed (Agreement, TermVersion, Commitments)
2. Activates only the capabilities required (Check, Shield, Fetch — modularly)
3. Coordinates evidence at every stage (item identity, condition, handoffs, delivery)
4. Holds payment under conditions and releases it when conditions are met
5. Provides structured recovery when something goes wrong
6. Records how the Exchange ended and why

### 6.2 Internal Product Law

> **What was agreed? → What happened? → What happens next?**

This is the question BUYI answers at every moment of an Exchange, for every party.

### 6.3 The Protection Map

Every Exchange presents a **Protection Map** before commitment. The Protection Map classifies every material stage as:

- ✓ **BUYI-CONTROLLED** — BUYI handles this stage, holds responsibility, and has evidence
- ◎ **BUYI-OBSERVED** — BUYI records what it can see, but does not directly control
- ✗ **OUTSIDE BUYI** — This stage happened or is happening outside BUYI's scope

Example Protection Maps:

**Full protection (CHECK + SHIELD + FETCH):**
```
✓ Payment protection
✓ Phone Check (independent verification)
✓ Pickup & delivery
✓ Problem handling & recovery
```

**Check only:**
```
✓ Phone Check (independent verification)
✗ Payment — outside BUYI
✗ Delivery — your carrier
```

**Fetch only (park-to-door):**
```
✓ Pickup & custody
✓ Delivery & evidence
✗ Original purchase — outside BUYI
✗ Payment — outside BUYI
```

The Protection Map is shown to the user before commitment and must be accurate to the actual capabilities activated.

---

## 7. Front Doors & Information Architecture

### 7.1 The Four Front Doors

| Front Door | User Intent | V1 Behaviour |
|---|---|---|
| **BUYI IT** | Find or make something happen for me | Supported supply + manual/private unmet-demand capture |
| **BUY / SELL / EARN** | I found an opportunity or want to earn | Approved supply + Share & Earn |
| **SHIELD IT** | Protect a deal I found anywhere | ARCHITECT NOW — controlled enablement after core loop |
| **FETCH IT** | Pick up or move something for me | Core movement inside V1; standalone pilots later |

### 7.2 Home Screen Architecture

Home is **three layers**, not four equal buttons:

```
Layer 1: Make something happen
  └── Search / BUYI IT / primary action

Layer 2: Happening now
  └── Active Exchanges with current state + next action

Layer 3: Your BUYI
  └── History, earnings, behavior, settings
```

**Shield, Fetch, Earn, and Sell are contextual actions**, surfaced when relevant to what the user is doing — not permanent role tabs or top-level navigation items.

### 7.3 Navigation Principles

- One primary action per screen
- The Exchange timeline is the living centre of any active deal
- No "super-app wall" — the home screen does not fragment into unrelated product areas
- No permanent Buyer / Seller / Reseller role tabs (roles are Exchange-specific)

---

## 8. The Six Engines

Underneath the user interface, six engines coordinate the Exchange. These are product concepts, not necessarily individual microservices. V1 is a modular monolith; engine separation is a logical boundary.

### 8.1 Demand Engine
**Purpose:** Capture what people need, match with supply, enable sourcing and grouping.  
**V1 status:** Private capture / manual matching. No public demand marketplace.  
**Key behaviour:** A buyer can state a need that is not yet listed in supply. This becomes an unmet-demand record that BUYI can try to source manually.

### 8.2 Opportunity Engine
**Purpose:** Enable selling, sharing, tasks, and earnings.  
**V1 status:** Share & Earn active. Approved products only. No store builder.  
**Key behaviour:** An approved product gets a unique BUYI Link that carries attribution through WhatsApp, Instagram, TikTok, SMS. Earnings are pending until Exchange settlement.

### 8.3 Exchange Engine
**Purpose:** Manage terms, commitments, states, and outcomes.  
**V1 status:** Core backbone of every V1 Exchange.  
**Key behaviour:** Every material action — agreement, payment, check, movement, delivery, review, settlement, problem — passes through the Exchange Engine. It is the source of truth.

### 8.4 Shield Engine
**Purpose:** Payment protection rules, payment state, evidence requirements for settlement, problems and recovery.  
**V1 status:** Core V1 — required for any Exchange involving protected payment.  
**Key behaviour:** Holds protected funds under conditions. Enforces settlement eligibility rules. Freezes settlement when a Problem is opened.

### 8.5 Movement Engine
**Purpose:** Pickup, custody, delivery, and reverse movement (returns).  
**V1 status:** Controlled V1 — one tight Lagos zone, approved logistics partner, manual dispatch.  
**Key behaviour:** Records custody at every material handoff. Captures releaser, receiver, time, proof method, item/package identity, and photos where required.

### 8.6 Trust Engine
**Purpose:** Identity, factual behavior history, limits, and restoration.  
**V1 status:** Basic events now; richer views later.  
**Key behaviour:** Records factual outcomes — promise made, promise kept, promise broken, reason code. Does not produce a public score in V1. Inputs to risk policy and capability activation.

---

## 9. Capability Model

### 9.1 Capability Statuses

Each capability within an Exchange carries one of five statuses:

| Status | Meaning |
|---|---|
| **Required** | This capability must be active for this Exchange to proceed |
| **Recommended** | Risk policy suggests this capability; user may opt out within policy limits |
| **Requested** | User has chosen to activate this capability |
| **Unavailable** | This capability cannot be activated for this Exchange (e.g. outside zone) |
| **Not Needed** | This Exchange type does not require this capability |

Risk policy can override user preference and escalate a capability from Requested/Recommended to Required.

### 9.2 Capability Combinations (V1)

| Configuration | BUYI handles | BUYI does not claim |
|---|---|---|
| CHECK ONLY | Agreement + Check + Evidence + Outcome | Payment protection; movement |
| SHIELD ONLY | Agreement + protected payment + recovery | Item Check; movement may be outside BUYI |
| FETCH ONLY | Movement + custody + evidence + completion | Original payment; item condition |
| CHECK + SHIELD | Agreement + Check + payment protection + recovery | Movement (may be outside BUYI) |
| SHIELD + FETCH | Agreement + payment protection + movement | Item-condition Check |
| CHECK + FETCH | Check + controlled movement | Earlier outside payment |
| CHECK + SHIELD + FETCH | Full supported configuration | Still not zero risk or unlimited guarantee |
| PERSONAL PICKUP | Shield/Check + evidenced personal handoff | No forced FETCH |
| OUTSIDE CARRIER | Relevant capabilities + observed movement | BUYI does not pretend continuous custody |

### 9.3 The Protection Map (User-Facing)

Before any commitment, the user sees a plain-language Protection Map corresponding to the capability configuration. See Section 6.3 for examples.

---

## 10. User Journeys

### 10.1 Buyer — Full Protected Exchange (CHECK + SHIELD + FETCH)

**Context:** Buyer wants a used iPhone 13 Pro Max. Finds an approved listing on BUYI.

```
Step 1 — Discovery
  User opens BUYI IT
  Sees approved supply listing
  Views item snapshot: model, storage, colour, condition, price, seller facts
  Sees exact Protection Map for this listing
  Decides to proceed

Step 2 — Buyer Review
  State: BUYER_REVIEWING
  User sees: final total, capabilities, Protection Map, TermVersion, reservation timer
  User accepts terms (creates Acceptance record linked to TermVersion)
  Reservation begins (10-minute window from payment-stage reservation)

Step 3 — Payment
  State: PAYMENT_PENDING
  User completes payment via licensed provider
  Provider sends verified webhook event
  State: FUNDED
  Protected funds frozen

Step 4 — Seller Notification
  State: AWAITING_SELLER
  Seller notified of funded Exchange
  Seller has configurable window (12h default) to confirm ability to fulfill
  Seller confirms exact item and condition

Step 5 — Phone Check Assignment
  State: AWAITING_CHECK → CHECKING
  Independent verifier assigned (no conflict of interest)
  Verifier receives: item identity, checklist version, Exchange reference
  Verifier inspects: model, IMEI, condition, battery, accessories, activation lock, all functional checks
  Evidence captured: continuous short video + required stills + timestamp + coarse location
  Outcome recorded: PASS / MISMATCH / INCONCLUSIVE

Step 6a — Check PASS
  State: READY_TO_MOVE
  Buyer notified of Check result
  Movement job created

Step 6b — Check MISMATCH
  State: MISMATCH
  Buyer shown exact mismatch findings
  Buyer choices: accept changed terms (creates new TermVersion, requires re-acceptance)
                  cancel Exchange (refund initiated)
                  (subject to policy: proceed to movement with noted mismatch)

Step 7 — Pickup
  State: PICKED_UP
  Logistics partner dispatched
  Verifier or seller performs evidenced handoff to carrier
  Handoff records: releaser, receiver, time, item identity, condition, photos
  Custody transfers to carrier

Step 8 — In Transit
  State: IN_TRANSIT
  Carrier in custody of item
  BUYI records custody

Step 9 — Delivery
  State: DELIVERED
  Carrier delivers to buyer
  Delivery evidence captured (OTP + photos/confirmation)
  OTP = receipt confirmation, NOT buyer acceptance of item condition
  Valid receipt evidence starts 24-hour review window

Step 10 — Review Window
  State: REVIEWING
  Buyer has 24 hours to inspect and raise a Problem if any
  If buyer explicitly accepts: BUYER_ACCEPTED
  If buyer raises Problem: PROBLEM (freezes settlement)
  If review window expires with no action: REVIEW_WINDOW_EXPIRED_NO_PROBLEM
    → Settlement eligibility opens
    → No fabricated BUYER_CONFIRMED event is created

Step 11 — Settlement
  State: SETTLING → DONE
  Settlement instruction created
  Funds released to seller (minus any BUYI fee)
  Share & Earn attribution settled if applicable
  Delivery fee (already paid before dispatch)
  Exchange record permanently preserved

Step 12 — Done
  State: DONE
  Both parties see outcome, factual history, earnings status
  No fake trust score generated
```

---

### 10.2 Buyer — Problem During Review

```
Step 1-9: Same as above through DELIVERED

Step 10 — Problem Raised
  State: PROBLEM
  Buyer opens Problem with specific complaint and evidence
  Problem type: wrong item / condition mismatch / damaged / incomplete / other
  Problem references specific Commitment not met
  Settlement frozen atomically
  Seller notified

Step 11 — Resolution Attempt
  BUYI presents structured resolution options to both parties:
    - Continue (buyer accepts as-is)
    - Correction (seller provides missing item/accessory)
    - Changed price / partial refund
    - Return and full refund
    - More time (extension agreed)
    - Escalate to Dispute

  If resolution agreed → creates ResolutionVersion with money effect and deadline
  If resolution fails → DISPUTED

Step 12a — Resolved
  State: RESOLVED → SETTLING → DONE
  Agreed resolution executed
  Money effect applied (partial refund, full refund, or release)
  Exchange completed with recovery record

Step 12b — Disputed
  State: DISPUTED → DECIDED
  Evidence reviewed by admin queue
  Decision made with explanation
  State: REFUNDED / SETTLING / PARTIAL
  Decision is immutable
```

---

### 10.3 Return Journey

```
Context: Resolution requires return of item

Return authorised by agreed ResolutionVersion

Reverse Movement Job created
Buyer performs evidenced handoff to return carrier:
  - Photos of item condition at return handoff
  - Package identity confirmed
  - Time and location recorded

Carrier in custody (reverse custody path)

Item returned to seller with evidence:
  - Condition on return recorded
  - Handoff to seller evidenced

Refund initiated after sufficient return evidence
Provider confirms refund
Exchange closes with full return record
```

---

### 10.4 Seller Journey

```
1. List item (approved supply): item snapshot, IMEI, price, condition, accessories
2. Receive funded Exchange notification
3. Review exact agreed terms (TermVersion reference)
4. Confirm ability to fulfill within window (default 12h)
5. Cooperate with Check assignment (present item to verifier)
6. Perform evidenced handoff to carrier when ready-to-move
7. Monitor Exchange state
8. Receive settlement notification when conditions met
9. View settlement breakdown and factual Exchange history
```

---

### 10.5 Verifier Journey

```
1. Receive assignment with full item details and Exchange reference
2. Check for conflict of interest — declare or refuse if present
3. Travel to item location within agreed window
4. Confirm item identity (model, IMEI, serial)
5. Follow category checklist: screen, cameras, speakers, mic, charging, buttons, network, Wi-Fi, Bluetooth, activation lock, battery health, visible condition, repairs disclosed, accessories
6. Capture: continuous short video + required stills + timestamp + coarse location
7. Record all findings honestly
8. Submit outcome: PASS / MISMATCH / INCONCLUSIVE
   — Never force uncertainty into PASS
   — MISMATCH includes description of specific findings
9. Check fee earned; recorded against Exchange
```

---

### 10.6 Logistics Partner Journey

```
1. Receive movement job: pickup location, item/package identity, declared value, release authority, destination, contacts (masked)
2. Confirm job before dispatch (collectible job verified)
3. Proceed to pickup location
4. Verify item/package identity against job details
5. Collect release from releaser (evidence captured)
6. Record handoff: releaser, time, condition, photos
7. Take custody → State: PICKED_UP
8. Transport item
9. Arrive at destination
10. Confirm recipient identity
11. Capture delivery evidence: OTP + photos/confirmation
12. Record handoff: receiver, time, item identity
13. Custody transfers to buyer
14. State: DELIVERED
15. Movement job complete
```

---

### 10.7 Share & Earn Journey

```
1. Earner finds approved product listing
2. Views exact earning: amount + conditions (must be visible before sharing)
3. Generates unique BUYI Link (carries item/offer + earner attribution)
4. Shares via WhatsApp / TikTok / Instagram / SMS
5. Recipient clicks BUYI Link
6. Recipient views: item snapshot, seller facts, price, protection scope, Check choice
7. Recipient proceeds to Exchange
8. Attribution freezes at payment (not at click)
9. If Exchange settles successfully → commission released to earner
10. If Exchange cancelled/refunded → commission does not pay
11. Earner views pending and available earnings in Your BUYI
```

---

## 11. Feature Specifications

### 11.1 Exchange

**Purpose:** Core source of truth. Every BUYI job that becomes a supported transaction is an Exchange.

**User Story:** As a buyer, I want a single, living record of my deal that shows me exactly what was agreed, what is happening, and what comes next.

**Acceptance Criteria:**
- AC-E1: An Exchange is created for every supported transaction before any money moves
- AC-E2: Every material action on an Exchange is appended to the event log — never silently overwritten
- AC-E3: The Exchange state machine enforces valid transitions only (see Section 5 of Master Build Document)
- AC-E4: Every Exchange has a recorded `exchange_origin` (BUYI supply / outside-origin / etc.)
- AC-E5: The Exchange timeline screen shows: current state, what happened, who acts next, deadline, next safe action
- AC-E6: Modular Exchanges (Check-only, Fetch-only) complete without fake purchase or payment states
- AC-E7: The Exchange record is preserved permanently after completion — settlement does not erase history
- AC-E8: All money values use integer kobo and explicit currency

**Business Rules:**
- BR-E1: No feature may create money or state outside an Exchange record
- BR-E2: An Exchange in PROBLEM state has its relevant settlement frozen atomically
- BR-E3: A Problem at 23h59m must block settlement — no race condition
- BR-E4: Reservation expires 10 minutes from payment-stage reservation, not from BUY NOW tap
- BR-E5: Payment success and reservation expiry resolve atomically for unique inventory

**Edge Cases:**
- EC-E1: Duplicate payment webhook — must not create duplicate protected funds
- EC-E2: Late seller confirmation after cancellation — must not reopen a cancelled Exchange
- EC-E3: State transition attempted while problem is open — must be blocked
- EC-E4: Payment starts before reservation expiry but outcome pending — configurable payment grace period supported

---

### 11.2 BUYI Link

**Purpose:** A unique, shareable link that carries a complete item snapshot and attribution into any external channel.

**User Story:** As an earner, I want to share a link that lets anyone view the exact item and protection offer, and gives me credit if they buy.

**Acceptance Criteria:**
- AC-BL1: A guest (not signed in) can view full item snapshot, seller facts, price, protection scope, and Check choice from a BUYI Link
- AC-BL2: Attribution is frozen at payment — not at click or at sign-in
- AC-BL3: After attribution is frozen, it cannot be claimed by another party
- AC-BL4: The BUYI Link includes item/offer identity and earner attribution — both are immutable after generation
- AC-BL5: Link functions correctly when opened in WhatsApp, Instagram, TikTok, and SMS previews

**Business Rules:**
- BR-BL1: Only approved products may have a BUYI Link generated
- BR-BL2: The buyer price shown on the BUYI Link is controlled — earner cannot inflate it
- BR-BL3: The exact earning amount must be visible to the earner before they share

---

### 11.3 Phone Check (Verification)

**Purpose:** Independent, evidence-backed inspection of a phone against a BUYI checklist before payment release or at the agreed stage.

**User Story:** As a buyer, I want an independent person to check the phone and record their findings so I know what I'm getting before any money moves to the seller.

**Acceptance Criteria:**
- AC-PC1: The verifier is assigned by BUYI — not chosen by buyer, seller, or reseller
- AC-PC2: Verifier conflict of interest check is required before assignment is confirmed
- AC-PC3: Checklist covers: model, storage, colour, IMEI/serial (where lawful), activation lock, screen, cameras, speakers, mic, charging, buttons, network, Wi-Fi, Bluetooth, visible condition, repairs disclosed, battery health, accessories
- AC-PC4: Evidence includes continuous short video + required stills + timestamp + coarse location + verifier identity + checklist version
- AC-PC5: Evidence is linked to the specific item identity and Exchange stage
- AC-PC6: Outcome is one of: PASS, MISMATCH, INCONCLUSIVE — never forced to PASS
- AC-PC7: MISMATCH includes a specific description of the finding
- AC-PC8: Check report is immutable after submission
- AC-PC9: Buyer cancellation after completed Check results in non-refundable Check fee (unless BUYI/Check materially failed)
- AC-PC10: Seller failure after verifier dispatch results in seller bearing wasted Check cost; reason code recorded

**Business Rules:**
- BR-PC1: Verifier cannot be buyer, seller, reseller, known associate, or directly paid by any party to the Exchange
- BR-PC2: Missing mandatory evidence fields prevent PASS
- BR-PC3: INCONCLUSIVE is a valid terminal check outcome — it does not revert to PASS
- BR-PC4: Check is not an authenticity guarantee and does not control post-inspection stages unless custody is also controlled

---

### 11.4 Protected Payment (Shield)

**Purpose:** Hold buyer payment under conditions set by the Exchange and release it only when those conditions are met and no blocking Problem exists.

**User Story:** As a buyer, I want my money to be held safely until the deal is fulfilled, so the seller only gets paid when everything checks out.

**Acceptance Criteria:**
- AC-PP1: Payment is processed via a licensed payment provider — BUYI does not operate its own payment rail
- AC-PP2: Protected funds are frozen at FUNDED state
- AC-PP3: Settlement eligibility requires: agreed delivery/completion conditions met + required evidence present + no blocking Problem
- AC-PP4: Settlement does not trigger automatically from a delivery OTP alone
- AC-PP5: Provider confirmation is required before refund status is shown as complete
- AC-PP6: Delivery fee is collected and held before dispatch
- AC-PP7: If cancelled before dispatch and no provider cost incurred, delivery fee refund is automatic
- AC-PP8: Settlement retry never pays already-successful recipients twice

**Business Rules:**
- BR-PP1: Live customer fund flows require provider + Nigerian fintech legal approval before production activation
- BR-PP2: KYC threshold is OPEN / PROVIDER-DEPENDENT — not hard-coded
- BR-PP3: All money values use integer kobo and explicit currency
- BR-PP4: No paid transit insurance product in V1

**Edge Cases:**
- EC-PP1: Duplicate payout webhook — idempotency key required; never double-pay
- EC-PP2: Problem opened at 23h59m — must atomically block settlement
- EC-PP3: Settlement instruction created but provider failure — idempotent retry; no double release

---

### 11.5 Controlled Movement (FETCH)

**Purpose:** Coordinate pickup, custody, and delivery of items within the approved V1 Lagos zone using a licensed logistics partner.

**User Story:** As a buyer, I want BUYI to handle getting the item from the seller to me, with proof at every step, so I know where my item is and who had it.

**Acceptance Criteria:**
- AC-FM1: Movement job created only after Exchange reaches READY_TO_MOVE state
- AC-FM2: Collectible job confirmed (item ready, release authority confirmed) before dispatch
- AC-FM3: Every material handoff records: releaser, receiver, time, proof method, item/package identity, condition, photos where required
- AC-FM4: Custody is recorded only when BUYI has sufficient handoff evidence
- AC-FM5: GPS alone is not delivery proof
- AC-FM6: `carrier_selected_by` is recorded: BUYI / BUYER / SELLER / MUTUAL
- AC-FM7: Delivery OTP is receipt confirmation — it is not buyer acceptance of item condition
- AC-FM8: Review window opens only after valid receipt evidence, not on OTP alone
- AC-FM9: Movement above supported declared-value / provider limit is blocked

**Business Rules:**
- BR-FM1: V1 is one tight Lagos zone, manual dispatch, one approved logistics partner — no open rider marketplace
- BR-FM2: Park-to-door: park, waybill/reference, release authority, package description/identity, declared value, destination, contacts must all be present before dispatch
- BR-FM3: Failed delivery attempt cost follows attributable cause (buyer / seller / BUYI / carrier) — not hard-coded as non-refundable
- BR-FM4: Reverse movement is a controlled custody path — returns do not happen informally outside BUYI for high-value or wrong/damaged goods

---

### 11.6 Problems, Recovery & Returns

**Purpose:** Provide structured recovery when something goes wrong — as a built-in Exchange Engine path, not an improvised support conversation.

**User Story:** As a buyer, if the item is wrong or damaged, I want a clear structured path to resolution, with my money still frozen until we reach a fair outcome.

**Acceptance Criteria:**
- AC-PR1: Problem is the first step — formal Dispute only after structured self-resolution fails
- AC-PR2: Problem opening atomically freezes relevant unreleased settlement
- AC-PR3: Problem references a specific Commitment and reason code — not vague blame
- AC-PR4: Resolution options presented: continue, correction, replacement, changed price/partial refund, return, full refund, more time, release, escalation
- AC-PR5: Accepted resolution creates immutable ResolutionVersion with money effect and deadline
- AC-PR6: Return is executed as reverse custody — not an informal instruction to privately return the item
- AC-PR7: Evidence used in a decision cannot be deleted or replaced after the decision
- AC-PR8: Admin decisions include explanation, actor, authorization level, before/after values, and immutable event

**Business Rules:**
- BR-PR1: Opening a Problem does not prove the reporter is right — it freezes settlement pending review
- BR-PR2: Post-completion issues (agreed seller warranty, consumer rights, fraud, later evidence) may exist — do not casually reopen settled money without policy/legal basis
- BR-PR3: Settlement closes the protected payment cycle but does not erase Exchange history

---

### 11.7 Agreement & Terms Versioning

**Purpose:** Ensure that what was agreed is permanently recorded and that changes require explicit re-acceptance.

**Acceptance Criteria:**
- AC-AT1: Every Exchange has a linked TermVersion with immutable content hash
- AC-AT2: Acceptance is recorded per party per TermVersion
- AC-AT3: Material change (e.g. MISMATCH leading to price change) creates a new TermVersion
- AC-AT4: Old TermVersion is preserved — admin cannot edit original terms
- AC-AT5: Changed terms invalidate old acceptance and block progression until new acceptance is received
- AC-AT6: The current TermVersion is shown to the user at every relevant moment

---

### 11.8 Exchange Timeline Screen

**Purpose:** One living screen that shows the full state of any Exchange, what happened, who acts next, and what to do.

**Acceptance Criteria:**
- AC-ET1: Shows current Exchange state in plain language
- AC-ET2: Shows ordered history of all events that have occurred
- AC-ET3: Shows who acts next and by when (deadline)
- AC-ET4: Shows the next safe action button — one primary action
- AC-ET5: If a Problem is open, it is prominently visible
- AC-ET6: Protection Map is accessible from the timeline
- AC-ET7: Processing states always describe what is happening and what comes next — never just "Processing..."

---

### 11.9 Admin Command Centre

**Purpose:** Give internal BUYI staff full visibility and controlled authority to manage exceptions, disputes, and operations.

**Acceptance Criteria:**
- AC-AD1: Queues visible: seller timeout, payment reconciliation, Check assignment, movement exception, Problems, returns, disputes, settlement failures
- AC-AD2: Full Exchange view: agreement history, item identity, evidence provenance, custody timeline, money ledger, notifications
- AC-AD3: Permitted actions: freeze, release, refund, partial refund, cancel, escalate, reassign verifier/carrier, apply restrictions
- AC-AD4: Every override records: actor, authorization level, reason, before/after values, immutable event
- AC-AD5: No direct database edits for money or state corrections
- AC-AD6: Admin cannot delete evidence, edit original terms, or hide overrides

---

### 11.10 Share & Earn

**Purpose:** Allow approved earners to share BUYI Links and earn commission when the resulting Exchange settles.

**Acceptance Criteria:**
- AC-SE1: Only approved products have shareable links
- AC-SE2: Exact earning is visible before sharing — no surprise commissions
- AC-SE3: Attribution freezes at payment — not at click or account creation
- AC-SE4: Attribution cannot be retrospectively claimed after payment
- AC-SE5: Commission is pending until Exchange settles successfully
- AC-SE6: No commission for clicks, views, recruitment, or empty activity
- AC-SE7: Earner sees pending and available earnings in Your BUYI
- AC-SE8: BUYI official social pages may manually promote selected approved products in MVP

---

## 12. UX Principles & Design Language

### 12.1 The Five User Moments

Every screen and flow must serve one of these five user moments:

1. **Check the deal** — Understand what's being offered and what protection is in place
2. **Pay** — Commit funds confidently, knowing exactly what is covered
3. **BUYI handles it** — Know that BUYI is coordinating the Exchange without needing to chase
4. **Receive / check** — Confirm receipt and inspect the item within the review window
5. **Done or tell BUYI there is a problem** — Complete cleanly or trigger structured recovery

### 12.2 Design Principles

**Warm light UI** — Large, readable text. Restrained green as the primary accent. No heavy dark crypto/fintech styling.

**One primary action per screen** — Never present two equally weighted actions that could lead to confusion or errors.

**Truthful language** — Never use: "Verified," "Fully Protected," "Delivered" (as a blanket claim), "Refunded" (before provider confirms), "Guaranteed," "Held."

Use factual statements instead:
- "Identity confirmed"
- "Item checked on [date] by independent verifier"
- "IMEI matched"
- "Pickup confirmed at [time]"
- "Delivery confirmed — review window open until [time]"

**Processing transparency** — Never show "Processing" without saying what is happening and what comes next.

**No fake trust badges** — No generic "Verified Seller" badges without backing evidence. No star ratings based on opaque algorithms. Facts only.

**Minimal cognitive load** — The user explains what they need; BUYI determines the machinery underneath.

### 12.3 Notification Principles

- Notifications are stage-specific and actionable
- Every notification tells the recipient what happened, what it means for them, and what (if anything) they need to do
- Delivery receipts are logged for compliance and audit
- No notification bombardment for passive state transitions the user does not need to act on

---

## 13. Non-Functional Requirements

### 13.1 Performance

| Requirement | Target |
|---|---|
| Exchange state read latency | < 500ms p95 |
| Payment webhook processing | < 5 seconds from receipt to state transition |
| Evidence upload | Support files up to 100MB; video upload to complete within 60 seconds on 4G |
| Admin queue load | Support 500 concurrent admin actions without degradation |

### 13.2 Availability

| Requirement | Target |
|---|---|
| Exchange Engine uptime | 99.9% (Lagos pilot) |
| Payment webhook receiver uptime | 99.99% — must not miss payment events |
| Evidence storage durability | 99.999999999% (11 nines) — evidence must not be lost |

### 13.3 Security

- All API calls require authentication except BUYI Link guest view (read-only item snapshot)
- Payment provider integration uses provider SDK / webhooks with signature verification
- Evidence assets are stored with access policy enforcement — not publicly accessible by default
- PII (IMEI, contact details, KYC data) encrypted at rest
- Masked contact access for logistics partners — real phone numbers not exposed
- Admin actions require role-based authorization; every action is auditable
- No direct database writes to money or state by any interface including admin UI

### 13.4 Scalability

- V1 is a modular monolith — services are logical modules, not separate deployments
- Data model is designed for eventual extraction into separate services without Exchange truth being compromised
- Event log is append-only — suitable for migration to event-sourcing primary model in Phase 2
- Market, currency, payment provider, identity policy, and category policy are layered — schema supports multiple markets

### 13.5 Compliance & Auditability

- Every consequential state transition is server-validated and idempotent
- Append-only event log for all Exchange history
- Evidence provenance fields on every EvidenceAsset
- Settlement instructions traceable to originating Exchange and Evidence
- KYC/AML thresholds: OPEN / PROVIDER-DEPENDENT — to be confirmed with provider before production
- No live fund flows until Nigerian fintech legal review approves fund flow, KYC/AML, refunds, chargebacks, and settlement responsibilities

### 13.6 Localisation

- V1: Nigeria (NG), Nigerian Naira (NGN), integer kobo
- Schema must support: market, currency, payment provider per market, identity policy per market, category policy per market, consumer-policy version per market
- Do not hard-code Nigeria-only values into logic layers

### 13.7 Accessibility

- Text must meet WCAG 2.1 AA contrast requirements
- Interactive elements must be reachable by keyboard and screen reader
- Error messages must be descriptive and associated with their input fields
- Touch targets on mobile must be ≥ 44x44px

---

## 14. Release Roadmap & Scope Gates

### Phase 0 — Foundation
**Ship:** Exchange schema, event log, capability model, terms/versioning, item identity, evidence provenance, custody model, problem/resolution, provider abstractions, admin skeleton  
**Exit test:** No UI action can create untracked money or state changes

### Phase 1 — One Real Protected Phone Exchange
**Ship:** Buyer + seller flows, payment sandbox/provider integration, seller confirm, Phone Check, controlled FETCH, delivery, 24h review, settlement, problem handling  
**Exit test:** One end-to-end Exchange works correctly — then ten

### Phase 2 — Harden Failure Paths
**Ship:** Refunds, retries, Problem freeze, changed terms, return/reverse custody, admin decisions, reconciliation  
**Exit test:** 30 dry-run failure scenarios pass (see Section 15 of Master Build Document)

### Phase 3 — Share & Earn
**Ship:** Approved products, BUYI Links, attribution, commission rules, pending/available earnings  
**Exit test:** Completed sale pays correct parties

### Phase 4 — Controlled Modular Pilots
**Ship:** Check-only; park-to-door FETCH-only; selected outside-origin flows  
**Exit test:** Operations can fulfill without a national promise

### Phase 5 — Open Outside-Origin (Later)
**Ship:** Shield-only, full capability combinations, Protection Map, risk engine, Handle the rest  
**Gate:** Only after Lagos pilot proves density, economics, and support capacity

### Scope Gates Summary

| Status | Items |
|---|---|
| **BUILD NOW** | Exchange engine; BUYI Link; approved phone supply; protected payment; seller commitment; Phone Check; controlled FETCH; evidence/item identity; custody; 24h evidence-triggered review; settlement; Problem/recovery/return basics; admin; immutable events; Share & Earn; basic behavior events |
| **ARCHITECT NOW / ENABLE LATER** | Outside-origin Exchange; Check-only; FETCH-only; park-to-door; Shield-only; full capability activation; Protection Map; personal pickup; external carriers; carrier_selected_by; risk rules; Handle the rest; global market/provider policy fields |
| **LATER** | Nationwide Check/FETCH; Human Carrier; transit insurance; public behavior score; credit; Ajo/group buying; public demand marketplace; cars/property/agro; cross-border |
| **DO NOT BUILD NOW** | Store builder; livestream; social feed; nationwide fleet; BUYI-owned payment rail; loans; insurance without approved partner; blockchain; fake social proof; permanent role accounts |

---

## 15. Risks & Mitigations

### 15.1 Technical Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Duplicate payment webhook creates duplicate funds | Critical — financial loss | Idempotency key on all payment events; release-blocking test required |
| Race condition: Problem opened at 23h59m | Critical — incorrect settlement | Atomic Problem-freeze check before any settlement eligibility evaluation |
| Reservation expiry and payment success race | Critical — inventory sold twice | Atomic resolution required; release-blocking test |
| God Aggregate — Exchange grows to contain everything | High — unmaintainable codebase | Enforce bounded context boundaries; Exchange references aggregates by ID, does not embed them |
| Evidence deleted or overwritten after decision | Critical — dispute integrity destroyed | Append-only evidence events; admin cannot delete evidence |

### 15.2 Operational Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Verifier conflict of interest not declared | High — corrupt check outcomes | Mandatory conflict declaration before assignment confirmation |
| Carrier dispatched before collectible job confirmed | Medium — wasted dispatch; custody dispute | Job confirmation required before dispatch |
| Seller fails to respond within confirmation window | Medium — buyer funds locked | Configurable timeout + auto-cancel with refund after window |
| Outside-carrier stage represented as BUYI-controlled | High — false protection claim | `carrier_selected_by` recorded; BUYI-OBSERVED vs BUYI-CONTROLLED classification enforced |

### 15.3 Legal & Regulatory Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Fund flows activated before provider/legal approval | Critical — regulatory violation | Hard gate: no live fund flows until Nigerian fintech legal review complete |
| KYC threshold hard-coded without provider approval | High — compliance failure | KYC threshold is OPEN / PROVIDER-DEPENDENT; not coded until approved |
| Transit insurance promised without licensed structure | High — unenforceable promise | No paid transit protect in V1; architecture fields only |
| Carrier liability cap hard-coded without contract | High — unenforceable promise | Carrier liability cap is OPEN / PROVIDER-DEPENDENT; not coded until contract confirmed |

### 15.4 Product Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Feature creep into Exchange aggregate | High — architecture degradation | Strict scope gates; ARCHITECT NOW / ENABLE LATER discipline |
| Generic trust language erodes credibility | Medium — brand and legal risk | Truthful Language Law enforced in every UI review |
| Too many microservices before V1 | High — delays and over-engineering | Modular monolith in V1; extract services only when justified |
| Domain leakage between bounded contexts | High — unmaintainable logic | Movement must never ask about payment; Exchange emits events that other contexts respond to |

---

## 16. Compliance & Legal Boundaries

- BUYI operates as an Exchange Completion Network, not as a payment provider, insurance company, or bank
- Payment processing is delegated to a licensed provider — BUYI controls Exchange rules and settlement instruction only
- Fund flow design, KYC/AML, refund policy, chargeback handling, and settlement responsibility must be reviewed and approved by the licensed provider and Nigerian fintech legal counsel before any live customer transactions
- Consumer rights under applicable Nigerian law are preserved — buyer-remorse return policy subject to applicable law and incorporated seller rights
- Carrier liability is subject to carrier contract/insurance and applicable law — BUYI does not invent or promise a liability cap
- Evidence retention policy must comply with applicable data protection regulations (Nigeria Data Protection Regulation / NDPR)
- IMEI recording is noted as "where lawful" — legal review required before IMEI storage is activated in production

---

## 17. Appendix — Glossary

| Term | Definition |
|---|---|
| **Exchange** | The fundamental unit of BUYI. A structured record of what was agreed, what happened, and how it ended. Every supported BUYI job is an Exchange. |
| **Exchange Completion Network** | BUYI's internal product category. A platform that turns agreements into completed outcomes by coordinating the supported capabilities needed. |
| **Capability** | A modular service that an Exchange may activate: Check, Shield, Fetch. Each has a status: Required, Recommended, Requested, Unavailable, or Not Needed. |
| **Protection Map** | The user-facing classification of every material Exchange stage as BUYI-CONTROLLED, BUYI-OBSERVED, or OUTSIDE BUYI. Shown before commitment. |
| **TermVersion** | An immutable, content-hashed version of agreed terms. Acceptance is recorded per party per version. Material changes create a new version. |
| **Acceptance** | A record that a specific party accepted a specific TermVersion at a specific time. |
| **Commitment** | A specific obligation accepted by a party to the Exchange. Failure is diagnosed by the specific Commitment not met. |
| **ItemSnapshot** | An immutable record of the item's described state at the time of agreement: model, condition, accessories, price, IMEI, etc. |
| **ItemIdentity** | The specific identifier(s) for a physical item: IMEI, serial number, seal ID, package ID, or category-appropriate identity. |
| **EvidenceAsset** | A piece of evidence (video, photo, document, OTP) with full provenance: who created it, when, for which item, at which stage, under which checklist version. |
| **Custody** | Legal and physical responsibility for an item at a specific moment. Changes only after sufficient handoff evidence. |
| **Handoff** | A recorded change of custody: releaser, receiver, time, proof method, item identity, condition, photos. |
| **BUYI-CONTROLLED** | A stage where BUYI holds direct responsibility and has sufficient evidence. |
| **BUYI-OBSERVED** | A stage where BUYI records what it can see but does not directly control. |
| **OUTSIDE BUYI** | A stage that occurred or is occurring outside BUYI's scope. No retroactive protection applies. |
| **Problem** | A structured report that something in an Exchange did not meet commitments. Opens a recovery path and atomically freezes relevant settlement. |
| **ResolutionVersion** | An immutable record of an agreed resolution to a Problem, including money effect and deadline. |
| **Dispute** | Formal escalation after structured Problem resolution fails. Goes to admin evidence review. |
| **Settlement** | The release of protected funds to the eligible party/parties after Exchange conditions are met. |
| **Review Window** | The buyer's period (24h default) to inspect the item and raise a Problem after sufficient delivery evidence. Not triggered by OTP alone. |
| **BUYI Link** | A unique, shareable link carrying item/offer identity and earner attribution into external channels. |
| **Share & Earn** | The capability that allows approved earners to share BUYI Links and receive commission when the resulting Exchange settles. |
| **Check** | Independent verification of a physical item against a BUYI category checklist. Outcome: PASS, MISMATCH, INCONCLUSIVE. |
| **Shield** | Payment protection capability: funds held under conditions and released when conditions are met. |
| **Fetch** | Controlled movement capability: pickup, custody, handoffs, delivery, and reverse movement within the approved zone. |
| **Outside-Origin** | An Exchange where the deal began outside BUYI. BUYI enters to handle a future supported stage. |
| **Stale Inventory** | OPEN policy — exact rule to be confirmed; do not hard-code. |
| **Kobo** | The smallest unit of Nigerian currency (1/100 of ₦1 Naira). All money values stored in integer kobo. |
| **carrier_selected_by** | Recorded field: BUYI / BUYER / SELLER / MUTUAL. Determines obligations and risk allocation for movement. |
| **exchange_origin** | Recorded field: how and where the Exchange originated (BUYI supply, outside-origin, etc.). |
| **Modular Monolith** | V1 architecture: single deployment with separate logical modules (Exchange, Settlement, Movement, Evidence, Identity, etc.) and clear interfaces. Services are extracted later as justified. |
| **Append-Only Event Log** | The Exchange event history. New events are added; nothing is deleted or overwritten. Corrections create new events. |

---

*End of Volume I — Product Requirements Document*  
*Next: Volume II — Software Requirements Specification*  
*BUYIspace Technologies Ltd. | Internal | Confidential*  
*Supersedes any conflicting earlier product documents*
