# Naming utility (scaffold)

> Status: scaffold only. `main.bicep` carries a `// TODO(author):` marker and is
> not yet implemented.

A deterministic naming utility that produces organization-standard resource
names from `workload`, `environment`, and `location` inputs. AVM deliberately
does not dictate naming, which makes this genuine custom value rather than a
reimplementation of an AVM module.

## Planned interface

- Inputs: `workload`, `environment`, `location`, optional `instance`.
- Outputs: deterministic names per [`docs/design-principles.md`](../../../docs/design-principles.md),
  for example `{workload}-{environment}-{locationShort}-{abbreviation}`.

The flagship `secure-hub-spoke-avnm` pattern consumes naming via parameters with
sensible defaults, so this utility is not a hard dependency.
