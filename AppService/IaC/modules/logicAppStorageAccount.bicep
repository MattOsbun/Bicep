
param location string
param tags object
param storageAccountName string
param virtualNetworks object
param privatelinkSubnetId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccountBlob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource storageAccountFile 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

module privateEndpointBlob 'privateEndpoint.bicep' = {
  name: 'pe-blob-${storageAccount.name}Deployment'
  params: {
    childService: {id:storageAccount.id, name:storageAccount.name}
    groupIds: ['blob']
    location: location
    privateDnsZoneName: 'privatelink.blob.core.windows.net'
    privateEndpointName: 'pe-blob-${storageAccount.name}'
    virtualNetworks: virtualNetworks
    tags: tags
    privatelinkSubnetId: privatelinkSubnetId
  }
}

module privateEndpointFile 'privateEndpoint.bicep' = {
  name: 'pe-file-${storageAccount.name}Deployment'
  params: {
    childService: {id:storageAccount.id, name:storageAccount.name}
    groupIds: ['file']
    location: location
    privateDnsZoneName: 'privatelink.file.core.windows.net'
    privateEndpointName: 'pe-file-${storageAccount.name}'
    virtualNetworks: virtualNetworks
    tags: tags
    privatelinkSubnetId: privatelinkSubnetId
  }
}

output id string = storageAccount.id
output name string = storageAccount.name
output accountKeyValue string = storageAccount.listKeys().keys[0].value
