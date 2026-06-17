metadata name = 'Basic'
metadata description = 'Deploys the secure hub-spoke AVNM pattern with the minimum set of parameters: one hub, one spoke, and the default security baseline. Diagnostics are disabled.'

targetScope = 'resourceGroup'

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module hubSpoke '../../main.bicep' = {
  name: 'secure-hub-spoke-avnm-basic'
  params: {
    namePrefix: 'corp-dev-neu'
    location: location
    tags: {
      environment: 'dev'
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
            name: 'workload'
            addressPrefix: '10.1.0.0/26'
          }
        ]
      }
    ]
    networkManagerScopes: {
      subscriptions: [subscription().id]
    }
  }
}
