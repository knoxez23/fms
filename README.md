# pamoja_twalima

Farm management app for crops, livestock, inventory, sales, and farm operations.

## Environment

Copy `.env.example` to `.env` and set:

- `API_BASE_URL`
- `SENTRY_DSN`
- `APP_ENV` (`development` or `production`)
- `ENABLE_LOGGING` (`true` or `false`)

## Quality Gates

Run before pushing:

```bash
flutter analyze
flutter test
```

## Release Pipeline

GitHub Actions workflow `.github/workflows/flutter-release.yml` builds release
artifacts on `v*` tags:

- `app-release.apk`
- `app-release.aab`
