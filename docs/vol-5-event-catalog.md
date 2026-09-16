# BUYI — Event Catalog
## Volume V of the BUYI Engineering Documentation Suite
**Version:** 1.0 — Final Decision Freeze Baseline  
**Date:** 31 August 2026  
**Prepared by:** BUYIspace Technologies Ltd. — Engineering  
**Classification:** Internal — Confidential  
**Authority:** Derived from the BUYI Programmer Master Build Document (Final Decision Freeze, 31 August 2026) and Volume III DDD Blueprint. This document is the authoritative reference for all domain event schemas, versioning, producers, consumers, and idempotency rules.

---

## Table of Contents

1. [Event Catalog Purpose & Rules](#1-event-catalog-purpose--rules)
2. [Event Envelope — Standard Schema](#2-event-envelope--standard-schema)
3. [Versioning Strategy](#3-versioning-strategy)
4. [Idempotency Rules](#4-idempotency-rules)
5. [Exchange Context Events](#5-exchange-context-events)
6. [Agreement Context Events](#6-agreement-context-events)
7. [Shield Context Events](#7-shield-context-events)
8. [Check Context Events](#8-check-context-events)
9. [Movement Context Events](#9-movement-context-events)
10. [Recovery Context Events](#10-recovery-context-events)
11. [Settlement Context Events](#11-settlement-context-events)
12. [Distribution Context Events](#12-distribution-context-events)
13. [Identity Context Events](#13-identity-context-events)
14. [Trust & Behavior Context Events](#14-trust--behavior-context-events)
15. [Admin & System Events](#15-admin--system-events)
16. [Event Consumer Matrix](#16-event-consumer-matrix)
17. [Event Flow Diagrams — Key Scenarios](#17-event-flow-diagrams--key-scenarios)
18. [Failure & Compensation Events](#18-failure--compensation-events)
19. [Event Log Integrity Rules](#19-event-log-integrity-rules)

---

## 1. Event Catalog Purpose & Rules

### 1.1 What This Catalog Is

The Event Catalog is the contract between bounded contexts. Every domain event that crosses a module boundary — or that is stored in the `exchange_event` append-only log — is defined here with its full schema, producer, consumers, versioning history, and idempotency behaviour.

This catalog is a **living document**. Every new event requires an entry here before it is implemented. Existing event schemas are versioned — they are never silently changed.

### 1.2 Governing Rules

| Rule | Detail |
|---|---|
| **Events are immutable facts** | An event describes something that happened. It is never updated or deleted. |
| **Events are named in past tense** | `ExchangeCreated`, not `CreateExchange`. Commands are present tense; events are past tense. |
| **Schema changes are versioned** | A breaking change to an event schema creates a new version (`v2`). The old version is preserved until all consumers have migrated. |
| **Every event has an idempotency strategy** | Consumers must handle duplicate delivery. Every event entry in this catalog documents the consumer idempotency rule. |
| **Producer is single** | Each event has exactly one producer (the bounded context that owns the aggregate that emitted it). Multiple consumers are allowed. |
| **No cross-context command embedding** | An event payload must not embed a command directed at another context. Events are facts; reactions are the consumer's responsibility. |
| **Sensitive data is excluded from payloads** | Event payloads must not contain: raw phone numbers, IMEI values (in transit — only IDs), payment card data, JWT tokens, raw bank details. Use IDs and reference keys. |

---

## 2. Event Envelope — Standard Schema

Every domain event, regardless of type, is wrapped in this standard envelope:

```typescript
interface DomainEventEnvelope {
  // Routing & Identity
  eventId: string;            // UUID — globally unique; used for deduplication
  eventType: string;          // e.g. "exchange.ExchangeCreated" — namespaced
  eventVersion: string;       // e.g. "v1" — schema version
  schemaVersion: number;      // integer; increments on schema changes within a version

  // Context
  exchangeId: string | null;  // present for all Exchange-related events; null for user events
  producerContext: string;    // bounded context name: "exchange" | "shield" | "check" | ...
  correlationId: string;      // UUID — traces a chain of causally related events
  causationId: string;        // eventId of the event or command that caused this event

  // Timing
  occurredAt: string;         // ISO 8601 UTC — when the business event occurred
  publishedAt: string;        // ISO 8601 UTC — when the event was published to the bus

  // Payload
  payload: Record<string, unknown>; // event-specific; schema defined per event type below

  // Metadata
  metadata: {
    actorId: string | null;   // userId or "SYSTEM" or "ADMIN:userId"
    actorRole: string | null; // BUYER | SELLER | VERIFIER | CARRIER | SYSTEM | ADMIN
    market: string;           // "NG" for V1
    environment: string;      // "production" | "staging" | "local"
  };
}
```

All events stored in `exchange_event` table use this envelope structure in the `payload` JSONB column, with `event_type`, `actor_id`, `actor_role`, and `created_at` promoted to dedicated columns for query performance.

---

## 3. Versioning Strategy

### 3.1 Backward-Compatible Changes (No Version Bump)

The following changes are safe to make without bumping `eventVersion`:
- Adding a new **optional** field to the payload
- Adding a new enum value to an existing field (consumers must handle unknown values gracefully)
- Changing a field description (not its name, type, or semantics)

### 3.2 Breaking Changes (Require New Version)

The following changes require a new `eventVersion` (e.g. `v1` → `v2`):
- Renaming a field
- Removing a field
- Changing a field's type
- Changing a field's semantics (same name, different meaning)
- Adding a new **required** field

### 3.3 Migration Protocol

When a breaking change creates `v2`:
1. Publish both `v1` and `v2` events simultaneously during transition period
2. Consumers migrate to `v2` at their own pace
3. `v1` publishing deprecated after all consumers confirm migration
4. `v1` event type retired (no longer published) after deprecation window

### 3.4 Unknown Event Handling

Every event consumer must implement a **default handler for unknown event types and versions**:
- Log the unknown event with full envelope
- Do not throw an unhandled exception
- Do not attempt to process the payload
- Alert if unknown event volume exceeds threshold (may indicate producer/consumer version mismatch)

---

## 4. Idempotency Rules

### 4.1 Why Idempotency Is Required

In V1's in-process event bus, duplicate delivery is unlikely but possible (retry on processing failure). In Phase 2's outbox pattern, at-least-once delivery makes duplicates expected. Every consumer must handle them safely.

### 4.2 Standard Consumer Idempotency Pattern

```typescript
// Standard pattern for all event consumers
async function handleEvent(envelope: DomainEventEnvelope): Promise<void> {
  // 1. Check if already processed
  const alreadyProcessed = await processedEventRepo.exists(envelope.eventId);
  if (alreadyProcessed) {
    log.info('Duplicate event ignored', { eventId: envelope.eventId });
    return; // Safe no-op
  }

  // 2. Process the event
  await doProcessing(envelope);

  // 3. Mark as processed (in same DB transaction as processing)
  await processedEventRepo.markProcessed(envelope.eventId);
}
```

The `processed_event` table:
```sql
processed_event (
  event_id      UUID PRIMARY KEY,
  event_type    VARCHAR(128) NOT NULL,
  consumer      VARCHAR(64)  NOT NULL,  -- which consumer processed this
  processed_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
)
```

### 4.3 Idempotency Notes Per Event

Each event entry below includes a **Consumer Idempotency** note describing the specific safe no-op behaviour for duplicate delivery.

---

## 5. Exchange Context Events

Producer: `exchange` module

---

### EVT-EX-001: ExchangeCreated

**Event type:** `exchange.ExchangeCreated`  
**Version:** v1  
**Emitted when:** A new Exchange record is successfully created.  
**Producer:** Exchange aggregate, `CreateExchange` command handler

```typescript
payload: {
  exchangeId: string;           // UUID
  origin: ExchangeOrigin;       // "BUYI_SUPPLY" | "OUTSIDE_ORIGIN" | "PRIVATE_DEMAND"
  category: string;             // "PHONE"
  market: string;               // "NG"
  currency: string;             // "NGN"
  capabilityStatuses: {
    CHECK: CapabilityStatus;
    SHIELD: CapabilityStatus;
    FETCH: CapabilityStatus;
  };
  riskPolicyVersion: string;
  initiatorPartyId: string;     // UUID of the party who created the Exchange
  initiatorRole: string;        // "BUYER" typically
  itemSnapshotId: string;       // UUID
}
```

**Consumers:**
- `notification` — send confirmation to initiator
- `trust` — open BehaviorRecord for this Exchange

**Consumer Idempotency:** If `ExchangeCreated` is delivered twice with the same `exchangeId`, the notification consumer checks whether a notification for this event was already sent (via `processed_event`). The trust consumer checks whether a BehaviorRecord for this `exchangeId` already exists before creating one.

---

### EVT-EX-002: TermsAccepted

**Event type:** `exchange.TermsAccepted`  
**Version:** v1  
**Emitted when:** A party explicitly accepts the current TermVersion.

```typescript
payload: {
  exchangeId: string;
  partyId: string;
  termVersionId: string;
  acceptedAt: string;           // ISO 8601 UTC
  acceptanceMethod: string;     // "EXPLICIT_UI_ACTION" | "OTP_CONFIRMATION"
  newExchangeState: string;     // state after transition
}
```

**Consumers:**
- `notification` — notify counterparty that terms were accepted

**Consumer Idempotency:** Check `processed_event` before sending notification.

---

### EVT-EX-003: TermsChanged

**Event type:** `exchange.TermsChanged`  
**Version:** v1  
**Emitted when:** A material change creates a new TermVersion and invalidates prior acceptances.

```typescript
payload: {
  exchangeId: string;
  previousTermVersionId: string;
  newTermVersionId: string;
  changeReason: string;         // e.g. "MISMATCH_PRICE_ADJUSTMENT"
  invalidatedPartyIds: string[];// parties whose acceptances are now invalid
  changedAt: string;
}
```

**Consumers:**
- `notification` — notify invalidated parties that new terms require acceptance
- `exchange` (self) — transition to state requiring re-acceptance

**Consumer Idempotency:** Notification checks `processed_event`. Exchange self-listener: if already in the state requiring re-acceptance, is a no-op.

---

### EVT-EX-004: ExchangeFunded

**Event type:** `exchange.ExchangeFunded`  
**Version:** v1  
**Emitted when:** Exchange transitions to `FUNDED` after payment confirmation.

```typescript
payload: {
  exchangeId: string;
  protectedFundsId: string;
  amount: number;               // integer kobo
  currency: string;             // "NGN"
  fundedAt: string;
}
```

**Consumers:**
- `notification` — notify seller: "A buyer has paid. Confirm your ability to fulfill."
- `distribution` — trigger attribution freeze check

**Consumer Idempotency:** Notification: check `processed_event`. Distribution: `Attribution` is created with `UNIQUE` constraint on `exchangeId`; duplicate insert is a no-op.

---

### EVT-EX-005: SellerConfirmed

**Event type:** `exchange.SellerConfirmed`  
**Version:** v1  
**Emitted when:** Seller confirms ability to fulfill.

```typescript
payload: {
  exchangeId: string;
  sellerPartyId: string;
  confirmedAt: string;
  newExchangeState: string;
}
```

**Consumers:**
- `check` — if CHECK capability required: begin verifier assignment process
- `notification` — notify buyer: "Seller confirmed. [Next step based on capability]."

**Consumer Idempotency:** Check module: if CheckJob already exists for this `exchangeId`, skip creation.

---

### EVT-EX-006: CheckRequested

**Event type:** `exchange.CheckRequested`  
**Version:** v1  
**Emitted when:** Exchange enters `AWAITING_CHECK` state.

```typescript
payload: {
  exchangeId: string;
  itemSnapshotId: string;
  itemIdentityId: string;
  checklistVersionId: string;
  requestedAt: string;
}
```

**Consumers:**
- `check` — create CheckJob and begin verifier assignment

**Consumer Idempotency:** CheckJob creation is idempotent on `exchangeId` — second call returns existing job.

---

### EVT-EX-007: MovementAuthorized

**Event type:** `exchange.MovementAuthorized`  
**Version:** v1  
**Emitted when:** Exchange enters `READY_TO_MOVE` state; conditions for movement are satisfied.

```typescript
payload: {
  exchangeId: string;
  itemIdentityId: string;
  pickupLocation: {
    addressLine1: string;
    addressLine2: string | null;
    city: string;
    state: string;
    country: string;
    landmark: string | null;
  };
  deliveryLocation: {
    addressLine1: string;
    city: string;
    state: string;
    country: string;
  };
  declaredValue: number;        // integer kobo
  releaseAuthorityPartyId: string;
  authorizedAt: string;
}
```

**Consumers:**
- `movement` — create MovementJob and prepare for dispatch
- `notification` — notify logistics partner (if integrated) or ops queue

**Consumer Idempotency:** MovementJob creation is idempotent on `exchangeId`.

---

### EVT-EX-008: ReviewWindowOpened

**Event type:** `exchange.ReviewWindowOpened`  
**Version:** v1  
**Emitted when:** Valid delivery evidence received; 24-hour review window opened.

```typescript
payload: {
  exchangeId: string;
  reviewWindowOpensAt: string;  // ISO 8601 UTC
  reviewWindowClosesAt: string; // ISO 8601 UTC (opens + 24h)
  deliveryEvidenceRef: string;  // evidenceAssetId of the delivery confirmation
  openedAt: string;
}
```

**Consumers:**
- `notification` — notify buyer: "Item delivered. Review window open until [closesAt]."
- `sagas` — SettlementEligibilitySaga schedules review window expiry check

**Consumer Idempotency:** Notification: `processed_event`. Saga: if already scheduled for this `exchangeId`, skip.

---

### EVT-EX-009: BuyerAccepted

**Event type:** `exchange.BuyerAccepted`  
**Version:** v1  
**Emitted when:** Buyer explicitly accepts the item within the review window. This is a distinct event from review window expiry.

```typescript
payload: {
  exchangeId: string;
  buyerPartyId: string;
  acceptedAt: string;
}
```

**Consumers:**
- `settlement` — begin settlement eligibility confirmation
- `notification` — notify seller: "Buyer accepted the item."
- `trust` — record PROMISE_KEPT for buyer (fulfilled review obligation)

**Consumer Idempotency:** Settlement: idempotent on `exchangeId`. Trust: `processed_event`.

---

### EVT-EX-010: ReviewWindowExpiredNoProblem

**Event type:** `exchange.ReviewWindowExpiredNoProblem`  
**Version:** v1  
**Emitted when:** Review window closes with no open blocking Problem. This is NOT a buyer acceptance event. It is a factual record of buyer silence.

```typescript
payload: {
  exchangeId: string;
  expiredAt: string;            // the exact moment the window closed
  noOpenProblems: boolean;      // always true when this event is emitted
}
```

**⚠️ Critical rule:** This event is NEVER named `BuyerConfirmed`, `BuyerAccepted`, or any synonym implying active buyer acceptance. Buyer silence is buyer silence.

**Consumers:**
- `settlement` — begin settlement eligibility confirmation
- `notification` — notify seller: "Review window closed with no issues."
- `trust` — record factual outcome (no buyer action taken)

**Consumer Idempotency:** All consumers check `processed_event`.

---

### EVT-EX-011: SettlementEligibilityConfirmed

**Event type:** `exchange.SettlementEligibilityConfirmed`  
**Version:** v1  
**Emitted when:** Exchange confirms all conditions for settlement are met (no blocking Problem, required evidence present, review resolved).

```typescript
payload: {
  exchangeId: string;
  protectedFundsId: string;
  eligibilityBasis: {
    trigger: string;            // "BUYER_ACCEPTED" | "REVIEW_WINDOW_EXPIRED" | "RESOLUTION_AGREED" | "DISPUTE_DECIDED"
    evidenceRef: string | null;
    triggeredAt: string;
  };
  confirmedAt: string;
}
```

**Consumers:**
- `settlement` — create SplitInstruction and execute settlement
- `distribution` — Commission release check

**Consumer Idempotency:** Settlement: idempotent on `exchangeId + protectedFundsId`. Only one SplitInstruction per Exchange.

---

### EVT-EX-012: ExchangeCancelled

**Event type:** `exchange.ExchangeCancelled`  
**Version:** v1  
**Emitted when:** Exchange transitions to `CANCELLED` terminal state.

```typescript
payload: {
  exchangeId: string;
  cancelledBy: string;          // partyId or "SYSTEM" (timeout) or "ADMIN:adminId"
  cancelledByRole: string;
  reason: string;               // reason code
  refundRequired: boolean;
  cancelledAt: string;
}
```

**Consumers:**
- `shield` — initiate refund if `refundRequired = true`
- `distribution` — cancel any pending attribution
- `notification` — notify both parties
- `trust` — record attributable failure if seller-caused

**Consumer Idempotency:** Each consumer checks `processed_event`.

---

### EVT-EX-013: ExchangeCompleted

**Event type:** `exchange.ExchangeCompleted`  
**Version:** v1  
**Emitted when:** Exchange reaches `DONE` terminal state.

```typescript
payload: {
  exchangeId: string;
  outcome: string;              // "SETTLED" | "REFUNDED" | "PARTIAL"
  completedAt: string;
}
```

**Consumers:**
- `trust` — record final completion quality for all parties
- `notification` — notify both parties: summary of outcome
- `distribution` — trigger commission release if outcome is SETTLED

**Consumer Idempotency:** All consumers check `processed_event`.

---

## 6. Agreement Context Events

Producer: `agreement` module

---

### EVT-AG-001: CommitmentOutcomeRecorded

**Event type:** `agreement.CommitmentOutcomeRecorded`  
**Version:** v1  
**Emitted when:** A Commitment is marked MET or FAILED.

```typescript
payload: {
  exchangeId: string;
  commitmentId: string;
  partyId: string;
  commitmentType: string;
  outcome: string;              // "MET" | "FAILED" | "WAIVED"
  failureReasonCode: string | null;
  recordedAt: string;
}
```

**Consumers:**
- `trust` — record PromiseEvent (PROMISE_KEPT or PROMISE_BROKEN) for the party

**Consumer Idempotency:** Check `processed_event` before recording PromiseEvent.

---

### EVT-AG-002: PriceBreakdownFinalized

**Event type:** `agreement.PriceBreakdownFinalized`  
**Version:** v1  
**Emitted when:** PriceBreakdown is validated and stored for an Exchange.

```typescript
payload: {
  exchangeId: string;
  itemPrice: number;            // kobo
  checkFee: number;             // kobo
  deliveryFee: number;          // kobo
  buyiFee: number;              // kobo
  totalBuyerPays: number;       // kobo — must equal sum of above
  sellerReceives: number;       // kobo
  currency: string;
  finalizedAt: string;
}
```

**Consumers:**
- `shield` — used to validate PaymentIntent amount

**Consumer Idempotency:** Shield: validate only if PaymentIntent not yet created for this Exchange.

---

## 7. Shield Context Events

Producer: `shield` module

---

### EVT-SH-001: PaymentIntentCreated

**Event type:** `shield.PaymentIntentCreated`  
**Version:** v1  
**Emitted when:** A PaymentIntent is created for an Exchange.

```typescript
payload: {
  exchangeId: string;
  paymentIntentId: string;
  amount: number;               // kobo
  currency: string;
  idempotencyKey: string;       // UUID
  createdAt: string;
}
```

**Consumers:**
- `notification` — notify buyer: "Your payment session is ready."

**Consumer Idempotency:** `processed_event`.

---

### EVT-SH-002: PaymentConfirmed

**Event type:** `shield.PaymentConfirmed`  
**Version:** v1  
**Emitted when:** Provider payment webhook verified and processed successfully.

```typescript
payload: {
  exchangeId: string;
  paymentIntentId: string;
  protectedFundsId: string;
  amount: number;               // kobo
  currency: string;
  providerReference: string;    // provider's internal event ID
  confirmedAt: string;
}
```

**Consumers:**
- `exchange` — transition Exchange from `PAYMENT_PENDING` to `FUNDED`

**Consumer Idempotency:** Exchange: if already in `FUNDED` or later state, this is a safe no-op. Uses `processed_event` as secondary guard.

---

### EVT-SH-003: FundsFrozen

**Event type:** `shield.FundsFrozen`  
**Version:** v1  
**Emitted when:** ProtectedFundsRecord created with status FROZEN.

```typescript
payload: {
  exchangeId: string;
  protectedFundsId: string;
  amount: number;               // kobo
  currency: string;
  frozenAt: string;
}
```

**Consumers:**
- `notification` — internal ops notification (not sent to users directly)

**Consumer Idempotency:** `processed_event`.

---

### EVT-SH-004: SettlementBlocked

**Event type:** `shield.SettlementBlocked`  
**Version:** v1  
**Emitted when:** Problem opens and `settlementBlocked` is set to `true` on the ProtectedFundsRecord.

```typescript
payload: {
  exchangeId: string;
  protectedFundsId: string;
  problemId: string;
  blockedAt: string;
}
```

**Consumers:**
- `notification` — notify ops/admin: settlement frozen for this Exchange

**Consumer Idempotency:** `processed_event`.

---

### EVT-SH-005: SettlementUnblocked

**Event type:** `shield.SettlementUnblocked`  
**Version:** v1  
**Emitted when:** Problem resolved and settlement block lifted.

```typescript
payload: {
  exchangeId: string;
  protectedFundsId: string;
  unblockedAt: string;
  resolutionVersionId: string;
}
```

**Consumers:**
- `exchange` — re-evaluate settlement eligibility

**Consumer Idempotency:** Exchange: if already eligible, is a no-op.

---

### EVT-SH-006: RefundInitiated

**Event type:** `shield.RefundInitiated`  
**Version:** v1  
**Emitted when:** Refund is sent to provider. NOT confirmation of completion.

```typescript
payload: {
  exchangeId: string;
  refundId: string;
  amount: number;               // kobo
  currency: string;
  reason: string;               // reason code
  initiatedAt: string;
}
```

**⚠️ Critical:** This event does NOT trigger "Refunded" status to user. Only `RefundConfirmed` does.

**Consumers:**
- `notification` — notify buyer: "Your refund is being processed. We'll confirm once complete."

**Consumer Idempotency:** `processed_event`.

---

### EVT-SH-007: RefundConfirmed

**Event type:** `shield.RefundConfirmed`  
**Version:** v1  
**Emitted when:** Provider confirms refund completion via webhook.

```typescript
payload: {
  exchangeId: string;
  refundId: string;
  amount: number;               // kobo
  currency: string;
  providerRefundReference: string;
  confirmedAt: string;
}
```

**Consumers:**
- `exchange` — transition to `REFUNDED` state
- `notification` — notify buyer: "Refund confirmed. ₦X.XX will appear in your account."

**Consumer Idempotency:** Exchange: if already REFUNDED, no-op. Notification: `processed_event`.

---

### EVT-SH-008: PayoutCompleted

**Event type:** `shield.PayoutCompleted`  
**Version:** v1  
**Emitted when:** Individual split payout confirmed by provider.

```typescript
payload: {
  exchangeId: string;
  splitInstructionId: string;
  recipientId: string;
  recipientType: string;        // "SELLER" | "BUYI" | "EARNER"
  amount: number;               // kobo
  currency: string;
  providerPayoutReference: string;
  completedAt: string;
}
```

**Consumers:**
- `settlement` — mark individual split as COMPLETED
- `notification` — notify seller/earner: "Payment of ₦X.XX sent."

**Consumer Idempotency:** Settlement: idempotent on `splitInstructionId + recipientId`. Notification: `processed_event`.

---

### EVT-SH-009: DeliveryFeeRefunded

**Event type:** `shield.DeliveryFeeRefunded`  
**Version:** v1  
**Emitted when:** Delivery fee is refunded due to pre-dispatch cancellation with no provider cost incurred.

```typescript
payload: {
  exchangeId: string;
  refundId: string;
  deliveryFeeAmount: number;    // kobo
  currency: string;
  reason: string;               // "CANCELLED_BEFORE_DISPATCH"
  confirmedAt: string;
}
```

**Consumers:**
- `notification` — notify buyer: delivery fee refund confirmed

**Consumer Idempotency:** `processed_event`.

---

## 8. Check Context Events

Producer: `check` module

---

### EVT-CH-001: VerifierAssigned

**Event type:** `check.VerifierAssigned`  
**Version:** v1  
**Emitted when:** A verifier is successfully assigned with conflict check passed.

```typescript
payload: {
  exchangeId: string;
  checkJobId: string;
  verifierId: string;
  conflictCheckResult: string;  // "CLEAR"
  deadline: string;             // ISO 8601 UTC
  assignedAt: string;
}
```

**Consumers:**
- `notification` — notify verifier: "You have a new assignment."
- `exchange` — transition from `AWAITING_CHECK` to `CHECKING`

**Consumer Idempotency:** Exchange: if already in `CHECKING`, no-op. `processed_event` for notification.

---

### EVT-CH-002: NoVerifierAvailable

**Event type:** `check.NoVerifierAvailable`  
**Version:** v1  
**Emitted when:** No qualified, unconflicted verifier is available for the assignment.

```typescript
payload: {
  exchangeId: string;
  checkJobId: string;
  reason: string;               // e.g. "NO_QUALIFIED_VERIFIER_IN_ZONE"
  occurredAt: string;
}
```

**Consumers:**
- `exchange` — transition to `NO_VERIFIER` state
- `notification` — admin alert queue: manual intervention required

**Consumer Idempotency:** Exchange: if already in `NO_VERIFIER`, no-op.

---

### EVT-CH-003: ConflictDeclared

**Event type:** `check.ConflictDeclared`  
**Version:** v1  
**Emitted when:** An assigned verifier declares a conflict of interest.

```typescript
payload: {
  exchangeId: string;
  checkJobId: string;
  assignmentId: string;
  verifierId: string;
  declaredAt: string;
}
```

**Consumers:**
- `check` (self) — trigger reassignment flow
- `notification` — admin notified; buyer notified of delay

**Consumer Idempotency:** Check self: if reassignment already initiated, no-op.

---

### EVT-CH-004: CheckResultSubmitted

**Event type:** `check.CheckResultSubmitted`  
**Version:** v1  
**Emitted when:** Verifier submits a check outcome (PASS, MISMATCH, or INCONCLUSIVE).

```typescript
payload: {
  exchangeId: string;
  checkJobId: string;
  verifierId: string;
  outcome: string;              // "PASS" | "MISMATCH" | "INCONCLUSIVE"
  mismatchDetails: Array<{
    checklistItemId: string;
    field: string;
    describedValue: string;
    observedValue: string;
  }> | null;                    // required if MISMATCH
  inconclusiveReason: string | null; // required if INCONCLUSIVE
  evidenceRefs: string[];       // list of evidenceAssetIds
  checklistVersionId: string;
  submittedAt: string;
}
```

**Consumers:**
- `exchange` — transition based on outcome: CHECK_PASSED, MISMATCH, or handle INCONCLUSIVE
- `notification` — notify buyer with outcome summary; notify seller

**Consumer Idempotency:** Exchange: transition is idempotent — if already in the target state, no-op. `processed_event` for notifications.

---

## 9. Movement Context Events

Producer: `movement` module

---

### EVT-MV-001: MovementJobCreated

**Event type:** `movement.MovementJobCreated`  
**Version:** v1  
**Emitted when:** A MovementJob is created after Exchange authorizes movement.

```typescript
payload: {
  exchangeId: string;
  movementJobId: string;
  carrierId: string;
  carrierSelectedBy: string;    // "BUYI" | "BUYER" | "SELLER" | "MUTUAL"
  declaredValue: number;        // kobo
  direction: string;            // "FORWARD" | "RETURN"
  createdAt: string;
}
```

**Consumers:**
- `notification` — notify seller: prepare item for pickup; notify carrier if integrated

**Consumer Idempotency:** `processed_event`.

---

### EVT-MV-002: PickupConfirmed

**Event type:** `movement.PickupConfirmed`  
**Version:** v1  
**Emitted when:** Carrier confirms pickup with valid handoff evidence.

```typescript
payload: {
  exchangeId: string;
  movementJobId: string;
  custodyEventId: string;
  newCustodianId: string;       // carrier userId
  releaserId: string;           // who released the item
  evidenceRefs: string[];       // photo and OTP evidence
  proofMethod: string;
  confirmedAt: string;
}
```

**Consumers:**
- `exchange` — transition to `PICKED_UP`; update `currentCustodian`
- `notification` — notify buyer: "Your item has been picked up."

**Consumer Idempotency:** Exchange: if already in `PICKED_UP` or later, no-op.

---

### EVT-MV-003: DeliveryConfirmed

**Event type:** `movement.DeliveryConfirmed`  
**Version:** v1  
**Emitted when:** Carrier confirms delivery with valid evidence (OTP + photos). This is receipt confirmation only — not buyer acceptance.

```typescript
payload: {
  exchangeId: string;
  movementJobId: string;
  custodyEventId: string;
  receiverId: string;           // buyer userId
  evidenceRefs: string[];       // delivery photos + OTP confirmation
  proofMethod: string;          // must not be "NONE"
  deliveredAt: string;
}
```

**⚠️ Critical:** This event opens the review window. It does NOT trigger settlement. It does NOT create a BuyerAccepted event. The exchange transitions to `DELIVERED` then `REVIEWING`.

**Consumers:**
- `exchange` — transition to `DELIVERED`; then emit `ReviewWindowOpened`
- `notification` — notify buyer: review window is open

**Consumer Idempotency:** Exchange: if already in `DELIVERED` or `REVIEWING`, no-op.

---

### EVT-MV-004: DeliveryAttemptFailed

**Event type:** `movement.DeliveryAttemptFailed`  
**Version:** v1  
**Emitted when:** Carrier reports a failed delivery attempt.

```typescript
payload: {
  exchangeId: string;
  movementJobId: string;
  attemptNumber: number;
  failureReason: string;        // reason code
  attributableTo: string;       // "BUYER" | "SELLER" | "CARRIER" | "BUYI" | "UNKNOWN"
  attemptedAt: string;
}
```

**Consumers:**
- `exchange` — may transition to `PROBLEM` if repeated failure
- `notification` — notify buyer and admin
- `shield` — record attributable cause for delivery fee handling

**Consumer Idempotency:** All consumers use `processed_event`.

---

### EVT-MV-005: ReturnJobCreated

**Event type:** `movement.ReturnJobCreated`  
**Version:** v1  
**Emitted when:** A reverse MovementJob is created for an authorised return.

```typescript
payload: {
  exchangeId: string;
  movementJobId: string;        // the new return job ID
  originalMovementJobId: string;
  resolutionVersionId: string;  // the ResolutionVersion that authorised this return
  direction: string;            // "RETURN"
  createdAt: string;
}
```

**Consumers:**
- `exchange` — update state to reflect return in progress
- `notification` — notify buyer: "Return pickup has been arranged."

**Consumer Idempotency:** `processed_event`.

---

### EVT-MV-006: ReturnDeliveryConfirmed

**Event type:** `movement.ReturnDeliveryConfirmed`  
**Version:** v1  
**Emitted when:** Item returned to seller with valid evidence.

```typescript
payload: {
  exchangeId: string;
  movementJobId: string;
  custodyEventId: string;
  returnedToId: string;         // seller userId
  itemConditionNote: string | null;
  evidenceRefs: string[];
  confirmedAt: string;
}
```

**Consumers:**
- `shield` — trigger refund initiation (the return evidence gates the refund)
- `notification` — notify buyer and seller

**Consumer Idempotency:** Shield: check whether refund already initiated for this Exchange before creating new Refund.

---

## 10. Recovery Context Events

Producer: `recovery` module

---

### EVT-RC-001: ProblemOpened

**Event type:** `recovery.ProblemOpened`  
**Version:** v1  
**Emitted when:** A Problem record is created. This event fires AFTER the atomic settlement block has been applied.

```typescript
payload: {
  exchangeId: string;
  problemId: string;
  commitmentId: string;         // specific commitment alleged to have failed
  problemType: string;
  reporterId: string;
  reporterRole: string;
  blocksSettlement: boolean;
  openedAt: string;
}
```

**Consumers:**
- `exchange` — transition to `PROBLEM` state
- `shield` — verify settlement block (should already be applied; this is a confirmation)
- `notification` — notify both parties; notify admin queue
- `trust` — record preliminary behavior event

**Consumer Idempotency:** Exchange: if already in `PROBLEM`, no-op. Shield: idempotent block (already applied).

---

### EVT-RC-002: ResolutionProposed

**Event type:** `recovery.ResolutionProposed`  
**Version:** v1  
**Emitted when:** One party proposes a resolution to an open Problem.

```typescript
payload: {
  exchangeId: string;
  problemId: string;
  resolutionVersionId: string;
  proposedBy: string;           // partyId
  proposedByRole: string;
  resolutionType: string;
  moneyEffect: {
    refundAmount: number;       // kobo
    releaseAmount: number;      // kobo
    currency: string;
  };
  deadline: string | null;
  proposedAt: string;
}
```

**Consumers:**
- `notification` — notify counterparty: "A resolution has been proposed."

**Consumer Idempotency:** `processed_event`.

---

### EVT-RC-003: ResolutionAgreed

**Event type:** `recovery.ResolutionAgreed`  
**Version:** v1  
**Emitted when:** Both parties agree to a ResolutionVersion.

```typescript
payload: {
  exchangeId: string;
  problemId: string;
  resolutionVersionId: string;
  resolutionType: string;
  moneyEffect: {
    refundAmount: number;       // kobo
    releaseAmount: number;      // kobo
    currency: string;
  };
  agreedAt: string;
}
```

**Consumers:**
- `exchange` — transition to `RESOLVED`; evaluate next state based on resolution type
- `shield` — unblock settlement if `resolutionType != RETURN_AND_REFUND`; or keep blocked pending return
- `movement` — if `resolutionType == RETURN_AND_REFUND`: create ReturnJob
- `notification` — notify both parties

**Consumer Idempotency:** Each consumer: `processed_event`.

---

### EVT-RC-004: DisputeOpened

**Event type:** `recovery.DisputeOpened`  
**Version:** v1  
**Emitted when:** Problem escalated to formal Dispute.

```typescript
payload: {
  exchangeId: string;
  problemId: string;
  disputeId: string;
  escalatedBy: string;          // partyId or "SYSTEM"
  openedAt: string;
}
```

**Consumers:**
- `exchange` — transition to `DISPUTED`
- `notification` — notify both parties; alert admin dispute queue

**Consumer Idempotency:** Exchange: if already in `DISPUTED`, no-op.

---

### EVT-RC-005: DisputeDecided

**Event type:** `recovery.DisputeDecided`  
**Version:** v1  
**Emitted when:** Admin records a formal decision on a Dispute.

```typescript
payload: {
  exchangeId: string;
  disputeId: string;
  decisionId: string;
  outcome: string;              // "FULL_REFUND_BUYER" | "FULL_RELEASE_SELLER" | "PARTIAL" | "NO_ACTION"
  moneyEffect: {
    refundAmount: number;       // kobo
    releaseAmount: number;      // kobo
    currency: string;
  };
  evidenceRefs: string[];       // evidence used in decision — these become is_used_in_decision=true
  adminId: string;
  decidedAt: string;
}
```

**Consumers:**
- `exchange` — transition to `DECIDED`
- `item-evidence` — mark referenced evidence as `is_used_in_decision = true`
- `shield` — apply money effect (refund or release as decided)
- `notification` — notify both parties with decision explanation

**Consumer Idempotency:** Each consumer: `processed_event`. Item-evidence: setting `is_used_in_decision=true` is idempotent.

---

## 11. Settlement Context Events

Producer: `settlement` module

---

### EVT-SE-001: SplitInstructionCreated

**Event type:** `settlement.SplitInstructionCreated`  
**Version:** v1  
**Emitted when:** A SplitInstruction is created and ready for execution.

```typescript
payload: {
  exchangeId: string;
  splitInstructionId: string;
  splits: Array<{
    recipientId: string;
    recipientType: string;      // "SELLER" | "BUYI" | "EARNER"
    amount: number;             // kobo
  }>;
  totalAmount: number;          // kobo — sum of all splits
  currency: string;
  createdAt: string;
}
```

**Consumers:**
- `notification` — internal ops notification

**Consumer Idempotency:** `processed_event`.

---

### EVT-SE-002: SettlementCompleted

**Event type:** `settlement.SettlementCompleted`  
**Version:** v1  
**Emitted when:** All splits in a SplitInstruction have been confirmed by the provider.

```typescript
payload: {
  exchangeId: string;
  settlementId: string;
  splitInstructionId: string;
  totalSettled: number;         // kobo
  currency: string;
  completedAt: string;
}
```

**Consumers:**
- `exchange` — transition to `DONE`
- `distribution` — release pending commissions for this Exchange
- `notification` — notify seller: "Payment sent." Notify earner if applicable.

**Consumer Idempotency:** Exchange: if already DONE, no-op. Distribution: idempotent commission release.

---

### EVT-SE-003: SettlementFailed

**Event type:** `settlement.SettlementFailed`  
**Version:** v1  
**Emitted when:** A payout split attempt fails at the provider.

```typescript
payload: {
  exchangeId: string;
  splitInstructionId: string;
  failedSplitRecipientId: string;
  failureReason: string;
  retryCount: number;
  failedAt: string;
}
```

**Consumers:**
- `exchange` — transition to `SETTLEMENT_FAILED` if all retries exhausted
- `notification` — alert admin; do NOT notify seller until resolved

**Consumer Idempotency:** `processed_event`.

---

### EVT-SE-004: SettlementRetried

**Event type:** `settlement.SettlementRetried`  
**Version:** v1  
**Emitted when:** A failed settlement split is retried.

```typescript
payload: {
  exchangeId: string;
  splitInstructionId: string;
  retryCount: number;
  retriedAt: string;
}
```

**Consumers:**
- `notification` — internal ops log only; no user notification

**Consumer Idempotency:** `processed_event`.

---

## 12. Distribution Context Events

Producer: `distribution` module

---

### EVT-DI-001: AttributionFrozen

**Event type:** `distribution.AttributionFrozen`  
**Version:** v1  
**Emitted when:** Attribution record created at payment confirmation. Commission is now pending.

```typescript
payload: {
  exchangeId: string;
  attributionId: string;
  shareLinkId: string;
  earnerId: string;
  commissionAmount: number;     // kobo — frozen at this amount; cannot change
  currency: string;
  frozenAt: string;             // equals payment confirmation timestamp
}
```

**Consumers:**
- `notification` — notify earner: "Your commission is pending settlement of this Exchange."

**Consumer Idempotency:** `processed_event`.

---

### EVT-DI-002: CommissionReleased

**Event type:** `distribution.CommissionReleased`  
**Version:** v1  
**Emitted when:** Exchange settles successfully and commission becomes available to earner.

```typescript
payload: {
  exchangeId: string;
  attributionId: string;
  earnerId: string;
  commissionAmount: number;     // kobo
  currency: string;
  releasedAt: string;
}
```

**Consumers:**
- `settlement` — include earner in SplitInstruction (or record as payable in next batch)
- `notification` — notify earner: "Your commission of ₦X is now available."

**Consumer Idempotency:** Settlement: idempotent on `attributionId`. Notification: `processed_event`.

---

### EVT-DI-003: CommissionCancelled

**Event type:** `distribution.CommissionCancelled`  
**Version:** v1  
**Emitted when:** Exchange is cancelled or refunded; pending commission cancelled.

```typescript
payload: {
  exchangeId: string;
  attributionId: string;
  earnerId: string;
  cancellationReason: string;   // "EXCHANGE_CANCELLED" | "EXCHANGE_REFUNDED"
  cancelledAt: string;
}
```

**Consumers:**
- `notification` — notify earner: "Commission cancelled — Exchange did not complete."

**Consumer Idempotency:** `processed_event`.

---

## 13. Identity Context Events

Producer: `identity` module

---

### EVT-ID-001: KYCStateUpdated

**Event type:** `identity.KYCStateUpdated`  
**Version:** v1  
**Emitted when:** KYC provider confirms a new KYC state for a user (never from user self-report).

```typescript
payload: {
  userId: string;
  previousKycState: string;
  newKycState: string;          // "UNVERIFIED" | "BASIC" | "ENHANCED" | "REJECTED"
  providerReference: string;
  updatedAt: string;
}
```

**Consumers:**
- `exchange` — re-evaluate any gated actions for this user's active Exchanges
- `notification` — notify user if KYC threshold reached

**Consumer Idempotency:** `processed_event`.

---

### EVT-ID-002: AccountRestricted

**Event type:** `identity.AccountRestricted`  
**Version:** v1  
**Emitted when:** Admin applies a restriction to a user account.

```typescript
payload: {
  userId: string;
  restrictionType: string;      // "SUSPENDED" | "RESTRICTED"
  reason: string;
  appliedBy: string;            // adminId
  appliedAt: string;
}
```

**Consumers:**
- `exchange` — block new Exchanges from this user; review active Exchanges
- `notification` — notify user per applicable policy

**Consumer Idempotency:** `processed_event`.

---

## 14. Trust & Behavior Context Events

Producer: `trust` module

---

### EVT-TR-001: PromiseEventRecorded

**Event type:** `trust.PromiseEventRecorded`  
**Version:** v1  
**Emitted when:** A PromiseEvent (KEPT, BROKEN, LATE, MADE) is recorded for a user.

```typescript
payload: {
  userId: string;
  exchangeId: string;
  partyRole: string;
  eventType: string;            // "PROMISE_MADE" | "PROMISE_KEPT" | "PROMISE_BROKEN" | "PROMISE_LATE"
  commitmentType: string;
  outcomeReason: string;
  recordedAt: string;
}
```

**Consumers:** None in V1 (internal record only; no external consumers).

**V1 note:** No public score is derived from this event in V1.

---

## 15. Admin & System Events

Producer: `admin` module (for admin actions) / `system` (for integrity alerts)

---

### EVT-AD-001: AdminActionPerformed

**Event type:** `admin.AdminActionPerformed`  
**Version:** v1  
**Emitted when:** Any admin action is performed through the admin command center.

```typescript
payload: {
  adminActionId: string;
  adminId: string;
  authorizationLevel: string;
  actionType: string;           // e.g. "FREEZE_EXCHANGE" | "RELEASE_SETTLEMENT" | etc.
  exchangeId: string | null;
  targetUserId: string | null;
  reason: string;
  beforeState: Record<string, unknown>;
  afterState: Record<string, unknown>;
  performedAt: string;
}
```

**Consumers:**
- `notification` — relevant parties notified of admin action where policy requires
- Audit log stream (persistent, 7-year retention minimum)

**Consumer Idempotency:** `processed_event`. Audit log: append-only.

---

### EVT-SYS-001: EventSequenceGapDetected

**Event type:** `system.EventSequenceGapDetected`  
**Version:** v1  
**Emitted when:** The integrity monitor detects a gap in `exchange_event.sequence_number` for any Exchange.

```typescript
payload: {
  exchangeId: string;
  expectedSequenceNumber: number;
  actualNextSequenceNumber: number;
  detectedAt: string;
}
```

**Consumers:**
- `notification` — CRITICAL alert to engineering team immediately

**This event should never fire in normal operation. Any occurrence is a critical integrity incident.**

---

### EVT-SYS-002: EvidenceHashMismatchDetected

**Event type:** `system.EvidenceHashMismatchDetected`  
**Version:** v1  
**Emitted when:** Nightly hash verification finds a stored file hash that does not match the current file.

```typescript
payload: {
  evidenceAssetId: string;
  exchangeId: string;
  storedHash: string;
  computedHash: string;
  detectedAt: string;
}
```

**Consumers:**
- `notification` — CRITICAL alert to engineering team immediately
- `admin` — Evidence asset marked INTEGRITY_FAILED; admin review required

**This event should never fire. Any occurrence is a critical integrity incident.**

---

## 16. Event Consumer Matrix

This matrix shows which bounded contexts consume which events. Use it to verify that no consumer is missing and no event is published with no consumer.

| Event | Exchange | Agreement | Shield | Check | Movement | Recovery | Settlement | Distribution | Identity | Trust | Notification | Sagas/Admin |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ExchangeCreated | — | — | — | — | — | — | — | — | — | ✓ | ✓ | — |
| TermsAccepted | — | — | — | — | — | — | — | — | — | — | ✓ | — |
| TermsChanged | ✓ | — | — | — | — | — | — | — | — | — | ✓ | — |
| ExchangeFunded | ✓ | — | — | — | — | — | — | ✓ | — | — | ✓ | — |
| SellerConfirmed | — | — | — | ✓ | — | — | — | — | — | — | ✓ | — |
| CheckRequested | — | — | — | ✓ | — | — | — | — | — | — | — | — |
| MovementAuthorized | — | — | — | — | ✓ | — | — | — | — | — | ✓ | — |
| ReviewWindowOpened | — | — | — | — | — | — | — | — | — | — | ✓ | ✓ |
| BuyerAccepted | — | — | — | — | — | — | ✓ | — | — | ✓ | ✓ | — |
| ReviewWindowExpiredNoProblem | — | — | — | — | — | — | ✓ | — | — | ✓ | ✓ | — |
| SettlementEligibilityConfirmed | — | — | — | — | — | — | ✓ | ✓ | — | — | — | — |
| ExchangeCancelled | — | — | ✓ | — | — | — | — | ✓ | — | ✓ | ✓ | — |
| ExchangeCompleted | — | — | — | — | — | — | — | ✓ | — | ✓ | ✓ | — |
| CommitmentOutcomeRecorded | — | — | — | — | — | — | — | — | — | ✓ | — | — |
| PaymentConfirmed | ✓ | — | — | — | — | — | — | — | — | — | — | — |
| RefundInitiated | — | — | — | — | — | — | — | — | — | — | ✓ | — |
| RefundConfirmed | ✓ | — | — | — | — | — | — | — | — | — | ✓ | — |
| SettlementBlocked | — | — | — | — | — | — | — | — | — | — | ✓ | — |
| SettlementUnblocked | ✓ | — | — | — | — | — | — | — | — | — | — | — |
| PayoutCompleted | — | — | — | — | — | — | ✓ | — | — | — | ✓ | — |
| CheckResultSubmitted | ✓ | — | — | — | — | — | — | — | — | — | ✓ | — |
| PickupConfirmed | ✓ | — | — | — | — | — | — | — | — | — | ✓ | — |
| DeliveryConfirmed | ✓ | — | — | — | — | — | — | — | — | — | ✓ | — |
| ReturnDeliveryConfirmed | — | — | ✓ | — | — | — | — | — | — | — | ✓ | — |
| ProblemOpened | ✓ | — | ✓ | — | — | — | — | — | — | ✓ | ✓ | — |
| ResolutionAgreed | ✓ | — | ✓ | — | ✓ | — | — | — | — | — | ✓ | — |
| DisputeDecided | ✓ | — | ✓ | — | — | — | — | — | — | — | ✓ | ✓ |
| SettlementCompleted | ✓ | — | — | — | — | — | — | ✓ | — | — | ✓ | — |
| SettlementFailed | ✓ | — | — | — | — | — | — | — | — | — | ✓ | ✓ |
| AttributionFrozen | — | — | — | — | — | — | — | — | — | — | ✓ | — |
| CommissionReleased | — | — | — | — | — | — | ✓ | — | — | — | ✓ | — |
| KYCStateUpdated | ✓ | — | — | — | — | — | — | — | — | — | ✓ | — |
| AdminActionPerformed | — | — | — | — | — | — | — | — | — | — | ✓ | ✓ |

---

## 17. Event Flow Diagrams — Key Scenarios

### 17.1 Full Protected Exchange — Happy Path

```
CreateExchange command
  → ExchangeCreated
  → [buyer accepts terms] → TermsAccepted
  → [buyer pays] → PaymentConfirmed → ExchangeFunded
  → [seller confirms] → SellerConfirmed → CheckRequested
  → [verifier assigned] → VerifierAssigned
  → [verifier submits PASS] → CheckResultSubmitted(PASS)
  → [exchange moves] → MovementAuthorized → MovementJobCreated
  → [carrier picks up] → PickupConfirmed
  → [carrier delivers] → DeliveryConfirmed
  → ReviewWindowOpened
  → [buyer does nothing for 24h] → ReviewWindowExpiredNoProblem
  → SettlementEligibilityConfirmed
  → SplitInstructionCreated → PayoutCompleted (seller) → PayoutCompleted (BUYI)
  → SettlementCompleted
  → ExchangeCompleted
  → CommissionReleased (if via ShareLink)
```

### 17.2 Problem During Review — Resolution Path

```
... DeliveryConfirmed → ReviewWindowOpened
  → [buyer opens problem] → ProblemOpened → SettlementBlocked
  → [parties negotiate] → ResolutionProposed → ResolutionAgreed
  → [if CONTINUE] → SettlementUnblocked → SettlementEligibilityConfirmed → SettlementCompleted
  → [if RETURN_AND_REFUND] → ReturnJobCreated → ReturnDeliveryConfirmed
                           → RefundInitiated → RefundConfirmed → ExchangeCompleted
  → [if PARTIAL] → partial refund + partial release → SettlementCompleted
```

### 17.3 Seller Timeout Path

```
ExchangeFunded
  → [seller confirmation deadline passes]
  → SellerTimeoutJob fires
  → ExchangeCancelled (cancelledBy: SYSTEM, reason: SELLER_TIMEOUT)
  → RefundInitiated → RefundConfirmed
  → CommitmentOutcomeRecorded (FAILED, SELLER, FULFILL_ORDER)
  → PromiseEventRecorded (PROMISE_BROKEN)
```

### 17.4 Check MISMATCH — Buyer Cancels

```
CheckResultSubmitted(MISMATCH)
  → Exchange state: MISMATCH
  → [buyer chooses to cancel]
  → ExchangeCancelled (reason: MISMATCH_BUYER_CANCELLED)
  → RefundInitiated (item price; check fee non-refundable)
  → CommitmentOutcomeRecorded (seller PROVIDE_ITEM_AS_DESCRIBED: FAILED)
  → PromiseEventRecorded (PROMISE_BROKEN for seller)
```

### 17.5 Duplicate Payment Webhook — Safe Handling

```
PaymentConfirmed (eventId: abc-123) received
  → Processed; Exchange transitions to FUNDED; ProtectedFundsRecord created

PaymentConfirmed (eventId: abc-123) received again (duplicate)
  → processed_event table: abc-123 already exists
  → No-op; no duplicate ProtectedFundsRecord created
  → Log: "Duplicate event ignored" with eventId
  → Return success (so provider does not retry)
```

---

## 18. Failure & Compensation Events

These events represent failure states and the system's compensating responses. They are as important as success events and must be handled with equal rigour.

| Failure Scenario | Event(s) Fired | Compensation |
|---|---|---|
| Payment fails | `exchange.PaymentFailed` (implicit via PaymentIntent.FAILED) | Reservation released; Exchange back to BUYER_REVIEWING |
| Reservation expires before payment | `exchange.ReservationExpired` | Inventory released; Exchange EXPIRED |
| No verifier available | `check.NoVerifierAvailable` | Exchange → NO_VERIFIER; admin queue |
| Verifier conflict declared | `check.ConflictDeclared` | Reassignment flow triggered |
| Delivery attempt failed | `movement.DeliveryAttemptFailed` | Admin alert; retry or PROBLEM state |
| Settlement split fails | `settlement.SettlementFailed` | Retry queue with backoff; admin alert on max retries |
| Refund fails at provider | `shield.RefundFailed` | Retry queue; admin manual intervention |
| Evidence hash mismatch | `system.EvidenceHashMismatchDetected` | CRITICAL alert; admin review |
| Event sequence gap | `system.EventSequenceGapDetected` | CRITICAL alert; engineering investigation |

---

## 19. Event Log Integrity Rules

The `exchange_event` table is the permanent, authoritative audit record of every Exchange. Its integrity is non-negotiable.

### 19.1 Append-Only Enforcement

```sql
-- No UPDATE or DELETE is ever executed on this table
-- Repository has no deleteEvent() or updateEvent() method
-- DB role used by application: INSERT only on exchange_event (no UPDATE, DELETE)
REVOKE UPDATE, DELETE ON TABLE exchange_event FROM app_role;
```

### 19.2 Sequence Number Integrity

Every event appended to the log receives the next sequence number for its Exchange:

```sql
INSERT INTO exchange_event (
  event_id, exchange_id, event_type, sequence_number, actor_id, actor_role, payload, created_at
)
SELECT
  :eventId, :exchangeId, :eventType,
  COALESCE(MAX(sequence_number), 0) + 1,   -- atomic next sequence
  :actorId, :actorRole, :payload, NOW()
FROM exchange_event
WHERE exchange_id = :exchangeId
FOR UPDATE;  -- row-level lock on the Exchange's events during insert
```

This prevents sequence gaps under concurrent inserts.

### 19.3 Integrity Monitoring

The hourly integrity check job:

```sql
-- Detect gaps in sequence numbers for any Exchange
WITH numbered AS (
  SELECT
    exchange_id,
    sequence_number,
    LAG(sequence_number) OVER (PARTITION BY exchange_id ORDER BY sequence_number) AS prev_seq
  FROM exchange_event
)
SELECT exchange_id, prev_seq + 1 AS expected, sequence_number AS actual
FROM numbered
WHERE sequence_number != prev_seq + 1
  AND prev_seq IS NOT NULL;
```

Any result from this query fires `system.EventSequenceGapDetected` immediately.

### 19.4 Event Payload Schema Validation

All events are schema-validated before appending to the log:
- Required fields present and non-null
- Types match the schema
- `exchangeId` references an existing Exchange
- `actorId` references a real user (or is "SYSTEM")

Invalid events are rejected with a domain exception. They are never stored with invalid payloads.

### 19.5 Retention Policy

All events in `exchange_event` are retained indefinitely. There is no automated purge.

Archival strategy for very old events (Phase 3+): Move events older than 3 years to cold storage (S3 Glacier / Cloud Storage Archive), but maintain queryable metadata (exchangeId, eventType, sequence_number, created_at) in the primary table for fast lookup. Full payload available from cold storage on-demand.

---

*End of Volume V — Event Catalog*  
*BUYIspace Technologies Ltd. | Internal | Confidential*
