# Staff, Roles, and Automation Gap Report

## Current Position

The app is now materially stronger in three areas:

- farm operations can trigger finance, stock, and marketplace draft flows
- local/session data isolation is much safer on shared devices
- the dashboard is becoming an operating assistant instead of a record counter
- onboarding can now seed a real farm workspace with counts, tracking mode, custom livestock/crops/materials, practical feed units, and setup photos

The biggest remaining gap is not feature count. It is system closure.
The app still needs a tighter operating model where one farm action updates all related records, reminders, responsibility, and commercial readiness without the farmer re-entering the same information.

## What The Setup Wizard Now Covers

The farm setup flow is no longer just a preset picker. It now supports:

- common animal and crop presets
- custom livestock, crops, and materials
- real animal counts
- group vs individual animal tracking
- optional animal naming and auto-generated names
- practical farm feed units such as buckets and scoops
- custom material quantities and units
- optional local setup photos for animals and crops
- starter tasks, stock, and feeding plans derived from that richer setup

That is now a solid onboarding base. The remaining work is less about collecting data and more about closing the operating loops after setup.

## Staff Module Recommendation

There is already a basic staff-contact concept in the app through staff contacts and task assignment. That should become a proper farm staff module instead of staying just a contact list.

### Recommended Staff Scope

Add a first-class `Staff` area under farm management with:

- staff profile
- role
- employment status
- assigned animals/crop blocks
- phone
- optional login/account link
- daily task board
- attendance or check-in log later

### Recommended Roles

Start with simple farm roles, not enterprise RBAC complexity:

- `Owner`
  - full control
  - can manage finance, marketplace, staff, settings, verification
- `Manager`
  - can manage operations, assign tasks, review stock, log production, view finance summaries
- `Worker`
  - can view assigned tasks, log feeding, health, harvest, production, inventory counts
- `Accountant`
  - can view or edit business records, expenses, sales, receivables
- `Vet / Advisor`
  - limited health/production advisory access later

### User Types

Do not model “user type” and “role” as the same thing.

Recommended account model:

- `Account user`
  - authenticated identity in the system
- `Farm membership`
  - which farm they belong to
- `Farm role`
  - what they can do in that farm
- `Staff profile`
  - operational/personnel record on the farm

That structure matters because one person may later:

- belong to multiple farms
- be a manager on one farm and advisor on another
- exist as staff without full app login at first

### Recommended Build Order for Staff

1. Add `farms`, `farm_memberships`, and `staff_profiles` on backend.
2. Keep current single-owner assumptions working during migration.
3. Link tasks to `staff_profile_id` and `membership_id`.
4. Add role-based API authorization.
5. Add staff dashboard filtered to assigned work.
6. Add audit logging for staff actions by actor and target.

## What Is Still Missing for a Mostly Automatic Farm OS

### 1. Cross-Module Inventory Closure

Still needed:

- sales should optionally deduct output stock automatically
- marketplace publication should be able to reserve or reference stock
- harvest and production stock should carry freshness/batch context
- input usage should keep reducing inventory from more workflows, not only feeding

### 2. Freshness and Batch Logic

Still needed:

- milk/eggs batch timestamps
- FIFO / oldest-first selling prompts
- spoilage or expiry warnings
- quality grade on stocked produce and animal output

### 3. Commercial Closure

Still needed:

- one-tap “stock to sale”
- one-tap “stock to marketplace listing”
- receivables follow-up automation
- post-sale stock reconciliation

### 4. Staff-Driven Automation

Still needed:

- assigned tasks by worker
- role-specific home views
- simple worker-mode logging screens
- approval flow for sensitive actions like delete/edit finance records

### 5. Notification and Reminder Layer

Still needed:

- low-stock notifications
- today’s feeding reminder
- due treatment reminder
- harvest-ready reminder
- pending payment reminder

### 6. Higher-Quality Financial Intelligence

Still needed:

- expense attribution to animal group / crop / output line
- gross margin per enterprise
- recurring expense detection
- cash forecast based on due tasks and expected harvest/production

### 7. Verification and Trust Layer

Still needed:

- verified farm profile
- verified production capacity
- marketplace trust signals
- operational consistency score from app data

This is necessary before lending should be taken seriously.

### 8. Lending Readiness Layer

Still needed:

- asset register
- livestock and crop valuation snapshots
- production consistency history
- repayment capacity model from actual sales and expense behavior
- fraud-resistant audit and stock integrity

### 9. Backend Governance

Still needed:

- full role-aware authorization
- end-to-end farm scoping instead of mostly single-user ownership
- stronger audit coverage across all important endpoints
- better actor metadata in audits

## Recommended Next Implementation Order

### Phase 1: Operational Closure

- stock deduction from sales
- freshness-aware output batches
- one-tap stock-to-sale
- one-tap stock-to-marketplace

### Phase 2: Staff and Farm Roles

- backend farm membership model
- staff profiles with assignments
- worker-mode task execution
- manager-mode approval and overview

### Phase 3: Notification and Decision Layer

- actionable reminders
- aging stock prompts
- daily task digest by role
- risk/blocker prioritization by enterprise

### Phase 4: Trust and Verification

- verified farm identity
- verified staff and asset records
- production consistency score
- marketplace seller trust score

### Phase 5: Lending Foundation

- asset register
- enterprise P&L by line
- operating consistency score
- repayment capacity and risk signals

## Audit Log Recommendation

The audit trail should answer:

- who did it
- what changed
- on which farm record
- when
- from which workflow
- why it matters operationally

Minimum required audit coverage:

- animals
- crops
- feeding schedules
- feeding logs
- health records
- production logs
- weight records
- inventory
- tasks
- sales
- customers
- suppliers
- staff

Next audit improvements after this pass:

- include actor name / actor role in event metadata
- include changed field values for sensitive updates
- show source workflow such as `onboarding`, `harvest pipeline`, `production draft`, `manual edit`
- add audit filters by entity type and date

## Short Conclusion

The app is now beyond MVP record-keeping. It is entering farm operating system territory.

To become mostly automatic and fully encompassed into farm management, the next decisive moves are:

- close stock/sales/marketplace loops
- introduce real farm staff roles and memberships
- add freshness-aware output handling
- make reminders and assignment flows role-based
- delay lending until verification, trust, and enterprise-level financial integrity are stronger
