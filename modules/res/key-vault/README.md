# Key Vault with organizational defaults (scaffold)

> Status: scaffold only. `main.bicep` carries a `// TODO(author):` marker and is
> not yet implemented.

An opinionated wrapper over [`avm/res/key-vault/vault`](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/key-vault/vault)
that layers organizational security defaults so every vault in the estate is
secure by construction.

## Planned organizational defaults

- RBAC authorization (`enableRbacAuthorization: true`), no legacy access policies.
- Deny-by-default network ACLs (`networkAcls.defaultAction: 'Deny'`).
- Soft delete and purge protection enabled.
- Diagnostics wired to a Log Analytics workspace (built-in `diagnosticSettings`).
- `CanNotDelete` lock by default.

## When NOT to use this

- When the AVM defaults already match your policy: consume
  `avm/res/key-vault/vault` directly.
- When you need access-policy mode (legacy): this wrapper is RBAC-only by design.

Pin the latest GA AVM version at implementation time and record it here.
