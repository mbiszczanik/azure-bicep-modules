metadata name = 'Secure Hub-Spoke with Azure Virtual Network Manager (AVNM)'
metadata description = 'Opinionated hub-and-spoke pattern that connects spokes to a hub using an Azure Virtual Network Manager connectivity configuration (not classic peering), enforces a centrally managed security admin baseline that subnet owners cannot override, and attaches organizational-default network security groups and diagnostic settings to every spoke. Built entirely on Azure Verified Modules resource modules.'

/*=====================================================
SUMMARY: Secure Hub-Spoke (AVNM) - opinionated AVNM-based hub-and-spoke pattern.
DESCRIPTION: Deploys a hub virtual network and one or more spoke virtual
networks, connects them with an Azure Virtual Network Manager HubAndSpoke
connectivity configuration, enforces a security admin rule baseline across all
spokes, and applies organizational-default network security groups and
diagnostic settings. Composes Azure Verified Modules (AVM) resource modules.
AUTHOR/S: Marcin Biszczanik
VERSION: 0.1.0
=====================================================*/

targetScope = 'resourceGroup'

import { lockType } from 'br/public:avm/utl/types/avm-common-types:0.7.0'

// ============== //
//   Parameters   //
// ============== //

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@minLength(2)
@maxLength(24)
@description('Required. Naming prefix applied to every deployed resource, for example "corp-prod-neu".')
param namePrefix string

@description('Optional. Tags applied to all resources.')
param tags object = {}

@description('Required. Address prefixes for the hub virtual network.')
@minLength(1)
param hubAddressPrefixes string[]

@description('Optional. Subnets to create in the hub virtual network. Each is associated with the hub network security group.')
param hubSubnets subnetInputType[] = []

@description('Required. The spoke virtual networks to create and connect to the hub.')
@minLength(1)
param spokes spokeInputType[]

@description('Required. The scope (subscriptions and/or management groups) the network manager governs.')
param networkManagerScopes networkManagerScopesInputType

@description('Optional. The Azure Virtual Network Manager features to enable.')
param networkManagerScopeAccesses ('Connectivity' | 'SecurityAdmin' | 'Routing')[] = [
  'Connectivity'
  'SecurityAdmin'
]

@description('Optional. Delete existing classic peerings between hub and spokes when the connectivity configuration is applied.')
param deleteExistingPeering bool = true

@description('Optional. Organizational-default NSG security rules applied to every spoke (and hub) network security group. Override to change the subnet-level baseline.')
param defaultNsgSecurityRules securityRuleInputType[] = [
  {
    name: 'DenyRdpInboundFromInternet'
    access: 'Deny'
    direction: 'Inbound'
    priority: 1000
    protocol: 'Tcp'
    sourceAddressPrefix: 'Internet'
    destinationPortRange: '3389'
  }
  {
    name: 'DenySshInboundFromInternet'
    access: 'Deny'
    direction: 'Inbound'
    priority: 1010
    protocol: 'Tcp'
    sourceAddressPrefix: 'Internet'
    destinationPortRange: '22'
  }
  {
    name: 'DenyManagementOutboundLateralTraversal'
    access: 'Deny'
    direction: 'Outbound'
    priority: 1020
    protocol: 'Tcp'
    destinationPortRanges: ['3389', '22']
  }
]

@description('Optional. Organizational-default AVNM security admin rules enforced across all spokes. These take precedence over subnet NSG rules and cannot be overridden by subnet owners. Override to change the centrally enforced baseline.')
param securityAdminRules securityAdminRuleInputType[] = [
  {
    name: 'DenyRdpInboundFromInternet'
    description: 'Centrally enforced deny of inbound RDP from the Internet.'
    access: 'Deny'
    direction: 'Inbound'
    priority: 100
    protocol: 'Tcp'
    destinationPortRanges: ['3389']
    sourceServiceTag: 'Internet'
  }
  {
    name: 'DenySshInboundFromInternet'
    description: 'Centrally enforced deny of inbound SSH from the Internet.'
    access: 'Deny'
    direction: 'Inbound'
    priority: 110
    protocol: 'Tcp'
    destinationPortRanges: ['22']
    sourceServiceTag: 'Internet'
  }
]

@description('Optional. Resource ID of a Log Analytics workspace for diagnostic settings. Leave empty to disable diagnostics.')
param diagnosticsWorkspaceResourceId string = ''

@description('Optional. The lock to apply to all deployed resources.')
param lock lockType?

@description('Optional. Enable or disable usage telemetry for the composed AVM modules.')
param enableTelemetry bool = true

// ============= //
//   Variables   //
// ============= //

var networkManagerName = '${namePrefix}-avnm'
var networkGroupName = 'ng-spokes'
var connectivityConfigurationName = 'cc-hub-and-spoke'
var securityAdminConfigurationName = 'sac-baseline'
var securityAdminRuleCollectionName = 'rc-baseline'

// The network group resource ID is deterministic from the manager name and
// resource group, so it can be referenced by the connectivity and security
// admin configurations that are passed into the same module call.
var networkManagerResourceId = resourceId('Microsoft.Network/networkManagers', networkManagerName)
var spokesNetworkGroupResourceId = '${networkManagerResourceId}/networkGroups/${networkGroupName}'

var diagnosticSettings = empty(diagnosticsWorkspaceResourceId)
  ? null
  : [
      {
        name: 'avnm-default-diagnostics'
        workspaceResourceId: diagnosticsWorkspaceResourceId
      }
    ]

// Map the opinionated NSG rule inputs to the AVM network-security-group rule shape.
var mappedNsgSecurityRules = [
  for rule in defaultNsgSecurityRules: {
    name: rule.name
    properties: union(
      {
        access: rule.access
        direction: rule.direction
        priority: rule.priority
        protocol: rule.protocol
        sourceAddressPrefix: rule.?sourceAddressPrefix ?? '*'
        sourcePortRange: rule.?sourcePortRange ?? '*'
        destinationAddressPrefix: rule.?destinationAddressPrefix ?? '*'
      },
      // A security rule uses either a single port range or a list, not both.
      rule.?destinationPortRanges != null
        ? { destinationPortRanges: rule.?destinationPortRanges }
        : { destinationPortRange: rule.?destinationPortRange ?? '*' }
    )
  }
]

// Map the opinionated security admin rule inputs to the AVM network-manager rule shape.
var mappedSecurityAdminRules = [
  for rule in securityAdminRules: {
    name: rule.name
    description: rule.?description ?? ''
    access: rule.access
    direction: rule.direction
    priority: rule.priority
    protocol: rule.protocol
    destinationPortRanges: rule.?destinationPortRanges
    sources: [
      {
        addressPrefix: rule.sourceServiceTag
        addressPrefixType: 'ServiceTag'
      }
    ]
  }
]

// ============= //
//   Resources   //
// ============= //

// Hub network security group (organizational defaults).
module hubNsg 'br/public:avm/res/network/network-security-group:0.5.3' = {
  name: '${uniqueString(deployment().name, location)}-hub-nsg'
  params: {
    name: '${namePrefix}-hub-nsg'
    location: location
    tags: tags
    securityRules: mappedNsgSecurityRules
    diagnosticSettings: diagnosticSettings
    lock: lock
    enableTelemetry: enableTelemetry
  }
}

// Hub virtual network.
module hubVnet 'br/public:avm/res/network/virtual-network:0.9.0' = {
  name: '${uniqueString(deployment().name, location)}-hub-vnet'
  params: {
    name: '${namePrefix}-hub-vnet'
    location: location
    tags: tags
    addressPrefixes: hubAddressPrefixes
    subnets: [
      for subnet in hubSubnets: {
        name: subnet.name
        addressPrefix: subnet.addressPrefix
        networkSecurityGroupResourceId: hubNsg.outputs.resourceId
      }
    ]
    diagnosticSettings: diagnosticSettings
    lock: lock
    enableTelemetry: enableTelemetry
  }
}

// Per-spoke network security group (organizational defaults).
module spokeNsg 'br/public:avm/res/network/network-security-group:0.5.3' = [
  for (spoke, index) in spokes: {
    name: '${uniqueString(deployment().name, location)}-spoke-nsg-${index}'
    params: {
      name: '${namePrefix}-${spoke.name}-nsg'
      location: location
      tags: tags
      securityRules: mappedNsgSecurityRules
      diagnosticSettings: diagnosticSettings
      lock: lock
      enableTelemetry: enableTelemetry
    }
  }
]

// Spoke virtual networks, each subnet associated with the spoke NSG.
module spokeVnet 'br/public:avm/res/network/virtual-network:0.9.0' = [
  for (spoke, index) in spokes: {
    name: '${uniqueString(deployment().name, location)}-spoke-vnet-${index}'
    params: {
      name: '${namePrefix}-${spoke.name}-vnet'
      location: location
      tags: tags
      addressPrefixes: spoke.addressPrefixes
      subnets: [
        for subnet in spoke.subnets: {
          name: subnet.name
          addressPrefix: subnet.addressPrefix
          networkSecurityGroupResourceId: spokeNsg[index].outputs.resourceId
        }
      ]
      diagnosticSettings: diagnosticSettings
      lock: lock
      enableTelemetry: enableTelemetry
    }
  }
]

// Azure Virtual Network Manager: connectivity (HubAndSpoke) plus security admin baseline.
module networkManager 'br/public:avm/res/network/network-manager:0.6.1' = {
  name: '${uniqueString(deployment().name, location)}-avnm'
  params: {
    name: networkManagerName
    location: location
    tags: tags
    lock: lock
    enableTelemetry: enableTelemetry
    networkManagerScopes: networkManagerScopes
    networkManagerScopeAccesses: networkManagerScopeAccesses
    networkGroups: [
      {
        name: networkGroupName
        description: 'Spoke virtual networks governed by the hub-and-spoke connectivity and security admin baseline.'
        memberType: 'VirtualNetwork'
        staticMembers: [
          for (spoke, index) in spokes: {
            name: spoke.name
            resourceId: spokeVnet[index].outputs.resourceId
          }
        ]
      }
    ]
    connectivityConfigurations: [
      {
        name: connectivityConfigurationName
        description: 'Hub-and-spoke connectivity managed by AVNM instead of classic peering.'
        connectivityTopology: 'HubAndSpoke'
        hubs: [
          {
            resourceId: hubVnet.outputs.resourceId
            resourceType: 'Microsoft.Network/virtualNetworks'
          }
        ]
        deleteExistingPeering: deleteExistingPeering
        isGlobal: false
        appliesToGroups: [
          {
            networkGroupResourceId: spokesNetworkGroupResourceId
            useHubGateway: false
            groupConnectivity: 'None'
            isGlobal: false
          }
        ]
      }
    ]
    securityAdminConfigurations: contains(networkManagerScopeAccesses, 'SecurityAdmin')
      ? [
          {
            name: securityAdminConfigurationName
            description: 'Centrally enforced security admin baseline applied to all spokes.'
            applyOnNetworkIntentPolicyBasedServices: ['AllowRulesOnly']
            ruleCollections: [
              {
                name: securityAdminRuleCollectionName
                description: 'Organizational-default security admin rules.'
                appliesToGroups: [
                  {
                    networkGroupResourceId: spokesNetworkGroupResourceId
                  }
                ]
                rules: mappedSecurityAdminRules
              }
            ]
          }
        ]
      : null
  }
}

// =========== //
//   Outputs   //
// =========== //

@description('The resource ID of the Azure Virtual Network Manager.')
output networkManagerResourceId string = networkManager.outputs.resourceId

@description('The name of the Azure Virtual Network Manager.')
output networkManagerName string = networkManager.outputs.name

@description('The resource ID of the spokes network group.')
output spokesNetworkGroupResourceId string = spokesNetworkGroupResourceId

@description('The resource ID of the hub virtual network.')
output hubVnetResourceId string = hubVnet.outputs.resourceId

@description('The resource IDs of the spoke virtual networks.')
output spokeVnetResourceIds array = [for (spoke, index) in spokes: spokeVnet[index].outputs.resourceId]

@description('The resource group the resources were deployed into.')
output resourceGroupName string = resourceGroup().name

// =========== //
//    Types    //
// =========== //

@export()
@description('A subnet to create within a virtual network.')
type subnetInputType = {
  @description('Required. The name of the subnet.')
  name: string

  @description('Required. The address prefix for the subnet, in CIDR notation.')
  addressPrefix: string
}

@export()
@description('A spoke virtual network to create and connect to the hub.')
type spokeInputType = {
  @description('Required. Short name of the spoke, used in resource names and as the static member name.')
  name: string

  @description('Required. Address prefixes for the spoke virtual network.')
  addressPrefixes: string[]

  @description('Required. Subnets to create in the spoke virtual network. Each is associated with the spoke network security group.')
  @minLength(1)
  subnets: subnetInputType[]
}

@export()
@description('The scope the network manager governs.')
type networkManagerScopesInputType = {
  @description('Optional. Subscription resource IDs in scope, for example "/subscriptions/00000000-0000-0000-0000-000000000000".')
  subscriptions: string[]?

  @description('Optional. Management group resource IDs in scope.')
  managementGroups: string[]?
}

@export()
@description('An opinionated, single-value network security group rule.')
type securityRuleInputType = {
  @description('Required. The name of the rule.')
  name: string

  @description('Required. Allow or deny traffic.')
  access: ('Allow' | 'Deny')

  @description('Required. The direction of the rule.')
  direction: ('Inbound' | 'Outbound')

  @description('Required. The priority of the rule (100-4096).')
  priority: int

  @description('Required. The protocol the rule applies to.')
  protocol: ('Tcp' | 'Udp' | 'Icmp' | '*')

  @description('Optional. Source address prefix or service tag. Defaults to "*".')
  sourceAddressPrefix: string?

  @description('Optional. Source port range. Defaults to "*".')
  sourcePortRange: string?

  @description('Optional. Destination address prefix or service tag. Defaults to "*".')
  destinationAddressPrefix: string?

  @description('Optional. Destination port range. Defaults to "*". Ignored if destinationPortRanges is set.')
  destinationPortRange: string?

  @description('Optional. Destination port ranges. Use instead of destinationPortRange to cover multiple ports.')
  destinationPortRanges: string[]?
}

@export()
@description('An opinionated AVNM security admin rule sourced from a service tag.')
type securityAdminRuleInputType = {
  @description('Required. The name of the rule.')
  name: string

  @description('Optional. A description of the rule.')
  description: string?

  @description('Required. Allow, deny, or always allow traffic. Deny rules here cannot be overridden by subnet NSGs.')
  access: ('Allow' | 'Deny' | 'AlwaysAllow')

  @description('Required. The direction of the rule.')
  direction: ('Inbound' | 'Outbound')

  @description('Required. The priority of the rule.')
  priority: int

  @description('Required. The protocol the rule applies to.')
  protocol: ('Tcp' | 'Udp' | 'Icmp' | 'Ah' | 'Esp' | 'Any')

  @description('Required. The destination port ranges the rule applies to.')
  destinationPortRanges: string[]

  @description('Required. The source service tag, for example "Internet".')
  sourceServiceTag: string
}
