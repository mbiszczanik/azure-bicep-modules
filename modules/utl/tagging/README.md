# Tagging utility (scaffold)

> Status: scaffold only. `main.bicep` carries a `// TODO(author):` marker and is
> not yet implemented.

A tagging utility that returns a merged tag set combining a mandatory governance
schema with caller-supplied tags. AVM deliberately does not dictate tagging,
which makes this genuine custom value.

## Planned interface

- Inputs: mandatory governance tags (`owner`, `costCenter`, `environment`,
  `dataClassification`) plus an optional free-form tag object.
- Output: a single merged tag object with governance defaults applied.

The flagship `secure-hub-spoke-avnm` pattern accepts a `tags` object directly;
this utility formalizes the mandatory schema for consistent governance.
