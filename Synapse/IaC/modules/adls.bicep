param location string
param tags object
param storageAccountName string
param synapseId string = '/subscriptions/4ef8bef2-1a2e-4b28-8a03-a2985c9f7235/resourceGroups/rg-mdptemp-eastus2-sandbox/providers/Microsoft.Synapse/workspaces/mdp-eastus2-syn-02'
param synapseTmpId string = '/subscriptions/4ef8bef2-1a2e-4b28-8a03-a2985c9f7235/resourceGroups/rg-mdptemp-eastus2-sandbox/providers/Microsoft.Synapse/workspaces/mdp-eastus2-syn-01-tmp'
var tenantId = tenant().tenantId

resource adlsResource 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    routingPreference: {
      routingChoice: 'MicrosoftRouting'
      publishMicrosoftEndpoints: true
      publishInternetEndpoints: false
    }
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    isHnsEnabled: true
    networkAcls: {
      resourceAccessRules: [
        {
          tenantId: tenantId
          resourceId: synapseId
        }
        {
          tenantId: tenantId
          resourceId: synapseTmpId
        }
      ]
      bypass: 'AzureServices'
      virtualNetworkRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: true
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

resource adlsBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: adlsResource
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
  }
}

resource adlsFileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: adlsResource
  name: 'default'
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

// resource adlsPrivateEndpointConn 'Microsoft.Storage/storageAccounts/privateEndpointConnections@2023-01-01' = {
//   parent: adlsResource
//   name: 'pe-${storageAccountName}'
//   properties: {
//     privateEndpoint: {}
//     privateLinkServiceConnectionState: {
//       status: 'Approved'
//       actionRequired: 'None'
//     }
//   }
// }

// module adlsPrivateEndpoint 'privatelink/privateEndpoint.bicep' = {
//   name: 'adlsPrivateEndpointDeployment'
//   params: {
//     childService: {
//     }
//     groupIds: 
//     hubVnetResourceGroupName: 
//     linkedVirtualNetworkId: 
//     location: 
//     privateDnsZoneName: 
//     privateEndpointName: 
//     privatelinkSubnetId: 
//     tags: {
//     }
//   }
// }

resource adlsQueueService 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: adlsResource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource adlsTableService 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: adlsResource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource adlsBlobDataEstate 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: adlsBlobService
  name: 'data-estate'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource adlsBlobDataLocation 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: adlsBlobService
  name: 'default-location'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}


output id string = adlsResource.id
output name string = adlsResource.name
