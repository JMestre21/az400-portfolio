param location string
param environmentName string
param keyVaultName string

var appServiceName = 'app-az400-${environmentName}-${uniqueString(resourceGroup().id)}'
var appServicePlanName = 'plan-az400-${environmentName}'

resource appPlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource appService 'Microsoft.Web/sites@2024-11-01' = {
  name: appServiceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'DATABASE_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=DbPassword)'
        }
      ]
    }
  }
}

output principalId string = appService.identity.principalId
output appServiceHostName string = appService.properties.defaultHostName
