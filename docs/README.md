# BUYI Engineering Documentation Suite
**BUYIspace Technologies Ltd. — Internal**  
**Final Decision Freeze Baseline: 31 August 2026**  
**Classification: Confidential**

---

> **Source of truth:** All volumes in this suite are derived from and subordinate to the  
> **BUYI Programmer Master Build Document — Final Decision Freeze, 31 August 2026.**  
> Where any conflict exists between a volume and the Master Build Document, the Master Build Document governs.

---

## What BUYI Is

BUYI is an **Exchange Completion Network**. It turns something people want to make happen into a structured Exchange, then coordinates the supported agreement, protection, evidence, checking, movement and recovery needed to complete it.

Internal product law: **What was agreed? → What happened? → What happens next?**

Public simplicity: **Make it happen.**

Pilot: Used phones / selected electronics · Computer Village / Lagos · Nigeria first, global-ready underneath.

---

## The Documentation Suite

| Volume | Document | Purpose | Audience |
|---|---|---|---|
| I | [Product Requirements Document (PRD)](./vol-1-prd.md) | What BUYI is, who it serves, what it must do, and why | Product, Engineering, Design, Operations |
| II | [Software Requirements Specification (SRS)](./vol-2-srs.md) | Precise, testable engineering requirements with FR IDs, data model, state machine, API contracts | Engineering |
| III | [Domain-Driven Design Blueprint](./vol-3-ddd-blueprint.md) | Bounded contexts, aggregates, commands, domain events, invariants, sagas, ADRs | Engineering (lead / senior) |
| IV | [System Architecture Document](./vol-4-system-architecture.md) | Technology stack, modular monolith structure, deployment, security, observability, evolution path | Engineering, DevOps |
| V | [Event Catalog](./vol-5-event-catalog.md) | Every domain event: schema, version, producer, consumers, idempotency rules, flow diagrams | Engineering |
| VI | [Build Roadmap & Timeline](./vol-6-build-roadmap.md) | Week-by-week task breakdown for a 5-person team, milestones, risk register, cost plan | All |

---

## Volume Summaries

### Volume I — Product Requirements Document
The business and product narrative. Covers the full product philosophy (20 principles), problem statement, 5 user personas, success metrics, the Protection Map model, all 4 front doors and 6 engines, the capability matrix, 7 detailed user journeys end-to-end, 10 feature specifications with acceptance criteria and business rules, UX principles, non-functional requirements, the full release roadmap, risks with mitigations, legal boundaries, and a complete glossary.

**Start here if:** you are new to BUYI, a designer, an ops hire, or you need to understand what the product does and why.

---

### Volume II — Software Requirements Specification
The engineering contract. Covers 14 functional requirement domains with FR IDs and P0/P1/P2 priority levels, the full PostgreSQL schema (20+ tables with constraints and indexes), the complete Exchange state machine transition table, API command and query endpoint sketches, 5 external integration specifications, engineering-level NFRs (idempotency, security, observability), and 25 numbered release-blocking engineering tests that must pass before pilot launch.

**Start here if:** you are implementing a feature and need the exact requirements, data model, or state transitions.

---

### Volume III — Domain-Driven Design Blueprint
The tactical domain engineering constitution. Covers the ubiquitous language (with a forbidden synonyms table), all 12 bounded contexts with their aggregates, entities, and value objects, the full commands catalog, the full domain events catalog, all aggregate invariants (enforced in aggregate constructors and command handlers — not service layers), 4 process managers (ExchangeLifecycleSaga, RefundSaga, ReturnSaga, SettlementEligibilitySaga), consistency boundary and transaction rules, repository contracts, anti-corruption layers for all external integrations, and 9 Architecture Decision Records.

**Start here if:** you are designing new domain logic, defining a new aggregate, or deciding where a piece of logic belongs.

---

### Volume IV — System Architecture Document
The infrastructure and engineering operations guide. Covers the full system diagram, the modular monolith folder structure, technology stack choices with rationale, the complete request lifecycle (command pattern + CQRS read side), database architecture (optimistic locking, append-only enforcement, index strategy, migration discipline), the event system evolution path (in-process V1 → outbox Phase 2 → broker Phase 3), API gateway and authentication flow, file storage upload/verify/access architecture, all external integration ACL patterns, background job architecture (scheduled and queued), security architecture (auth, encryption, secrets management), observability (structured logs, metrics, alerts), CI/CD and zero-downtime deployment, scalability phases from vertical monolith to service extraction, disaster recovery, and environment strategy.

**Start here if:** you are setting up infrastructure, configuring deployment, or making decisions about the technology stack.

---

### Volume V — Event Catalog
The integration contract between all bounded contexts. Covers the standard event envelope schema, versioning strategy and breaking-change protocol, idempotency rules and standard consumer pattern, full schemas for all 40+ domain events across 10 bounded contexts, the complete consumer matrix (which context consumes which event), event flow diagrams for key scenarios (happy path, problem/resolution, seller timeout, mismatch cancellation, duplicate webhook handling), a failure and compensation event table, and event log integrity rules including append-only enforcement, sequence number gap detection, and retention policy.

**Start here if:** you are implementing an event consumer, adding a new event, or debugging an unexpected state transition.

---

## Key Engineering Laws (Quick Reference)

These are the non-negotiable rules that govern every implementation decision. Full detail in the Master Build Document.

| # | Law | Engineering Meaning |
|---|---|---|
| 1 | Exchange Law | Every BUYI job is an Exchange. No competing Order/Payment/Delivery truth. |
| 3 | No-Retroactive-Protection | BUYI never protects stages that happened before it entered. `exchange_origin` is immutable. |
| 6 | Exchange Truth | Append-only events. No silent overwrites. Corrections create new events. |
| 7 | Agreement Versioning | Material changes create a new TermVersion. Old acceptances are invalidated. |
| 8 | Commitment Law | Failures reference a specific Commitment + reason code. No vague blame. |
| 9 | Proof Follows the Object | Evidence attaches to `ItemIdentity`, not just to an Exchange. |
| 13 | Custody Law | `currentCustodian` changes only after sufficient handoff evidence. |
| 16 | Settlement Law | Money releases when conditions + evidence are met and no Problem is open. Never from a screen click alone. |
| 17 | Review Law | Review window opens only after sufficient delivery evidence. OTP ≠ buyer acceptance. |
| 18 | Problem Freeze Law | A Problem opened at 23h59m still atomically blocks settlement. |
| 22 | Human Capability Law | Roles are Exchange-specific. No permanent Buyer/Seller account types. |
| 28 | Truthful Language Law | Never use blanket "Verified," "Delivered," "Refunded," or "Guaranteed." State the exact fact. |

---

## Scope Gates (Quick Reference)

| Status | What It Means |
|---|---|
| **BUILD NOW** | Implement for V1 pilot |
| **ARCHITECT NOW / ENABLE LATER** | Code structure may exist; capability not exposed without written approval |
| **LATER** | Do not implement. Not in scope. |
| **DO NOT BUILD NOW** | Explicitly out of scope. If anyone asks, escalate to founder. |

Full gate lists: [PRD §14](./vol-1-prd.md#14-release-roadmap--scope-gates) · [SRS §3 (priority levels)](./vol-2-srs.md#13-requirement-priority-levels)

---

## Release-Blocking Engineering Tests (Quick Reference)

25 tests must pass before V1 pilot launch. Full list with sources: [SRS §20](./vol-2-srs.md#20-release-blocking-engineering-tests).

Most critical:
- Duplicate payment webhook never creates duplicate funds or payout
- Problem at 23h59m atomically blocks settlement
- Delivery OTP creates receipt evidence — never BuyerAccepted
- Review window expiry creates ReviewWindowExpiredNoProblem — never a fabricated BuyerConfirmed
- Evidence used in a decision cannot be deleted by any actor
- Reservation expiry and payment success resolve atomically (no double inventory sale)

---

## Open Policy Items (DO NOT HARD-CODE)

These policies are explicitly **OPEN / PROVIDER-DEPENDENT** in the Master Build Document. Do not invent or hard-code values for these until the exact rule is confirmed with the relevant provider or legal counsel:

| Policy | Status |
|---|---|
| KYC threshold amounts | OPEN / PROVIDER-DEPENDENT |
| Carrier liability cap | OPEN / PROVIDER-DEPENDENT |
| Stale inventory expiry period | OPEN (3-day / 48h-nudge rule to be confirmed) |
| Changed terms response window | OPEN (exact rule to be recovered/approved) |
| Transit protection premium / coverage | LATER / PROVIDER-DEPENDENT |

---

## V1 Milestone

> **First milestone: 1 real protected phone Exchange.**  
> Then 10. Then 100. Then 1,000.  
>  
> Do not make BUYI look powerful by adding features.  
> Make it powerful by completing one real Exchange correctly, repeatedly, and visibly.

---

## Programmer Sign-Off Checklist

Before writing production code, every engineer must confirm:

- [ ] I understand the Exchange is the source of truth and will not create competing Order/Payment/Delivery truth
- [ ] I will not invent transitions, timers, liability, KYC thresholds or coverage promises
- [ ] I will use versioned terms, append-only events, evidence provenance and idempotent consequential actions
- [ ] I understand delivery evidence/OTP is not automatic buyer acceptance
- [ ] I will model `current_custodian` separately from `obligations_by_party`
- [ ] I will implement returns as reverse custody where controlled evidence is required
- [ ] I will preserve modular Exchanges so Check-only and Fetch-only work without fake purchase states
- [ ] I will not expose ARCHITECT NOW / ENABLE LATER capabilities without written scope approval
- [ ] I will provide test evidence for all 25 release-blocking tests before pilot

---

## File Index

```
docs/
├── README.md                    ← This file — master index and quick reference
├── vol-1-prd.md                 ← Volume I: Product Requirements Document
├── vol-2-srs.md                 ← Volume II: Software Requirements Specification
├── vol-3-ddd-blueprint.md       ← Volume III: Domain-Driven Design Blueprint
├── vol-4-system-architecture.md ← Volume IV: System Architecture Document
├── vol-5-event-catalog.md       ← Volume V: Event Catalog
└── vol-6-build-roadmap.md       ← Volume VI: Build Roadmap & Timeline
```

Source document (workspace root):
```
BUYISPACE/
├── buyispace_roadmap.md
├── buyispace_roadmap.docx
└── BUYI-Programmer-Master-Build-Document-FINAL-2026-08-31.docx  ← governing authority
```

---

*BUYIspace Technologies Ltd. · Internal · Confidential*  
*Supersedes all conflicting earlier build instructions*
