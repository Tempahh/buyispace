# Programmer Quotation Response Template

Complete this template against the backlog in
[01-milestone-breakout.md](./01-milestone-breakout.md). All values below are
intentionally blank: no fees, durations, or delivery owners were supplied in
the repository or RFQ.

## Estimate basis

- **Duration unit** (working days or calendar weeks):
- **Quote validity**:
- **Currency:** NGN
- **Gate 0 charged separately?**:
- **Total proposed V1 fee (NGN):**
- **Total estimated calendar duration:**
- **Payment schedule proposal** (not agreed until separately signed):
- **Estimate assumptions:**

## Milestone quotation

| Milestone | Duration / unit | Fee (NGN) | Named delivery owner | Dependencies, assumptions, and notes |
|---|---|---:|---|---|
| Gate 0 — Handoff readiness |  |  |  |  |
| M0 — Skeleton |  |  |  |  |
| M1 — Truth & Agreement |  |  |  |  |
| M2 — Execution Core |  |  |  |  |
| M3 — Outcome & Review |  |  |  |  |
| M4 — Problem & Recovery |  |  |  |  |
| M5 — Closing & Money |  |  |  |  |
| M6 — Pilot Operations |  |  |  |  |
| M7 — First Public Door |  |  |  |  |
| **Total** |  |  |  |  |

For each milestone, attach or describe:

- Tangible deliverables, including code, migrations, tests, documentation, and
  reproducible build artifacts as applicable.
- Demo and test evidence; the acceptance gate BUYI can inspect.
- Dependencies, assumptions, external costs, and product/legal/provider
  decisions.
- The point at which BUYI can inspect the result and the evidence needed for
  written acceptance.

## Team and technical approach

| Role / named owner | Responsibilities | Allocation / period | Milestones owned |
|---|---|---|---|
|  |  |  |  |

- **Proposed architecture and stack:**
- **Repository, environments, and access needed at each milestone (and why):**
- **Existing libraries, background IP, third-party services, or AI-generated
  components planned:**

## Open decisions, blockers, and external dependencies

For each item, cite the backlog ID and/or source section. Do not implement an
unapproved interpretation.

| ID / source | Question, blocker, or dependency | Proposed interpretation (if useful) | Owner needed | Schedule / cost impact |
|---|---|---|---|---|
|  |  |  |  |  |

Use **OPEN DECISION — PRODUCT/DOMAIN INPUT REQUIRED** for unresolved domain
rules. Identify payment, settlement, refund, custody, legal, provider, and
physical-pilot dependencies separately.

## Manual V1 proposal

List only operational work that will be human-assisted under
**MANUAL_V1_ALLOWED**. For every step, state the authoritative evidence/record
BUYI will retain, who may perform it, and how it is audited.

| Backlog ID | Human-assisted operation | Authoritative BUYI record/evidence | Authorized role | Audit/control |
|---|---|---|---|---|
|  |  |  |  |  |

## Explicit scope confirmation

- [ ] I have priced all applicable **V1_REQUIRED** rows and their acceptance
      tests.
- [ ] I have priced only the necessary foundation/boundary for
      **ARCHITECT_NOW** rows, not the future feature.
- [ ] I have excluded all **ENABLE_LATER** and
      **NOT_IN_CURRENT_SCOPE** items from the current build price.
- [ ] I understand **MANUAL_V1_ALLOWED** permits operational assistance only;
      it does not permit invented authority, consent, payment confirmation,
      delivery, acceptance, settlement, or other authoritative truth.
- [ ] I will not begin substantial coding without written authorization and a
      completed protection agreement.
- [ ] I understand this RFQ is not a signed development contract and does not
      grant equity, partnership, or intellectual-property rights.

## Questions for BUYI

1. Which canonical requirement or command is unclear? Cite it and state the
   interpretation requiring approval.
2. Which payment, settlement, refund, or custody steps need a licensed
   provider, legal advice, or partner contract?
3. Which `V1_REQUIRED` rows do you propose to operate manually, and what
   authoritative record will BUYI retain?
4. Which acceptance tests need test-provider access or staged physical pilot
   operations?
5. What access, repository, environments, and credentials are needed at each
   milestone, and why?
6. Are any existing libraries, background IP, third-party services, or
   AI-generated components planned?
