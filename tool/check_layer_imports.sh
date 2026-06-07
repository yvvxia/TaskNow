#!/usr/bin/env bash
# Layer-dependency lint (design/00-architecture-overview.md §3, 07 §7).
#
# Enforces the dependency rule: the `domain` and `presentation` layers must not
# import the `data` or `platform` layers directly — they depend only on
# `core/contracts` interfaces. Cross-module wiring happens via Riverpod
# providers in feature `*_providers.dart` files (composition root), so those are
# allowed to reference data/platform.
#
# By default this is a *non-blocking* gate: it prints any offenders but exits 0
# so it never breaks the pipeline on pre-existing, reviewed exceptions. Pass
# --strict to fail (exit 1) when violations are found.
set -uo pipefail

STRICT=0
for arg in "$@"; do
  [ "$arg" = "--strict" ] && STRICT=1
done

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2

# Match Dart files inside any `domain/` or `presentation/` directory under lib/.
mapfile -t FILES < <(find lib -type f -name '*.dart' \
  \( -path '*/domain/*' -o -path '*/presentation/*' \) )

violations=0
for f in "${FILES[@]}"; do
  # Skip generated files.
  case "$f" in
    *.g.dart|*.freezed.dart) continue ;;
  esac
  # Forbidden: importing the data or platform layers.
  if matches=$(grep -nE "import\s+['\"](package:plan_list/(data|platform)/|(\.\./)+(data|platform)/)" "$f"); then
    echo "Forbidden layer import in $f:"
    echo "$matches"
    violations=$((violations + 1))
  fi
done

if [ "$violations" -gt 0 ]; then
  echo ""
  if [ "$STRICT" -eq 1 ]; then
    echo "FAIL: $violations file(s) violate the layer-dependency rule (strict)."
    exit 1
  fi
  echo "WARNING: $violations file(s) violate the layer-dependency rule (non-blocking)."
  exit 0
fi

echo "OK: no presentation/domain -> data/platform imports found."
