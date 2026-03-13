# Product Audit And Automation Plan

## What the app is today

Pamoja Twalima is no longer just a concept. The current codebase already has:

- Flutter mobile app with feature modules for auth, farm management, inventory, sales, profile, weather, knowledge, and marketplace.
- Laravel API with versioned routes under `/api/v1`, Sanctum auth, request validation, API resources, audit events, and feature tests.
- Offline-first local SQLite storage with sync queues for inventory, tasks, and sales.
- Event-driven task generation for some cases like low stock, breeding follow-up, crop harvest, and animal health alerts.

That is a strong base. The main product problem is not missing CRUD anymore. The main problem is that too much value still depends on the farmer manually recording every action.

## Main findings

### 1. The app is still record-first, not operation-first

Most flows are built around forms:

- add animal
- add crop
- add inventory
- add sale
- add marketplace product

That makes the app feel like work. The next version of the product needs to behave more like an operations assistant:

- suggest the next actions
- create follow-up tasks automatically
- link one action to many records
- reuse existing data instead of asking again

### 2. Farm automation has started, but it is fragmented

There is already a useful automation pattern in the codebase:

- domain events create tasks for low stock, breeding, crop harvest, and health alerts

That is the right direction. The gap is that these automations are not yet turned into a visible system-wide operating model for the farmer.

### 3. Finance is not yet strong enough to power lending later

Sales exist, but the app does not yet capture a complete operating ledger:

- expenses are missing
- receivables and payables are weak
- production-to-sale traceability is incomplete
- inventory consumption is only partly connected

Without structured cashflow and asset-quality history, a future loan engine would be weak or easy to game.

### 4. Marketplace exists as UX, but not yet as a trusted commerce system

Marketplace screens exist, but the current implementation is still local-first and inventory-backed. It is not yet a true verified seller network with:

- seller verification
- product verification
- order flow
- logistics state
- dispute handling
- payout rules

### 5. Lending must be the last major layer, not the next one

Asset-based lending depends on trustworthy operational data. That means lending should only come after:

- reliable farm records
- strong finance records
- verified identity and assets
- stable seller history

If launched before those are mature, default risk and fraud risk will be high.

## Refined product strategy

The marketable version of the app should be positioned as:

**An offline-first farm operating system for African farmers that reduces record keeping, automates routine decisions, and turns farm activity into trusted financial data.**

The product ladder should be:

1. Farm operations autopilot
2. Farm cashflow and unit economics
3. Verified trade network
4. Asset-backed working capital

## Recommended roadmap

### Phase 1. Farm operations autopilot

Goal: remove repetitive manual entry.

Build around these automation loops:

- Animal loop:
  - breeding event creates follow-up tasks
  - feeding schedule deducts inventory and suggests restock
  - health status creates treatment reminders
  - production logs update expected sales supply

- Crop loop:
  - planting date predicts task schedule
  - expected harvest date creates prep tasks
  - weather changes trigger reminders
  - harvest updates available stock and sale readiness

- Daily operator loop:
  - dashboard tells farmer what needs action today
  - one action can update task, inventory, and production records together
  - low-value typing is replaced with defaults, templates, and smart suggestions

Success metric:

- the farmer can complete core daily operations in under 2 minutes

### Phase 2. Finance foundation

Goal: create reliable farm cashflow.

Add:

- expense tracking
- receivables and payables
- enterprise-level profit view by crop, animal unit, or product line
- cash-in vs cash-out timeline
- inventory valuation linked to usage and sales

This is what later supports credit scoring and marketplace pricing.

### Phase 3. Verified marketplace

Goal: turn verified production into real trade.

Add:

- verified farmer profiles
- seller quality score
- inventory-backed listings
- order and inquiry lifecycle
- buyer trust features
- fulfillment and payout controls

Marketplace listings should come from actual farm output and stock, not manual re-entry.

### Phase 4. Lending

Goal: lend against observed farm performance, not just claims.

Only launch this after the system can validate:

- identity
- farm activity consistency
- livestock or crop assets
- repayment behavior
- sales and margin patterns

The first credit product should be narrow:

- short-term input financing
- inventory restock financing
- milk/feed or seed/fertilizer working capital

## Immediate implementation priorities

### Priority A. Turn the dashboard into an operating assistant

The dashboard should show:

- overdue work
- low stock blockers
- harvest window risks
- unpaid sales
- active feeding and treatment plans

This has now been implemented as a first step in the app.

### Priority B. Create linked workflows instead of separate forms

Examples:

- completing feeding should optionally log feed use and inventory deduction together
- recording milk or eggs should suggest a sale draft if inventory is available
- harvesting should suggest stock creation and marketplace readiness

### Priority C. Add finance records before expanding marketplace

The next feature should be expenses and collections, not loans.

## Suggested build order from here

1. Dashboard automation and operational insights
2. Expense tracking and receivables
3. Linked workflows for feeding, production, harvest, and sales
4. Inventory-backed marketplace publishing
5. Verification and trust layer
6. Narrow lending pilot

## What I implemented in this pass

- Added a dashboard operational insights feed derived from existing farm data.
- Surfaced issues like overdue tasks, low stock, harvest windows, pending collections, and active feeding plans directly on the home screen.
- Added tests for the new insight generation logic.

This is the right first move because it shifts the app from passive record storage toward active farm guidance without destabilizing the current architecture.
