param location string
param tags object
param serviceMask string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: replace(serviceMask,'$Service','log')
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource applicationInsights 'microsoft.insights/components@2020-02-02' = {
  name: replace(serviceMask,'$Service','appi')
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    RetentionInDays: 90
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

module ampls 'ampls.bicep' = {
  name: 'amplsDeployment'
  params: {
    amplsName: replace(serviceMask,'$Service','ampls')
    lawId: logAnalyticsWorkspace.id
    tags: tags
    scopedResourceName: 'scoped-${logAnalyticsWorkspace.name}'
  }
}

output appInsightsId string = applicationInsights.id
output appInsightsName string = applicationInsights.name
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
