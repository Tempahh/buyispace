# Acceptance, Dependencies, and Repository Context

## Delivery and acceptance controls

Apply these controls at every milestone:

- Use a BUYIspace-controlled source repository and named developer accounts.
  Deliver code, migrations, tests, documentation, and reproducible builds there.
- Demonstrate the milestone acceptance gate and its required tests. Written
  BUYI acceptance is required; silence, elapsed time, or payment is not technical
  acceptance.
- Preserve immutable Exchange and AgreementVersion history. UI screens and
  provider callbacks cannot manufacture authoritative state.
- Manual V1 work still requires controlled records. It cannot invent payment
  confirmation, authorization, delivery, acceptance, or settlement.
- Record proposed scope changes separately, including their cost, schedule,
  dependency, and acceptance impact. Do not silently add features based on older
  plans or mockups.
- M0 must include a ticketed, testable design for the high-risk identity-change
  guard. Before live settlement, new-device access, recovery, credential reset,
  or payout-destination change cannot enable immediate settlement solely on SMS
  OTP. Support independent confirmation/review, scoped hold, and audit; policy
  thresholds remain BUYI decisions.

## RFQ release tests

The programmer plans and demonstrates these tests across the relevant
milestones:

1. Duplicate command creates no duplicate consequential event.
2. Two concurrent `START_EXECUTION` commands produce at most one
   `ExecutionStarted`.
3. Provider timeout/`UNKNOWN` is not guessed into success or failure.
4. Expired reservation blocks execution even if funding exists.
5. Material change uses a new `AgreementVersion`; old authorization is not
   silently extended.
6. OTP proves only the scoped fact it can establish; it does not fabricate
   acceptance or high-risk authority.
7. New-device login, account recovery, credential reset, or payout-destination
   change cannot be followed immediately by settlement solely because SMS OTP
   succeeded.
8. Check `PASS` cannot close the Exchange.
9. Delivery cannot close the Exchange.
10. A Problem opened before review expiry blocks the affected settlement path.
11. Review expiry cannot confirm settlement.
12. Settlement/refund instruction cannot equal provider confirmation.
13. Admin/operations action cannot fabricate participant consent or bypass
    required authority.
14. Evidence for one unique item/outcome cannot silently migrate to a
    replacement.

Map each test to its implementing milestone, automated test/evidence, test
environment, and any required test-provider account or staged pilot operation.

## Dependencies and questions to resolve

Return these in the quotation. Cite the applicable source and do not invent an
answer for a domain rule:

- Which canonical requirement or command is unclear? State the proposed
  interpretation, but do not implement it until approved. Use
  **OPEN DECISION — PRODUCT/DOMAIN INPUT REQUIRED** for unresolved domain rules.
- Which payment, settlement, refund, or custody steps depend on a licensed
  provider, external legal advice, or partner contract?
- Which `V1_REQUIRED` rows will be human-assisted in the pilot, and how will
  BUYI still record the authoritative facts?
- Which acceptance tests require test-provider access or staged physical pilot
  operations?
- What access, repository, environments, and credentials are needed at each
  milestone, and why?
- Disclose planned existing libraries, background IP, third-party services,
  and AI-generated components for legal review.

The RFQ also identifies **Control Artifact 02 — Command & Authority Matrix** as
still being completed. Do not invent consequential domain commands,
authorization, settlement, lifecycle, or policy behavior before the applicable
command/authority row and external decisions are approved. Provider `UNKNOWN`
remains `UNKNOWN`.

## Optional repository context

The parent repository's engineering suite predates this RFQ. It may provide
useful implementation background, but it is not a reason to change this
breakout's RFQ-defined scope, milestone order, acceptance language, or lifecycle
vocabulary. Consult it only when the RFQ or its named higher-authority sources
leave an implementation detail open.

| RFQ work | Existing repository material |
|---|---|
| Product model and user journeys | [PRD](../vol-1-prd.md) |
| Functional requirements and current implementation detail | [SRS](../vol-2-srs.md) |
| Aggregate boundaries, commands, invariants, and events | [DDD blueprint](../vol-3-ddd-blueprint.md) and [event catalog](../vol-5-event-catalog.md) |
| Modular monolith, security, integrations, and deployment | [System architecture](../vol-4-system-architecture.md) |
| Historical team plan and delivery sequence | [Build roadmap](../vol-6-build-roadmap.md) |
| Historical provider and operating cost assumptions | [Financial implications](../vol-7-financial-implications.md) |

If a background document differs from the RFQ, follow the RFQ breakout for
quotation structure and record the discrepancy as a question only when it
affects a decision reserved to one of the RFQ's higher-authority artifacts.
Do not silently import older scope or milestone assumptions.
