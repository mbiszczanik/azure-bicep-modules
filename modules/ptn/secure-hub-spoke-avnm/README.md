# Secure Hub-Spoke with Azure Virtual Network Manager (AVNM)

An opinionated hub-and-spoke pattern that connects spokes to a hub using an
**Azure Virtual Network Manager (AVNM) connectivity configuration** instead of
classic VNet peering, enforces a **centrally managed security admin baseline**
that subnet owners cannot override, and attaches **organizational-default
network security groups and diagnostics** to every spoke.

It is built entirely on Azure Verified Modules (AVM) resource modules. It does
not reinvent any resource that AVM already provides; it composes them.

## Why this exists (the gap it fills)

AVM ships `avm/ptn/network/hub-networking`, but as of June 2026 that module:

- wires connectivity with **classic 1:1 VNet peering**, not AVNM,
- **does not provision NSGs** (it only attaches a pre-existing NSG by ID), and
- is **orphaned** (security and bug fixes only).

This pattern fills exactly that gap: AVNM connectivity (one connectivity
configuration governs every spoke, instead of N peering objects to manage) plus
an enforced security admin baseline and organizational-default NSGs.

## When NOT to use this

Reach for something else when:

- **Classic peering is sufficient.** If you have a small, static number of
  spokes and do not need centralized connectivity management, use
  [`avm/ptn/network/hub-networking`](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/network/hub-networking).
  It is simpler and battle-tested for that case.
- **You need a Virtual WAN topology.** Use
  [`avm/ptn/network/virtual-wan`](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/network/virtual-wan).
- **You need shared edge services (Azure Firewall, Bastion) in the hub.** Those
  are deliberately out of scope here to keep the AVNM and NSG story sharp. Add
  them in the hub separately, or use `hub-networking` which includes them.
- **You only need a single VNet.** Consume `avm/res/network/virtual-network`
  directly.

## Usage

```bicep
module hubSpoke 'br/public:avm/res/...' = {
  // For now, reference the module by relative path until it is published.
  name: 'secure-hub-spoke-avnm'
  params: {
    namePrefix: 'corp-prod-neu'
    hubAddressPrefixes: ['10.0.0.0/24']
    hubSubnets: [
      { name: 'shared', addressPrefix: '10.0.0.0/26' }
    ]
    spokes: [
      {
        name: 'app'
        addressPrefixes: ['10.1.0.0/24']
        subnets: [ { name: 'workload', addressPrefix: '10.1.0.0/26' } ]
      }
    ]
    networkManagerScopes: {
      subscriptions: [ subscription().id ]
    }
  }
}
```

See [`examples/basic`](./examples/basic), [`examples/waf-aligned`](./examples/waf-aligned),
and [`examples/multi-env`](./examples/multi-env).

## Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `namePrefix` | string | Yes | Naming prefix applied to every resource (for example `corp-prod-neu`). |
| `hubAddressPrefixes` | string[] | Yes | Address prefixes for the hub virtual network. |
| `spokes` | spokeInputType[] | Yes | Spoke virtual networks to create and connect to the hub. |
| `networkManagerScopes` | object | Yes | Subscriptions and/or management groups the network manager governs. |
| `location` | string | No | Location for all resources. Defaults to the resource group location. |
| `tags` | object | No | Tags applied to all resources. |
| `hubSubnets` | subnetInputType[] | No | Subnets to create in the hub. Each is associated with the hub NSG. |
| `networkManagerScopeAccesses` | string[] | No | AVNM features to enable. Defaults to `Connectivity` and `SecurityAdmin`. |
| `deleteExistingPeering` | bool | No | Delete existing classic peerings when applying the connectivity config. Default `true`. |
| `defaultNsgSecurityRules` | securityRuleInputType[] | No | Organizational-default NSG rules. Sensible deny baseline by default. |
| `securityAdminRules` | securityAdminRuleInputType[] | No | Centrally enforced AVNM security admin rules. Sensible deny baseline by default. |
| `diagnosticsWorkspaceResourceId` | string | No | Log Analytics workspace resource ID for diagnostics. Empty disables diagnostics. |
| `lock` | lockType | No | Lock to apply to all deployed resources. |
| `enableTelemetry` | bool | No | Enable AVM telemetry. Default `true`. |

## Outputs

| Name | Type | Description |
| --- | --- | --- |
| `networkManagerResourceId` | string | Resource ID of the Azure Virtual Network Manager. |
| `networkManagerName` | string | Name of the Azure Virtual Network Manager. |
| `spokesNetworkGroupResourceId` | string | Resource ID of the spokes network group. |
| `hubVnetResourceId` | string | Resource ID of the hub virtual network. |
| `spokeVnetResourceIds` | array | Resource IDs of the spoke virtual networks. |
| `resourceGroupName` | string | Resource group the resources were deployed into. |

## AVM modules composed (and why)

| AVM module | Pinned version | Why |
| --- | --- | --- |
| `avm/res/network/virtual-network` | 0.9.0 | Hub and spoke VNets and their subnets. |
| `avm/res/network/network-security-group` | 0.5.3 | Organizational-default NSG per hub and per spoke. |
| `avm/res/network/network-manager` | 0.6.1 | The differentiator: AVNM connectivity configuration (HubAndSpoke) and the enforced security admin baseline. |
| `avm/utl/types/avm-common-types` | 0.7.0 | Shared `lockType` for a consistent lock interface. |

Diagnostics use the built-in `diagnosticSettings` parameter on each AVM resource
module (AVM does not have a separate per-resource diagnostics module).

## Defense in depth: two security layers

1. **Subnet NSGs** (`defaultNsgSecurityRules`): the familiar subnet-level
   control, owned by workload teams.
2. **AVNM security admin rules** (`securityAdminRules`): a higher-priority,
   centrally enforced baseline that subnet owners **cannot** override. This is
   the platform team's guardrail.

Both default to denying inbound RDP and SSH from the Internet.

## Roadmap

- Pester integration tests once a deployment target is available.
- Optional dynamic network group membership via Azure Policy.
- Publishing to a private Bicep registry (ACR). See the versioning ADR in the
  repository README.
