targetScope = 'subscription'
param location  string
param environmentName  string
param tags object
param intent  string
param ordinal string
param hubNetworkParams object
param spokeResources object
param locationShortForm string = 'eus2' // Used for naming only. Not to be used to set regions for services
var serviceNameMask = '$Service-${intent}-${environmentName}-${location}-${ordinal}'

resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: hubNetworkParams.rg
}
resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: spokeResources.rgname
}

resource hubNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: hubNetworkParams.name
  scope: hubResourceGroup
}

resource spokeNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: spokeResources.vnetName
  scope: spokeResourceGroup
}

resource privateLinkSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: spokeNetwork
  name: spokeResources.privatelinkSubnetName
}

var hubVNet = union(hubNetworkParams,{id: hubNetwork.id})
var spoke = union(spokeResources,{rg: spokeResourceGroup, vnetId: spokeNetwork.id, privatelinkSubnetId: privateLinkSubnet.id})

resource mdpResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: replace(serviceNameMask,'$Service','rg')
  location: location
  tags: tags
}

module adlsResource 'modules/adls.bicep' = {
  scope: mdpResourceGroup
  name: 'adlsDeployment'
  params: {
    location: location
    tags: tags
    storageAccountName:'stg${intent}int${environmentName}${locationShortForm}${ordinal}'
  }
}

module synapse 'modules/synapse.bicep' = {
  scope: mdpResourceGroup
  name: 'synapseDeployment'
  params: {
    adls: {
      id: adlsResource.outputs.id
      name: adlsResource.outputs.name
    }
    location: location
    synapseWorkspaceName: replace(serviceNameMask,'$Service','syn')
    tags: tags
    hubVNet: hubVNet
    privatelinkSubnetId: spoke.privatelinkSubnetId
  }
}
