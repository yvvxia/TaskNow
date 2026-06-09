# AGENTS.md — Liveline

A Flutter task/planner app (Android + Windows desktop) with calendar/Gantt,
search, reminders, and zh/en localization. Riverpod + Drift + go_router.

## Architecture (strict one-way dependencies)

```
presentation ─▶ domain ─▶ core/contracts ◀─ data / platform
```

- `lib/features/<feature>/presentation/` — widgets, pages, notifiers.
- `lib/features/<feature>/domain/` — use cases, pure logic, view-state.
- `lib/core/contracts/` — abstract interfaces (`ITaskRepository`, `INotificationService`, …).
- `lib/data/` (Drift) and `lib/platform/` (notifications, settings) — concrete
  implementations, bound to contracts via Riverpod overrides at the composition root.

**`presentation/` and `domain/` MUST NOT import `data/` or `platform/`.** Enforced
by `tool/check_layer_imports.sh` (see `tool/import_lint.md`).

## Adding a feature: l10n + usecase + test (required)

Every new feature/behavior change must:

1. **l10n** — no hardcoded user-facing strings; add keys to **both**
   `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`, then regenerate.
2. **usecase** — data-touching logic in a `*UseCase` under `domain/`, exposed via
   a Riverpod provider; widgets don't call repositories/services directly.
3. **test** — unit test logic (`test/unit/...`), widget-test UI (`test/widget/...`),
   mirroring the `lib/` path.

Full version: `.cursor/rules/feature-conventions.mdc`.

## Common commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift/freezed/riverpod codegen
flutter gen-l10n                                            # regenerate localizations
dart format .
flutter analyze
bash tool/check_layer_imports.sh                           # layer-import lint
flutter test --coverage
dart run tool/check_coverage.dart coverage/lcov.info       # coverage thresholds
```

## Release builds

Use `tool/build.ps1` (Windows host). See `tool/build.md` for sqlite3 native-lib
setup, Android SDK setup, and the Windows AOT note.

```powershell
pwsh tool/build.ps1                  # release Windows + Android
pwsh tool/build.ps1 -Target windows
```

## Generated files

`*.g.dart` / `*.freezed.dart` are generated — never edit by hand; run codegen.
