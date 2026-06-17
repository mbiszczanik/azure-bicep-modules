# Changelog

All notable changes to this repository are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project
aims to follow semantic versioning per module.

## [0.1.0] - 2026-06-16

### Added

- Repository scaffolding: README with AVM-first positioning and a "when to use
  this vs raw AVM" decision guide, MIT license, strict `bicepconfig.json`,
  `.gitignore`, and design principles documentation.
- Quality CI (`quality.yml`): Bicep build and lint, PSRule for Azure static
  analysis, and markdownlint. Azure DevOps parity pipeline as a reference.
- `ptn/secure-hub-spoke-avnm` pattern module, fully built: hub and spoke virtual
  networks connected with an Azure Virtual Network Manager connectivity
  configuration, an enforced security admin baseline, organizational-default
  network security groups (including outbound lateral-traversal denies), and
  diagnostics. Includes `basic`, `waf-aligned`, and `multi-env` examples and a
  reference deployment test.
- Scaffolds (README, `version.json`, and `// TODO(author):`) for
  `ptn/monitoring-baseline`, `res/key-vault`, `utl/naming`, and `utl/tagging`.
