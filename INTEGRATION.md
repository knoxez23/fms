# Integration & Local Run

This document explains how to run the backend and the Flutter app locally and how to configure `.env` for API integration during development.

## Backend (Laravel)

1. Copy the example `.env`:

```bash
cp backend/.env.example backend/.env
```

2. Edit `backend/.env` and set at least:

- `APP_URL=http://localhost`
- `DB_CONNECTION` and database credentials
- `CORS_ALLOWED_ORIGINS` — e.g. `http://localhost:3000,http://127.0.0.1:8000`
- `SANCTUM_STATEFUL_DOMAINS` — e.g. `localhost,127.0.0.1`

3. Install PHP dependencies and migrate:

```bash
cd backend
composer install
php artisan key:generate
php artisan migrate
php artisan db:seed # optional
php artisan serve --host=0.0.0.0 --port=8000
```

The API will be available at `http://localhost:8000` and API base at `http://localhost:8000/api`.

## Flutter App

1. Create a `.env` file in the Flutter project root (the Flutter app reads `.env` via `flutter_dotenv`). Add:

```
API_BASE_URL=http://10.0.2.2:8000/api
```

- Use `10.0.2.2` for Android emulator to reach host `localhost`.
- Use your machine IP for real devices: `http://192.168.x.y:8000/api`.

2. Install packages and run the app:

```bash
flutter pub get
flutter run
```

3. Notes

- Authentication tokens are stored securely using `flutter_secure_storage` under the key `auth_token`.
- On `401 Unauthorized` responses the app deletes the token and redirects to the login screen.
- For production, use HTTPS and restrict `CORS_ALLOWED_ORIGINS` to your domain.

## Quick Verification

- Register a user via the app or `POST /api/register`.
- Login via the app; the app should store the token and navigate to `/home`.
- Open `Inventory` screen (in the app) to see items fetched from `/api/inventories` when authenticated.

If you want, I can add more details (Postman collection, integration tests, or CI steps).