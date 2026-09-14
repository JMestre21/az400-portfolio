param location string = resourceGroup().location
param environmentName string
@secure()
param dbAdminPassword string

// Include location in uniqueString seed to avoid soft-delete collisions across regions
var uniqueSuffix = uniqueString(subscription().subscriptionId, resourceGroup().id, location)
var keyVaultName = take('kvaz400${environmentName}${uniqueSuffix}', 24)

resource kv 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Enabled'
  }
}

resource dbSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kv
  name: 'DbPassword'
  properties: {
    value: dbAdminPassword
  }
}

output keyVaultName string = kv.name
