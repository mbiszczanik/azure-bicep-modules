metadata name = 'Naming'
metadata description = 'Deterministic resource naming utility producing organization-standard names from workload, environment, and location inputs. Scaffold only in this release.'

/*=====================================================
SUMMARY: Naming utility - deterministic organization-standard names.
DESCRIPTION: Planned utility module returning standardized resource names.
AVM deliberately does not dictate naming, so this is genuine custom value.
Not yet implemented.
AUTHOR/S: Marcin Biszczanik
VERSION: 0.1.0
=====================================================*/

targetScope = 'resourceGroup'

// TODO(author): implement. Planned interface:
//   inputs : workload, environment, location (and optional instance)
//   outputs: deterministic names per docs/design-principles.md, for example
//            '{workload}-{environment}-{locationShort}-{abbreviation}'
//   The flagship pattern consumes this via parameters; it is not a hard dependency.
