metadata name = 'Tagging'
metadata description = 'Tagging utility that returns a merged tag set combining a mandatory governance schema with caller-supplied tags. Scaffold only in this release.'

/*=====================================================
SUMMARY: Tagging utility - mandatory governance tag schema.
DESCRIPTION: Planned utility module returning a merged, policy-aligned tag set.
AVM deliberately does not dictate tagging, so this is genuine custom value.
Not yet implemented.
AUTHOR/S: Marcin Biszczanik
VERSION: 0.1.0
=====================================================*/

targetScope = 'resourceGroup'

// TODO(author): implement. Planned interface:
//   inputs : mandatory tags (owner, costCenter, environment, dataClass) + extra tags
//   outputs: a single merged tag object with governance defaults applied
//   The flagship pattern accepts a tags object directly; this formalizes the schema.
