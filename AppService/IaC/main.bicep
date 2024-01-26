targetScope = 'subscription'
param environmentName string
param location string = 'eastus2'
param locationShortForm string = 'eus2' // Used for naming only. Not to be used to set regions for services
param intent string = 'esbint'
param ordinal string = '01'
param tags object
param apimPublisherEmail string
param apimPublisherName string
param vnetIpRange string
param subnetValues object
param hubNetworkParams object
param apimSubnetIpRange string
param apimARecordLabel string
var tenantDefinition = tenant()

var serviceMask = '$Service-${intent}-${environmentName}-${location}-${ordinal}'
var serviceMaskShort = '$Service-${intent}-${environmentName}-${locationShortForm}'
var logicAppMask = '$Service-${intent}-${environmentName}-$Domain-${location}-${ordinal}'
var linkedVNet = union(hubNetworkParams,{id: hubNetwork.id, location: hubNetwork.location})
var virtualNetworks = {
  hub: linkedVNet
  spoke: {id: vnet.outputs.id, name: vnet.outputs.name, location: location, rg: resourceGroup.name}
}

resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: hubNetworkParams.rg
}

resource hubNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: hubNetworkParams.name
  scope: hubResourceGroup
}

// module apimSubnet 'modules/apimSubnet.bicep' = {
//   scope: hubResourceGroup
//   name: 'apimSubnetDeployment'
//   params: {
//     hubNetworkName: hubNetworkParams.name
//     subnetIpAddressRange: apimSubnetIpRange
//     tags: tags
//     environmentName: environmentName
//     nsgName: replace(serviceMask,'$Service','nsg-apim')
//     hubVnetLocation: linkedVNet.location
//   }
// }

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: replace(serviceMask,'$Service','rg')
  location: location
  tags: tags
}

module vnet 'modules/vnet.bicep' = {
  scope: resourceGroup
  name: 'vnetDeployment'
  params: {
    location: location
    vnetName: replace(serviceMask,'$Service','vnet')
    tags: tags
    vnetIpRange: vnetIpRange
    subnetValues: subnetValues
    aseNsgName: replace(serviceMask,'$Service','nsg-ase')
  }
}

module applicationInsights 'modules/appInsights.bicep' = {
  scope: resourceGroup
  name: 'appInsightsDeployment'
  params: {
    location: location
    serviceMask: serviceMask
    tags: tags
  }
  dependsOn: [
    vnet
  ]
}

module serviceBus 'modules/asbNamespace.bicep' = {
  scope: resourceGroup
  name: 'serviceBusNamespaceDeployment'
  params: {
    location: location
    tags: tags
    topicNames: []
    privatelinkSubnetId: vnet.outputs.privateLinkSubnetID
    serviceBusName: replace(serviceMaskShort,'$Service','sb')
    virtualNetworks: virtualNetworks
  }
  dependsOn: [
    vnet
  ]
}

module keyVault 'modules/keyvault.bicep' = {
  scope: resourceGroup
  name: 'keyVaultDeployment'
  params: {
    location: location
    keyVaultName: '${replace(serviceMaskShort,'$Service','kv')}-api'
    tags: tags
    tenantId: tenantDefinition.tenantId
    privatelinkSubnetId: vnet.outputs.privateLinkSubnetID
    enableSoftDelete: environmentName != 'local'
    softDeleteRetentionInDays: environmentName == 'local'?7:90
    virtualNetworks: virtualNetworks
  }
  dependsOn: [
    vnet
  ]
}

module apimPublicIpAddress 'modules/publicIpAddress.bicep' = {
  scope: hubResourceGroup
  name: 'apimPipDeployment'
  params: {
    aRecordLabel: apimARecordLabel
    location: location
    publicIPAddressesName: replace(serviceMask,'$Service','pip')
    tags: tags
    domainNameLabel: replace(serviceMask,'$Service','apim')
  }
}

// Code is commented out to preserve the initial forms rather than having to muck about with source control history

// module apimStandard 'modules/apim.bicep' = {
//   scope: hubResourceGroup
//   name: 'apimStandardDeployment'
//   params: {
//     apimPublisherEmail: apimPublisherEmail
//     apimPublisherName: apimPublisherName
//     location: location
//     serviceMask: serviceMask
//     tags: tags
//     apimSubnetId: apimSubnet.outputs.apimSubnetId
//     appInsightsId: applicationInsights.outputs.appInsightsId
//     publicIpAddressId: apimPublicIpAddress.outputs.id
//     skuName: environmentName == 'prod'? 'Premium' : 'Developer'
//   }
//   dependsOn: [
//     apimSubnet
//   ]
// }

module ase 'modules/ase.bicep' = {
  scope: resourceGroup
  name: 'aseDeployment'
  params: {
    location: location
    serviceMask: serviceMask
    tags: tags
    aseSubnetId: vnet.outputs.aseSubnetId
    virtualNetworks: virtualNetworks
  }
  dependsOn: [
    vnet
  ]
}

module logicAppOrchestration 'modules/logicApp.bicep' = {
  scope: resourceGroup
  name: 'logicAppOrchestrationDeployment'
  params: {
    location: location
    logicAppDomain: 'orchestration'
    tags: tags
    privatelinkSubnetId: vnet.outputs.privateLinkSubnetID
    aseId: ase.outputs.id
    virtualNetworks: virtualNetworks
    logicAppMask: logicAppMask
    appInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    storageAccountName:'stg${intent}orch${environmentName}${locationShortForm}${ordinal}'
  }
  dependsOn: [
    ase
    applicationInsights
    vnet
  ]
}

module logicAppTranslation 'modules/logicApp.bicep' = {
  scope: resourceGroup
  name: 'logicAppTranslationDeployment'
  params: {
    location: location
    logicAppDomain: 'translation'
    tags: tags
    privatelinkSubnetId: vnet.outputs.privateLinkSubnetID
    aseId: ase.outputs.id
    virtualNetworks: virtualNetworks
    logicAppMask: logicAppMask
    appInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    storageAccountName:'stg${intent}int${environmentName}${locationShortForm}${ordinal}'
  }
  dependsOn: [
    ase
    applicationInsights
    vnet
    logicAppOrchestration
  ]
}

output aseNetworking string = ase.outputs.networking
