param location string
param tags object
param appServiceName string
param hostingEnvironmentProfileId string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServiceName
  location: location
  tags: tags
  sku: {
    name: 'I1v2'
    tier: 'IsolatedV2'
    size: 'I1v2'
    family: 'Iv2'
    capacity: 1
  }
  kind: 'app'
  properties: {
    hostingEnvironmentProfile: {
      id: hostingEnvironmentProfileId
    }
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
