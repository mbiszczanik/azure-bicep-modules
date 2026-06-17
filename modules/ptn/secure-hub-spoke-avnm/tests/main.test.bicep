metadata name = 'Deployment test'
metadata description = 'Provisions a resource group and deploys the secure hub-spoke AVNM pattern with a representative parameter set. Used as a reference deployment for the module.'

targetScope = 'subscription'

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'rg-test-secure-hub-spoke-avnm'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resourceGroupName
  location: resourceLocation
  tags: {
    environment: 'test'
    workload: 'connectivity'
    managedBy: 'bicep'
  }
}

module testDeployment '../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-test'
  params: {
    namePrefix: 'tst-shs-neu'
    location: resourceLocation
    tags: {
      environment: 'test'
      workload: 'connectivity'
      managedBy: 'bicep'
    }
    hubAddressPrefixes: ['10.100.0.0/24']
    hubSubnets: [
      {
        name: 'shared'
        addressPrefix: '10.100.0.0/26'
      }
    ]
    spokes: [
      {
        name: 'app'
        addressPrefixes: ['10.101.0.0/24']
        subnets: [
          {
            name: 'workload'
            addressPrefix: '10.101.0.0/26'
          }
        ]
      }
      {
        name: 'data'
        addressPrefixes: ['10.102.0.0/24']
        subnets: [
          {
            name: 'database'
            addressPrefix: '10.102.0.0/26'
          }
        ]
      }
    ]
    networkManagerScopes: {
      subscriptions: [subscription().id]
    }
  }
}
