# Design principles

The opinions this library encodes, and the conventions every module follows.

## 1. AVM-first

Azure Verified Modules are the baseline. Before writing any resource, ask: does
AVM already do this, and does it do it well enough? If yes, consume the AVM
module. Custom code must justify why it is not just AVM. The two justifications
this library accepts are:

1. **Composition**: a pattern that wires several AVM resource modules together
   to solve a scenario AVM does not cover as a single pattern.
2. **Opinion**: organizational defaults (naming, tagging, security posture) that
   AVM deliberately leaves to the consumer.

Each module README states which AVM modules it composes and the gap it fills.

## 2. Taxonomy mirrors AVM

Modules live under `modules/ptn` (patterns), `modules/res` (resource wrappers),
and `modules/utl` (utilities). This matches AVM's own structure so the library
reads as a natural extension of AVM, not a parallel universe.

## 3. Coding conventions

- **camelCase**, AVM-idiomatic. Parameters, variables, and symbolic names use
  plain camelCase (`location`, `hubVnetName`, `networkManager`). The library
  consumes AVM modules constantly, so it reads like AVM rather than introducing a
  competing notation.
- **Header block** on every `main.bicep`: SUMMARY, DESCRIPTION, AUTHOR/S,
  VERSION. A reader should understand a file's purpose from its first lines.
- **No raw-resource API-version pinning policy.** Because modules mostly call
  AVM (`br/public:avm/...`) rather than declaring raw resources, the relevant
  pins are the AVM module versions, which are pinned explicitly and recorded in
  each module README.
- **Strict linting.** `bicepconfig.json` treats correctness rules as errors.
  `use-recent-api-versions` is disabled because pinned AVM versions, not raw API
  versions, are the contract.

## 4. Naming

Resource names should be deterministic and convention-driven. The planned
`utl/naming` module will produce names of the shape
`{workload}-{environment}-{locationShort}-{abbreviation}`. Until it ships,
modules accept a `namePrefix` and derive names from it. This document is the
single source of truth for the naming pattern; modules do not redefine it.

## 5. Tagging

A small set of governance tags is mandatory: `owner`, `costCenter`,
`environment`, and a data classification. The planned `utl/tagging` module will
formalize and merge this schema. Modules accept a `tags` object and apply it to
every resource they create.

## 6. Security posture defaults

- Network security groups deny inbound RDP and SSH from the Internet and deny
  outbound management traffic (lateral traversal) by default.
- Where a platform-wide guarantee is needed, prefer a control that owners cannot
  override. The flagship pattern uses Azure Virtual Network Manager security
  admin rules for exactly this reason: they take precedence over subnet NSGs.
- Diagnostics are wired to a Log Analytics workspace by default when a workspace
  resource ID is supplied, using the built-in `diagnosticSettings` parameter on
  AVM resource modules.
- Resource locks (`CanNotDelete`) are applied to production-grade resources.

## 7. Versioning and distribution

Each module carries a `version.json` starting at `0.1.0`. Distribution is
path-based today and moves to a private Bicep registry (ACR) when a second
consumer appears. See
[ADR-0003](https://github.com/mbiszczanik/azure-architecture-decisions/blob/main/adr/0003-bicep-module-versioning.md).
