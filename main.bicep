targetScope = 'subscription'

param location string = 'eastus'
param resourceGroupName string = 'rg-az400-devops-lab'
param storageAccountName string = 'staz400lab${uniqueString(subscription().id)}'

// Create Resource Group with Tags
resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Environment: 'dev'
    ManagedBy: 'Bicep-CI-CD'
    CostCenter: 'AZ400-Lab'
  }
}

// Deploy Storage Account Module
module storage './storage.bicep' = {
  name: 'storageDeployment'
  scope: rg
  params: {
    location: location
    storageName: storageAccountName
  }
}
