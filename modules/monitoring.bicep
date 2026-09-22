@description('Target region for monitoring resources')
param location string

@description('Environment name (dev, prod)')
param environmentName string

@description('Workload identifier')
param workloadName string = 'az400'

@description('Retention period in days for Log Analytics logs')
param logRetentionDays int = 30

var logAnalyticsName = 'log-${workloadName}-${environmentName}-${uniqueString(resourceGroup().id)}'
var appInsightsName = 'appi-${workloadName}-${environmentName}-${uniqueString(resourceGroup().id)}'

// 1. Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logRetentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// 2. Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Outputs
output workspaceId string = logAnalyticsWorkspace.id
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
