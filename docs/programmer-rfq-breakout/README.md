# BUYI V1 Programmer RFQ — Repository Breakout

This folder turns the programmer-facing **BUYI V1 Programmer Scope & Quotation
Request** (8 October 2026) into a standalone, estimate-ready package. The RFQ
drives this package's scope labels, milestone sequence, and lifecycle
terminology; this package is allowed to differ from the older engineering
suite in the parent repository.

It is a breakout and cross-reference, not a replacement for the RFQ or the
canonical build package. It does not supply fees, durations, product decisions,
or approvals that have not been provided.

## Package contents

| Document | Purpose |
|---|---|
| [Milestone and backlog breakout](./01-milestone-breakout.md) | Gate 0 and M0–M7, the RFQ backlog IDs and their scope boundaries |
| [Acceptance, dependencies, and repository context](./02-acceptance-and-repository-context.md) | Cross-milestone controls, release tests, external dependencies, and optional background references |
| [Quotation response template](./03-quotation-response-template.md) | Blank NGN estimate table, delivery-owner/team response, assumptions, exclusions, and questions |
| [Draft V1 quotation](./04-draft-quotation-v1.md) | NGN 5m programmer/build cap, milestone pricing, delivery assumptions, and separate infrastructure/operating estimates for review |

## Governing inputs

1. The RFQ states the authority order as: Locked BUYI Core + Master Decision
   Register; canonical BUYI V1 First Build Programmer Package v1.1; then the RFQ.
2. The RFQ is derived from the 7 October scoped backlog and is a request for
   quotation, not authorization to begin work or a signed development contract.
3. Existing engineering documents in the parent repository are background
   references only for this breakout. They do not override the RFQ's requested
   scope, milestone structure, labels, or terminology.

The RFQ names higher-authority artifacts (Locked BUYI Core + Master Decision
Register and the canonical v1.1 programmer package). They are not present in
the current repository snapshot. If they are supplied, apply the RFQ's stated
authority order; otherwise, do not invent decisions they reserve for those
artifacts.

## Scope labels

Use the labels exactly as defined by the RFQ:

- **V1_REQUIRED** — include in the current build quotation and deliver with
  applicable acceptance tests.
- **ARCHITECT_NOW** — price only the foundation or boundary needed now; do not
  price the full future feature.
- **ENABLE_LATER** — exclude from the current build price; activation requires
  written approval.
- **NOT_IN_CURRENT_SCOPE** — exclude from the current build and price.
- **MANUAL_V1_ALLOWED** — human assistance is allowed for the flagged
  operational step only; authoritative records and controls are still required.

The quotation response template remains blank for a prospective programmer to
complete. The separate draft quotation is a budgetary estimate prepared from
the breakout scope and main-repository cost assumptions; its price, staffing,
and schedule must be validated with the programmer and governing documents
before it is treated as an offer.
