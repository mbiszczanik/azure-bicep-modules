#!/usr/bin/env bash
# Offline Bicep validation: build, build-params and lint. No Azure login, no deployment, no what-if.
# Usage: tools/check-bicep.sh [fast]
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v bicep >/dev/null 2>&1; then
  echo "bicep is not on PATH: run 'mise install' (the version is pinned in mise.toml)" >&2
  exit 127
fi

if [ "${1:-}" = "fast" ]; then
  mains=(modules/utl/naming/main.bicep modules/utl/tagging/main.bicep)
  params=()
  lints=("${mains[@]}")
else
  mapfile -t mains < <(find modules -name 'main.bicep' | sort)
  mapfile -t params < <(find modules -name '*.bicepparam' | sort)
  mapfile -t lints < <(find modules -name '*.bicep' | sort)
fi

if [ "${#mains[@]}" -eq 0 ]; then
  echo "no main.bicep found: refusing to report success" >&2
  exit 1
fi

failed=0
run() {
  local label=$1 file=$2
  shift 2
  if "$@" >/dev/null; then
    echo "ok   $label $file"
  else
    echo "FAIL $label $file"
    failed=1
  fi
}

for f in "${mains[@]}"; do run build "$f" bicep build "$f" --stdout; done
for f in "${params[@]}"; do run build-params "$f" bicep build-params "$f" --stdout; done
for f in "${lints[@]}"; do run lint "$f" bicep lint "$f"; done
exit "$failed"
