param location string
param tags object
param topicNames array = []
param privatelinkSubnetId string
param serviceBusName string
param virtualNetworks object

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusName
  location: location
  tags: tags
  sku:{
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
  }
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2021-11-01' = [for topicName in topicNames: {
    name: topicName
    parent: serviceBus
  }
]

module asbPrivateEndpoint 'privateEndpoint.bicep' = {
  name: 'serviceBusPrivateEndpointDeployment'
  params: {
    childService: {id:serviceBus.id, name:serviceBus.name}
    groupIds: ['namespace']
    location: location
    privateEndpointName: 'pe-${serviceBus.name}'
    privatelinkSubnetId: privatelinkSubnetId
    tags: tags
    virtualNetworks: virtualNetworks
    privateDnsZoneName: 'privatelink.servicebus.windows.net'
  }
}

output id string = serviceBus.id
output name string = serviceBus.name
