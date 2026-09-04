// Do NOT include targetScope here; it defaults to 'resourceGroup' automatically

param location string

// Generates a globally unique name based on the Resource Group ID
param storageName string = 'staz400${uniqueString(resourceGroup().id)}'

resource sa 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
