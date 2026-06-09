# Layer-dependency import lint

Source: `design/00-architecture-overview.md` §3 · `design/07-testing-strategy.md` §7

## Rule

The architecture is layered so that each module is independently testable. The
dependency direction is strictly one-way:

```
presentation ─▶ domain ─▶ core/contracts ◀─ data / platform
```

Therefore:

- **`presentation/` and `domain/` code MUST NOT import `data/` or `platform/`.**
  They depend only on the abstract interfaces in `core/contracts` (e.g.
  `ITaskRepository`, `INotificationService`) plus `core/models`, `core/enums`,
  `core/utils`.
- Concrete implementations (`DriftTaskRepository`, the notification service,
  `SharedPrefsSettingsStore`, …) are bound to those interfaces at the
  **composition root** via Riverpod overrides:
  - `lib/data/data_providers.dart` (`driftDataLayerOverrides`)
  - `main()` and feature `*_providers.dart` wiring.

## Enforcement

- **Static analysis:** `flutter analyze` runs in CI and catches obvious errors.
- **Grep-based gate:** `tool/check_layer_imports.sh` scans every `*.dart` file
  under any `domain/` or `presentation/` directory in `lib/` and reports any
  `import` of `package:plan_list/data/…`, `package:plan_list/platform/…`, or a
  relative path resolving into those layers. This step runs in
  `.github/workflows/ci.yml`.
  - **Default mode is non-blocking** (prints offenders, exits 0).
  - Pass `--strict` to fail the build (exit 1) on any violation. The tree is
    clean as of the `fts_tokenizer` / `setting_keys` migration to `core/`; CI
    may switch to `--strict` when ready.

## Running locally

```bash
bash tool/check_layer_imports.sh           # report only (exit 0)
bash tool/check_layer_imports.sh --strict  # enforce (exit 1 on violations)
```

A clean tree prints `OK: no presentation/domain -> data/platform imports found.`

> Future hardening: replace the grep gate with a `custom_lint` /
> `dart_code_metrics` "banned imports" rule wired into `analysis_options.yaml`
> for editor-level feedback. The grep script is the lightweight Phase-1 gate.
