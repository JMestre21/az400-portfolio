targetScope = 'subscription'

@description('Target environment tier')
@allowed([
  'dev'
  'prod'
])
param environment string

@description('Primary Azure region for infrastructure')
param location string = 'eastus2'

@description('Storage Account redundancy SKU')
param storageSku string

@description('Database administrator password (auto-generated GUID default)')
@secure()
param dbAdminPassword string = newGuid()

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

// Module for Key Vault and Key Vault Secrets
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVaultDeployment'
  scope: rg
  params: {
    location: location
    environmentName: environment
    dbAdminPassword: dbAdminPassword
  }
}

// Module for App Service with Key Vault reference
module appService 'modules/appservice.bicep' = {
  name: 'appServiceDeployment'
  scope: rg
  params: {
    location: location
    environmentName: environment
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

// 5. RBAC Role Assignment Module (Breaks Circular Dependency)
module keyVaultRbac 'modules/keyvault-rbac.bicep' = {
  name: 'keyVaultRbacDeployment'
  scope: rg
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    principalId: appService.outputs.principalId
  }
}

output storageAccountName string = storage.outputs.storageAccountName
output appServiceHostName string = appService.outputs.principalId
output keyVaultName string = keyVault.outputs.keyVaultName
