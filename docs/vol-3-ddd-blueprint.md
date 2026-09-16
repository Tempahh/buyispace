# BUYI — Domain-Driven Design Blueprint
## Volume III of the BUYI Engineering Documentation Suite
**Version:** 1.0 — Final Decision Freeze Baseline  
**Date:** 31 August 2026  
**Prepared by:** BUYIspace Technologies Ltd. — Engineering  
**Classification:** Internal — Confidential  
**Authority:** Derived from the BUYI Programmer Master Build Document (Final Decision Freeze, 31 August 2026), Volume I PRD, and Volume II SRS. Where conflict exists, the Master Build Document governs.

---

## Table of Contents

1. [Why DDD for BUYI](#1-why-ddd-for-buyi)
2. [Ubiquitous Language](#2-ubiquitous-language)
3. [Bounded Context Map](#3-bounded-context-map)
4. [Bounded Context: Exchange](#4-bounded-context-exchange)
5. [Bounded Context: Agreement](#5-bounded-context-agreement)
6. [Bounded Context: Identity](#6-bounded-context-identity)
7. [Bounded Context: Item & Evidence](#7-bounded-context-item--evidence)
8. [Bounded Context: Shield (Payment Protection)](#8-bounded-context-shield-payment-protection)
9. [Bounded Context: Check (Verification)](#9-bounded-context-check-verification)
10. [Bounded Context: Movement (FETCH)](#10-bounded-context-movement-fetch)
11. [Bounded Context: Recovery](#11-bounded-context-recovery)
12. [Bounded Context: Settlement](#12-bounded-context-settlement)
13. [Bounded Context: Distribution (Share & Earn)](#13-bounded-context-distribution-share--earn)
14. [Bounded Context: Trust & Behavior](#14-bounded-context-trust--behavior)
15. [Bounded Context: Notification](#15-bounded-context-notification)
16. [Commands — Full Catalog](#16-commands--full-catalog)
17. [Domain Events — Full Catalog](#17-domain-events--full-catalog)
18. [Aggregate Invariants — Full Specification](#18-aggregate-invariants--full-specification)
19. [Process Managers (Sagas)](#19-process-managers-sagas)
20. [Consistency Boundaries & Transaction Rules](#20-consistency-boundaries--transaction-rules)
21. [Repository Contracts](#21-repository-contracts)
22. [Anti-Corruption Layers](#22-anti-corruption-layers)
23. [Architecture Decision Records (ADRs)](#23-architecture-decision-records-adrs)

---

## 1. Why DDD for BUYI

BUYI is not a CRUD application. It does not describe a system where users purchase products. It describes a **business process with legal, operational, financial, and evidentiary consequences**.

The source document does not say "Users purchase products." It says:

> "An Exchange coordinates agreement, evidence, commitments, movement, settlement, and recovery."

That is domain language, not technical language. That distinction drives every architectural decision in this document.

### 1.1 The Core Mindset Shift

Most engineers will default to:
```
User → Order → Payment → Delivery
```

BUYI requires:
```
Exchange → Agreement → Commitments → Evidence → Movement → Settlement → Recovery
```

Payment is not the centre. The product is not the centre. The **Exchange** is the centre — and it is the permanent source of truth.

### 1.2 What DDD Gives BUYI

| DDD Pattern | BUYI Benefit |
|---|---|
| Ubiquitous Language | Every engineer, founder, and ops person uses the same vocabulary — "Exchange", not "Order" |
| Bounded Contexts | Each domain area owns its vocabulary, rules, and persistence. No domain leakage. |
| Aggregates | Consistency boundaries protect invariants — payment doesn't release because the UI says so |
| Domain Events | Movement never asks "has the buyer paid?" — it only responds to `MovementAuthorized` |
| Commands | All mutations are explicit, named, and intentional — no silent state patching |
| Process Managers | Complex multi-step flows (full Exchange lifecycle) are explicit sagas, not tangled service calls |

### 1.3 God Aggregate Warning

The Exchange is the source of truth. That does **not** mean Exchange should own everything.

These are different ideas.

Exchange is the **orchestrator** and **identity reference point**. It owns:
- Lifecycle state machine
- Capability statuses
- References (by ID) to other aggregates
- Commands and emitted events

Exchange does **not** own:
- Image upload logic
- Payment processing
- Notification sending
- SMS/WhatsApp calls
- Carrier API calls
- Verification logic
- Ledger entries

Those belong to their own aggregates and domain services.

---

## 2. Ubiquitous Language

The following terms must be used **consistently** in code, APIs, documentation, UI copy, and team conversation. Engineers must not invent synonyms.

| Term | Meaning in Code & Conversation |
|---|---|
| **Exchange** | The fundamental unit. Never "Order", "Transaction", "Deal", or "Purchase". |
| **ExchangeParty** | A person in a specific role within one Exchange. Never "User" in domain context. |
| **TermVersion** | An immutable version of agreed terms. Never "contract" or "agreement snapshot". |
| **Acceptance** | A recorded act of agreeing to a specific TermVersion. Never "sign-off" or "approval". |
| **Commitment** | A specific obligation on a specific party. Never "promise" or "duty" in code. |
| **ItemSnapshot** | The immutable described state of an item at agreement time. Never "listing" in domain context. |
| **ItemIdentity** | The physical identifier (IMEI, serial). Never "device ID" or "product code". |
| **EvidenceAsset** | A piece of captured proof with provenance. Never "photo", "file", or "upload" in domain context. |
| **Handoff** | A recorded custody transfer between parties. Never "delivery" (generic) in domain context. |
| **CustodyEvent** | A specific recorded moment of custody change. |
| **ProtectedFundsRecord** | Held payment under Exchange conditions. Never "escrow balance" or "held amount". |
| **Problem** | A structured recovery trigger. Never "complaint", "issue", or "ticket". |
| **ResolutionVersion** | An immutable agreed resolution to a Problem. Never "settlement agreement" or "deal". |
| **Dispute** | Formal escalation after Problem self-resolution fails. Never "chargeback" or "claim". |
| **SplitInstruction** | The instruction to distribute protected funds. Never "payout order" or "transfer". |
| **ShareLink** | A unique attribution-carrying link for an approved product. Never "referral link" or "affiliate link". |
| **Attribution** | The frozen record of who introduced a buyer. Never "referral" in domain code. |
| **ProtectionMap** | The per-Exchange classification of stages as BUYI-CONTROLLED, BUYI-OBSERVED, OUTSIDE BUYI. |
| **CapabilityStatus** | Required / Recommended / Requested / Unavailable / Not Needed. |
| **ReviewWindow** | The 24-hour buyer inspection period opened by valid delivery evidence. |
| **carrier_selected_by** | Who chose the carrier: BUYI / BUYER / SELLER / MUTUAL. |
| **exchange_origin** | How the Exchange originated. Never "source" or "channel" in domain context. |

### 2.1 Forbidden Synonyms in Code

These must never appear in domain model classes, method names, or API routes:

| Forbidden | Use instead |
|---|---|
| `Order` | `Exchange` |
| `Purchase` | `Exchange` |
| `Transaction` | `Exchange` (for business domain) |
| `Escrow` | `ProtectedFundsRecord` |
| `Delivered` (as buyer acceptance) | `DeliveryConfirmed` then `ReviewWindowOpened` |
| `Verified` (blanket) | Specific: `IdentityConfirmed`, `CheckPassed`, `IMEIMatched` |
| `responsibility_owner` | `current_custodian` + `obligations_by_party` |
| `seller.isVerified` | `seller.identityConfirmedAt` or `seller.checkQualificationStatus` |

---

## 3. Bounded Context Map

### 3.1 Context Definitions

Each bounded context owns its vocabulary, rules, persistence, and internal API. No bounded context reaches into another's database directly.

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   EXCHANGE CONTEXT          AGREEMENT CONTEXT                       │
│   ─────────────────         ──────────────────                      │
│   Exchange aggregate        TermVersion aggregate                   │
│   ExchangeParty entity      Acceptance entity                       │
│   CapabilityEngine svc      Commitment entity                       │
│   StateTransitionEngine     PriceBreakdown value object             │
│                                                                     │
├──────────────┬──────────────┬──────────────┬────────────────────────┤
│              │              │              │                        │
│  SHIELD      │  CHECK       │  MOVEMENT    │  RECOVERY              │
│  CONTEXT     │  CONTEXT     │  CONTEXT     │  CONTEXT               │
│  ──────────  │  ──────────  │  ──────────  │  ──────────            │
│  PaymentIntent│  CheckJob   │  MovementJob │  Problem               │
│  ProtectedFunds│ CheckReport│  CustodyEvent│  ResolutionVersion     │
│  Refund      │  Checklist   │  Handoff     │  Dispute               │
│  SplitInstr. │  Version     │  ReverseJob  │  Decision              │
│              │              │              │                        │
├──────────────┴──────────────┴──────────────┴────────────────────────┤
│                                                                     │
│   SETTLEMENT CONTEXT        IDENTITY CONTEXT                        │
│   ──────────────────        ──────────────────                      │
│   LedgerAccount             User/Person aggregate                   │
│   LedgerEntry               KYCState                                │
│   SettlementInstruction     PayoutDestinationToken                  │
│   Reconciliation            CapabilityProfile                       │
│                                                                     │
├──────────────┬──────────────┬──────────────────────────────────────┤
│              │              │                                       │
│  ITEM &      │  DISTRIBUTION│  TRUST & BEHAVIOR    NOTIFICATION    │
│  EVIDENCE    │  CONTEXT     │  CONTEXT             CONTEXT         │
│  CONTEXT     │  ──────────  │  ──────────          ──────────      │
│  ──────────  │  ProductAppr.│  PromiseEvent        Notification    │
│  ItemSnapshot│  ShareLink   │  ReliabilitySummary  Template        │
│  ItemIdentity│  Attribution │  BehaviorRecord      DeliveryReceipt │
│  EvidenceAsset│ CommissionRl│                                      │
│  ChecklistVsn│              │                                       │
│              │              │                                       │
└──────────────┴──────────────┴───────────────────────────────────────┘
```

### 3.2 Context Integration Patterns

| Integration | Pattern | Direction |
|---|---|---|
| Exchange → Shield | Domain Event (`ExchangeFunded`) | Exchange emits; Shield listens |
| Exchange → Check | Domain Event (`CheckRequested`) | Exchange emits; Check listens |
| Exchange → Movement | Domain Event (`MovementAuthorized`) | Exchange emits; Movement listens |
| Exchange → Recovery | Domain Event (`ProblemOpened`) | Exchange emits; Recovery listens |
| Shield → Exchange | Domain Event (`PaymentConfirmed`, `RefundConfirmed`) | Shield emits; Exchange listens |
| Check → Exchange | Domain Event (`CheckResultSubmitted`) | Check emits; Exchange listens |
| Movement → Exchange | Domain Event (`DeliveryConfirmed`, `PickupConfirmed`) | Movement emits; Exchange listens |
| Recovery → Exchange | Domain Event (`ResolutionAgreed`, `DisputeDecided`) | Recovery emits; Exchange listens |
| Settlement → Exchange | Domain Event (`SettlementCompleted`, `SettlementFailed`) | Settlement emits; Exchange listens |
| Exchange → Settlement | Domain Event (`SettlementEligibilityConfirmed`) | Exchange emits; Settlement listens |
| Exchange → Distribution | Domain Event (`AttributionFreezeRequired`) | Exchange emits; Distribution listens |
| Exchange → Trust | Domain Event (`CommitmentOutcomeRecorded`) | Exchange emits; Trust listens |
| Exchange → Notification | Domain Event (any significant state change) | Exchange emits; Notification listens |
| Agreement → Exchange | Synchronous query: `GetCurrentTermVersion(exchangeId)` | Exchange calls Agreement read model |

### 3.3 The Golden Rule of Context Boundaries

> Movement must never ask: "Has the buyer paid?"  
> Instead, Exchange emits `MovementAuthorized`.  
> Movement does not care **why**. Only **that** it is authorized.

This keeps every context clean, independently testable, and replaceable.

---

## 4. Bounded Context: Exchange

### 4.1 Role

The Exchange context is the **orchestrator**. It manages the state machine, the capability model, party relationships, and the coordination of all other contexts. It is the source of truth for "what stage is this Exchange at and what is allowed next."

### 4.2 Aggregate: Exchange (Root)

**Aggregate Root:** `Exchange`

```
Exchange
├── exchangeId: ExchangeId              (Value Object — UUID wrapper)
├── origin: ExchangeOrigin              (Value Object — BUYI_SUPPLY | OUTSIDE_ORIGIN | PRIVATE_DEMAND)
├── market: Market                      (Value Object — e.g. "NG")
├── currency: Currency                  (Value Object — e.g. "NGN")
├── category: Category                  (Value Object — e.g. "PHONE")
├── state: ExchangeState                (Value Object — state machine enum)
├── capabilityStatuses: CapabilityMap   (Value Object — map of Capability → CapabilityStatus)
├── riskPolicyVersion: PolicyVersion    (Value Object)
├── parties: List<ExchangeParty>        (Entity — owned by aggregate)
├── termVersionRef: TermVersionId       (Value Object — reference to Agreement context)
├── itemSnapshotRef: ItemSnapshotId     (Value Object — reference to Item context)
├── protectedFundsRef: ProtectedFundsId (Value Object — reference to Shield context)
├── movementJobRef: MovementJobId       (Value Object — reference to Movement context, nullable)
├── activeProblemRef: ProblemId         (Value Object — reference to Recovery context, nullable)
├── reviewWindow: ReviewWindow          (Value Object — opens_at, closes_at, nullable)
├── reservationWindow: ReservationWindow(Value Object — starts_at, expires_at, nullable)
├── createdAt: Timestamp
└── version: Long                       (Optimistic locking counter)
```

**Exchange does NOT embed:**
- Agreement content (only holds `termVersionRef`)
- Evidence files (only holds reference via ItemSnapshot or stage events)
- Ledger entries (Settlement context owns the ledger)
- Problem details (only holds `activeProblemRef`)
- Payment details (only holds `protectedFundsRef`)

### 4.3 Entity: ExchangeParty

```
ExchangeParty
├── partyId: PartyId
├── exchangeId: ExchangeId
├── userId: UserId                      (reference to Identity context)
├── role: PartyRole                     (BUYER | SELLER | VERIFIER | CARRIER | RESELLER)
├── commitmentRefs: List<CommitmentId>  (references to Agreement context)
└── joinedAt: Timestamp
```

### 4.4 Value Objects

```
ExchangeId          — UUID, immutable after creation
ExchangeOrigin      — ENUM: BUYI_SUPPLY | OUTSIDE_ORIGIN | PRIVATE_DEMAND
Market              — String code, e.g. "NG" — validated against supported market list
Currency            — String code, e.g. "NGN" — validated against supported currency list
Category            — ENUM: PHONE | (future: LAPTOP | TABLET)
ExchangeState       — ENUM: full state list (see SRS §16)
CapabilityStatus    — ENUM: REQUIRED | RECOMMENDED | REQUESTED | UNAVAILABLE | NOT_NEEDED
CapabilityMap       — Map<Capability, CapabilityStatus> — value object, compared by all entries
ReviewWindow        — { opensAt: Timestamp, closesAt: Timestamp } — immutable after creation
ReservationWindow   — { startsAt: Timestamp, expiresAt: Timestamp } — immutable after creation
PolicyVersion       — String reference to the risk policy active at creation time
```

### 4.5 Domain Service: StateTransitionEngine

The `StateTransitionEngine` is not part of the `Exchange` aggregate — it is a domain service that the aggregate uses. This keeps the aggregate lean and the transition rules externally configurable.

```
StateTransitionEngine
  + canTransition(exchange: Exchange, targetState: ExchangeState): TransitionResult
  + transition(exchange: Exchange, command: ExchangeCommand): Exchange
  + getAvailableTransitions(exchange: Exchange, actorRole: PartyRole): List<ExchangeState>
```

Internally, the engine holds a configuration map:
```
SELLER_CONFIRMED → AWAITING_CHECK
  requires: [
    capability CHECK is REQUIRED or REQUESTED,
    exchange.protectedFundsRef is not null,
    verifier pool has available qualified verifier
  ]
```

Adding a new capability combination requires adding a new transition configuration entry — not modifying if/else branches.

### 4.6 Domain Service: CapabilityEngine

```
CapabilityEngine
  + evaluateCapabilities(
      origin: ExchangeOrigin,
      category: Category,
      market: Market,
      riskPolicyVersion: PolicyVersion,
      userRequests: List<Capability>
    ): CapabilityMap
  + canActivate(exchange: Exchange, capability: Capability): Boolean
  + isRequired(exchange: Exchange, capability: Capability): Boolean
```

The capability engine consults the active risk policy and returns the full CapabilityMap for a new Exchange. Engineers never write `if (check && payment && ...)` — they ask `capabilityEngine.isRequired(exchange, CHECK)`.

### 4.7 Exchange Aggregate Methods (Business Interface)

```kotlin
// Commands processed by the Exchange aggregate
Exchange.create(command: CreateExchange): Exchange
exchange.acceptTerms(command: AcceptTerms): Exchange
exchange.confirmPayment(event: PaymentConfirmed): Exchange       // triggered by Shield event
exchange.sellerConfirm(command: SellerConfirm): Exchange
exchange.receiveCheckResult(event: CheckResultSubmitted): Exchange
exchange.authorizeMovement(): Exchange                           // emits MovementAuthorized
exchange.receivePickupConfirmation(event: PickupConfirmed): Exchange
exchange.receiveDeliveryConfirmation(event: DeliveryConfirmed): Exchange
exchange.openProblem(command: OpenProblem): Exchange             // atomically freezes settlement
exchange.receiveResolution(event: ResolutionAgreed): Exchange
exchange.buyerAccept(command: BuyerAccept): Exchange
exchange.expireReviewWindow(): Exchange                          // scheduled job triggers this
exchange.cancel(command: CancelExchange): Exchange
exchange.receiveSettlementConfirmation(event: SettlementCompleted): Exchange
```

Each method:
1. Validates the command/event against the current state
2. Applies invariant checks
3. Produces a new immutable Exchange state (or raises a domain exception)
4. Returns a list of domain events to be published
5. Does NOT directly call other services — side effects happen via published events

---

## 5. Bounded Context: Agreement

### 5.1 Role

The Agreement context owns all terms, acceptance records, commitments, and price breakdowns. It ensures that what was agreed is permanently recorded and that changes require explicit re-acceptance.

### 5.2 Aggregate: TermVersion (Root)

```
TermVersion
├── termVersionId: TermVersionId
├── exchangeId: ExchangeId              (reference — Agreement context knows about Exchange IDs)
├── versionNumber: Int                  (monotonically increasing, starts at 1)
├── content: AgreementContent           (Value Object — immutable; full terms as structured data)
├── contentHash: ContentHash            (Value Object — SHA-256 of content; computed on creation)
├── createdAt: Timestamp
├── createdBy: ActorId
├── supersedesVersionId: TermVersionId? (null for initial version)
└── acceptances: List<Acceptance>       (Entity — owned by this aggregate)
```

**Invariants:**
- `content` and `contentHash` are immutable after the TermVersion is created
- `versionNumber` is unique per `exchangeId`
- A new TermVersion cannot be created if the previous version has no acceptances yet (prevents spamming new versions)

### 5.3 Entity: Acceptance

```
Acceptance
├── acceptanceId: AcceptanceId
├── termVersionId: TermVersionId
├── partyId: PartyId
├── acceptedAt: Timestamp
├── acceptanceMethod: AcceptanceMethod  (EXPLICIT_UI_ACTION | OTP_CONFIRMATION)
└── ipAddress: IpAddress                (Value Object — for legal record)
```

### 5.4 Entity: Commitment

```
Commitment
├── commitmentId: CommitmentId
├── exchangeId: ExchangeId
├── partyId: PartyId
├── commitmentType: CommitmentType      (FULFILL_ORDER | PROVIDE_ITEM_AS_DESCRIBED | PAY_AMOUNT | ...)
├── description: CommitmentDescription (Value Object)
├── dueAt: Timestamp?
├── status: CommitmentStatus            (ACTIVE | MET | FAILED | WAIVED)
└── failureReasonCode: FailureReasonCode? (must be specific if FAILED)
```

### 5.5 Value Objects

```
AgreementContent    — Immutable structured record of full terms; includes PriceBreakdown
ContentHash         — SHA-256 hex string; computed from AgreementContent serialization
PriceBreakdown      — { itemPrice, checkFee, deliveryFee, buyiFee, totalBuyerPays, sellerReceives, currency }
                      Invariant: totalBuyerPays == itemPrice + checkFee + deliveryFee + buyiFee
CommitmentType      — ENUM of all obligation types
CommitmentStatus    — ENUM: ACTIVE | MET | FAILED | WAIVED
FailureReasonCode   — Typed string from approved reason code list; not free text
```

### 5.6 Agreement Domain Service

```
AgreementService
  + createInitialTermVersion(exchange: Exchange, content: AgreementContent): TermVersion
  + recordAcceptance(termVersionId: TermVersionId, partyId: PartyId, method: AcceptanceMethod): Acceptance
  + createNewVersionForMaterialChange(
      exchangeId: ExchangeId,
      newContent: AgreementContent,
      reason: ChangeReason
    ): TermVersion                  // emits TermsChanged event; invalidates prior acceptances
  + hasRequiredAcceptances(termVersionId: TermVersionId, requiredParties: List<PartyId>): Boolean
  + recordCommitmentOutcome(commitmentId: CommitmentId, outcome: CommitmentStatus, reason: FailureReasonCode?): Commitment
```

---

## 6. Bounded Context: Identity

### 6.1 Role

The Identity context owns user records, KYC state, payout destination tokens, and verifier capability profiles. It does not own roles — roles are Exchange-specific and live in the Exchange context.

### 6.2 Aggregate: Person (Root)

```
Person
├── userId: UserId
├── phoneNumber: EncryptedPhoneNumber   (Value Object — E.164, encrypted at rest)
├── displayName: DisplayName            (Value Object)
├── kycState: KYCState                  (Value Object — UNVERIFIED | BASIC | ENHANCED | REJECTED)
├── payoutDestinationToken: PayoutToken (Value Object — provider-issued; never raw bank details)
├── accountStatus: AccountStatus        (Value Object — ACTIVE | SUSPENDED | RESTRICTED)
├── capabilityProfiles: List<CapabilityProfile> (Entity — verifier qualifications, etc.)
└── createdAt: Timestamp
```

### 6.3 Entity: CapabilityProfile

A person may hold qualifications separate from Exchange roles:

```
CapabilityProfile
├── profileId: ProfileId
├── userId: UserId
├── capabilityType: PersonCapabilityType (PHONE_VERIFIER | LOGISTICS_PARTNER | ...)
├── qualificationStatus: QualificationStatus (PENDING | ACTIVE | SUSPENDED | REVOKED)
├── qualifiedAt: Timestamp?
├── qualifiedBy: AdminId?
└── expiresAt: Timestamp?
```

A person can be a PHONE_VERIFIER by qualification (CapabilityProfile) in any Exchange — but this does not mean they have a permanent "Verifier" account type. (Human Capability Law.)

### 6.4 Value Objects

```
EncryptedPhoneNumber — E.164 format; encrypted at rest; never logged in plaintext
KYCState             — ENUM: UNVERIFIED | BASIC | ENHANCED | REJECTED
PayoutToken          — Opaque string from provider; references bank account in provider system
AccountStatus        — ENUM: ACTIVE | SUSPENDED | RESTRICTED
```

### 6.5 Domain Service: ConflictOfInterestChecker

```
ConflictOfInterestChecker
  + check(
      candidateVerifierId: UserId,
      exchange: Exchange
    ): ConflictCheckResult        // CLEAR | CONFLICTED(reason)
```

Internally checks:
- Candidate is not Buyer or Seller in this Exchange
- Candidate has no recorded KnownAssociation with Buyer or Seller
- Candidate has no recent direct payment from Buyer or Seller (configurable window)

---

## 7. Bounded Context: Item & Evidence

### 7.1 Role

This context owns the immutable record of what item was described, its physical identity, and all evidence assets with full provenance. Evidence is the single source of proof for all dispute and decision-making.

### 7.2 Aggregate: ItemRecord (Root)

```
ItemRecord
├── itemSnapshotId: ItemSnapshotId
├── exchangeId: ExchangeId
├── snapshot: ItemSnapshot              (Value Object — immutable)
├── identities: List<ItemIdentity>      (Entity — may have multiple: IMEI + serial)
└── evidenceAssets: List<EvidenceAsset> (Entity — append-only; never removed)
```

**Invariant:** `evidenceAssets` is append-only. No EvidenceAsset is ever removed from the aggregate.

### 7.3 Value Object: ItemSnapshot

```
ItemSnapshot
├── category: Category
├── make: String
├── model: String
├── storage: String?
├── colour: String?
├── describedCondition: ItemCondition   (NEW | LIKE_NEW | GOOD | FAIR | PARTS_ONLY)
├── describedAccessories: List<String>
├── repairsDisclosed: String?
├── listedPrice: Money                  (Value Object — amount in kobo + currency)
└── snapshotHash: ContentHash           (SHA-256 of all above fields)
```

Immutable after creation.

### 7.4 Entity: ItemIdentity

```
ItemIdentity
├── itemIdentityId: ItemIdentityId
├── itemSnapshotId: ItemSnapshotId
├── identityType: IdentityType          (IMEI | SERIAL | SEAL_ID | PACKAGE_ID)
├── identityValue: EncryptedIdentityValue
├── recordedAt: Timestamp
├── recordedBy: UserId
└── recordingStage: ExchangeState
```

IMEI recording is gated by market-level `imei_recording_enabled` configuration flag (legal requirement varies by market).

### 7.5 Entity: EvidenceAsset

```
EvidenceAsset
├── evidenceAssetId: EvidenceAssetId
├── itemSnapshotId: ItemSnapshotId
├── exchangeId: ExchangeId
├── stage: ExchangeState                (the Exchange state when evidence was captured)
├── evidenceType: EvidenceType          (VIDEO | PHOTO | OTP_CONFIRMATION | DOCUMENT | CHECKLIST_RESULT)
├── fileReference: StorageReference     (Value Object — storage key; never raw file in DB)
├── fileHash: FileHash                  (Value Object — SHA-256; verified on upload)
├── capturedAt: Timestamp               (from device — validated against server time)
├── uploadedAt: Timestamp               (server-assigned)
├── capturedBy: UserId
├── capturerRole: PartyRole
├── checklistVersionId: ChecklistVersionId? (FK if checklist-related)
├── coarseLocation: CoarseLocation?     (Value Object — lat/lng rounded to ~1km)
├── accessPolicy: EvidenceAccessPolicy  (EXCHANGE_PARTIES | ADMIN_ONLY | DISPUTE_REVIEWERS)
└── isUsedInDecision: Boolean           (set to true when referenced in ResolutionVersion or Decision)
```

**Invariant:** When `isUsedInDecision` is `true`, the EvidenceAsset is permanently locked — no actor including admin can delete or replace it.

### 7.6 Value Object: Money

```
Money
├── amount: Long                        (integer kobo — NEVER floating point)
└── currency: Currency                  (e.g. "NGN")

Money.add(other: Money): Money          — validates currencies match
Money.subtract(other: Money): Money    — validates currencies match; result must be non-negative
Money.zero(currency): Money
```

This value object is used everywhere money appears in the domain. It prevents the accidental introduction of floating-point arithmetic.

### 7.7 Domain Service: EvidenceIntegrityService

```
EvidenceIntegrityService
  + verifyHash(evidenceAssetId: EvidenceAssetId): IntegrityResult  // VALID | TAMPERED
  + recordDecisionReference(evidenceAssetId: EvidenceAssetId): Unit // locks the asset
  + validateRequiredEvidence(
      stage: ExchangeState,
      checklistVersionId: ChecklistVersionId,
      submitted: List<EvidenceAsset>
    ): ValidationResult               // COMPLETE | INCOMPLETE(missingFields)
```

---

## 8. Bounded Context: Shield (Payment Protection)

### 8.1 Role

Shield owns the entire payment lifecycle: payment intent creation, webhook handling, fund protection, refund initiation, and payout split instructions. It does not own Exchange state — it emits events that Exchange listens to.

### 8.2 Aggregate: ProtectedPayment (Root)

```
ProtectedPayment
├── protectedFundsId: ProtectedFundsId
├── exchangeId: ExchangeId
├── paymentIntent: PaymentIntent        (Entity)
├── status: FundsStatus                 (FROZEN | RELEASED | REFUNDED | PARTIALLY_REFUNDED)
├── settlementBlocked: Boolean          (set to true atomically when Problem opens)
├── frozenAt: Timestamp?
├── releasedAt: Timestamp?
└── splitInstruction: SplitInstruction? (Entity — created when settlement is triggered)
```

**Invariant:** A `ProtectedPayment` in `FROZEN` status with `settlementBlocked = true` cannot transition to `RELEASED`. This is enforced by the aggregate, not by a service layer check.

### 8.3 Entity: PaymentIntent

```
PaymentIntent
├── paymentIntentId: PaymentIntentId
├── exchangeId: ExchangeId
├── amount: Money
├── providerReference: ProviderReference? (assigned by provider)
├── idempotencyKey: IdempotencyKey      (UUID — immutable after creation)
├── status: PaymentIntentStatus         (PENDING | SUCCEEDED | FAILED | CANCELLED | EXPIRED)
├── createdAt: Timestamp
└── resolvedAt: Timestamp?
```

**Invariant:** `idempotencyKey` is immutable. The same key is used on every provider call and retry.

### 8.4 Entity: SplitInstruction

```
SplitInstruction
├── splitInstructionId: SplitInstructionId
├── exchangeId: ExchangeId
├── protectedFundsId: ProtectedFundsId
├── splits: List<PayoutSplit>           (Value Object list)
├── idempotencyKey: IdempotencyKey
├── status: SplitStatus                 (PENDING | PROCESSING | COMPLETED | FAILED)
└── createdAt: Timestamp
```

```
PayoutSplit (Value Object)
├── recipientId: UserId
├── recipientType: RecipientType        (SELLER | BUYI | EARNER)
├── amount: Money
├── payoutDestinationToken: PayoutToken
└── payoutStatus: PayoutStatus          (PENDING | COMPLETED | FAILED)
```

**Invariant:** `Sum of all split amounts == protectedPayment.amount`. Validated before instruction is created.

**Invariant:** Retries skip splits with `payoutStatus = COMPLETED`. Never retry a completed payout.

### 8.5 Domain Service: ShieldService

```
ShieldService
  + createPaymentIntent(exchangeId: ExchangeId, amount: Money): PaymentIntent
  + handleProviderWebhook(raw: RawWebhook): Unit     // validates signature, deduplicates, processes
  + freezeFunds(paymentIntentId: PaymentIntentId): ProtectedPayment
  + blockSettlement(protectedFundsId: ProtectedFundsId): Unit   // called when Problem opens
  + unblockSettlement(protectedFundsId: ProtectedFundsId): Unit // called when Problem resolves (if eligible)
  + createSplitInstruction(
      protectedFundsId: ProtectedFundsId,
      splits: List<PayoutSplit>
    ): SplitInstruction
  + initiateRefund(protectedFundsId: ProtectedFundsId, amount: Money, reason: RefundReason): Refund
```

---

## 9. Bounded Context: Check (Verification)

### 9.1 Role

The Check context owns the verifier assignment, checklist execution, evidence capture requirements, and check outcome recording. It is entirely independent of Shield and Movement — it only knows about ExchangeIds and emits events when a result is ready.

### 9.2 Aggregate: CheckJob (Root)

```
CheckJob
├── checkJobId: CheckJobId
├── exchangeId: ExchangeId
├── itemSnapshotRef: ItemSnapshotId
├── assignedVerifierId: UserId?
├── checklistVersion: ChecklistVersion  (Entity — snapshot of the version used)
├── assignment: VerifierAssignment?     (Entity)
├── findings: List<ChecklistFinding>    (Entity — recorded during check)
├── outcome: CheckOutcome?              (Value Object — PASS | MISMATCH | INCONCLUSIVE)
├── evidenceRefs: List<EvidenceAssetId>
├── status: CheckJobStatus              (PENDING_ASSIGNMENT | ASSIGNED | IN_PROGRESS | COMPLETED | CANCELLED)
└── createdAt: Timestamp
```

**Invariant:** Outcome cannot be `PASS` if any mandatory checklist item has a failing finding.  
**Invariant:** Outcome cannot be `PASS` if any required evidence type is absent.  
**Invariant:** `INCONCLUSIVE` is a terminal outcome — it cannot be changed to `PASS`.

### 9.3 Entity: VerifierAssignment

```
VerifierAssignment
├── assignmentId: AssignmentId
├── checkJobId: CheckJobId
├── verifierId: UserId
├── conflictCheckResult: ConflictCheckResult
├── assignedAt: Timestamp
├── deadline: Timestamp
└── status: AssignmentStatus            (ASSIGNED | ACCEPTED | DECLINED | COMPLETED | EXPIRED)
```

### 9.4 Entity: ChecklistFinding

```
ChecklistFinding
├── findingId: FindingId
├── checkJobId: CheckJobId
├── checklistItemId: ChecklistItemId    (references the specific item in ChecklistVersion)
├── result: FindingResult               (PASS | FAIL | NOT_APPLICABLE | NOT_CHECKED)
├── notes: String?
└── evidenceRefs: List<EvidenceAssetId>
```

### 9.5 Value Object: CheckOutcome

```
CheckOutcome
├── result: CheckResult                 (PASS | MISMATCH | INCONCLUSIVE)
├── mismatchDetails: List<MismatchDetail>? (required if MISMATCH)
└── inconclusiveReason: String?           (required if INCONCLUSIVE)
```

`INCONCLUSIVE` cannot be forced to `PASS`. This rule is in the value object constructor — not just in a service.

### 9.6 Domain Service: CheckAssignmentService

```
CheckAssignmentService
  + findEligibleVerifier(
      category: Category,
      exchange: Exchange
    ): UserId?                         // null if no verifier available → NO_VERIFIER state
  + createAssignment(checkJobId: CheckJobId, verifierId: UserId): VerifierAssignment
  + handleConflictDeclaration(assignmentId: AssignmentId): Unit  // blocks assignment; triggers reassignment
  + submitResult(
      checkJobId: CheckJobId,
      findings: List<ChecklistFinding>,
      outcome: CheckOutcome,
      evidenceRefs: List<EvidenceAssetId>
    ): CheckJob                        // validates; emits CheckResultSubmitted event
```

---

## 10. Bounded Context: Movement (FETCH)

### 10.1 Role

The Movement context owns pickup, custody tracking, delivery, and reverse movement (returns). It knows about ExchangeIds and ItemIdentityIds. It does not know about payment amounts or check outcomes — it only knows it has been authorized to move an item.

### 10.2 Aggregate: MovementJob (Root)

```
MovementJob
├── movementJobId: MovementJobId
├── exchangeId: ExchangeId
├── direction: MovementDirection        (FORWARD | RETURN)
├── carrierId: UserId
├── carrierSelectedBy: CarrierSelector  (BUYI | BUYER | SELLER | MUTUAL)
├── pickupLocation: Location            (Value Object)
├── deliveryLocation: Location          (Value Object)
├── itemIdentityRef: ItemIdentityId
├── declaredValue: Money
├── releaseAuthority: ReleaseAuthority  (Value Object)
├── currentCustodian: UserId?
├── custodyEvents: List<CustodyEvent>   (Entity — append-only)
├── status: MovementJobStatus           (PENDING | DISPATCHED | PICKED_UP | IN_TRANSIT | DELIVERED | FAILED | RETURNED)
├── movementValueLimit: Money           (from policy at job creation time — blocks if declaredValue exceeds)
└── createdAt: Timestamp
```

**Invariant:** `currentCustodian` changes only when a new `CustodyEvent` is appended with valid evidence.  
**Invariant:** `declaredValue` must be ≤ `movementValueLimit`. Job creation fails otherwise.  
**Invariant:** `CustodyEvent` of type `DELIVERY` requires `proof_method` ≠ `NONE` and requires at least one photo EvidenceAsset.

### 10.3 Entity: CustodyEvent

```
CustodyEvent
├── custodyEventId: CustodyEventId
├── movementJobId: MovementJobId
├── eventType: CustodyEventType         (PICKUP | INTERMEDIATE_HANDOFF | DELIVERY | FAILED_ATTEMPT | RETURN_PICKUP | RETURN_DELIVERY)
├── releaserId: UserId?
├── receiverId: UserId?
├── newCustodianId: UserId?
├── timestamp: Timestamp
├── proofMethod: ProofMethod            (OTP | PHOTO | SIGNATURE | COMBINED)
├── evidenceRefs: List<EvidenceAssetId>
└── itemConditionNote: String?
```

**GPS is NOT a valid proof method.** GPS coordinates are stored as supplemental metadata in the `CustodyEvent` payload but do not count as proof.

### 10.4 Value Objects

```
Location
├── addressLine1: String
├── addressLine2: String?
├── city: String
├── state: String
├── country: String                     (default "NG" for V1)
└── landmark: String?

ReleaseAuthority
├── authoriserName: String
├── authoriserPhone: MaskedPhone        (Value Object — masked number for carrier contact)
└── authCode: String?                   (optional code to verify release)

CarrierSelector     — ENUM: BUYI | BUYER | SELLER | MUTUAL
MovementDirection   — ENUM: FORWARD | RETURN
```

### 10.5 Domain Service: MovementDispatchService

```
MovementDispatchService
  + createJob(command: CreateMovementJob): MovementJob   // validates pre-dispatch checklist
  + confirmPickup(
      movementJobId: MovementJobId,
      evidence: List<EvidenceAssetId>,
      otpConfirmed: Boolean
    ): MovementJob
  + confirmDelivery(
      movementJobId: MovementJobId,
      evidence: List<EvidenceAssetId>,
      otpValue: String
    ): MovementJob                    // validates OTP; emits DeliveryConfirmed
  + createReverseJob(
      exchangeId: ExchangeId,
      resolutionVersionId: ResolutionVersionId
    ): MovementJob
```

---

## 11. Bounded Context: Recovery

### 11.1 Role

Recovery owns the Problem, resolution negotiation, dispute escalation, and admin decision. It enforces that every failure is diagnosed by a specific commitment, and that recovery paths are structured, not improvised.

### 11.2 Aggregate: Problem (Root)

```
Problem
├── problemId: ProblemId
├── exchangeId: ExchangeId
├── commitmentRef: CommitmentId         (the specific Commitment alleged to have failed)
├── problemType: ProblemType
├── description: ProblemDescription     (Value Object)
├── evidenceRefs: List<EvidenceAssetId>
├── reporterId: UserId
├── reporterRole: PartyRole
├── blocksSettlement: Boolean           (computed from problem type and policy)
├── status: ProblemStatus               (OPEN | RESOLVED | ESCALATED | DISPUTED | CLOSED)
├── resolutionVersions: List<ResolutionVersion> (Entity — negotiation history)
├── dispute: Dispute?                   (Entity — created on escalation)
└── openedAt: Timestamp
```

**Invariant:** A Problem must reference a specific `CommitmentId`. Problems without a Commitment reference are rejected.  
**Invariant:** When a Problem is opened with `blocksSettlement = true`, the Shield context must be notified to set `settlementBlocked = true` atomically in the same unit of work.

### 11.3 Entity: ResolutionVersion

```
ResolutionVersion
├── resolutionVersionId: ResolutionVersionId
├── problemId: ProblemId
├── proposedBy: UserId
├── resolutionType: ResolutionType
├── moneyEffect: MoneyEffect            (Value Object)
├── deadline: Timestamp?
├── agreedByBuyerAt: Timestamp?
├── agreedBySellerAt: Timestamp?
├── createdAt: Timestamp
└── contentHash: ContentHash            (immutable after both parties agree)
```

```
MoneyEffect (Value Object)
├── refundAmount: Money
├── releaseAmount: Money
└── currency: Currency

Invariant: refundAmount + releaseAmount == protectedPayment.amount (for full-resolution cases)
```

### 11.4 Entity: Dispute

```
Dispute
├── disputeId: DisputeId
├── problemId: ProblemId
├── evidenceReviewRequired: Boolean
├── assignedAdminId: UserId?
├── status: DisputeStatus               (OPEN | IN_REVIEW | DECIDED | APPEALED)
├── decision: DisputeDecision?          (Entity)
└── openedAt: Timestamp
```

### 11.5 Entity: DisputeDecision

```
DisputeDecision
├── decisionId: DecisionId
├── disputeId: DisputeId
├── outcome: DecisionOutcome            (FULL_REFUND_BUYER | FULL_RELEASE_SELLER | PARTIAL | NO_ACTION)
├── reasoning: DecisionReasoning        (Value Object — required text; cannot be empty)
├── moneyEffect: MoneyEffect
├── evidenceRefs: List<EvidenceAssetId> (these become is_used_in_decision = true)
├── actorId: UserId                     (admin)
└── decidedAt: Timestamp
```

---

## 12. Bounded Context: Settlement

### 12.1 Role

Settlement owns the ledger, payout execution, and reconciliation. It listens for settlement eligibility events from Exchange and executes fund distribution via the Shield context's SplitInstruction.

### 12.2 Aggregate: SettlementRecord (Root)

```
SettlementRecord
├── settlementId: SettlementId
├── exchangeId: ExchangeId
├── splitInstructionRef: SplitInstructionId
├── eligibilityBasis: EligibilityBasis  (Value Object — what condition triggered eligibility)
├── status: SettlementStatus            (PENDING | PROCESSING | COMPLETED | FAILED)
├── retryCount: Int
├── ledgerEntries: List<LedgerEntryRef> (references — LedgerEntry lives in own sub-aggregate)
└── createdAt: Timestamp
```

### 12.3 Entity: LedgerAccount

```
LedgerAccount
├── ledgerAccountId: LedgerAccountId
├── ownerId: UserId                     (BUYI platform or user)
├── accountType: AccountType            (PROTECTED_FUNDS | EARNINGS | FEES | REFUNDS)
└── currency: Currency
```

### 12.4 Entity: LedgerEntry (append-only)

```
LedgerEntry
├── ledgerEntryId: LedgerEntryId
├── ledgerAccountId: LedgerAccountId
├── exchangeId: ExchangeId
├── entryType: EntryType                (DEBIT | CREDIT)
├── amount: Money
├── referenceId: UUID                   (PaymentIntent, SplitInstruction, or Refund ID)
├── referenceType: String
└── recordedAt: Timestamp
```

**Invariant:** LedgerEntries are never deleted, updated, or reversed. Corrections create new entries with a reference to the original.

### 12.5 Value Object: EligibilityBasis

```
EligibilityBasis
├── trigger: EligibilityTrigger         (BUYER_ACCEPTED | REVIEW_WINDOW_EXPIRED | RESOLUTION_AGREED | DISPUTE_DECIDED)
├── evidenceRef: EvidenceAssetId?       (the delivery evidence that opened the review window)
└── triggeredAt: Timestamp
```

---

## 13. Bounded Context: Distribution (Share & Earn)

### 13.1 Role

Distribution owns product approvals, BUYI Link generation, attribution, commission rules, and earnings state. It listens for Exchange events to freeze attribution and release commission.

### 13.2 Aggregate: ApprovedProduct (Root)

```
ApprovedProduct
├── productApprovalId: ProductApprovalId
├── itemSnapshotRef: ItemSnapshotId
├── approvedBy: AdminId
├── approvedAt: Timestamp
├── status: ApprovalStatus              (PENDING | APPROVED | SUSPENDED | WITHDRAWN)
├── buyerPrice: Money                   (controlled; earner cannot modify)
├── commissionRule: CommissionRule       (Value Object)
└── shareLinks: List<ShareLink>         (Entity)
```

### 13.3 Entity: ShareLink

```
ShareLink
├── shareLinkId: ShareLinkId
├── productApprovalId: ProductApprovalId
├── earnerId: UserId
├── linkToken: LinkToken                (Value Object — short unique slug)
├── commissionPreviewAmount: Money      (shown before sharing; computed at generation time)
├── createdAt: Timestamp
└── expiresAt: Timestamp?
```

### 13.4 Aggregate: Attribution (Root)

```
Attribution
├── attributionId: AttributionId
├── exchangeId: ExchangeId
├── shareLinkId: ShareLinkId
├── earnerId: UserId
├── frozenAt: Timestamp                 (= payment confirmation timestamp — immutable after freeze)
├── commissionStatus: CommissionStatus  (PENDING | AVAILABLE | CANCELLED)
└── commissionAmount: Money             (calculated at freeze time; immutable after freeze)
```

**Invariant:** `frozenAt` and `commissionAmount` are immutable after the Attribution is created. No post-freeze modifications.

### 13.5 Value Object: CommissionRule

```
CommissionRule
├── commissionRuleId: CommissionRuleId
├── ruleType: CommissionRuleType        (FLAT_AMOUNT | PERCENTAGE)
├── value: Long                         (kobo if flat; basis points if percentage)
├── currency: Currency
└── conditions: List<CommissionCondition> (e.g. minimum Exchange value)
```

---

## 14. Bounded Context: Trust & Behavior

### 14.1 Role

Trust records factual behavior outcomes per user per Exchange. It does not compute a public score in V1. It provides input to the risk policy engine for capability activation decisions.

### 14.2 Aggregate: BehaviorRecord (Root)

```
BehaviorRecord
├── behaviorRecordId: BehaviorRecordId
├── userId: UserId
├── exchangeId: ExchangeId
├── partyRole: PartyRole
├── events: List<PromiseEvent>          (Entity — append-only)
└── completionQuality: CompletionQuality? (Value Object — computed on Exchange completion)
```

### 14.3 Entity: PromiseEvent

```
PromiseEvent
├── promiseEventId: PromiseEventId
├── behaviorRecordId: BehaviorRecordId
├── eventType: PromiseEventType         (PROMISE_MADE | PROMISE_KEPT | PROMISE_BROKEN | PROMISE_LATE)
├── commitmentType: CommitmentType
├── outcomeReason: OutcomeReason        (Value Object — specific reason code)
└── recordedAt: Timestamp
```

### 14.4 V1 Constraint

No public `ReliabilitySummary` or behavior score is exposed in V1. The `BehaviorRecord` is an internal record used only for risk policy and future Trust Engine views.

---

## 15. Bounded Context: Notification

### 15.1 Role

Notification listens for domain events from all other contexts and translates them into user-facing messages. It owns template management, channel selection, delivery tracking, and retry logic.

### 15.2 Aggregate: NotificationJob (Root)

```
NotificationJob
├── notificationId: NotificationId
├── exchangeId: ExchangeId?
├── recipientId: UserId
├── channel: NotificationChannel        (IN_APP | SMS | PUSH)
├── templateId: MessageTemplateId
├── templateVariables: TemplateVariables (Value Object — key/value map)
├── status: NotificationStatus          (PENDING | SENT | FAILED | DELIVERED)
├── attempts: List<NotificationAttempt> (Entity)
├── createdAt: Timestamp
└── sentAt: Timestamp?
```

### 15.3 Design Rule

Notification subscribes to domain events. It does not receive direct calls from Exchange or other aggregates. If a new notification is needed for a new event type, a new subscription is added to the Notification context — the Exchange context is not modified.

---

## 16. Commands — Full Catalog

Commands are the only way to mutate state. The frontend never directly sets state. All commands are processed by the relevant aggregate via its repository.

### Exchange Commands
| Command | Actor | Target Aggregate |
|---|---|---|
| `CreateExchange` | BUYER / SYSTEM | Exchange |
| `AcceptTerms` | BUYER | Exchange → Agreement |
| `DeclineTerms` | BUYER | Exchange |
| `SellerConfirm` | SELLER | Exchange |
| `CancelExchange` | BUYER / SELLER / ADMIN | Exchange |
| `BuyerAccept` | BUYER | Exchange |
| `OpenProblem` | BUYER / ADMIN | Exchange → Recovery |
| `ProposeResolution` | BUYER / SELLER | Recovery (Problem) |
| `AgreeResolution` | BUYER / SELLER | Recovery (Problem) |
| `EscalateToDispute` | BUYER / SELLER / ADMIN | Recovery (Problem) |

### Check Commands
| Command | Actor | Target Aggregate |
|---|---|---|
| `RequestCheck` | SYSTEM (from Exchange) | Check (CheckJob) |
| `AssignVerifier` | SYSTEM / ADMIN | Check (CheckJob) |
| `DeclareConflict` | VERIFIER | Check (CheckJob) |
| `AcceptAssignment` | VERIFIER | Check (CheckJob) |
| `SubmitCheckResult` | VERIFIER | Check (CheckJob) |

### Movement Commands
| Command | Actor | Target Aggregate |
|---|---|---|
| `CreateMovementJob` | SYSTEM (from Exchange) | Movement (MovementJob) |
| `ConfirmPickup` | CARRIER | Movement (MovementJob) |
| `UpdateTransitStatus` | CARRIER / SYSTEM | Movement (MovementJob) |
| `ConfirmDelivery` | CARRIER | Movement (MovementJob) |
| `ReportFailedAttempt` | CARRIER | Movement (MovementJob) |
| `CreateReturnJob` | SYSTEM (from Recovery) | Movement (MovementJob) |

### Shield Commands
| Command | Actor | Target Aggregate |
|---|---|---|
| `CreatePaymentIntent` | SYSTEM (from Exchange) | Shield (ProtectedPayment) |
| `HandlePaymentWebhook` | SYSTEM (provider webhook) | Shield (ProtectedPayment) |
| `BlockSettlement` | SYSTEM (from Problem open) | Shield (ProtectedPayment) |
| `UnblockSettlement` | SYSTEM (from Resolution) | Shield (ProtectedPayment) |
| `InitiateRefund` | SYSTEM / ADMIN | Shield (ProtectedPayment) |

### Settlement Commands
| Command | Actor | Target Aggregate |
|---|---|---|
| `CreateSplitInstruction` | SYSTEM (from Exchange) | Settlement |
| `ExecuteSplit` | SYSTEM | Settlement |
| `RetryFailedSplit` | SYSTEM / ADMIN | Settlement |

### Admin Commands
| Command | Actor | Notes |
|---|---|---|
| `FreezeExchange` | ADMIN | Requires authorization level + reason |
| `ReleaseSettlement` | ADMIN | Requires reason; goes through domain logic |
| `ReassignVerifier` | ADMIN | Creates new CheckJob assignment |
| `RecordDisputeDecision` | ADMIN | Requires reasoning text; locks evidence |
| `ApplyUserRestriction` | ADMIN | Creates AdminAction record |

---

## 17. Domain Events — Full Catalog

Domain events are the integration language between bounded contexts. They are immutable facts about something that happened. Every event has: `eventId`, `exchangeId` (where applicable), `occurredAt`, and event-specific payload.

### Exchange Context Events
| Event | Emitted When | Key Payload |
|---|---|---|
| `ExchangeCreated` | New Exchange created | exchangeId, origin, category, capabilityStatuses |
| `TermsAccepted` | Buyer accepts TermVersion | partyId, termVersionId, acceptedAt |
| `TermsChanged` | Material change creates new TermVersion | oldVersionId, newVersionId, changeReason |
| `ExchangeFunded` | Payment confirmed | exchangeId, amount, currency |
| `SellerConfirmed` | Seller confirms ability to fulfill | sellerId, confirmedAt |
| `CheckRequested` | Exchange enters AWAITING_CHECK | exchangeId, itemSnapshotId, checklistVersionId |
| `MovementAuthorized` | Exchange enters READY_TO_MOVE | exchangeId, itemIdentityId, pickupLocation, deliveryLocation |
| `ReviewWindowOpened` | Valid delivery evidence received | exchangeId, opensAt, closesAt |
| `BuyerAccepted` | Buyer explicitly accepts in review | exchangeId, acceptedAt |
| `ReviewWindowExpiredNoProblem` | Review window closed with no action | exchangeId, expiredAt |
| `SettlementEligibilityConfirmed` | Conditions met for settlement | exchangeId, eligibilityBasis |
| `ExchangeCancelled` | Exchange cancelled | exchangeId, cancelledBy, reason |
| `ExchangeCompleted` | Exchange reaches DONE | exchangeId, completedAt, outcome |

### Agreement Context Events
| Event | Emitted When | Key Payload |
|---|---|---|
| `CommitmentOutcomeRecorded` | A Commitment is marked MET or FAILED | commitmentId, partyId, status, failureReasonCode |

### Shield Context Events
| Event | Emitted When | Key Payload |
|---|---|---|
| `PaymentConfirmed` | Provider payment webhook verified | exchangeId, amount, paymentIntentId |
| `FundsFrozen` | ProtectedFundsRecord created | exchangeId, protectedFundsId, amount |
| `SettlementBlocked` | Problem opens with blocks_settlement=true | exchangeId, protectedFundsId, problemId |
| `SettlementUnblocked` | Problem resolved | exchangeId, protectedFundsId |
| `RefundInitiated` | Refund sent to provider | exchangeId, amount, reason |
| `RefundConfirmed` | Provider confirms refund | exchangeId, providerRefundReference |
| `PayoutCompleted` | Individual split payout confirmed | exchangeId, recipientId, amount |

### Check Context Events
| Event | Emitted When | Key Payload |
|---|---|---|
| `VerifierAssigned` | Verifier assigned with no conflict | checkJobId, verifierId, deadline |
| `NoVerifierAvailable` | No qualified verifier found | checkJobId, exchangeId |
| `ConflictDeclared` | Verifier declares conflict | checkJobId, verifierId |
| `CheckResultSubmitted` | Verifier submits outcome | checkJobId, outcome, mismatchDetails? |

### Movement Context Events
| Event | Emitted When | Key Payload |
|---|---|---|
| `MovementJobCreated` | MovementJob created | movementJobId, exchangeId, carrierId |
| `PickupConfirmed` | Carrier confirms pickup with evidence | movementJobId, newCustodianId, evidenceRefs |
| `DeliveryConfirmed` | Carrier confirms delivery with valid evidence | movementJobId, receiverId, evidenceRefs, otpValue |
| `DeliveryAttemptFailed` | Carrier reports failed attempt | movementJobId, reason, attemptCount |
| `ReturnJobCreated` | Reverse movement created | movementJobId, direction=RETURN, resolutionVersionId |

### Recovery Context Events
| Event | Emitted When | Key Payload |
|---|---|---|
| `ProblemOpened` | Problem record created | problemId, exchangeId, commitmentId, problemType, blocksSettlement |
| `ResolutionProposed` | Party proposes resolution | problemId, proposedBy, resolutionType, moneyEffect |
| `ResolutionAgreed` | Both parties agree to resolution | problemId, resolutionVersionId, moneyEffect |
| `DisputeOpened` | Problem escalated to Dispute | disputeId, problemId, exchangeId |
| `DisputeDecided` | Admin records decision | disputeId, outcome, moneyEffect, evidenceRefs |

### Settlement Context Events
| Event | Emitted When | Key Payload |
|---|---|---|
| `SettlementCompleted` | All splits confirmed | exchangeId, settlementId |
| `SettlementFailed` | Provider failure on split | exchangeId, splitInstructionId, failureReason |
| `SettlementRetried` | Retry initiated for failed split | exchangeId, splitInstructionId, retryCount |

### Distribution Context Events
| Event | Emitted When | Key Payload |
|---|---|---|
| `AttributionFrozen` | Attribution record created at payment | attributionId, exchangeId, earnerId, commissionAmount |
| `CommissionReleased` | Exchange settles; commission becomes available | attributionId, earnerId, amount |
| `CommissionCancelled` | Exchange refunded or cancelled | attributionId, earnerId |

---

## 18. Aggregate Invariants — Full Specification

This section consolidates all invariants. Engineers must enforce these in aggregate constructors and command handlers — not in service layers.

### Exchange Aggregate Invariants

| ID | Invariant | Enforcement Point |
|---|---|---|
| INV-EX-01 | `exchangeId` is immutable after creation | Constructor |
| INV-EX-02 | `exchange_origin` is immutable after creation | Constructor |
| INV-EX-03 | State transitions follow the defined state machine only | `StateTransitionEngine.transition()` |
| INV-EX-04 | A REQUIRED capability that is UNAVAILABLE blocks Exchange creation | `CapabilityEngine.evaluateCapabilities()` |
| INV-EX-05 | `optimisticLock.version` increments on every state change | Every command handler |
| INV-EX-06 | `activeProblemRef` being non-null blocks settlement transition | `exchange.receiveSettlementEligibility()` |
| INV-EX-07 | ReviewWindow is immutable once opened | `exchange.receiveDeliveryConfirmation()` |

### Agreement Aggregate Invariants

| ID | Invariant | Enforcement Point |
|---|---|---|
| INV-AG-01 | `content` and `contentHash` are immutable after TermVersion creation | Constructor |
| INV-AG-02 | `versionNumber` is unique per `exchangeId` | Repository insert |
| INV-AG-03 | `totalBuyerPays` must equal the sum of all PriceBreakdown components | `PriceBreakdown` constructor |
| INV-AG-04 | A Commitment with `status = FAILED` must have a non-null `failureReasonCode` | `Commitment.fail()` method |

### ProtectedPayment Aggregate Invariants

| ID | Invariant | Enforcement Point |
|---|---|---|
| INV-SH-01 | `idempotencyKey` is immutable after PaymentIntent creation | Constructor |
| INV-SH-02 | A FROZEN ProtectedPayment with `settlementBlocked = true` cannot transition to RELEASED | `protectedPayment.release()` method |
| INV-SH-03 | Sum of all PayoutSplit amounts must equal ProtectedFunds amount | `SplitInstruction` constructor |
| INV-SH-04 | A COMPLETED PayoutSplit is never retried | `SplitInstruction.retry()` method |

### ItemRecord Aggregate Invariants

| ID | Invariant | Enforcement Point |
|---|---|---|
| INV-IE-01 | `evidenceAssets` list is append-only | `ItemRecord.addEvidence()` method |
| INV-IE-02 | `EvidenceAsset.isUsedInDecision = true` blocks any deletion attempt | `EvidenceIntegrityService.recordDecisionReference()` |
| INV-IE-03 | `ItemSnapshot.snapshotHash` is immutable after creation | Constructor |

### CheckJob Aggregate Invariants

| ID | Invariant | Enforcement Point |
|---|---|---|
| INV-CH-01 | Outcome cannot be PASS if any mandatory checklist item has a failing finding | `CheckJob.submitResult()` method |
| INV-CH-02 | Outcome cannot be PASS if any required evidence type is absent | `CheckJob.submitResult()` method |
| INV-CH-03 | INCONCLUSIVE cannot be changed to PASS | `CheckOutcome` constructor |
| INV-CH-04 | Verifier with a declared conflict cannot submit a result | `CheckJob.submitResult()` method |

### MovementJob Aggregate Invariants

| ID | Invariant | Enforcement Point |
|---|---|---|
| INV-MV-01 | `currentCustodian` changes only when a CustodyEvent is appended with valid evidence | `MovementJob.recordHandoff()` method |
| INV-MV-02 | `declaredValue` must be ≤ `movementValueLimit` | Constructor |
| INV-MV-03 | A DELIVERY CustodyEvent requires proof_method ≠ NONE and at least one photo EvidenceAsset | `MovementJob.confirmDelivery()` method |

### Problem Aggregate Invariants

| ID | Invariant | Enforcement Point |
|---|---|---|
| INV-PR-01 | A Problem must reference a specific `CommitmentId` | Constructor |
| INV-PR-02 | Opening a Problem with `blocksSettlement = true` atomically blocks Shield settlement | `Problem.open()` — in same DB transaction |

### Attribution Aggregate Invariants

| ID | Invariant | Enforcement Point |
|---|---|---|
| INV-DI-01 | `frozenAt` and `commissionAmount` are immutable after Attribution creation | Constructor |
| INV-DI-02 | Attribution is created only at payment confirmation, not at click | Domain event handler — listens for `PaymentConfirmed` |

### LedgerEntry Invariants

| ID | Invariant | Enforcement Point |
|---|---|---|
| INV-SE-01 | LedgerEntries are never deleted, updated, or reversed | Repository — no delete or update methods |
| INV-SE-02 | Corrections create new LedgerEntries with reference to original | `SettlementRecord.correctEntry()` method |

---

## 19. Process Managers (Sagas)

Process managers coordinate long-running, multi-step flows that span multiple aggregates and bounded contexts. They are event-driven and must be durable (state persisted to database).

### 19.1 ExchangeLifecycleSaga

**Purpose:** Coordinate the full Exchange lifecycle from creation to terminal state.  
**Trigger:** `ExchangeCreated`  
**Ends on:** `ExchangeCompleted` | `ExchangeCancelled`

```
State: WAITING_FOR_PAYMENT
  Listens for: PaymentConfirmed
  On receive: Command → ExchangeContext.confirmPayment()
  Timeout: reservation_window.expiresAt → Command → CancelExchange

State: WAITING_FOR_SELLER
  Listens for: SellerConfirmed | SellerTimeout
  On SellerConfirmed: Command → ExchangeContext.proceedFromSellerConfirm()
  On timeout: Command → CancelExchange (refund initiated)

State: WAITING_FOR_CHECK
  Listens for: CheckResultSubmitted | NoVerifierAvailable
  On CheckResultSubmitted (PASS): Command → ExchangeContext.receiveCheckResult(PASS)
  On CheckResultSubmitted (MISMATCH): Command → ExchangeContext.receiveCheckResult(MISMATCH)
  On NoVerifierAvailable: Command → ExchangeContext.transitionToNoVerifier()

State: WAITING_FOR_MOVEMENT
  Listens for: PickupConfirmed | DeliveryConfirmed
  On PickupConfirmed: Command → ExchangeContext.receivePickup()
  On DeliveryConfirmed: Command → ExchangeContext.receiveDelivery() → opens ReviewWindow

State: WAITING_FOR_REVIEW
  Listens for: BuyerAccepted | ReviewWindowExpiry | ProblemOpened
  On BuyerAccepted: Command → ExchangeContext.confirmSettlementEligibility()
  On ReviewWindowExpiry: Check for open Problems → if none → Command → ExchangeContext.confirmSettlementEligibility()
  On ProblemOpened: Transition to WAITING_FOR_RECOVERY

State: WAITING_FOR_RECOVERY
  Listens for: ResolutionAgreed | DisputeDecided
  On ResolutionAgreed: Execute money effect → possibly WAITING_FOR_RETURN or SETTLING
  On DisputeDecided: Execute decision money effect → SETTLING or DONE

State: SETTLING
  Listens for: SettlementCompleted | SettlementFailed
  On SettlementCompleted: Command → ExchangeContext.complete()
  On SettlementFailed: Alert admin → retry queue
```

### 19.2 RefundSaga

**Purpose:** Handle the complete refund lifecycle from initiation to provider confirmation.  
**Trigger:** `RefundInitiated` (from Shield context)  
**Ends on:** `RefundConfirmed` | `RefundFailed` (max retries exceeded)

```
State: REFUND_SENT_TO_PROVIDER
  Listens for: RefundConfirmed (provider webhook)
  Timeout: 72 hours → alert admin; do not show "Refunded" to user until confirmed

State: REFUND_CONFIRMED
  Command → Update ProtectedFundsRecord status
  Command → Notify buyer: "Refund confirmed by provider"
  (Never: notify buyer on INITIATED — only on CONFIRMED)
```

### 19.3 ReturnSaga

**Purpose:** Coordinate reverse custody for authorised returns.  
**Trigger:** `ResolutionAgreed` with `resolutionType = RETURN_AND_REFUND`  
**Ends on:** `ReturnDeliveryConfirmed` → then triggers RefundSaga

```
State: AWAITING_RETURN_PICKUP
  Command → CreateReturnJob (Movement context)
  Listens for: ReturnPickupConfirmed
  Timeout: configurable → alert admin

State: RETURN_IN_TRANSIT
  Listens for: ReturnDeliveryConfirmed

State: RETURN_DELIVERED
  Evidence: Condition on return recorded
  Command → InitiateRefund (Shield context)
  Handoff to RefundSaga
```

### 19.4 SettlementEligibilitySaga

**Purpose:** Monitor review window and evaluate settlement eligibility at the right moment.  
**Trigger:** `ReviewWindowOpened`

```
Scheduled job fires at review_window.closes_at:
  Check: Any open Problem with blocks_settlement = true?
    YES → Do nothing; settlement blocked; wait for Recovery
    NO  → Emit ReviewWindowExpiredNoProblem
         → Command → ExchangeContext.confirmSettlementEligibility()
         → Command → SettlementContext.createSplitInstruction()
```

---

## 20. Consistency Boundaries & Transaction Rules

### 20.1 What Must Be Atomic (Same Database Transaction)

| Operation | Why atomic |
|---|---|
| Problem.open() + Shield.blockSettlement() | Problem at 23h59m must freeze before any settlement check runs |
| Payment success + Inventory reservation check | Prevent double-sale of unique item |
| TermVersion creation + old Acceptance invalidation | Changed terms must atomically invalidate prior acceptance |
| CustodyEvent append + MovementJob.currentCustodian update | Custody state must always reflect the latest evidenced handoff |
| SplitInstruction creation + sum validation | No split instruction leaves the system if amounts don't add up |
| EvidenceAsset.isUsedInDecision = true + DisputeDecision.save() | Evidence lock and decision creation are inseparable |

### 20.2 What Is Eventually Consistent (Across Contexts via Events)

| Operation | Acceptable lag |
|---|---|
| Exchange state change → Notification sent | Seconds acceptable; not instant |
| Exchange completed → Attribution.commissionStatus = AVAILABLE | Seconds acceptable |
| CommitmentOutcome recorded → Trust BehaviorRecord updated | Seconds to minutes acceptable |
| Settlement completed → Ledger entries | Must be consistent within same transaction inside Settlement context |

### 20.3 Optimistic Locking

The `exchange` table carries a `version` column (long integer). Every command handler:
1. Reads the Exchange and notes its current `version`
2. Applies the command
3. Writes the updated Exchange with `WHERE version = :readVersion`
4. If 0 rows updated → version conflict → return HTTP 409 Conflict
5. Client retries from step 1

This prevents lost updates in concurrent command scenarios (e.g. two people attempting to cancel the same Exchange simultaneously).

---

## 21. Repository Contracts

Repositories are the only way to persist and retrieve aggregates. No aggregate reaches into another's repository.

```kotlin
interface ExchangeRepository {
    fun save(exchange: Exchange): Exchange
    fun findById(id: ExchangeId): Exchange?
    fun findByPartyUserId(userId: UserId, page: Page): List<Exchange>
    fun findByState(state: ExchangeState, page: Page): List<Exchange>
    // No deleteById — Exchanges are never deleted
}

interface TermVersionRepository {
    fun save(termVersion: TermVersion): TermVersion
    fun findCurrentVersion(exchangeId: ExchangeId): TermVersion?
    fun findAllVersions(exchangeId: ExchangeId): List<TermVersion>
    // No deleteById — TermVersions are never deleted
}

interface ItemRecordRepository {
    fun save(itemRecord: ItemRecord): ItemRecord
    fun findByExchangeId(exchangeId: ExchangeId): ItemRecord?
    fun addEvidence(itemSnapshotId: ItemSnapshotId, evidence: EvidenceAsset): EvidenceAsset
    // No deleteEvidence — EvidenceAssets are never deleted
}

interface ProtectedPaymentRepository {
    fun save(protectedPayment: ProtectedPayment): ProtectedPayment
    fun findByExchangeId(exchangeId: ExchangeId): ProtectedPayment?
    fun findByPaymentIntentIdempotencyKey(key: IdempotencyKey): ProtectedPayment?
}

interface MovementJobRepository {
    fun save(movementJob: MovementJob): MovementJob
    fun findByExchangeId(exchangeId: ExchangeId): MovementJob?
    fun appendCustodyEvent(movementJobId: MovementJobId, event: CustodyEvent): CustodyEvent
}

interface ProblemRepository {
    fun save(problem: Problem): Problem
    fun findActiveByExchangeId(exchangeId: ExchangeId): Problem?
    fun findAll(exchangeId: ExchangeId): List<Problem>
}

interface LedgerRepository {
    fun appendEntry(entry: LedgerEntry): LedgerEntry
    fun findByExchangeId(exchangeId: ExchangeId): List<LedgerEntry>
    // No deleteEntry, no updateEntry — append-only
}

interface ExchangeEventRepository {
    fun append(event: ExchangeEvent): ExchangeEvent
    fun findByExchangeId(exchangeId: ExchangeId): List<ExchangeEvent>  // ordered by sequence_number
    // No deleteEvent — Events are never deleted
}
```

---

## 22. Anti-Corruption Layers

Anti-corruption layers (ACLs) protect domain model purity when integrating with external systems that use different concepts and vocabularies.

### 22.1 PaymentProviderACL

Translates between BUYI's domain language and the payment provider's API language.

```
PaymentProviderACL
  + createPaymentIntent(intent: PaymentIntent): ProviderPaymentReference
  + parseWebhookEvent(raw: RawWebhook): DomainPaymentEvent  // translates provider event → BUYI domain event
  + initiateRefund(refund: Refund): ProviderRefundReference
  + executePayout(split: PayoutSplit): ProviderPayoutReference
```

The domain never sees `provider_charge_id`, `provider_customer_id`, or provider-specific status codes. Everything is translated by the ACL before entering the domain.

### 22.2 LogisticsPartnerACL

```
LogisticsPartnerACL
  + createJob(job: MovementJob): PartnerJobReference
  + getJobStatus(ref: PartnerJobReference): MovementJobStatus
  + confirmPickup(ref: PartnerJobReference, evidence: HandoffEvidence): Unit
  + confirmDelivery(ref: PartnerJobReference, evidence: HandoffEvidence): Unit
```

When the V1 logistics partner is replaced, only the ACL implementation changes. The `MovementJob` aggregate is unaffected.

### 22.3 KYCProviderACL

```
KYCProviderACL
  + initiateVerification(userId: UserId, level: KYCLevel): ProviderVerificationRef
  + parseVerificationResult(raw: RawCallback): KYCStateUpdate  // translates → BUYI KYCState event
```

### 22.4 SMSProviderACL

```
SMSProviderACL
  + send(phone: MaskedPhone, message: String, idempotencyKey: IdempotencyKey): SMSReference
  + parseDeliveryReceipt(raw: RawReceipt): NotificationDeliveryStatus
```

---

## 23. Architecture Decision Records (ADRs)

### ADR-001: Exchange Is the Source of Truth
**Date:** 2026-08-31  
**Status:** Accepted  
**Context:** Multiple domain areas (payment, logistics, verification) each have their own internal records. Without a clear source of truth, state can diverge.  
**Decision:** The `Exchange` aggregate is the authoritative source of truth for the lifecycle, parties, capability statuses, and terminal state of any BUYI job. Payment records, movement records, and check records are views of an Exchange — not competing sources of truth.  
**Consequences:** All state changes in other contexts must ultimately be reflected in Exchange state transitions via domain events. The Exchange event log is the permanent, authoritative record.

---

### ADR-002: Modular Monolith for V1
**Date:** 2026-08-31  
**Status:** Accepted  
**Context:** The system spans many concerns: payment, logistics, verification, agreement, recovery, distribution. Splitting into microservices immediately would introduce distributed systems complexity before the domain model is proven.  
**Decision:** V1 is a modular monolith. All bounded contexts are modules in a single deployment. They communicate through in-process domain events and well-defined module interfaces. No cross-module direct database access.  
**Consequences:** Faster V1 development. Clean module boundaries preserved for later service extraction. Service extraction requires no domain model changes — only deployment changes.

---

### ADR-003: Append-Only Event Log from Day One
**Date:** 2026-08-31  
**Status:** Accepted  
**Context:** BUYI requires complete audit trails for disputes, evidence provenance, and settlement verification. Relational UPDATE-based state management loses history.  
**Decision:** Every consequential state transition appends to `exchange_events`. The relational tables hold current state for operational reads. The event log is the audit trail.  
**Consequences:** Complete auditability from day one. Foundation for future migration to full event sourcing. No historical state is ever lost.

---

### ADR-004: Hybrid Persistence (Relational + Event Log) for V1
**Date:** 2026-08-31  
**Status:** Accepted  
**Context:** Full event sourcing (state rebuilt entirely from events) adds significant complexity for reads. V1 must ship quickly while preserving the option to migrate.  
**Decision:** PostgreSQL relational tables hold current aggregate state for fast reads. Append-only `exchange_events` table holds complete history. Phase 2 may evolve to event sourcing as the primary model.  
**Consequences:** Simpler reads in V1. Event log proves the history. Migration path to full event sourcing is preserved.

---

### ADR-005: Money as Integer Kobo
**Date:** 2026-08-31  
**Status:** Accepted (Non-negotiable)  
**Context:** Floating-point arithmetic for financial calculations produces rounding errors that accumulate and cause financial discrepancies.  
**Decision:** All money values are stored and computed as `int64` (long) in the smallest currency unit (kobo = 1/100 Naira). No floating-point in any financial calculation path. The `Money` value object enforces this.  
**Consequences:** No rounding errors. All arithmetic is exact. Division operations (e.g. percentage commission) must be implemented with explicit rounding rules (always round down for payer, round up for recipient, document the rule).

---

### ADR-006: Delivery OTP Is Receipt Evidence, Not Buyer Acceptance
**Date:** 2026-08-31  
**Status:** Accepted (Non-negotiable — overrides earlier drafts)  
**Context:** Earlier BUYI designs treated delivery OTP as triggering immediate settlement. This is incorrect. OTP proves the buyer received a package; it does not prove the buyer accepts the item's condition.  
**Decision:** Delivery OTP creates a `CustodyEvent` of type `DELIVERY` and opens the 24-hour review window. Settlement eligibility follows only after the review window closes without a blocking Problem, or after explicit buyer acceptance.  
**Consequences:** Buyer has protected time to inspect. The event log distinguishes `DeliveryConfirmed` from `BuyerAccepted`. No fabricated buyer-acceptance event is created from OTP alone.

---

### ADR-007: Carrier Selection Recorded by carrier_selected_by
**Date:** 2026-08-31  
**Status:** Accepted  
**Context:** Who selected the carrier determines risk allocation and obligations for failed deliveries and movement exceptions.  
**Decision:** Every `MovementJob` records `carrier_selected_by`: BUYI | BUYER | SELLER | MUTUAL. Risk allocation and failed-attempt cost recovery follow this value, not a hardcoded policy.  
**Consequences:** BUYI can have different obligations depending on whether it selected the carrier vs the seller chose their own carrier. Policy is applied per value, not hardcoded.

---

### ADR-008: No God Aggregate
**Date:** 2026-08-31  
**Status:** Accepted  
**Context:** There is a risk that engineers add all Exchange-related concepts into the Exchange aggregate, making it unwieldy.  
**Decision:** Exchange is an orchestrator, not a container. It holds references (IDs) to other aggregates: `termVersionRef`, `protectedFundsRef`, `movementJobRef`, `activeProblemRef`. It does not embed the content of these aggregates. Each aggregate owns its own consistency boundary.  
**Consequences:** Exchange remains small and focused. Aggregates are independently testable. The Exchange aggregate does not need a 200-method interface.

---

### ADR-009: Roles Are Exchange-Specific, Not Account Types
**Date:** 2026-08-31  
**Status:** Accepted  
**Context:** Early designs implied permanent Buyer/Seller/Reseller account types.  
**Decision:** Roles are `ExchangeParty.role` values, scoped to a specific Exchange. The `Person` aggregate has no role field. The same user is BUYER in one Exchange and SELLER in another. Capability profiles (Verifier qualification) are separate from roles.  
**Consequences:** No role-based UI lock-in. Users can participate in any Exchange role they have the capability for. Verifier qualification is managed separately via `CapabilityProfile`.

---

*End of Volume III — Domain-Driven Design Blueprint*  
*Next: Volume IV — System Architecture Document*  
*BUYIspace Technologies Ltd. | Internal | Confidential*
