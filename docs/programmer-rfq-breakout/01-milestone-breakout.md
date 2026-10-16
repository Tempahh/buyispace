# Milestone and Backlog Breakout

This is the RFQ’s estimate structure. Backlog IDs and scope labels are
preserved so a quotation can be reviewed against the source request.
**MANUAL_V1_ALLOWED** applies only to the operational assistance described; it
does not make an authoritative record optional.

## Gate 0 — Handoff readiness

**Purpose:** Establish scope and company control before substantial domain
coding or expanded access.

**Deliverables:** Signed scope acknowledgement; programmer explanation of the
first build in their own words; company-controlled repository and core accounts;
contract schedules ready for signature.

**Acceptance:** No substantial domain coding or expanded access until scope and
company-control conditions are satisfied. Gate 0 is not authorization to start
development.

## M0 — Sprint 0: Skeleton

**Acceptance gate:** A governed Exchange can be created and immutable, ordered
events appended safely. The high-risk identity-change guard has a ticketed,
testable design.

### Foundation

| ID | Capability | Scope | Acceptance boundary |
|---|---|---|---|
| B0-01 | Company-controlled repository, branch/review discipline, CI/build skeleton | V1_REQUIRED | Repository is under BUYIspace control; developer access is least-privilege. |
| B0-02 | Modular-monolith module skeleton and database migrations | V1_REQUIRED | Module boundaries exist without premature microservices. |
| B0-03 | Exchange identity, aggregate version, immutable ordered event history | V1_REQUIRED | A governed Exchange can be created and immutable, ordered events appended. |
| B0-04 | Idempotency, optimistic concurrency, stale-command protection | V1_REQUIRED | Duplicate or concurrent consequential commands cannot create duplicate truth. |
| B0-05 | PolicyVersion framework and versioned configuration | V1_REQUIRED | Changeable values are not buried in lifecycle code. |
| B0-06 | Audit trail and reason-coded operations actions | V1_REQUIRED | Privileged activity is attributable; immutable history cannot be deleted. |
| B0-07 | Identity/authentication baseline and least-privilege access | V1_REQUIRED | No shared credentials; MFA where supported; access is role- and scope-based. |
| B0-08 | High-risk identity-change guard: new device, recovery, credential reset, payout-destination change | V1_REQUIRED; MANUAL_V1_ALLOWED | Such a change cannot by itself, or with SMS OTP, trigger immediate settlement; independent confirmation/manual review and scoped hold are supported. |

## M1 — Sprint 1: Truth and Agreement

**Acceptance gate:** A supported Exchange reaches `READY_TO_EXECUTE` only
through its locked guards.

| ID | Capability | Scope | Acceptance boundary |
|---|---|---|---|
| B1-01 | ParticipantResponsibility model | V1_REQUIRED | Requester, chooser, payer, recipient, and fulfiller may be different participants. |
| B1-02 | Supply/item/outcome identity and supply provenance | V1_REQUIRED; MANUAL_V1_ALLOWED | An outside reference is not fabricated as seller-confirmed supply. |
| B1-03 | Availability confirmation and reservation truth | V1_REQUIRED; MANUAL_V1_ALLOWED | Staff may contact a seller manually, but availability/reservation is authoritatively recorded in BUYI. |
| B1-04 | Support assessment and CapabilityInstance structure | V1_REQUIRED; MANUAL_V1_ALLOWED | BUYI determines whether and how an Exchange is supportable without fabricating a capability. |
| B1-05 | Immutable AgreementVersion | V1_REQUIRED | A material change creates a new version; history is preserved. |
| B1-06 | AuthorizationEnvelope and authority source | V1_REQUIRED | Funding, identity, and link possession do not become blanket authority. |
| B1-07 | Execution-readiness establishment | V1_REQUIRED | An Exchange reaches `READY_TO_EXECUTE` only through required guards. |

## M2 — Sprint 2: Execution Core

**Acceptance gate:** `READY_TO_EXECUTE` → `EXECUTING` cannot be forced by a UI
or provider shortcut.

| ID | Capability | Scope | Acceptance boundary |
|---|---|---|---|
| B2-01 | `START_EXECUTION` final revalidation | V1_REQUIRED | Readiness is revalidated immediately before execution begins. |
| B2-02 | Commitments and capability execution tracking | V1_REQUIRED; MANUAL_V1_ALLOWED | Human-assisted execution is allowed where specified, but results are recorded. |
| B2-03 | Evidence/provenance records | V1_REQUIRED; MANUAL_V1_ALLOWED | Evidence remains bound to the correct item/outcome and producer. |
| B2-04 | Custody hooks and custody chain where physical movement applies | V1_REQUIRED; MANUAL_V1_ALLOWED | Manual handoff/logistics may be used; custody truth remains recorded. |
| B2-05 | Provider `UNKNOWN` and reconciliation behavior | V1_REQUIRED; MANUAL_V1_ALLOWED | `UNKNOWN` is never guessed into success/failure; operations may reconcile from authoritative provider evidence. |

## M3 — Sprint 3: Outcome and Review

**Acceptance gate:** `EXECUTING` → `OUTCOME_RECORDED` → `REVIEWING` works
without fabricated acceptance.

| ID | Capability | Scope | Acceptance boundary |
|---|---|---|---|
| B3-01 | `RECORD_EXECUTION_OUTCOME` and `ExecutionOutcomeRecorded` | V1_REQUIRED | One canonical execution-outcome event; no duplicate `OutcomeRecorded` business event. |
| B3-02 | OutcomeRecord and obligation/capability result aggregation | V1_REQUIRED; MANUAL_V1_ALLOWED | Partial/non-fulfilment outcomes can be recorded without being called success. |
| B3-03 | Outcome review, scoped challenge, and review expiry | V1_REQUIRED; MANUAL_V1_ALLOWED | Receipt, silence, or OTP never fabricates acceptance. |
| B3-04 | Review completion and `START_CLOSING` separation | V1_REQUIRED | `OutcomeReviewCompleted` is distinct from `ClosingStarted`. |

## M4 — Sprint 4: Problem and Recovery

**Acceptance gate:** A Problem blocks only affected work and never assigns
automatic guilt.

| ID | Capability | Scope | Acceptance boundary |
|---|---|---|---|
| B4-01 | Problem records with scoped blocking effect | V1_REQUIRED; MANUAL_V1_ALLOWED | Freeze only work that cannot safely continue; do not assign guilt. |
| B4-02 | Cause and Responsibility findings as separate truth | V1_REQUIRED; MANUAL_V1_ALLOWED | Human review may establish findings; history records basis/evidence. |
| B4-03 | RecoveryCase structure | V1_REQUIRED; MANUAL_V1_ALLOWED | Structurally supports correction, replacement, return, refund, re-fulfilment, and no-adjustment paths. |
| B4-04 | Reverse custody/return evidence where applicable | V1_REQUIRED; MANUAL_V1_ALLOWED | Return is a custody/evidence flow, not a boolean. |

## M5 — Sprint 5: Closing and Money

**Acceptance gate:** No instruction is mistaken for provider confirmation;
`CLOSED` history remains immutable.

| ID | Capability | Scope | Acceptance boundary |
|---|---|---|---|
| B5-01 | FundingRecord and provider-adapter abstraction | V1_REQUIRED | Provider state maps into BUYI financial truth without becoming lifecycle truth. |
| B5-02 | Provider webhook authenticity, raw-event retention, and idempotency | V1_REQUIRED | Untrusted provider input cannot directly create authoritative success. |
| B5-03 | Settlement eligibility engine | V1_REQUIRED | Funding present does not equal settlement eligibility. |
| B5-04 | Settlement instruction/provider confirmation separation | V1_REQUIRED; MANUAL_V1_ALLOWED | Operations may initiate approved actions; only authoritative provider confirmation records money movement. |
| B5-05 | Refund instruction/provider confirmation separation | V1_REQUIRED; MANUAL_V1_ALLOWED | Refund instruction never equals refund completion. |
| B5-06 | `CLOSING` / `CLOSE_EXCHANGE` / `ExchangeClosed` | V1_REQUIRED | Closure guards pass; `CLOSED` does not move backward. |
| B5-07 | PostClosureCase | V1_REQUIRED; MANUAL_V1_ALLOWED | Late reversal/evidence creates linked post-closure truth without reopening the Exchange. |

## M6 — Sprint 6: Pilot Operations

**Acceptance gate:** Operations can understand and control every pilot Exchange
without bypassing authority.

| ID | Capability | Scope | Acceptance boundary |
|---|---|---|---|
| B6-01 | Internal operations console | V1_REQUIRED; MANUAL_V1_ALLOWED | Operations can see lifecycle/subordinate truths, blockers, evidence, funding, and recovery without generic authority bypass. |
| B6-02 | Responsibility-aware notifications | V1_REQUIRED; MANUAL_V1_ALLOWED | Notifications are not authority or acceptance; manual channels may support the pilot. |
| B6-03 | Risk/policy configuration and provider reconciliation view | V1_REQUIRED; MANUAL_V1_ALLOWED | Open/tunable policy values remain configurable and auditable. |

## M7 — Sprint 7: First Public Door

**Acceptance gate:** One real controlled Exchange can complete end to end; the
customer flow uses the same Exchange engine and does not duplicate business
logic.

| ID | Capability | Scope | Acceptance boundary |
|---|---|---|---|
| B7-01 | Thin first public/customer intake door | V1_REQUIRED; MANUAL_V1_ALLOWED | Uses the same Exchange engine; no duplicate marketplace logic. |
| B7-02 | Controlled pilot support for selected phones/electronics | V1_REQUIRED; MANUAL_V1_ALLOWED | Pilot configuration only; no phone-specific core model. |

## Architecture boundaries only

Price only the foundation/boundary needed now. Do not include full future
features.

| ID | Capability | Scope | Boundary |
|---|---|---|---|
| A-01 | Provider replaceability/adapter boundary | ARCHITECT_NOW | Provider replacement must not require changing Exchange/Agreement/Outcome semantics. |
| A-02 | Profile/capability extension mechanism for later entry experiences | ARCHITECT_NOW | Later profiles use the same Exchange Core. |
| A-03 | Distribution module boundary/attribution hook | ARCHITECT_NOW | Preserve a boundary; do not build the Share & Earn commerce engine now. |
| A-04 | Trust factual behavior-event boundary | ARCHITECT_NOW | Preserve factual events where needed; do not build an advanced public score. |
| A-05 | Category-neutral item/outcome model | ARCHITECT_NOW | Core can grow beyond phones without a category-specific rewrite. |

## Enable later — excluded from current quote

| ID | Capability | Scope | Boundary |
|---|---|---|---|
| L-01 | Pay 4 Me consumer entry/profile | ENABLE_LATER; MANUAL_V1_ALLOWED | Use the same Exchange Core; not a separate architecture. |
| L-02 | Share & Earn distribution experience | ENABLE_LATER; MANUAL_V1_ALLOWED | Later attribution/allocation; not a second commerce engine. |
| L-03 | Public Live Demand | ENABLE_LATER; MANUAL_V1_ALLOWED | Later request/discovery experience. |
| L-04 | Open national seller network | ENABLE_LATER; MANUAL_V1_ALLOWED | Controlled sellers may support the pilot; open network comes later. |
| L-05 | Standalone FETCH/Human Carrier/Hub marketplace | ENABLE_LATER; MANUAL_V1_ALLOWED | V1 includes only movement support required by the controlled pilot. |
| L-06 | Advanced public Trust/B-Score | ENABLE_LATER | Factual behavior may be preserved; public scoring comes later. |
| L-07 | Advanced METE AI | ENABLE_LATER | V1 remains deterministic/human-assisted where appropriate. |
| L-08 | Ajo/group buying | ENABLE_LATER; MANUAL_V1_ALLOWED | Future profile/capability; no current engineering. |
| L-09 | Multi-sponsor funding | ENABLE_LATER; MANUAL_V1_ALLOWED | Future funding/authorization profile. |

## Not in current scope — excluded

| ID | Capability | Scope | Boundary |
|---|---|---|---|
| N-01 | Credit/lending | NOT_IN_CURRENT_SCOPE | No current engineering. |
| N-02 | BUYI-issued insurance/advanced Shield financial products | NOT_IN_CURRENT_SCOPE | V1 uses only protected-funding controls required by the Exchange. |
| N-03 | Cross-border funding complexity | NOT_IN_CURRENT_SCOPE | Nigeria-first controlled V1. |
| N-04 | Store builder | NOT_IN_CURRENT_SCOPE | Not part of the first Exchange proof. |
| N-05 | Livestream commerce | NOT_IN_CURRENT_SCOPE | Not part of the first Exchange proof. |
| N-06 | Property/agriculture/vehicle vertical implementations | NOT_IN_CURRENT_SCOPE | Future profiles; not current build. |
| N-07 | Nationwide BUYI-owned logistics network | NOT_IN_CURRENT_SCOPE | Use only movement support required by the controlled pilot. |
