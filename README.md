# azure-bicep-modules

An opinionated, **AVM-first** Bicep module library: pattern modules and
organizational defaults for Azure platform engineering.

This library treats [Azure Verified Modules (AVM)](https://aka.ms/avm) as the
baseline. It does not reinvent resource modules that AVM already provides. It
adds value in two places only: opinionated **pattern modules** that compose
multiple AVM resource modules to solve a scenario, and thin **wrappers** that
layer organizational defaults (naming, tagging, diagnostics, locks) on an AVM
resource module.

## When to use these modules vs reaching for raw AVM

This is the most important section. Use the decision below honestly.

| Situation | Use |
| --- | --- |
| You need a single resource (a VNet, a Key Vault, a workspace) | **Raw AVM** (`br/public:avm/res/...`). Do not add a wrapper for its own sake. |
| AVM ships a pattern that already fits (for example peering-based hub-spoke, Virtual WAN) | **Raw AVM pattern** (`br/public:avm/ptn/...`). |
| You need a scenario AVM does not cover, or covers with a gap that matters to you | **A pattern module here.** Each one documents the specific AVM gap it fills and a "When NOT to use this" section. |
| You want AVM resources but with enforced organizational defaults (RBAC-only Key Vault, mandatory tags, deny-by-default networking) | **A wrapper here**, or raw AVM if its defaults already match your policy. |

The flagship `secure-hub-spoke-avnm` is a worked example of this judgment: AVM's
`avm/ptn/network/hub-networking` exists, but it uses classic VNet peering, does
not provision NSGs, and is currently orphaned. This library adds the
Azure Virtual Network Manager (AVNM) based alternative with an enforced security
baseline. If classic peering is enough for you, use the AVM module instead. That
honesty is the point.

## Structure

The taxonomy mirrors AVM's own:

```text
modules/
  ptn/   pattern modules (opinionated compositions of multiple AVM modules)
  res/   resource wrappers (one AVM resource module plus organizational defaults)
  utl/   utility modules (naming, tagging, and other cross-cutting helpers)
```

| Module | Kind | Status |
| --- | --- | --- |
| [`ptn/secure-hub-spoke-avnm`](./modules/ptn/secure-hub-spoke-avnm) | Pattern | Built |
| [`ptn/monitoring-baseline`](./modules/ptn/monitoring-baseline) | Pattern | Scaffold |
| [`res/key-vault`](./modules/res/key-vault) | Wrapper | Scaffold |
| [`utl/naming`](./modules/utl/naming) | Utility | Scaffold |
| [`utl/tagging`](./modules/utl/tagging) | Utility | Scaffold |

Scaffolded modules carry a README, a `version.json`, and a `// TODO(author):`
marker in place of an unverified implementation.

## Versioning

Each module ships a `version.json` carrying a semantic version, starting at
`0.1.0`. The current distribution model is path-based references within this
repository. When a second consumer appears, the modules move to a private Bicep
registry (Azure Container Registry) with per-module semantic versioning.

The rationale, and the trigger for that migration, are documented in the public
[ADR-0003: Versioning Custom Bicep Modules](https://github.com/mbiszczanik/azure-architecture-decisions/blob/main/adr/0003-bicep-module-versioning.md).

## Design principles

See [docs/design-principles.md](./docs/design-principles.md) for naming, tagging,
the AVM-first strategy, and the coding conventions used here.

Related public ADRs:

- [ADR-0001: Choosing a Landing Zone Reference Implementation in Bicep](https://github.com/mbiszczanik/azure-architecture-decisions/blob/main/adr/0001-landing-zone-reference-implementation.md)
- [ADR-0002: Azure Deployment Stacks - Adopt Now or Compensate](https://github.com/mbiszczanik/azure-architecture-decisions/blob/main/adr/0002-deployment-stacks-adopt-or-compensate.md)
- [ADR-0003: Versioning Custom Bicep Modules](https://github.com/mbiszczanik/azure-architecture-decisions/blob/main/adr/0003-bicep-module-versioning.md)

## Quality and CI

The [Quality workflow](./.github/workflows/quality.yml) runs on every pull
request and push to `main`:

- `bicep build` on every `main.bicep` (compile check)
- `bicep lint` (rules configured in [bicepconfig.json](./bicepconfig.json))
- [PSRule for Azure](https://azure.github.io/PSRule.Rules.Azure/) static analysis
  (no Azure authentication required), configured in [ps-rule.yaml](./ps-rule.yaml)
- markdownlint on documentation

An Azure DevOps parity pipeline is provided as a reference in
[pipelines/azure-pipelines.yml](./pipelines/azure-pipelines.yml).

## Roadmap

- Implement the scaffolded modules (`monitoring-baseline`, `res/key-vault`,
  `utl/naming`, `utl/tagging`).
- Pester integration tests for behavioral and deployment validation (requires
  Azure authentication, so out of scope for the static gate above).
- Publish modules to a private Bicep registry (ACR) when a second consumer
  appears, per ADR-0003.
- Optional Azure Deployment Stacks deployment path with deny settings, per
  [ADR-0002](https://github.com/mbiszczanik/azure-architecture-decisions/blob/main/adr/0002-deployment-stacks-adopt-or-compensate.md).

## License

[MIT](./LICENSE).
