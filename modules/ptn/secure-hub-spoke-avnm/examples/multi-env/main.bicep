metadata name = 'Multi-environment'
metadata description = 'Deploys the secure hub-spoke AVNM pattern across dev, test, and prod from a single template driven by per-environment .bicepparam files. Production scales up hardening (locks, diagnostics) automatically.'

targetScope = 'resourceGroup'

@description('Required. The deployment environment.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. The hub virtual network address prefix (a /24).')
param hubAddressPrefix string

@description('Required. The application spoke virtual network address prefix (a /24).')
param spokeAddressPrefix string

@description('Optional. Resource ID of a Log Analytics workspace for diagnostics. Recommended for test and prod.')
param diagnosticsWorkspaceResourceId string = ''

module hubSpoke '../../main.bicep' = {
  name: 'secure-hub-spoke-avnm-${environment}'
  params: {
    namePrefix: 'corp-${environment}-neu'
    location: location
    tags: {
      environment: environment
      workload: 'connectivity'
      managedBy: 'bicep'
    }
    hubAddressPrefixes: [hubAddressPrefix]
    hubSubnets: [
      {
        name: 'shared'
        addressPrefix: cidrSubnet(hubAddressPrefix, 26, 0)
      }
    ]
    spokes: [
      {
        name: 'app'
        addressPrefixes: [spokeAddressPrefix]
        subnets: [
          {
            name: 'workload'
            addressPrefix: cidrSubnet(spokeAddressPrefix, 26, 0)
          }
        ]
      }
    ]
    networkManagerScopes: {
      subscriptions: [subscription().id]
    }
    diagnosticsWorkspaceResourceId: diagnosticsWorkspaceResourceId
    // Production is locked; lower environments stay deletable for fast teardown.
    lock: environment == 'prod'
      ? {
          kind: 'CanNotDelete'
          name: 'avnm-prod-lock'
        }
      : null
  }
}
