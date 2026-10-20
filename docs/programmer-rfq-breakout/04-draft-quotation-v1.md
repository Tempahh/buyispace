# BUYI V1 Programmer Quotation — Draft

**Prepared for:** BUYIspace Technologies Ltd.  
**Prepared on:** 20 October 2026  
**Status:** Budgetary draft for review — not a signed offer or authorization to
start work  
**Currency:** Nigerian Naira (₦)  
**Quote validity proposed:** 30 calendar days, through 19 November 2026  
**Estimate basis:** RFQ dated 8 October 2026 and the 61-row scoped backlog in
[this breakout](./01-milestone-breakout.md)

> This draft provides a working price and schedule for discussion. Named
> personnel, the canonical v1.1 build package, the Locked BUYI Core, the Master
> Decision Register, and the Command & Authority Matrix were not available in
> the repository at the time of drafting. Confirm the assumptions and
> dependencies below before treating this as a firm programmer quotation.

## 1. Quotation summary

| Cost category | Estimate (₦) | Basis |
|---|---:|---|
| Gate 0 — Handoff readiness | ₦150,000 | Separately priced; included in the cap |
| M0–M7 — V1 delivery milestones | ₦4,850,000 | Lean, fixed-scope estimate for the RFQ backlog and acceptance gates |
| **Maximum V1 programmer/build fee** | **₦5,000,000** | **Hard cap; no work above this amount without prior written approval** |

Here, “V1 skill spend” is interpreted as programmer/development spend. The
cap does not include infrastructure, tools, provider charges, legal fees, or
pilot operating costs; these are shown separately below.

**Estimated delivery duration:** 105 working days (21 five-day work weeks),
approximately five calendar months after Gate 0. This estimate assumes one
primary full-stack delivery engineer, BUYI-provided product decisions and
acceptance, managed infrastructure, and manual pilot operations where the RFQ
permits them. Waiting for decisions, provider access, legal clearance, or pilot
availability pauses the schedule.

The cap is a deliberate lean-build budget for the narrower RFQ breakout; it is
not based on the main repo's five-person monthly salary plan. It depends on the
assumptions above, excludes infrastructure and operating expenses, and is not
a commitment to deliver a broader marketplace or the deferred features.

## 2. Milestone quotation

| Milestone | Estimate | Duration | Delivery owner* | Main deliverables and acceptance evidence |
|---|---:|---:|---|---|
| Gate 0 — Handoff readiness | ₦150,000 | 5 working days | Delivery engineer + BUYI product owner | Scope acknowledgement; programmer walkthrough; company-controlled repository/account checklist; contract schedules ready. No substantial domain coding. |
| M0 — Skeleton | ₦600,000 | 10 working days | Delivery engineer | Governed Exchange skeleton, modular monolith structure, migrations, ordered immutable event history, idempotency/concurrency controls, PolicyVersion foundation, audit/access baseline, and testable high-risk identity-change guard design. |
| M1 — Truth & Agreement | ₦600,000 | 10 working days | Delivery engineer | ParticipantResponsibility, supply provenance, availability/reservation records, support assessment/CapabilityInstance, immutable AgreementVersion, AuthorizationEnvelope, readiness guards. |
| M2 — Execution Core | ₦700,000 | 15 working days | Delivery engineer | Final `START_EXECUTION` revalidation, commitments, capability tracking, evidence provenance, custody hooks, provider `UNKNOWN` and reconciliation behavior. |
| M3 — Outcome & Review | ₦550,000 | 10 working days | Delivery engineer | Canonical `ExecutionOutcomeRecorded`, OutcomeRecord and aggregation, scoped challenge/review expiry, separate review completion and closing start. |
| M4 — Problem & Recovery | ₦600,000 | 15 working days | Delivery engineer | Scoped Problems and blocking, separate cause/responsibility findings, RecoveryCase paths, reverse custody/return evidence. |
| M5 — Closing & Money | ₦900,000 | 20 working days | Delivery engineer | FundingRecord/provider adapter, authenticated/idempotent webhooks and raw-event retention, settlement eligibility, separate settlement/refund instructions and confirmations, close guards and PostClosureCase. |
| M6 — Pilot Operations | ₦450,000 | 10 working days | Delivery engineer | Internal operations console, responsibility-aware notifications, policy configuration and provider reconciliation view. |
| M7 — First Public Door | ₦450,000 | 10 working days | Delivery engineer | Thin customer intake for a controlled selected-phone/electronics pilot on the same Exchange engine. |
| **Total** | **₦5,000,000** | **105 working days** | **Named owner to be confirmed before award** | **Gate 0 + M0–M7; programmer/build fee cap.** |

*The cap assumes one primary delivery engineer. BUYI supplies the product
owner/decision-maker and pilot operations. Any requested additional delivery
staff, scope, or work beyond the RFQ requires written repricing before it
starts.

Each milestone includes implementation in the company-controlled repository,
relevant migrations, automated tests, concise technical documentation, a
reproducible build, and a review/demo against that milestone's acceptance gate.
BUYI may inspect deliverables during the milestone; acceptance requires BUYI's
written approval after the gate and evidence are demonstrated.

### 2.1 Proposed payment schedule

The following is a discussion proposal only and is not an agreed payment
schedule:

- Gate 0: ₦150,000 on written authorization to perform Gate 0; no domain
  implementation work is included.
- M0–M7: 30% of each milestone fee at its authorized start and 70% after that
  milestone passes its acceptance gate and BUYI gives written acceptance.
- The combined Gate 0 and M0–M7 programmer/build payments cannot exceed
  ₦5,000,000 without a separately approved written change.
- No silence, elapsed time, or payment is deemed technical acceptance.
- Final invoice dates, payment terms, taxes, and any applicable withholding are
  to be set out in the signed programmer protection/development agreement.

## 3. Delivery team and technical approach

The cap assumes one primary delivery engineer, with BUYI supplying product
ownership, policy decisions, acceptance coordination, and pilot operations.
This lean delivery assumption is not a commitment of a named individual.

| Proposed role | Primary responsibility | Main milestones |
|---|---|---|
| Programmer / full-stack delivery engineer | Exchange domain and API, persistence, tests, provider adapter, operations console, customer intake | M0–M7 |
| BUYI product owner (BUYI-supplied) | Authority decisions, scope clarifications, review and written acceptance | Gate 0 and all milestones |
| BUYI operations (BUYI-supplied) | Manual pilot steps, partner coordination, staged pilot evidence | M2–M7 |

**Provisional technical approach:** modular monolith with explicit module
boundaries, relational persistence and immutable ordered Exchange history,
versioned policy/configuration, idempotent commands, and controlled web
surfaces for the pilot intake and internal operations. A TypeScript/PostgreSQL
implementation is a working assumption, subject to confirmation against the
canonical v1.1 package at Gate 0. Use managed services and a thin responsive web
flow to stay within the cap. This quote does not include a separate native
mobile application, bespoke infrastructure platform, or premature
microservices.

All source, migrations, tests, documentation, and reproducible builds are
delivered to a BUYIspace-controlled repository with named accounts and
least-privilege access. No shared developer credentials are assumed.

## 4. Scope included in this price

- All **V1_REQUIRED** rows B0-01 through B7-02 in the breakout backlog, subject
  to their stated milestone acceptance boundaries.
- **ARCHITECT_NOW** rows A-01 through A-05, limited to foundations and
  boundaries: provider adapter, profile/capability extension point, distribution
  attribution hook, factual behavior-event boundary, and category-neutral
  item/outcome model. No full deferred feature is included.
- Human-assisted pilot operations only where marked
  **MANUAL_V1_ALLOWED**, with controlled BUYI records, evidence provenance,
  accountable actor, and audit trail.
- Planning and demonstration of the 14 RFQ release tests in
  [Acceptance, Dependencies, and Repository Context](./02-acceptance-and-repository-context.md).
- A single controlled Nigeria-first pilot configuration for selected
  phones/electronics; the domain model remains category-neutral.

The core estimate assumes one agreed payment/funding provider adapter and one
pilot integration path. Additional providers, material changes to the
authority model, or new acceptance criteria require written change control.

## 5. Infrastructure and separately funded costs

The **₦5,000,000 programmer/build cap does not include infrastructure**. The
following NGN figures are copied from the main repo's
[Financial Implications Document](../vol-7-financial-implications.md) and are
planning estimates, not current provider quotes. Actual bills depend on region,
traffic, data volume, retention, exchange rate, and provider pricing.

### 5.1 Infrastructure required for the controlled pilot

| Infrastructure component | Pilot estimate (₦/month) | V1 live estimate (₦/month) | Why it is needed |
|---|---:|---:|---|
| Application compute — AWS EC2 | ₦48,000 | ₦48,000 | Runs the modular-monolith API and web application. |
| Managed PostgreSQL — AWS RDS | ₦96,000 | ₦96,000 base | Stores Exchange records, ordered events, agreements, evidence metadata, and audit history. |
| Database resilience — Multi-AZ RDS | Not in pilot estimate | +₦88,000 | Required by the main repo before live funds; failover protection for financial records. |
| Evidence object storage — S3 and requests | ₦11,200 | ₦48,000 | Stores controlled evidence files and associated object requests. |
| CDN and signed evidence delivery — CloudFront | ₦16,000 | ₦24,000 | Delivers static assets and access-controlled evidence. |
| Network and HTTPS ingress — ALB, VPC/NAT, Route 53 | ₦40,000 | ₦40,000 | TLS termination, domain routing, and controlled network access; certificate is listed as no-charge in the repo. |
| Secrets — AWS Secrets Manager | ₦6,400 | ₦9,600 | Stores application/provider credentials. |
| Web application firewall — AWS WAF | Not in pilot estimate | ₦16,000 | Add before public launch, per the main repo estimate. |
| Threat detection — AWS GuardDuty | Not in pilot estimate | ₦12,800–₦24,000 | Add before live operations, per the main repo estimate. |
| Logs, metrics, alarms, dashboards — CloudWatch | ₦24,000 | ₦40,000 | Supports operations, reconciliation, and integrity monitoring. |
| **Detailed line-item subtotal** | **₦241,600/month** | **₦422,400–₦433,600/month** | **Calculated from the component estimates above.** |
| **Published AWS infrastructure estimate** | **₦241,600/month** | **₦411,200/month** | **The main repo's live aggregate is ₦11,200–₦22,400 below its listed component estimates; reconcile before budget approval.** |

At the published pilot rate, ten weeks of infrastructure is approximately
**₦604,000** (2.5 months × ₦241,600), excluding any costs before provisioning
or usage above the assumptions. The live infrastructure estimate is
approximately **₦411,200 per month** as published in the main repo; summing
its live component estimates yields **₦422,400–₦433,600 per month**. That is
**₦4,934,400 published** or **₦5,068,800–₦5,203,200 by component sum** for
12 months at a constant rate. Reconcile the difference before budget approval.
The main repo specifically calls for RDS Multi-AZ before processing live funds.
Do not treat pilot infrastructure as production-ready for live money.

### 5.2 Other operating and setup costs (not in build cap)

| Cost | Main-repo estimate | Treatment |
|---|---:|---|
| Development & engineering tools (main-repo summary budget) | ₦403,200/month | Separate team/tool operating cost; confirm required seats and reconcile with the detailed tool list. |
| AI development usage | ₦80,000/month conservative planning estimate | Usage-based; can be capped or omitted by decision. |
| Design and collaboration tools | ₦273,600/month | Separate operating cost; BUYI may provide existing accounts. |
| SMS / notifications | ₦16,000/month pilot; ₦56,000/month V1 live | Volume-sensitive; provider charges are separate. |
| KYC provider | ₦0 sandbox; ₦80,000–₦320,000/month live estimate | Provider- and policy-dependent; confirm before use. |
| Live security add-ons | ₦0 pilot; approx. ₦32,000/month live | WAF and GuardDuty estimate; confirm against AWS line items to avoid double counting. |
| Fintech legal review | ₦800,000–₦3,200,000 one-time | Required decision/dependency before live customer funds. |
| Data protection / NITDA registration | ₦160,000–₦800,000 one-time | Main-repo planning estimate; verify applicability and current fees. |
| Domain | ₦16,000–₦48,000/year | Estimate from main repo. |
| TablePlus | ₦142,400 one-time | developer tooling; alternative tools may be used. |
| Payment, payout, logistics, verifier, pilot operations | Variable / provider quote | Separate third-party or per-Exchange spend; not included. |

The main repo's planning table gives combined non-salary operating costs of
approximately **₦1,014,400/month for pilot** and **₦1,336,000–₦1,576,000/month
for V1 live**, before one-time setup and legal work. These summary figures
include infrastructure, tools, AI usage, design/collaboration, communications,
and the listed live KYC/security estimates. Some detailed tool and AWS line
items do not reconcile exactly with the summary totals; confirm the current
vendor budget before approval. These operating costs are **not** part of the
programmer/build cap.

### 5.3 Explicit feature exclusions

- **ENABLE_LATER:** L-01 through L-09, including Pay 4 Me, Share & Earn
  experience, Public Live Demand, open national seller network, standalone
  FETCH/Human Carrier/Hub marketplace, public Trust/B-Score, advanced METE AI,
  Ajo/group buying, and multi-sponsor funding.
- **NOT_IN_CURRENT_SCOPE:** N-01 through N-07, including credit/lending,
  BUYI-issued insurance/advanced Shield products, cross-border funding
  complexity, store builder, livestream commerce, property/agriculture/vehicle
  vertical implementations, and a nationwide BUYI-owned logistics network.
- Any capability not present in the RFQ backlog, including a full marketplace,
  standalone seller/rider network, native mobile applications, or a second
  commerce engine.

Taxes and statutory charges must be confirmed and accounted for in the final
agreement/invoice. No cloud, tool, provider, legal, pilot, or operating expense
is chargeable to the programmer/build cap unless BUYI separately approves it in
writing. The repository's financial figures are budget references, not binding
provider quotes.

## 6. Assumptions, dependencies, and open decisions

The estimate and schedule assume:

1. **Authority documents:** Before substantial implementation, BUYI supplies
   and confirms the Locked BUYI Core, Master Decision Register, canonical
   Programmer Package v1.1, and completed Command & Authority Matrix.
2. **Timely decisions:** BUYI assigns a decision-maker and returns domain,
   acceptance, and access decisions within five working days when requested.
   Waiting time pauses the delivery schedule; no disputed rule is invented.
3. **Company access:** BUYI establishes the company-controlled source
   repository, developer accounts, and required environments before M0.
4. **Provider readiness:** BUYI selects and obtains any licensed payment
   provider relationship, sandbox access, integration credentials, webhook
   documentation, and settlement/refund legal clearance needed for M5.
5. **Pilot operation:** BUYI supplies the approved pilot participants,
   controlled supply, operating staff, and staged physical conditions needed to
   demonstrate custody and the end-to-end pilot flow.
6. **Scope stability:** Estimate includes the listed RFQ backlog only; scope
   changes are separately assessed and authorized in writing.

The following remain dependencies and are not silently resolved in this
quotation:

| Dependency / open decision | Needed from | Schedule or price effect |
|---|---|---|
| **OPEN DECISION — PRODUCT/DOMAIN INPUT REQUIRED:** Command authority, permitted transitions, authorization sources, and any unresolved lifecycle/policy rules (Control Artifact 02) | BUYI product/domain authority | M1–M5 cannot safely finalize affected behavior until approved; waiting time pauses the schedule. |
| Legal basis for protected funding, settlement and refund flow; provider confirmation semantics | BUYI legal/finance and selected licensed provider | M5 sandbox work may proceed only within approved boundaries; live-money work and launch are gated on clearance. |
| Provider choice, sandbox credentials, webhook signing/retry rules, reconciliation access, settlement/refund test capability | BUYI and provider | Provider-specific implementation or retesting beyond one selected adapter may change fee and schedule. |
| High-risk identity-change independent confirmation, review/hold policy and thresholds | BUYI product/risk authority | Guard design is included; unresolved policy thresholds are not invented. |
| Availability, reservation expiry, review/challenge windows, cause/responsibility determination and recovery authority | BUYI product/domain authority | Configurable structure is included; the exact policy values and authority rules require written decisions. |
| Custody, return and carrier evidence accepted for the selected pilot path | BUYI operations and pilot partner | Manual records are supported; physical partner access and real-world validation are external dependencies. |
| Test accounts, test data, and participant availability for each acceptance test | BUYI/provider/operations | Missing access or participants pauses the affected demonstration and schedule. |

The quote does not assume live-funds handling or public launch approval. A
provider timeout or indeterminate result remains `UNKNOWN` until reconciled
using authoritative evidence.

## 7. Manual V1 operating boundary

Human assistance is priced only as operational workflow support and recorded
actions, not as a substitute for system truth:

| Work area | Permitted manual activity | BUYI record and control |
|---|---|---|
| Supply and availability (B1-02, B1-03) | Staff contact a controlled supplier and record the response. | Source/provenance, actor, time, availability/reservation result, and supporting evidence recorded on the Exchange. |
| Support assessment (B1-04) | Operations assess whether the requested Exchange is supportable. | Capability assessment, policy version, decision reason, and any limitation recorded. |
| Execution, evidence, and custody (B2-02–B2-05) | Staff/verifier/carrier performs approved pilot tasks and enters observed results. | Actor, stage, item/outcome identity, evidence provenance, custody handoff, time, and provider status retained; `UNKNOWN` is never promoted by assumption. |
| Review, Problems, and recovery (B3-02–B4-04) | Staff assist parties and coordinate an approved recovery path. | Participant acts/findings remain distinct; scope, evidence, basis, responsibility, and authority are recorded. No automatic acceptance or guilt. |
| Funding, settlement, and refund (B5-04–B5-05) | Authorized operations staff initiate an approved provider action. | Instruction and provider confirmation are distinct records; only authoritative provider confirmation records completed money movement. |
| Pilot operations and notifications (B6-01–B6-03) | Operations use approved manual channels and configured policy controls. | Actor, recipient, message/event, policy version, reconciliation evidence, and reason-coded action are auditable. |
| Controlled intake (B7-01–B7-02) | Staff may support customer intake and controlled pilot onboarding. | Intake creates and uses the same Exchange engine; no shadow marketplace record or duplicate lifecycle logic. |

## 8. Change control and acceptance

- Deliverables are reviewed against the specific RFQ milestone gate and
  corresponding acceptance evidence. Written BUYI acceptance is required.
- The 14 release tests are mapped to milestones in the implementation test
  plan; tests depending on providers or physical pilot operations are marked
  with their test environment and dependency.
- A proposed change must state its backlog/reference, scope effect, fee, dates,
  dependencies, and acceptance impact. No change is included without written
  approval.
- A milestone with an unresolved higher-authority decision or missing provider
  evidence is not represented as successfully accepted by a UI state, manual
  note, silence, or payment.
- Work begins only after Gate 0, written authorization, and the completed
  protection/development agreement. This document itself authorizes no work.

## 9. Draft acceptance of quotation

This section is for review only. Signature does not replace the required
protection/development agreement or its intellectual-property, confidentiality,
payment, and termination terms.

| For BUYIspace Technologies Ltd. | Programmer / delivery provider |
|---|---|
| Name: ______________________________ | Name: ______________________________ |
| Title: ______________________________ | Company (if applicable): ____________ |
| Signature: __________________________ | Signature: __________________________ |
| Date: _______________________________ | Date: _______________________________ |

---

**Reference style:** NGN-primary budget tables follow the convention in the
repository's [Financial Implications Document](../vol-7-financial-implications.md).
This draft is a project delivery estimate, not a revision of that operating
budget.
