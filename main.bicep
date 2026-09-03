// Explicitly set the deployment target to Subscription level
targetScope = 'subscription'

param location string = 'eastus'
param resourceGroupName string = 'rg-az400-devops-lab'

// 1. Create the Resource Group at the subscription scope
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

// 2. Deploy the storage module INSIDE the resource group created above
module storageModule './storage.bicep' = {
  name: 'storageModuleDeployment'
  scope: rg // <--- CRITICAL: This tells Bicep to switch scope to the Resource Group
  params: {
    location: location
  }
}
