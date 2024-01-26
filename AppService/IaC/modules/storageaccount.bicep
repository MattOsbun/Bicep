param serviceMask string
param location string
param tags object
param privatelinkSubnetId string
param linkedVNet object
var stgAcctNameRaw = toLower(replace(replace(serviceMask,'$Service','stg'),'-',''))
var stgAcctName = length(stgAcctNameRaw) > 24?substring(stgAcctNameRaw,0,24):stgAcctNameRaw

resource stgAcct 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: stgAcctName
  location: location
  tags: tags
  sku: {
    name: 'Standard_ZRS' 
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: false
  }
}

module privateEndpoint 'privateEndpoint.bicep' = {
  name: 'storageAccountPrivateEndpointDeployment'
  params: {
    childService: {id:stgAcct.id, name:stgAcct.name}
    groupIds: ['blob']
    location: location
    privateDnsZoneName: 'privatelink.blob.core.windows.net'
    privateEndpointName: '${stgAcctName}-pe'
    privatelinkSubnetId: privatelinkSubnetId
    tags: tags
    linkedVirtualNetworkId: linkedVNet.id
    hubVnetResourceGroupName: linkedVNet.rg
  }
}
