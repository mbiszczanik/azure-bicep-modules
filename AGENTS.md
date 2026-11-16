# AGENTS.md

## Purpose

Public, AVM-first Bicep library: pattern modules (`modules/ptn`), wrappers (`modules/res`) and utilities (`modules/utl`). The flagship is `ptn/secure-hub-spoke-avnm`. Design rules live in `docs/design-principles.md`.

## Build and check

- `mise install` installs the pinned Bicep CLI (version in `mise.toml`).
- `mise run check:fast`: build and lint of the two utility modules, seconds, no credentials, no Azure call.
- `mise run check`: build, build-params and lint of every module (`tools/check-bicep.sh`); CI runs it. It exits non-zero on any failure and when Bicep is missing.
- PSRule for Azure (`ps-rule.yaml`) and Markdown lint run as separate CI jobs in `.github/workflows/quality.yml`.

## Conventions

- Never reimplement a resource AVM already ships; a pattern module documents the AVM gap it fills and a "When NOT to use this" section.
- Every AVM dependency is pinned to an exact version and listed in the module README with its status; module status and latest version are re-verified (AVM module index, MCR tags) before a release and dated "as of" in the README.
- No module, example or test names a real client, tenant, subscription or resource id; examples use placeholders.
- A module change bumps its `version.json` and adds a `CHANGELOG.md` entry.
- Work goes through a branch and a pull request, never a commit to `main`. A claim that something was tested carries its command, exit code and date.
- Documentation is in English, without em dashes or promotional wording.
