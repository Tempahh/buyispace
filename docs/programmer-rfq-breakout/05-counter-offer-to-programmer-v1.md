# BUYI V1 Programmer RFQ — Programmer's Counter-Offer

**From:** Programmer / intended Principal Engineer
**To:** BUYIspace Technologies Ltd.
**Date:** 3 November 2026  
**Status:** Counter-offer for discussion; subject to the signed development agreement and written authorization
**Currency:** Nigerian Naira (NGN)

## 1. Response to BUYI's engineering review

Thank you for the **BUYI V1 Engineering Review & Completion Pack** dated
28 October 2026. I agree that it is a useful reconciliation and delivery-control
document. I understand it is not implementation authorization and remains
subordinate to the locked October 5 Core, Master Decision Register, and
canonical Programmer Package v1.1.

I am the intended Principal Engineer and propose to lead the implementation.
My counter-offer retains the RFQ's Gate 0 and M0–M7 structure and the current
V1_REQUIRED scope. It clarifies the staffing and delivery basis, explicitly
includes the identity-change safeguard's design and later enforcement, and
maps the required tests and external dependencies. It does not silently remove
required controls to fit the earlier figure.

## 2. Commercial counter-offer

| Work | Fee (NGN) | Duration | Commercial basis |
|---|---:|---:|---|
| Gate 0 — Handoff readiness | **₦250,000** | Up to 5 working days | Fixed fee for authority reconciliation, delivery plan, dependency register, and final milestone schedule. No substantial domain implementation. |
| M0–M7 — V1 delivery | **₦4,850,000** | 100 working days | Fixed-scope programmer/build fee for the RFQ backlog and acceptance gates, on the assumptions in this offer. |
| **Total programmer/build fee** | **₦5,100,000** | **105 working days total** | Gate 0 plus M0–M7; excludes separately identified third-party and operating costs. |

The M0–M7 price remains the original ₦4,850,000 milestone allocation. The
Gate 0 fee is countered at ₦250,000, making the revised total ₦5,100,000.
Schedule is five Gate 0 working days plus 100 M0–M7 working days, excluding
BUYI/provider/legal/pilot delays and other agreed pauses. The schedule begins
only after the required written authorization, signed agreement, and provision
of the governing inputs and access.

### Milestone fees

| Milestone | Fee (NGN) | Working days |
|---|---:|---:|
| Gate 0 — Handoff readiness | ₦250,000 | 5 |
| M0 — Skeleton | ₦600,000 | 10 |
| M1 — Truth & Agreement | ₦600,000 | 10 |
| M2 — Execution Core | ₦700,000 | 15 |
| M3 — Outcome & Review | ₦550,000 | 10 |
| M4 — Problem & Recovery | ₦600,000 | 15 |
| M5 — Closing & Money | ₦900,000 | 20 |
| M6 — Pilot Operations | ₦450,000 | 10 |
| M7 — First Public Door | ₦450,000 | 10 |
| **Total** | **₦5,100,000** | **105** |

Each milestone fee includes implementation, relevant migrations, automated
tests, concise technical documentation, a reproducible build, and a
demonstration against that milestone's RFQ acceptance gate. BUYI's written
acceptance remains the technical acceptance record.

## 3. Delivery and scope commitments

### Principal Engineer and BUYI responsibilities

- I will be the named Principal Engineer and primary delivery owner for
  architecture, domain implementation, integration boundaries, code review,
  automated tests, and handover across M0–M7.
- Gate 0 will record the planned allocation and availability, plus any
  supporting personnel or BUYI-supplied work, in the milestone schedule.
- BUYI supplies timely product/domain decisions, a product owner, company
  repository and accounts, provider/legal contacts, and pilot operations and
  participants where required.
- Any independent security or financial review requiring a separate reviewer
  is **not included** in the programmer/build fee. I will identify the review
  scope and gate; BUYI may appoint/pay the independent reviewer directly or
  authorize a separately priced engagement.

### Identity-change safeguard

- **M0 (₦600,000):** Deliver the RFQ-required ticketed, testable design for
  new-device access, account recovery, credential reset, and payout-destination
  change, including the scoped hold, independent confirmation/review boundary,
  audit requirements, and tests/design evidence.
- **M5 (₦900,000):** Implement and test the enforcement needed to prevent those
  changes, or SMS OTP alone, from enabling immediate settlement. Map test T07
  to the relevant implementation and test evidence.
- No live settlement is authorized by delivery of code alone. It remains gated
  on passing evidence, BUYI policy decisions, and the independent review
  required by BUYI.

### Release tests and money boundaries

The M0–M7 fee includes implementation and demonstration of the 14 RFQ release
tests. The test plan will identify each test's milestone, automated test or
evidence, environment, provider/physical-pilot dependency, and BUYI acceptance
record. Provider `UNKNOWN` remains `UNKNOWN` until reconciled against
authoritative evidence. Funding mocks, provider instructions, delivery, check
results, OTP, and manual operations will not be represented as authoritative
financial or participant-consent facts.

M1/M2 will establish and test readiness/funding interfaces and guards. Provider
specific funding, settlement, refund, webhook, and reconciliation behavior is
completed against the selected provider's documented sandbox and available
test capabilities in M5. BUYI/provider/legal confirmation is a prerequisite
for any live-money activity; software milestones do not constitute such
approval.

The quoted scope is the RFQ's V1_REQUIRED backlog plus ARCHITECT_NOW
foundations, with MANUAL_V1_ALLOWED operations recorded under the required
BUYI controls. ENABLE_LATER and NOT_IN_CURRENT_SCOPE features remain excluded.

## 4. Gate 0 deliverables and dependencies

Within up to five working days after Gate 0 authorization and receipt of the
necessary materials, I will:

1. Reconcile the supplied October 5 authorities, RFQ, breakout, and review
   pack; list conflicts and unresolved product, provider, legal, or operational
   decisions without inventing answers.
2. Map proposed commands, events, guards, and authority sources to the
   canonical Event Catalog and AUTH-001–018. Any unmapped or conflicting item
   remains blocked pending BUYI decision.
3. Confirm delivery roles, planned allocation, milestones, schedule, acceptance
   evidence, and BUYI-supplied responsibilities.
4. Map all 14 release tests to milestone, test/evidence, environment,
   provider/physical-pilot dependency, and acceptance record.
5. Confirm the funding dependency boundary for M1/M2 and provider-specific
   work/test prerequisites for M5.
6. Refresh separately funded infrastructure and operating-cost assumptions;
   distinguish planning estimates from confirmed vendor quotes.

The following are BUYI/provider/legal/operations dependencies. Their absence
pauses affected work and the delivery clock; it does not convert an unresolved
decision into an implementation assumption:

- Locked Core, Master Decision Register, canonical Programmer Package v1.1,
  and completed authority/event references.
- Product policy and privacy decisions, including reservation/review periods,
  holds, recovery, payout timing, and sensitive-field access.
- Selected provider, sandbox credentials and documentation, plus written
  confirmation of custody, settlement/refund capabilities, reversals, and
  reconciliation semantics.
- Legal advice and executed agreements applicable to development and any
  regulated or live-money activity.
- Test participants, controlled supply, qualified checkers/carriers, and
  staged physical-pilot availability.
- BUYI-controlled repository, environments, named accounts, and required
  access.

## 5. Exclusions and change control

The ₦5,100,000 fee excludes cloud infrastructure, third-party tools and
provider charges, legal and regulatory advice/fees, independent security or
financial review, and pilot operating expenses. They require BUYI approval and
are payable separately to the relevant provider/reviewer or under a separate
written authorization. The earlier operating-cost figures are estimates, not
vendor quotations.

Any change to backlog, approved authority, acceptance criteria, provider
count, or delivery responsibilities will be documented before work proceeds,
with its fee, schedule, dependency, and acceptance impact. No unapproved
additional work is implied.

All source, migrations, tests, documentation, build instructions, and
reproducible build artifacts will be delivered in BUYI-controlled accounts
with named, least-privilege access. No shared credentials are required.

## 6. Proposed payment and acceptance terms

For discussion, I propose:

- Gate 0: ₦250,000 following signed agreement and written Gate 0 authorization.
- M0–M7: 30% of each milestone fee on written authorization to start that
  milestone; 70% after the acceptance evidence is demonstrated and BUYI gives
  written acceptance.
- No silence, elapsed time, payment, or user-interface status constitutes
  technical acceptance.
- Taxes, invoicing dates, response/review periods, termination, delay remedies,
  intellectual-property assignment, confidentiality, and background-IP
  schedules are to be agreed in the signed development agreement.
- This counter-offer does not authorize work. Gate 0 and each subsequent
  milestone require the applicable written authorization.

## 7. Acceptance of counter-offer

This is the programmer's counter-offer to BUYI for negotiation. It becomes
binding only when incorporated into a separately executed development
agreement and expressly authorized in writing by both parties.

| Programmer / Principal Engineer | For BUYIspace Technologies Ltd. |
|---|---|
| Name: ______________________________ | Name: ______________________________ |
| Signature: __________________________ | Signature: __________________________ |
| Date: _______________________________ | Date: _______________________________ |
