metadata name = 'Key Vault (organizational defaults)'
metadata description = 'An opinionated wrapper over the AVM Key Vault resource module that layers organizational security defaults: RBAC authorization, deny-by-default network ACLs, diagnostics, and a delete lock. Scaffold only in this release.'

/*=====================================================
SUMMARY: Key Vault wrapper - AVM consumption with org defaults.
DESCRIPTION: Planned opinionated wrapper over br/public:avm/res/key-vault/vault
applying organizational security defaults. Not yet implemented.
AUTHOR/S: Marcin Biszczanik
VERSION: 0.1.0
=====================================================*/

targetScope = 'resourceGroup'

// TODO(author): implement. Planned behavior (pin latest GA at build time):
//   - Wrap br/public:avm/res/key-vault/vault
//   - enableRbacAuthorization: true            (no legacy access policies)
//   - networkAcls.defaultAction: 'Deny'        (deny-by-default)
//   - enableSoftDelete + enablePurgeProtection
//   - diagnosticSettings -> workspace via the built-in parameter
//   - lock: CanNotDelete by default
