# BUYI — System Architecture Document
## Volume IV of the BUYI Engineering Documentation Suite
**Version:** 1.0 — Final Decision Freeze Baseline  
**Date:** 31 August 2026  
**Prepared by:** BUYIspace Technologies Ltd. — Engineering  
**Classification:** Internal — Confidential  
**Authority:** Derived from the BUYI Programmer Master Build Document (Final Decision Freeze, 31 August 2026), Volume I PRD, Volume II SRS, and Volume III DDD Blueprint.

---

## Table of Contents

1. [Architecture Philosophy](#1-architecture-philosophy)
2. [V1 System Overview](#2-v1-system-overview)
3. [Modular Monolith Structure](#3-modular-monolith-structure)
4. [Technology Stack](#4-technology-stack)
5. [Application Layer Architecture](#5-application-layer-architecture)
6. [Database Architecture](#6-database-architecture)
7. [Event System Architecture](#7-event-system-architecture)
8. [API Gateway & Client Layer](#8-api-gateway--client-layer)
9. [File Storage Architecture](#9-file-storage-architecture)
10. [External Integration Architecture](#10-external-integration-architecture)
11. [Background Job Architecture](#11-background-job-architecture)
12. [Security Architecture](#12-security-architecture)
13. [Observability Architecture](#13-observability-architecture)
14. [Deployment Architecture](#14-deployment-architecture)
15. [Scalability & Evolution Path](#15-scalability--evolution-path)
16. [Disaster Recovery & Data Durability](#16-disaster-recovery--data-durability)
17. [Environment Strategy](#17-environment-strategy)

---

## 1. Architecture Philosophy

### 1.1 Governing Constraints

Every architectural decision in this document is governed by four constraints in priority order:

1. **Correctness** — One real Exchange must complete correctly, repeatedly, and visibly. Correctness beats elegance.
2. **Auditability** — Every money movement, state change, and evidence capture must be permanently traceable. Nothing is silently lost.
3. **Concentration** — Build depth in one zone and category before breadth. Lagos and phones before Nigeria and before global. Architecture must not be over-built for problems BUYI does not yet have.
4. **Provider Independence** — BUYI owns Exchange truth. Payment rails, logistics partners, KYC providers, and SMS gateways are replaceable. The architecture must enforce this separation.

### 1.2 V1 Architecture Decision

BUYI V1 is a **modular monolith**. A single deployable application containing all bounded contexts as separate internal modules with enforced interface boundaries.

This is an explicit decision, not a shortcut. The risks of premature microservices for a V1 product are higher than the risks of a well-structured monolith:

| Premature Microservices | Modular Monolith |
|---|---|
| Distributed transactions required immediately | Local transactions; simple consistency |
| Network latency between every context | In-process calls; fast |
| Service discovery, load balancing, tracing overhead | Single deployment; simpler ops |
| Domain model not yet stable | Module boundaries enforce correctness; refactor internally |
| Kubernetes before BUYI is built | Ship BUYI first |

**Service extraction happens later**, when:
- The domain model is proven in production
- A specific module's load profile justifies independent scaling
- A team boundary makes independent deployment valuable

The module boundaries defined in Volume III DDD Blueprint are preserved throughout V1. Extraction requires no domain model changes — only deployment changes.

---

## 2. V1 System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CLIENT LAYER                                      │
│    Mobile App (iOS/Android)          Web App (React/Next.js)                │
│    BUYI Link Guest View              Admin Dashboard                        │
└───────────────────────────┬─────────────────────────────────────────────────┘
                            │ HTTPS / WSS
┌───────────────────────────▼─────────────────────────────────────────────────┐
│                         API GATEWAY / EDGE                                  │
│   Rate limiting • Auth token validation • Request routing                   │
│   TLS termination • CORS • Static asset CDN                                 │
└───────────────────────────┬─────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────────────────┐
│                    BUYI APPLICATION SERVER                                  │
│                   (Modular Monolith — V1)                                   │
│                                                                             │
│  ┌───────────┐ ┌───────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐   │
│  │ Exchange  │ │Agreement  │ │ Shield   │ │  Check   │ │  Movement    │   │
│  │  Module   │ │  Module   │ │  Module  │ │  Module  │ │   Module     │   │
│  └───────────┘ └───────────┘ └──────────┘ └──────────┘ └──────────────┘   │
│  ┌───────────┐ ┌───────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐   │
│  │ Recovery  │ │Settlement │ │ Identity │ │   Item & │ │Distribution  │   │
│  │  Module   │ │  Module   │ │  Module  │ │ Evidence │ │   Module     │   │
│  └───────────┘ └───────────┘ └──────────┘ └──────────┘ └──────────────┘   │
│  ┌───────────┐ ┌───────────────────────────────────────────────────────┐   │
│  │  Trust &  │ │           Notification Module                         │   │
│  │ Behavior  │ │                                                       │   │
│  └───────────┘ └───────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │            Internal Event Bus (in-process, synchronous V1)         │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │              Background Job Engine (scheduled + queued)            │    │
│  └────────────────────────────────────────────────────────────────────┘    │
└───────────────────────────┬─────────────────────────────────────────────────┘
                            │
          ┌─────────────────┼──────────────────────┐
          │                 │                      │
┌─────────▼──────┐ ┌────────▼───────┐ ┌───────────▼─────────┐
│  PostgreSQL DB  │ │  Blob Storage  │ │  External Services  │
│  (primary)      │ │  (Evidence     │ │  Payment Provider   │
│  Read Replica   │ │   files)       │ │  KYC Provider       │
│  (optional V1+) │ │                │ │  SMS Provider       │
└─────────────────┘ └────────────────┘ │  Logistics Partner  │
                                       └─────────────────────┘
```

---

## 3. Modular Monolith Structure

### 3.1 Module Layout

```
buyi-server/
├── app/                        — Application entry point, server config, DI wiring
├── api/                        — HTTP handlers, request/response DTOs, auth middleware
│   ├── v1/
│   │   ├── exchanges/
│   │   ├── links/              — BUYI Link guest endpoints
│   │   ├── users/
│   │   ├── admin/
│   │   └── webhooks/
│
├── modules/
│   ├── exchange/               — Exchange bounded context
│   │   ├── domain/             — Exchange aggregate, ExchangeParty, value objects
│   │   ├── application/        — Command handlers, query handlers, saga listeners
│   │   ├── infrastructure/     — ExchangeRepository (PostgreSQL), event publisher
│   │   └── api/                — Internal module interface (no direct DB cross-access)
│   │
│   ├── agreement/              — Agreement bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │
│   ├── shield/                 — Payment protection bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │   └── acl/                — PaymentProviderACL
│   │
│   ├── check/                  — Verification bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │
│   ├── movement/               — Fetch/movement bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │   └── acl/                — LogisticsPartnerACL
│   │
│   ├── recovery/               — Problem & recovery bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │
│   ├── settlement/             — Settlement & ledger bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │
│   ├── identity/               — User & KYC bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │   └── acl/                — KYCProviderACL
│   │
│   ├── item-evidence/          — Item snapshot & evidence bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │
│   ├── distribution/           — Share & Earn bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │
│   ├── trust/                  — Trust & behavior bounded context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── api/
│   │
│   └── notification/           — Notification bounded context
│       ├── domain/
│       ├── application/
│       ├── infrastructure/
│       └── api/
│       └── acl/                — SMSProviderACL, PushProviderACL
│
├── shared/
│   ├── domain/                 — Shared value objects: Money, Timestamp, UserId, etc.
│   ├── events/                 — Internal event bus interface & domain event base types
│   ├── persistence/            — DB connection, migration runner, base repository
│   ├── security/               — JWT utilities, HMAC verification
│   └── config/                 — Environment config loading (no secrets in code)
│
├── sagas/                      — Process managers
│   ├── ExchangeLifecycleSaga
│   ├── RefundSaga
│   ├── ReturnSaga
│   └── SettlementEligibilitySaga
│
└── jobs/                       — Scheduled and queued background jobs
    ├── ReservationExpiryJob
    ├── ReviewWindowExpiryJob
    ├── SellerTimeoutJob
    ├── SettlementRetryJob
    └── NotificationRetryJob
```

### 3.2 Module Boundary Rules

These rules are enforced via code review, linting rules (e.g. ArchUnit or equivalent), and team discipline:

| Rule | Detail |
|---|---|
| **No cross-module DB access** | Module A never queries Module B's tables. All cross-module reads use the module's internal API (query method or read model). |
| **No cross-module aggregate instantiation** | Module A never instantiates Module B's aggregate. It references Module B entities by ID only. |
| **Events are the integration language** | Cross-module side effects happen via published domain events, not direct method calls across module boundaries. |
| **Shared kernel is minimal** | Only truly shared types (Money, UserId, Timestamp, base event types) live in `shared/`. Domain concepts stay in their owning module. |
| **ACLs live inside the owning module** | PaymentProviderACL lives inside `shield/acl/`, not in a generic `integrations/` folder. |

---

## 4. Technology Stack

### 4.1 Backend

| Component | Choice | Rationale |
|---|---|---|
| **Language** | TypeScript (Node.js) or Kotlin (JVM) | Both are strongly typed, well-suited to DDD, and have mature PostgreSQL drivers. Final choice at engineering kickoff. |
| **Web Framework** | Fastify (Node) / Ktor (Kotlin) | Low overhead; good middleware support; JSON-first |
| **ORM / Query Builder** | Prisma or TypeORM (Node) / Exposed or jOOQ (Kotlin) | Migrations managed in code; schema versioned |
| **Database** | PostgreSQL 15+ | ACID transactions; JSONB for flexible payloads; excellent row-level locking |
| **Background Jobs** | BullMQ (Node) / Quartz (Kotlin) | Persistent job queues; retry with backoff; job deduplication |
| **In-Process Event Bus** | Custom typed event emitter (V1) | Simple; no network; sufficient for modular monolith |
| **Auth** | JWT (access token, 15min) + Refresh token rotation | Standard; stateless; revocation via refresh token invalidation |
| **Config Management** | Environment variables via dotenv / cloud secrets manager | No secrets in code or version control |

### 4.2 Frontend

| Component | Choice | Rationale |
|---|---|---|
| **Mobile** | React Native | Single codebase for iOS and Android; large ecosystem |
| **Web (Admin + BUYI Link)** | Next.js (React) | SSR for BUYI Link guest views (SEO/sharing previews); SPA for admin |
| **State Management** | React Query / TanStack Query | Server state management; automatic cache invalidation on mutations |
| **Design System** | Custom (warm light, restrained green per brand spec) | No off-the-shelf dark crypto UI kits |

### 4.3 Infrastructure

| Component | Choice | Rationale |
|---|---|---|
| **Cloud** | AWS or GCP (Nigeria region preferred) | Data residency; latency for Lagos users |
| **Compute (V1)** | Single EC2/GCE instance or managed container (ECS/Cloud Run) | Modular monolith needs one deployment; no Kubernetes yet |
| **Database hosting** | AWS RDS PostgreSQL / Cloud SQL | Managed; automated backups; read replicas available when needed |
| **Blob storage** | AWS S3 / GCS | Evidence file storage; 11-nines durability; immutable object policy |
| **CDN** | CloudFront / Cloud CDN | Static assets; signed URL delivery for evidence files |
| **DNS / TLS** | Route53 / Cloud DNS + ACM / Let's Encrypt | HTTPS everywhere |
| **Secrets** | AWS Secrets Manager / GCP Secret Manager | No secrets in environment files committed to version control |

---

## 5. Application Layer Architecture

### 5.1 Request Lifecycle

```
HTTP Request
    │
    ▼
API Gateway (rate limit, TLS termination)
    │
    ▼
Auth Middleware (JWT validation → attach UserId + role to request context)
    │
    ▼
Route Handler (api/v1/exchanges/:id/...)
    │  parses + validates request body → Command DTO
    ▼
Command Bus
    │  routes Command to correct Command Handler
    ▼
Command Handler (in module/application/)
    │  1. Load aggregate via Repository
    │  2. Call aggregate method (business logic)
    │  3. Persist updated aggregate via Repository (optimistic lock)
    │  4. Publish domain events to Internal Event Bus
    │  5. Return result
    ▼
Response Serializer (aggregate state → response DTO)
    │
    ▼
HTTP Response
```

### 5.2 Command Handler Pattern

```typescript
// Example: AcceptTermsCommandHandler
class AcceptTermsCommandHandler {
  constructor(
    private exchangeRepo: ExchangeRepository,
    private agreementService: AgreementService,
    private eventBus: DomainEventBus
  ) {}

  async handle(command: AcceptTermsCommand): Promise<AcceptTermsResult> {
    // 1. Load aggregate
    const exchange = await this.exchangeRepo.findById(command.exchangeId);
    if (!exchange) throw new ExchangeNotFoundError(command.exchangeId);

    // 2. Load current term version (cross-module read via Agreement module API)
    const termVersion = await this.agreementService.getCurrentTermVersion(command.exchangeId);
    if (!termVersion) throw new NoTermVersionError(command.exchangeId);

    // 3. Call aggregate — all business logic lives here, not in the handler
    const [updatedExchange, events] = exchange.acceptTerms({
      partyId: command.partyId,
      termVersionId: termVersion.termVersionId,
      acceptanceMethod: command.acceptanceMethod,
      ipAddress: command.ipAddress
    });

    // 4. Persist (optimistic lock — throws OptimisticLockError if version conflict)
    await this.exchangeRepo.save(updatedExchange);

    // 5. Record acceptance in Agreement module
    await this.agreementService.recordAcceptance(
      termVersion.termVersionId,
      command.partyId,
      command.acceptanceMethod,
      command.ipAddress
    );

    // 6. Publish events — side effects handled by listeners in other modules
    await this.eventBus.publishAll(events);

    return { success: true, newState: updatedExchange.state };
  }
}
```

### 5.3 Query Pattern (CQRS Read Side)

Reads do not go through the aggregate. They go directly to optimised read models (projections built from the database).

```typescript
// Exchange Timeline — a projection, not the aggregate
class ExchangeTimelineQuery {
  async execute(exchangeId: ExchangeId, requestingUserId: UserId): Promise<TimelineView> {
    // Direct SQL query against exchange_events + related tables
    // Returns a flattened, display-ready view
    // No aggregate loading; no business logic
    return this.timelineProjection.build(exchangeId, requestingUserId);
  }
}
```

This separation means:
- Reads are fast (optimised SQL, no aggregate reconstruction)
- Writes are correct (go through aggregate invariants)
- Read models can be rebuilt at any time from the event log

### 5.4 Internal Event Bus (V1)

In V1, the event bus is in-process and synchronous. Events are published after the primary transaction commits, not inside it (to avoid transaction bloat).

```typescript
interface DomainEventBus {
  publish(event: DomainEvent): Promise<void>;
  publishAll(events: DomainEvent[]): Promise<void>;
  subscribe<T extends DomainEvent>(
    eventType: EventType,
    handler: EventHandler<T>
  ): void;
}
```

**V1 implementation:** After the repository `save()` commits, `eventBus.publishAll(events)` is called. Each subscriber is invoked in order. If a subscriber fails, it is logged and retried via the background job system — it does not roll back the primary transaction.

**Phase 2 evolution:** The event bus interface stays the same. The implementation is swapped to an outbox pattern (events written to DB in the same transaction as the aggregate save, then reliably published by a background worker). This guarantees at-least-once delivery without losing events on server crash.

---

## 6. Database Architecture

### 6.1 Database Design Principles

| Principle | Implementation |
|---|---|
| **Append-only for events and ledger** | `exchange_event`, `ledger_entry`, `admin_action`: no DELETE or UPDATE ever; enforced by removing those methods from repositories |
| **Optimistic locking on aggregates** | `version` column on `exchange`, `protected_funds_record`, `movement_job`. Every save uses `WHERE id = :id AND version = :version` |
| **Integer kobo for all money** | All monetary columns are `BIGINT`. DB constraint on `price_breakdown` enforces component sum |
| **Encrypted sensitive fields** | `item_identity.identity_value`, `app_user.phone_number` encrypted at application layer before write. DB stores ciphertext. |
| **JSONB for flexible payloads** | `exchange_event.payload`, `capability_statuses`, `split_instruction.splits`: structured but variable content stored as JSONB |
| **UTC everywhere** | All `TIMESTAMPTZ` columns store UTC. Application layer converts for display. |
| **Foreign keys with appropriate cascade** | Referential integrity enforced. Cascading deletes only on non-critical join tables. |

### 6.2 Migration Strategy

- All schema changes managed via versioned migration files (Flyway / Liquibase / Prisma Migrate)
- Migrations are forward-only. No destructive migrations in production.
- Every migration is reviewed before merge. Money-column changes require two reviewers.
- Zero-downtime migrations: add columns as nullable first; backfill; then add constraint.

### 6.3 Index Strategy

Critical indexes for V1 performance:

```sql
-- Exchange lookups
CREATE INDEX idx_exchange_state ON exchange(current_state);
CREATE INDEX idx_exchange_created ON exchange(created_at DESC);

-- Event log (sequential read by exchange)
CREATE INDEX idx_exchange_event_exchange_seq ON exchange_event(exchange_id, sequence_number);

-- Party lookup (user's exchanges)
CREATE INDEX idx_exchange_party_user ON exchange_party(user_id);

-- Payment idempotency (critical — must be fast)
CREATE UNIQUE INDEX idx_payment_intent_idem ON payment_intent(idempotency_key);

-- Problem lookup
CREATE INDEX idx_problem_exchange_status ON problem(exchange_id, status);

-- Attribution (earner earnings view)
CREATE INDEX idx_attribution_earner ON attribution(earner_id, commission_status);

-- Evidence by exchange
CREATE INDEX idx_evidence_exchange ON evidence_asset(exchange_id);

-- Ledger by exchange
CREATE INDEX idx_ledger_exchange ON ledger_entry(exchange_id, recorded_at);
```

### 6.4 Connection Pooling

- PgBouncer (or equivalent) in transaction-mode pooling sits between the application and PostgreSQL
- Pool size: start at 20 connections; increase based on observed load
- Connection timeout: 5 seconds; query timeout: 30 seconds for normal operations; 120 seconds for report queries

### 6.5 Read Replica (Phase 1+)

V1 starts with a single primary instance. A read replica is added when:
- Admin reporting queries start impacting write latency, OR
- Exchange Timeline queries show p95 > 300ms

The application layer routes writes to primary, reads to replica (configurable per query).

---

## 7. Event System Architecture

### 7.1 V1 — In-Process Synchronous Bus

```
Command Handler
  └── aggregate.command() → returns [updatedAggregate, List<DomainEvent>]
  └── repository.save(updatedAggregate)  ← DB transaction commits here
  └── eventBus.publishAll(events)        ← after commit
        ├── Notification module listener
        ├── Trust module listener
        ├── Distribution module listener
        └── Saga listener (if applicable)
```

Trade-offs:
- Simple. No message broker to operate.
- Events can be lost if the server crashes between `save()` and `publishAll()`.
- Acceptable for V1 pilot. Detected via event log integrity monitoring.

### 7.2 Phase 2 — Transactional Outbox Pattern

When at-least-once delivery is required (before public launch):

```
Command Handler
  └── aggregate.command()
  └── DB Transaction:
        ├── repository.save(updatedAggregate)
        └── outbox_event table.insert(events)   ← same transaction
  └── Transaction commits atomically

Outbox Worker (background job, runs every 100ms):
  └── SELECT unprocessed events from outbox_event
  └── Publish to internal bus (or external message broker)
  └── Mark events as processed
```

This guarantees no event is lost even on crash. The outbox worker handles retries.

### 7.3 Phase 3 — External Message Broker (When Needed)

When service extraction begins, domain events are published to a message broker (AWS SQS/SNS, Google Pub/Sub, or RabbitMQ). Each extracted service subscribes to its relevant event streams.

The domain event schemas defined in Volume III remain unchanged. Only the transport layer changes.

---

## 8. API Gateway & Client Layer

### 8.1 API Gateway Responsibilities

| Responsibility | Implementation |
|---|---|
| TLS termination | Load balancer / API gateway (ALB, Cloud Load Balancer) |
| Rate limiting | Per-IP and per-user limits; stricter on auth and payment endpoints |
| JWT validation | Token signature and expiry checked at gateway; UserId injected into request context |
| CORS | Allowed origins: mobile app, web app, admin dashboard. Not wildcard. |
| Request size limits | Max 50MB for evidence upload endpoints; 1MB for all others |
| Access logging | All requests logged with method, path, status, latency, userId (no PII in logs) |

### 8.2 Authentication Flow

```
1. User registers / logs in with phone number
2. OTP sent via SMS (6-digit, 5-minute expiry)
3. User submits OTP
4. Server validates OTP → issues:
     - access_token: JWT, 15-minute expiry, signed with RS256
     - refresh_token: opaque UUID, 30-day expiry, stored in DB
5. Client includes access_token in Authorization: Bearer header
6. On expiry, client calls /auth/refresh with refresh_token
7. Server validates refresh_token, issues new access_token + rotated refresh_token
8. Old refresh_token is immediately invalidated
```

Admin authentication uses a separate elevated-privilege token flow, distinct from user tokens. Admin actions require a scope claim in the token not present in regular user tokens.

### 8.3 BUYI Link Guest Access

`GET /api/v1/links/:token` requires no authentication.

Returns:
- Item snapshot (model, storage, colour, described condition, accessories)
- Buyer price breakdown
- Protection scope for this listing
- Seller facts (display name, join date, exchange completion count — no PII)
- Check option availability

Does NOT return:
- Seller phone number or contact details
- IMEI or serial number
- Buyer identity

### 8.4 WebSocket / Real-Time Updates

The Exchange Timeline is a living screen. Clients need real-time state updates.

V1 approach: **Polling** (simpler, no WebSocket infrastructure needed for pilot scale).
- Client polls `GET /api/v1/exchanges/:id/timeline` every 5 seconds when viewing an active Exchange.
- Response includes `lastEventSequenceNumber` so client detects new events.

Phase 2: Upgrade to **Server-Sent Events (SSE)** per Exchange channel. No WebSocket complexity; unidirectional; reconnects automatically.

---

## 9. File Storage Architecture

### 9.1 Evidence File Storage

Evidence files (videos, photos) are the most critical data in BUYI. They must be:
- **Immutable after upload** — no overwrite
- **Durable** — 99.999999999% (11 nines)
- **Access-controlled** — not publicly accessible; only via signed URL
- **Verifiable** — hash stored at upload; verifiable at any time

### 9.2 Upload Flow

```
1. Client requests upload URL:
   POST /api/v1/exchanges/:id/evidence/upload-url
   Body: { evidenceType, stage, mimeType, fileSize }

2. Server:
   a. Validates exchange is in the correct stage for this evidence type
   b. Generates a pre-signed upload URL (direct-to-storage, 5-minute expiry)
   c. Creates a pending EvidenceAsset record (status: PENDING)
   d. Returns { uploadUrl, evidenceAssetId }

3. Client uploads file directly to storage (S3/GCS) using pre-signed URL
   (Server not in the upload path — avoids proxy bottleneck for large files)

4. Storage triggers webhook or client confirms:
   POST /api/v1/exchanges/:id/evidence/:evidenceAssetId/confirm
   Body: { uploadedFileHash }

5. Server:
   a. Computes server-side hash of the uploaded file
   b. Compares with client-reported hash
   c. If match: EvidenceAsset.status = ACTIVE; fileHash stored
   d. If mismatch: EvidenceAsset marked as CORRUPT; client must re-upload
```

### 9.3 Signed URL Access

```
Client requests access to evidence:
GET /api/v1/exchanges/:id/evidence/:evidenceAssetId/url

Server:
  a. Validates requesting user is an exchange party OR admin
  b. Checks EvidenceAsset.accessPolicy
  c. Generates signed URL (expiry per access_policy: 1h for parties, 24h for admin)
  d. Returns { signedUrl, expiresAt }

Client fetches directly from storage using signed URL
```

### 9.4 Immutability Enforcement

- S3/GCS bucket policy: **no overwrite, no delete** at the storage level
- Object versioning enabled; only the first version of each object is accessible
- Application-level: `ItemRecordRepository` has no `deleteEvidence()` method
- Infrastructure-level: The service account used by the application has PutObject but NOT DeleteObject permissions on the evidence bucket

---

## 10. External Integration Architecture

### 10.1 Payment Provider Integration

```
BUYI Shield Module
    │
    ├── PaymentProviderACL
    │     ├── POST /provider/payment-intents  (create payment)
    │     ├── POST /provider/refunds          (initiate refund)
    │     └── POST /provider/payouts          (execute payout)
    │
    └── Webhook Receiver
          POST /api/v1/webhooks/payment
          ├── Raw body stored to payment_webhook_log BEFORE processing
          ├── HMAC signature verified (provider public key)
          ├── Duplicate check (provider_event_id in processed_webhook table)
          ├── Parsed by PaymentProviderACL → DomainPaymentEvent
          └── Dispatched to Shield module command handler
```

**Webhook reliability:**
- Webhook endpoint returns HTTP 200 immediately after raw body is stored
- Processing happens asynchronously (background job reads from webhook log)
- If processing fails, the raw webhook is preserved and retried
- Provider receives 200 quickly → no provider-side retry storm

### 10.2 Logistics Partner Integration

V1: Single approved partner. Integration may be API or manual (phone call + digital confirmation entry by BUYI ops). Architecture is identical either way — the `LogisticsPartnerACL` interface is implemented against the actual integration method.

```
Movement Module
    │
    └── LogisticsPartnerACL
          ├── createJob(movementJob)     → PartnerJobReference
          ├── confirmPickup(ref, proof)  → void
          ├── confirmDelivery(ref, proof)→ void
          └── [future] getJobStatus(ref) → MovementJobStatus
```

When the partner is replaced, only `LogisticsPartnerACL` implementation changes. `MovementJob` aggregate is unaffected.

### 10.3 KYC Provider Integration

```
Identity Module
    │
    └── KYCProviderACL
          ├── initiateVerification(userId, level) → ProviderRef
          └── Webhook receiver: POST /api/v1/webhooks/kyc
                ├── Signature verified
                ├── Parsed → KYCStateUpdate
                └── Updates Person.kycState (never via user self-report)
```

KYC thresholds are configuration values from provider policy, not hard-coded in BUYI. Stored in `policy_config` table, not in application code.

### 10.4 SMS Provider Integration

```
Notification Module
    │
    └── SMSProviderACL
          ├── send(maskedPhone, message, idempotencyKey)
          └── Webhook: POST /api/v1/webhooks/sms-delivery
                └── Updates Notification.status = DELIVERED
```

OTP for delivery confirmation is generated by BUYI, stored (hashed) in the database, and sent to the buyer via this channel. OTP expiry is configurable (default: 10 minutes).

---

## 11. Background Job Architecture

### 11.1 Job Categories

| Category | Jobs | Trigger |
|---|---|---|
| **Scheduled** | ReservationExpiryJob, ReviewWindowExpiryJob, SellerTimeoutJob | Time-based; runs every minute |
| **Queued** | SettlementRetryJob, NotificationRetryJob, WebhookProcessingJob | Event-triggered; retry with backoff |
| **Admin-triggered** | RefundRetryJob, ManualReconciliationJob | Admin action in dashboard |

### 11.2 Scheduled Jobs

**ReservationExpiryJob** (every 60 seconds):
```
SELECT exchange_id FROM exchange
WHERE current_state = 'PAYMENT_PENDING'
AND reservation_expires_at < NOW()
AND (payment_grace_period_expires_at IS NULL OR payment_grace_period_expires_at < NOW())

For each expired Exchange:
  → Command: ExpireReservation(exchangeId)
  → Exchange transitions to BUYER_REVIEWING or CANCELLED
  → Inventory released
```

**ReviewWindowExpiryJob** (every 60 seconds):
```
SELECT exchange_id FROM exchange
WHERE current_state = 'REVIEWING'
AND review_window_closes_at < NOW()

For each expired Exchange:
  → Check: Any open Problem with blocks_settlement = true?
  → If none: emit ReviewWindowExpiredNoProblem → settlement eligibility
  → If yes: leave in REVIEWING; alert admin
```

**SellerTimeoutJob** (every 60 seconds):
```
SELECT exchange_id FROM exchange
WHERE current_state = 'AWAITING_SELLER'
AND seller_confirmation_deadline < NOW()

For each timed-out Exchange:
  → Command: SellerTimeout(exchangeId)
  → Exchange transitions to CANCELLED
  → Refund initiated
  → Behavior event recorded: PROMISE_BROKEN for seller
```

### 11.3 Queued Jobs (Retry with Backoff)

All queued jobs use exponential backoff: 1s, 5s, 30s, 2min, 10min, then dead-letter queue.

**SettlementRetryJob:**
```
Triggered when: SettlementFailed event received
Payload: { splitInstructionId, failedSplitIds }

For each failed split:
  → Verify split.payoutStatus ≠ COMPLETED (idempotency)
  → Re-attempt payout with same idempotencyKey
  → On success: mark split COMPLETED
  → On max retries: dead-letter; admin alert
```

**NotificationRetryJob:**
```
Triggered when: Notification.status = FAILED
Payload: { notificationId }

→ Re-attempt delivery via channel
→ On success: status = SENT
→ On max retries: status = PERMANENTLY_FAILED; log
```

**WebhookProcessingJob:**
```
Triggered when: Raw webhook stored in payment_webhook_log
Payload: { webhookLogId }

→ Validate signature (second pass)
→ Check deduplication
→ Process event
→ On success: mark webhook processed
→ On failure: retry with backoff; preserve raw body
```

---

## 12. Security Architecture

### 12.1 Authentication & Authorisation

| Layer | Mechanism |
|---|---|
| User authentication | Phone OTP → JWT (RS256, 15min access + 30d refresh rotation) |
| Admin authentication | Separate elevated-privilege token; distinct scope claim; shorter expiry (8h) |
| Webhook authentication | HMAC signature verification on every request |
| Service-to-service (future) | mTLS when services are extracted |

### 12.2 Authorisation Model

Access control checks happen at the Command Handler layer, not at the aggregate level:

```
Handler receives command with { actorId, actorRole }

Before executing:
  1. Is the actor an ExchangeParty of this Exchange?
  2. Does the actor's role permit this command?
  3. Is the Exchange in a state that allows this command?

Rules examples:
  - BuyerAccept: actor must be BUYER of this Exchange
  - SellerConfirm: actor must be SELLER of this Exchange
  - SubmitCheckResult: actor must be assigned VERIFIER of this CheckJob
  - AdminAction: actor must have admin token with required scope
```

### 12.3 Data Protection

| Data | Protection |
|---|---|
| Phone numbers | Encrypted at rest (AES-256 GCM); never logged in plaintext |
| IMEI / serial numbers | Encrypted at rest; access restricted to exchange parties + admin |
| Payment tokens | Provider-issued opaque tokens only; raw bank details never stored |
| Evidence files | Immutable object storage; signed URL access only; not public |
| JWT private key | Stored in secrets manager; rotated quarterly |
| Database credentials | Secrets manager; not in environment files or version control |
| Webhook signing keys | Secrets manager; rotated on provider instruction |

### 12.4 Input Validation

- All request inputs validated against strict schemas before reaching command handlers
- TypeScript: `zod` or `io-ts` for runtime validation at API boundary
- Kotlin: data class validation with Bean Validation / custom validators
- No dynamic SQL — all database queries use parameterised statements
- File uploads: MIME type validated server-side (not trusted from client header); max size enforced

### 12.5 Secrets Management

```
┌───────────────────────────────────────────┐
│         Secrets Manager                   │
│  (AWS Secrets Manager / GCP Secret Mgr)  │
│                                           │
│  DB_PASSWORD                              │
│  JWT_PRIVATE_KEY                          │
│  PAYMENT_PROVIDER_SECRET_KEY              │
│  PAYMENT_WEBHOOK_SIGNING_KEY              │
│  KYC_API_KEY                              │
│  SMS_API_KEY                              │
│  STORAGE_ACCESS_KEY                       │
└──────────────┬────────────────────────────┘
               │  Fetched at startup; rotated without redeploy
               ▼
         Application Server
         (secrets in memory only; never written to disk or logs)
```

No secrets in `.env` files committed to version control. `.env.example` contains only key names with placeholder values.

---

## 13. Observability Architecture

### 13.1 Three Pillars

| Pillar | Tool | Purpose |
|---|---|---|
| **Logs** | Structured JSON logs → CloudWatch / GCP Logging | Debug, audit, incident investigation |
| **Metrics** | Prometheus / CloudWatch Metrics | Performance, business KPIs, alerting |
| **Traces** | OpenTelemetry → Jaeger / Cloud Trace | Latency diagnosis; request path visibility |

### 13.2 Structured Logging

Every log entry is JSON with mandatory fields:

```json
{
  "timestamp": "2026-08-31T10:00:00.000Z",
  "level": "INFO",
  "service": "buyi-server",
  "module": "exchange",
  "traceId": "abc123",
  "exchangeId": "exch_...",
  "userId": "user_...",
  "event": "ExchangeStateTransition",
  "fromState": "REVIEWING",
  "toState": "SETTLING",
  "durationMs": 42
}
```

**Never log:** phone numbers, IMEI values, payment card data, JWT tokens, raw webhook bodies with sensitive fields. Log only reference IDs.

### 13.3 Key Metrics

**Business metrics (custom):**
```
buyi.exchange.created{category, origin}                — Exchanges created
buyi.exchange.completed{outcome}                       — Exchanges completed
buyi.exchange.problem_opened{type}                     — Problems raised
buyi.settlement.completed{currency}                    — Settlements completed
buyi.settlement.amount_kobo{currency}                  — Volume settled
buyi.check.outcome{result}                             — Check outcomes
buyi.payment.webhook_received{provider, event_type}    — Webhook volume
buyi.notification.sent{channel, template}              — Notifications sent
```

**Integrity alerts (critical):**
```
buyi.integrity.event_sequence_gap                      — Alert: event log gap detected
buyi.integrity.evidence_hash_mismatch                  — Alert: evidence tampered
buyi.integrity.duplicate_payment_prevented             — Alert: dedup fired (should be 0 normally)
buyi.integrity.settlement_blocked_before_release       — Alert: problem froze settlement
```

### 13.4 Alerting Rules

| Alert | Threshold | Severity |
|---|---|---|
| Exchange state transition error rate | > 1% of transitions | HIGH |
| Payment webhook processing latency | p99 > 10s | HIGH |
| Settlement failure | Any unresolved failure > 30min | CRITICAL |
| Evidence hash mismatch | Any occurrence | CRITICAL |
| Event sequence gap | Any occurrence | CRITICAL |
| Review window expiry job lag | > 5min behind schedule | MEDIUM |
| Notification failure rate | > 5% of notifications | MEDIUM |
| DB connection pool saturation | > 80% utilisation | HIGH |

### 13.5 Admin Audit Log

Every `AdminAction` is written to the `admin_action` table (append-only) and simultaneously emitted as a log event. A separate admin audit log stream is preserved with retention of at least 7 years (regulatory baseline).

---

## 14. Deployment Architecture

### 14.1 V1 Deployment

```
┌────────────────────────────────────────────────────────────┐
│                    Production Environment                   │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Load Balancer (HTTPS)                   │  │
│  └──────────────────────┬───────────────────────────────┘  │
│                         │                                  │
│  ┌──────────────────────▼───────────────────────────────┐  │
│  │        Application Server (single instance V1)       │  │
│  │        buyi-server (Node.js / Kotlin JVM)            │  │
│  │        2-4 vCPU, 4-8GB RAM                          │  │
│  └──────────────────────┬───────────────────────────────┘  │
│                         │                                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          PostgreSQL (RDS / Cloud SQL)                 │  │
│  │          Single primary; automated backups daily      │  │
│  │          Point-in-time recovery enabled               │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          Blob Storage (S3 / GCS)                     │  │
│  │          Evidence bucket: versioned, no-delete policy │  │
│  └───────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

V1 is deliberately simple. One application instance. One database. Managed storage. This matches the pilot scale (hundreds of Exchanges, not millions).

### 14.2 CI/CD Pipeline

```
Developer pushes to feature branch
    │
    ▼
GitHub Actions / GitLab CI
    ├── Lint (no rule violations)
    ├── Type check (no type errors)
    ├── Unit tests (all pass)
    ├── Integration tests (all pass against test DB)
    └── Build Docker image
    │
    ▼
PR review (required before merge to main)
    │
    ▼
Merge to main
    │
    ▼
Staging deploy (automatic)
    ├── Run migration against staging DB
    ├── Run smoke tests
    └── Notify engineering
    │
    ▼
Production deploy (manual approval required)
    ├── Run migration against production DB
    ├── Zero-downtime restart (graceful drain)
    └── Monitor error rate for 10 minutes post-deploy
```

### 14.3 Zero-Downtime Deployment

V1 achieves zero-downtime with a simple strategy:
1. New application version starts alongside old version for 30 seconds
2. Load balancer drains existing connections from old version
3. Old version stopped after drain complete
4. Database migrations run **before** new code is deployed (migrations must be backward-compatible with the previous code version)

### 14.4 Rollback Strategy

- Docker image tags are immutable and versioned
- Rollback is a one-click redeploy of the previous image tag
- Database rollback is **not** supported for destructive migrations — forward-only migration discipline prevents this from being needed

---

## 15. Scalability & Evolution Path

### 15.1 V1 Scaling (Vertical)

At pilot scale (hundreds of exchanges per day), a single application instance is sufficient. Vertical scaling (larger instance) is the first response to load growth. This is intentional — premature horizontal scaling adds operational complexity before it's needed.

### 15.2 Phase 2 Scaling (Horizontal Monolith)

When vertical scaling is insufficient:
- Run 2–3 instances behind the load balancer
- Stateless application layer: no in-memory session state; all state in PostgreSQL
- Background jobs use distributed locking (Redis or DB-level advisory locks) to prevent duplicate job execution across instances
- Upgrade event bus to outbox pattern (Phase 2) for reliable cross-instance event delivery

### 15.3 Phase 3 — Service Extraction

When a specific module's traffic profile justifies independent scaling, or when a team boundary makes independent deployment valuable:

**Extraction order (suggested):**
1. **Notification** — highest volume, no complex domain logic, independent scaling makes sense
2. **Evidence/Storage** — heavy file I/O; benefit from independent resource allocation
3. **Settlement** — regulatory sensitivity; dedicated team may want independent deployment
4. **Movement** — logistics partner integration; independent deploy cycle possible

**Each extraction:**
- Module's internal API becomes an HTTP/gRPC service interface
- Internal event bus subscription becomes an external message broker subscription
- Module's database schema is migrated to its own database instance
- No domain model changes required

### 15.4 Database Scaling Path

| Phase | Strategy |
|---|---|
| V1 pilot | Single PostgreSQL primary |
| Phase 2 | Add read replica; route timeline/reporting reads there |
| Phase 3 | Partition `exchange_event` table by month (historical events) |
| Phase 4 | Extract high-volume append-only tables (ledger, events) to TimescaleDB or dedicated append-optimised store |

---

## 16. Disaster Recovery & Data Durability

### 16.1 Recovery Objectives

| Metric | Target | How Achieved |
|---|---|---|
| RTO (Recovery Time Objective) | < 4 hours | Automated DB restore; application redeploy from image registry |
| RPO (Recovery Point Objective) | < 1 hour | Continuous WAL archiving; point-in-time recovery |
| Evidence file durability | 99.999999999% | S3/GCS 11-nines; cross-region replication for evidence bucket |
| Event log durability | Same as primary DB | Evidence of state is as durable as the DB itself |

### 16.2 Backup Strategy

| Data | Backup Method | Retention |
|---|---|---|
| PostgreSQL | Automated daily snapshots + continuous WAL | 30 days snapshots; 7 days WAL |
| Evidence files | Object storage versioning + cross-region replication | Indefinite (legal requirement) |
| Application config | Version controlled | Git history |
| Secrets | Secrets manager versioning | Provider-managed |

### 16.3 Data Integrity Monitoring

- Evidence file hash verification runs nightly: compares stored `file_hash` against current file in storage
- Event log sequence gap check runs hourly: alerts on any gap in `exchange_event.sequence_number`
- Ledger balance reconciliation runs daily: total credits must equal total debits per Exchange
- Settlement reconciliation: every settlement outcome is cross-checked against provider payout confirmation

---

## 17. Environment Strategy

### 17.1 Environments

| Environment | Purpose | Data |
|---|---|---|
| **Local** | Developer machines | Dockerised PostgreSQL; mock provider integrations |
| **Staging** | Integration testing; QA; partner integration testing | Anonymised copy of production schema; sandbox provider credentials |
| **Production** | Live pilot | Real data; live provider credentials |

No other environments. Keeping the environment count low reduces configuration drift and maintenance overhead.

### 17.2 Feature Flags

BUYI has explicit scope gates (BUILD NOW / ARCHITECT NOW / LATER). Feature flags implement the ARCHITECT NOW gates — code exists but is not reachable by users.

```typescript
// Example: outside-origin capability (ARCHITECT NOW / ENABLE LATER)
const FEATURE_FLAGS = {
  OUTSIDE_ORIGIN_EXCHANGES: config.bool('FF_OUTSIDE_ORIGIN', false),
  SHIELD_ONLY_EXCHANGES: config.bool('FF_SHIELD_ONLY', false),
  CHECK_ONLY_EXCHANGES: config.bool('FF_CHECK_ONLY', false),
  PARK_TO_DOOR_FETCH: config.bool('FF_PARK_DOOR', false),
};
```

Flags are configuration values (not hardcoded). Enabling an ARCHITECT NOW capability for a controlled pilot requires a config change + written scope approval — not a code change.

### 17.3 Provider Sandbox Strategy

All external provider integrations must have a sandbox/test mode that can be used in Local and Staging environments:

- Payment provider: sandbox API keys; test card numbers
- KYC provider: sandbox mode; test identity responses
- SMS provider: sandbox mode; messages logged but not sent
- Logistics partner: mock ACL implementation for automated testing

**No production credentials ever in Local or Staging environments.**

---

*End of Volume IV — System Architecture Document*  
*Next: Volume V — Event Catalog*  
*BUYIspace Technologies Ltd. | Internal | Confidential*
