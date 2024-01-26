param location string
param tags object
param tenantId string = tenant().tenantId
param privatelinkSubnetId string
param enableSoftDelete bool
param softDeleteRetentionInDays int
param keyVaultName string
param virtualNetworks object

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    enableSoftDelete: enableSoftDelete
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    softDeleteRetentionInDays: softDeleteRetentionInDays
    sku: {
      family: 'A'
      name: 'premium'
    }
  }
}

module keyVaultPrivateEndpoint 'privateEndpoint.bicep' = {
  name: 'keyVaultPrivateEndpointDeployment'
  params: {
    childService: {id:keyVault.id, name:keyVault.name}
    location: location
    privatelinkSubnetId: privatelinkSubnetId
    tags: tags
    groupIds: ['vault']
    privateEndpointName: 'pe-${keyVault.name}'
    privateDnsZoneName: 'privatelink.vaultcore.azure.net'
    virtualNetworks: virtualNetworks
  }
}

output id string = keyVault.id
output name string = keyVault.name
