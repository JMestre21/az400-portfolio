param location string
param environmentName string
@secure()
param dbAdminPassword string

var keyVaultName = 'kv-az400-${environmentName}-${uniqueString(resourceGroup().id)}'

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
