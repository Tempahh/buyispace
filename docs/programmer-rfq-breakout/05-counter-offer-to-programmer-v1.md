# BUYI V1 Programmer RFQ — Counterproposal

**Prepared for:** BUYIspace Technologies Ltd.  
**Date:** 3 November 2026  
**Status:** Commercial counterproposal for discussion; not a signed contract or authorization to begin development  
**Currency:** Nigerian Naira (NGN)

## 1. Position

BUYI appreciates the programmer's conditional budgetary draft and the
engineering review in the **BUYI V1 Engineering Review & Completion Pack
(28 October 2026)**.
The review pack is a useful reconciliation and control document, but it is not
a revised quotation: it identifies corrections and gates without proposing a
replacement price or delivery plan.

BUYI does **not** accept ₦5,000,000 and 105 working days as a firm price and
schedule for completing the full M0–M7 V1 scope until the basis is reconciled.
The quotation identifies one primary delivery engineer, and BUYI understands
that you are the intended principal engineer; the issue is not that the
technical lead is unknown. The quotation should confirm your delivery
allocation and clarify which implementation, testing, and independent-review
responsibilities you will own versus any supporting personnel or BUYI-supplied
work. The estimate may be achievable under a lean, tightly bounded delivery
model, but the submitted breakdown does not yet substantiate the effort,
capacity, risk allowance, or independent security/financial review. It also
prices the M0 identity-change safeguard as a design, while the review pack
requires working enforcement before live settlement.

The RFQ scope and its V1_REQUIRED acceptance criteria remain unchanged for
quotation purposes. No required controls or release tests may be silently
removed to fit the earlier cap.

## 2. Commercial proposal

### Gate 0 — the only presently priced engagement

BUYI is prepared to consider Gate 0 at **₦150,000 for up to five working days**,
subject to a signed development/protection agreement and written Gate 0
authorization. Gate 0 is limited to handoff, reconciliation, and estimation;
it is not authorization for substantial domain coding.

Gate 0 must produce:

- Acknowledgement of the governing-document hierarchy and a list of any
  conflicts or missing authorities.
- A mapping of proposed commands, events, guards, and authority sources to the
  canonical Event Catalog and AUTH-001–018; unresolved items remain pending
  and are not implemented.
- A dependency and decision register with named owners and the milestones
  blocked by each item.
- Confirmation that you are the intended principal engineer and delivery
  owner; document your responsibilities, allocation, availability, and any
  additional proposed staff or BUYI-supplied work.
- A revised, itemized fixed-price quotation for M0–M7, with assumptions,
  inclusions, exclusions, milestone durations, acceptance evidence, and a
  dependency-aware schedule.
- A refreshed, separately funded estimate for infrastructure and other
  operating costs, based on identified providers and current quotes where
  available.

Gate 0 acceptance does not automatically award M0 or any later milestone.

### M0–M7 — conditional award after Gate 0

After reviewing and accepting the Gate 0 outputs, BUYI will consider a
separate written award for M0–M7. The programmer must quote the full RFQ scope
and acceptance gates before that award. The earlier **₦5,000,000 cap is not an
approved full-V1 budget** and must not be used to imply that the full scope can
be delivered for that amount.

The revised quote must show, for each milestone:

| Required quotation item | Required detail |
|---|---|
| Fee | Fixed NGN milestone fee, with taxes and any conditional charges identified |
| Effort | Estimated working days and allocation by named role; identify any BUYI-supplied work |
| Schedule | Planned start, duration, critical-path dependencies, and what pauses the clock |
| Deliverables | Code, migrations, tests, documentation, reproducible build, and demonstration evidence |
| Acceptance | Applicable RFQ gate, required test evidence, reviewer, and written BUYI acceptance |
| Exclusions | Provider, legal, infrastructure, pilot, and other costs, with payer and current estimate/source |
| Change control | Written scope, fee, timing, dependency, and acceptance impact before work starts |

Any budget ceiling BUYI later sets must be handled through a written scope
decision before award. It cannot be met by omitting required tests, weakening
authority or audit controls, treating manual activity as system truth, or
quietly deferring V1_REQUIRED work.

## 3. Technical and delivery conditions

1. **Governing inputs:** Reconcile the October 5 locked Core and Master Decision
   Register, canonical Programmer Package v1.1, the RFQ, and this breakout.
   The review pack is subordinate and does not approve new product or provider
   rules. Record conflicts for BUYI decision; do not resolve them by assumption.
2. **Commands and authority:** Map every implemented consequential command,
   event, guard, and authority source to the governing catalog and matrix.
   Descriptive labels in the review pack are not approval of new identifiers.
3. **Identity-change safeguard:** M0 must deliver the required ticketed,
   testable design. The revised quote must separately identify the engineering
   work and tests for enforcing the scoped hold and independent confirmation /
   review before live settlement. SMS OTP alone must never authorize immediate
   settlement. Live settlement is gated on successful tests and the required
   independent review.
4. **Funding dependencies:** M1/M2 must define and test readiness and funding
   boundaries without presenting a mock or provider instruction as real
   funding confirmation. Provider `UNKNOWN` remains `UNKNOWN` until reconciled
   against authoritative evidence.
5. **Release tests:** Map all 14 RFQ release tests to their milestone, automated
   test/evidence, environment, provider test account or physical-pilot
   dependency, and acceptance record. The quote must include the effort to
   implement and demonstrate them.
6. **Security and quality ownership:** Identify who owns automated test
   coverage, integration testing, deployment/reproducibility, and security
   review. Price independent review separately if it is not included in the
   delivery team.
7. **Money and launch gates:** No live funds, settlement, or public launch is
   implied by software acceptance. These require the applicable provider,
   legal, security, and operational confirmations.
8. **Repository and handover:** All source, migrations, tests, build
   instructions, configuration needed to reproduce the build, and operating
   documentation reside in BUYI-controlled accounts. No shared credentials.
9. **Acceptance and payment:** Payment, elapsed time, silence, or a UI status
   is not technical acceptance. Any milestone payment schedule, including
   advances, must be stated in the signed agreement and tied to the written
   acceptance and remedies agreed there.

## 4. Separate costs and estimate reliability

Infrastructure, provider fees, legal advice, data-protection obligations,
pilot operations, and third-party services are separate from programmer fees.
The earlier infrastructure figures are planning assumptions, not confirmed
vendor quotations. The revised estimate must reconcile line items against
subtotals and identify which services are needed for a controlled pilot versus
live funds.

For context only, the earlier programmer/build estimate averages approximately
**₦47,619 per working day** across Gate 0 and M0–M7 (₦5,000,000 ÷ 105 days).
That arithmetic does not establish a fair market rate or prove the estimate
impossible. In light of the intended principal engineer being me, it should
not be treated as evidence that the lead is missing or that the price is
automatically too low. It does show why the quote needs a capacity and effort
basis: the single-primary-engineer plan includes consequential state,
evidence, payment-provider, settlement/refund, operations, and customer-flow
work, while the review pack also calls for complete test evidence and
independent security/financial review. A revised quote should show which of
those responsibilities are included in the fee and schedule.

## 5. Ready-to-send response

> We have reviewed the ₦5,000,000 / 105-working-day budgetary draft and the
> 28 October Engineering Review & Completion Pack. We find the review pack
> useful, but it is not a priced counterproposal. We are not accepting the
> current amount and duration as a firm price for the full M0–M7 V1 scope,
> particularly while effort, allocation of the intended principal engineer
> (me), the identity-change safeguard, release test evidence, provider
> dependencies, and independent review remain unconfirmed.
>
> We are prepared to consider Gate 0 at ₦250,000 for up to five working days
> under a signed agreement and written authorization. Please include the
> reconciliation and revised-quotation deliverables in Section 2. Gate 0 does
> not authorize substantial coding or automatically award later work.
>
> Following Gate 0, please submit a complete itemized fixed-price quotation
> and dependency-aware schedule for the unchanged M0–M7 RFQ scope. Identify
> your named role and allocation, any supporting staff; price working
> enforcement of the identity-change
> safeguard before live settlement; map all 14 release tests; explain the
> M1/M2 funding boundary; and separate current, verified third-party costs
> from programmer fees. Do not remove required controls or tests to meet the
> previous cap. Any scope or budget adjustment requires a written decision
> before award.
>
> This is a request to revise and clarify the quotation, not a development
> contract, acceptance of the earlier full-build estimate, or authorization
> for work beyond an expressly authorized Gate 0.

## 6. Approval record

This counterproposal is for negotiation only. It becomes binding only through a
separately executed agreement and a written authorization specifying the
awarded work, price, schedule, and acceptance terms.

| For BUYIspace Technologies Ltd. | Programmer / delivery provider |
|---|---|
| Name: ______________________________ | Name: ______________________________ |
| Title: ______________________________ | Company: ___________________________ |
| Signature: __________________________ | Signature: __________________________ |
| Date: _______________________________ | Date: _______________________________ |
