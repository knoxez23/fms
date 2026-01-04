Feature-based structure (scaffold)

This repository has been scaffolded with feature folders and re-export (barrel) files
to allow a gradual migration from the existing `lib/ui/...` layout to a feature-based
architecture where each feature contains: presentation, application, domain, infrastructure.

Example mapping created so far:

- Core
  - `lib/core/presentation/widgets.dart` -> exports existing core widgets
  - `lib/core/presentation/themes.dart` -> exports app theme files
  - `lib/core/infrastructure/shared_services.dart` -> exports shared infra files

- Farm management
  - `lib/farm_mgmt/presentation/overview.dart` -> re-exports `lib/ui/farm_mgmt/overview_screen.dart`
  - `lib/farm_mgmt/presentation/crops.dart` -> re-exports crop screens
  - `lib/farm_mgmt/presentation/animals.dart` -> re-exports animal screens
  - `lib/farm_mgmt/presentation/tasks.dart` -> re-exports task screens

- Auth, Inventory, Marketplace, Business/Sales, Profile, Knowledge, Weather, Home
  - Each has a `presentation/*.dart` file that re-exports the existing `lib/ui/...` screens.

Next steps (recommended):
- Create `application`, `domain`, and `infrastructure` folders inside each feature.
- Move domain models (e.g., `crop.dart`, `animal.dart`, `task.dart`) into the feature `domain/entities/` and update imports incrementally.
- Implement repository interfaces in `domain` and concrete implementations in `infrastructure`.
- Replace usages gradually to point at `lib/<feature>/presentation/...` and new domain paths.
- Run `dart analyze` and `flutter format` after each feature migration.

If you'd like, I will now:
1. Create `domain` and `application` placeholders for `farm_mgmt` and move the `crop`/`animal`/`task` models into domain (non-destructively),
2. Update imports for the `overview` pilot feature to use the new structure.
