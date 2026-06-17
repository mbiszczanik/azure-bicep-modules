using './main.bicep'

param environment = 'prod'
param hubAddressPrefix = '10.30.0.0/24'
param spokeAddressPrefix = '10.31.0.0/24'
// Set to a shared platform workspace resource ID to enable diagnostics in prod.
param diagnosticsWorkspaceResourceId = ''
