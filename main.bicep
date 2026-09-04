targetScope = 'subscription'

param location string = 'eastus'
param resourceGroupName string = 'rg-az400-devops-lab'
param storageAccountName string = 'staz400lab${uniqueString(subscription().id)}'

// Create Resource Group with Tags
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Environment: 'Development'
    ManagedBy: 'Bicep-CI-CD'
    CostCenter: 'AZ400-Lab'
  }
}

// Deploy Storage Account Module
module storage './modules/storage.bicep' = {
  name: 'storageDeployment'
  scope: rg
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}
