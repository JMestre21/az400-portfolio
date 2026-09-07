targetScope = 'subscription'

@description('Target environment tier')
@allowed([
  'dev'
  'prod'
])
param environment string

@description('Primary Azure region for infrastructure')
param location string = 'eastus'

@description('Storage Account redundancy SKU')
param storageSku string

// Naming convention: rg-az400-<env>-lab
var resourceGroupName = 'rg-az400-${environment}-lab'

// Resource Group creation at Subscription scope
resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Environment: environment
    ManagedBy: 'GitHubActions'
    Project: 'AZ400-Portfolio'
  }
}

// Module invocation targeting the created Resource Group
module storage './storage.bicep' = {
  name: 'storageDeploy-${environment}'
  scope: rg
  params: {
    location: location
    // Globality constraint: Append unique string based on RG ID
    storageName: 'staz400${environment}${uniqueString(rg.id)}'
    storageSku: storageSku
  }
}

output deployedResourceGroupName string = rg.name
