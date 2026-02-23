# Mobile Sync QA (Device)

## Preconditions
- Backend running and reachable from device/emulator.
- Test user exists and can authenticate.
- Clear app storage before run.

## A. Inventory Integrity
1. Disable network.
2. Create inventory item, edit it, then delete it.
3. Re-enable network and trigger sync from home/app start.
4. Expected:
   - Item is not re-created locally.
   - Item is not present on server.
   - No duplicate rows in inventory list.

## B. Task Integrity
1. Disable network.
2. Create task, update status/title, then delete another synced task.
3. Re-enable network and wait for sync worker.
4. Expected:
   - New task is created once on server.
   - Updated task matches latest local values.
   - Deleted task does not reappear.

## C. Cross-Screen Consistency
1. Add pending task in Tasks screen.
2. Go to Home/Overview.
3. Expected:
   - Pending task count matches task list.
   - Upcoming task cards match DB/API tasks.

## D. Animal/Crop Data Consistency
1. Add animal and crop records with details.
2. Open detail screens and return to overview.
3. Expected:
   - Values are loaded from persisted data (not placeholders).
   - Production/health/task links display persisted records.

## E. Reinstall Scenario
1. Sync all data online.
2. Reinstall app and log in again.
3. Expected:
   - No duplicate inventory/task records after initial sync.
   - Existing server records are restored correctly.

