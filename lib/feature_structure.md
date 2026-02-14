Feature-based structure

The project now uses a feature-based architecture where each feature owns:
`presentation`, `application`, `domain`, and `infrastructure`.

Current mapping:

- Core
  - `lib/core/presentation/widgets.dart` -> exports existing core widgets
  - `lib/core/presentation/themes.dart` -> exports app theme files
  - `lib/core/infrastructure/shared_services.dart` -> exports shared infra files

- Farm management
  - Screens are under `lib/farm_mgmt/presentation/<subfeature>/...`
  - Screens are imported directly from their subfeature paths.

- Auth, Inventory, Marketplace, Business/Sales, Profile, Knowledge, Weather, Home
  - Presentation files are imported directly (barrel files removed to reduce indirection).

Next steps (recommended):
- Prefer direct imports from the owning feature/subfeature path.
- Keep domain/application layers independent from `data/*` implementation imports.
- Run `flutter analyze` and tests after each refactor step.
