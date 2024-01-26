param logicAppMask string
param logicAppDomain string
param location string
param tags object
param privatelinkSubnetId string
param virtualNetworks object
param aseId string
param storageAccountName string
param appInsightsInstrumentationKey string

var domainName = replace(logicAppMask,'$Domain',logicAppDomain)
var logicAppName = replace(domainName,'$Service','logic')
var appServicePlanName = replace(domainName,'$Service','asp')

module appServicePlan 'appServicePlan.bicep' = {
  name: 'appServicePlanDeploy'
  params: {
    location: location
    tags: tags
    appServiceName:appServicePlanName
    hostingEnvironmentProfileId: aseId
  }
}

resource logicApp 'Microsoft.Web/sites@2022-09-01' = {
  name: logicAppName
  location: location
  tags: tags
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.outputs.name};AccountKey=${storageAccount.outputs.accountKeyValue}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: logicAppName
        }
        {
          name: 'ANCM_ADDITIONAL_ERROR_PAGE_LINK'
          value: 'https://${logicAppName}.scm.azurewebsites.net/detectors?type=tools&name=eventviewer'
        }
        {
          name: 'APPINSIGHTS_PROFILERFEATURE_VERSION'
          value: '1.0.0'
        }
        {
          name: 'APPINSIGHTS_SNAPSHOTFEATURE_VERSION'
          value: '1.0.0'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsightsInstrumentationKey};IngestionEndpoint=https://${location}.in.applicationinsights.azure.com/'
        }
      ]
      alwaysOn: true
      functionsRuntimeScaleMonitoringEnabled: false
    }
    hostNameSslStates: [
      {
        name: 'scm.${logicAppName}.appserviceenvironment.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
      {
        name: '${logicAppName}.appserviceenvironment.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
    ]
    hostingEnvironmentProfile: {
      id: aseId
    }
    serverFarmId: appServicePlan.outputs.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: true
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

module storageAccount 'logicAppStorageAccount.bicep' = {
  name: 'laSaDeployment${uniqueString(logicAppName)}'
  params: {
    location: location
    storageAccountName: storageAccountName
    tags: tags
    virtualNetworks: virtualNetworks
    privatelinkSubnetId: privatelinkSubnetId
  }
}
