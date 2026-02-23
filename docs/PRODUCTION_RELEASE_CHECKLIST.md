# Production Release Checklist

## 1. Security Gate
- [ ] `flutter analyze` passes.
- [ ] `flutter test` passes.
- [ ] `cd backend && php artisan test` passes.
- [ ] `cd backend && composer audit` has no critical vulnerabilities.
- [ ] Verify auth throttling works for `/api/v1/login`, `/api/v1/register`.
- [ ] Verify security headers include `X-Request-Id`, `X-Frame-Options`, `X-Content-Type-Options`.

## 2. Data Integrity Gate
- [ ] Offline create/update/delete for inventory syncs without duplication.
- [ ] Offline create/update/delete for tasks syncs without duplication.
- [ ] Deleted inventory items do not reappear after pull sync.
- [ ] Deleted tasks do not reappear after pull sync.
- [ ] Reinstall + login + sync does not create duplicates.

## 3. Backend Readiness
- [ ] Run migrations in staging: `php artisan migrate --force`.
- [ ] Verify API health endpoint: `GET /api/v1/health`.
- [ ] Verify critical APIs:
  - [ ] `/api/v1/tasks`
  - [ ] `/api/v1/inventories`
  - [ ] `/api/v1/sales`
  - [ ] `/api/v1/animals`
  - [ ] `/api/v1/crops`

## 4. Mobile Readiness
- [ ] App starts cleanly on Android physical device.
- [ ] Background sync worker runs after login and on periodic interval.
- [ ] Notifications permissions requested and scheduled reminders trigger.
- [ ] No screen overflow errors on key farm screens.

## 5. Observability
- [ ] API responses include `X-Request-Id`.
- [ ] Server logs include request id context.
- [ ] Error logs reviewed for `500` and sync failures before release.

## 6. Release Decision
- [ ] Staging sign-off complete.
- [ ] Rollback plan documented.
- [ ] Production deployment approved.

