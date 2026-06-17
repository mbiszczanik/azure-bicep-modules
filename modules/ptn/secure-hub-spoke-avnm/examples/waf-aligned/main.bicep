metadata name = 'WAF-aligned'
metadata description = 'Deploys the secure hub-spoke AVNM pattern with Well-Architected Framework aligned defaults: diagnostics wired to a Log Analytics workspace, resource locks, and multiple spokes each with multiple subnets governed by the centrally enforced security admin baseline.'

targetScope = 'resourceGroup'

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

// A workspace to receive diagnostics. In a real platform this is typically a
// shared, pre-existing workspace whose resource ID is passed in.
module workspace 'br/public:avm/res/operational-insights/workspace:0.15.1' = {
  name: 'avnm-waf-workspace'
  params: {
    name: 'corp-prod-neu-law'
    location: location
    tags: {
      environment: 'prod'
      workload: 'connectivity'
      managedBy: 'bicep'
    }
  }
}

module hubSpoke '../../main.bicep' = {
  name: 'secure-hub-spoke-avnm-waf'
  params: {
    namePrefix: 'corp-prod-neu'
    location: location
    tags: {
      environment: 'prod'
      workload: 'connectivity'
      managedBy: 'bicep'
    }
    hubAddressPrefixes: ['10.0.0.0/24']
    hubSubnets: [
      {
        name: 'shared'
        addressPrefix: '10.0.0.0/26'
      }
    ]
    spokes: [
      {
        name: 'app'
        addressPrefixes: ['10.1.0.0/24']
        subnets: [
          {
            name: 'frontend'
            addressPrefix: '10.1.0.0/26'
          }
          {
            name: 'backend'
            addressPrefix: '10.1.0.64/26'
          }
        ]
      }
      {
        name: 'data'
        addressPrefixes: ['10.2.0.0/24']
        subnets: [
          {
            name: 'database'
            addressPrefix: '10.2.0.0/26'
          }
        ]
      }
    ]
    networkManagerScopes: {
      subscriptions: [subscription().id]
    }
    networkManagerScopeAccesses: [
      'Connectivity'
      'SecurityAdmin'
    ]
    diagnosticsWorkspaceResourceId: workspace.outputs.resourceId
    lock: {
      kind: 'CanNotDelete'
      name: 'avnm-prod-lock'
    }
  }
}
