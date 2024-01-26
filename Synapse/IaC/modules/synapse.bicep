param location string
param tags object
param adls object
param tenantId string = tenant().tenantId
param synapseWorkspaceName string
param hubVNet object
param privatelinkSubnetId string
var childService = {
  id: synapseResource.id
  name: synapseResource.name
}

resource synapseResource 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      resourceId: adls.id
      createManagedPrivateEndpoint: true
      accountUrl: 'https://${adls.name}.dfs.core.windows.net'
      filesystem: 'default-location'
    }
    encryption: {}
    managedVirtualNetwork: 'default'
    //managedResourceGroupName: 'synapseworkspace-managedrg-69b95c42-136a-48da-a9dd-b55c04a8a6b5'
    sqlAdministratorLogin: 'sqladminuser'
    // privateEndpointConnections: [
    //   {
    //     properties: {
    //       privateEndpoint: {}
    //       privateLinkServiceConnectionState: {
    //         status: 'Approved'
    //       }
    //     }
    //   }
    //   {
    //     properties: {
    //       privateEndpoint: {}
    //       privateLinkServiceConnectionState: {
    //         status: 'Approved'
    //       }
    //     }
    //   }
    //   {
    //     properties: {
    //       privateEndpoint: {}
    //       privateLinkServiceConnectionState: {
    //         status: 'Approved'
    //       }
    //     }
    //   }
    // ]
    managedVirtualNetworkSettings: {
      preventDataExfiltration: false
      allowedAadTenantIdsForLinking: []
    }
    workspaceRepositoryConfiguration: {
      accountName: 'PeterMillar'
      collaborationBranch: 'main'
      //lastCommitId: '00842609b769b36fe3201e74d4afe06eeb0c6c42'
      projectName: 'Peter Millar ESB'
      repositoryName: 'Synapse'
      rootFolder: '/mdp'
      tenantId: tenantId
      type: 'WorkspaceVSTSConfiguration'
    }
    publicNetworkAccess: 'Enabled'
    // cspWorkspaceAdminProperties: {
    //   initialWorkspaceAdminObjectId: 'b40f9b39-db48-41cf-af32-f635a3a901dd'
    // }
    azureADOnlyAuthentication: false
    trustedServiceBypassEnabled: false
  }
}

resource synapseBigDataPools 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapseResource
  name: 'DevelopmentPool'
  location: location
  tags: tags
  properties: {
    sparkVersion: '3.3'
    nodeCount: 0
    nodeSize: 'Small'
    nodeSizeFamily: 'MemoryOptimized'
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 10
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    isComputeIsolationEnabled: false
    sessionLevelPackagesEnabled: true
    dynamicExecutorAllocation: {
      enabled: false
    }
    isAutotuneEnabled: false
  }
}

resource synapseExecutionPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapseResource
  name: 'ExecutionPool'
  location: location
  properties: {
    sparkVersion: '3.3'
    nodeCount: 10
    nodeSize: 'Medium'
    nodeSizeFamily: 'MemoryOptimized'
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 10
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    isComputeIsolationEnabled: false
    sessionLevelPackagesEnabled: false
    dynamicExecutorAllocation: {
      enabled: false
    }
    isAutotuneEnabled: false
  }
}

resource synapseSqlTlsSetting 'Microsoft.Synapse/workspaces/dedicatedSQLminimalTlsSettings@2021-06-01' = {
  parent: synapseResource
  name: 'default'
  properties: {
    minimalTlsVersion: '1.2'
  }
}

resource synapseAutoResolveIntegrationRuntime 'Microsoft.Synapse/workspaces/integrationruntimes@2021-06-01' = {
  parent: synapseResource
  name: 'AutoResolveIntegrationRuntime'
  properties: {
    type: 'Managed'
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
    managedVirtualNetwork: {
      referenceName: 'default'
      type: 'ManagedVirtualNetworkReference'
      //id: 'd04bcde7-5804-4c63-8f63-d52ac2338154'
    }
  }
}

module synapseDevPrivateEndpoint 'privatelink/privateEndpoint.bicep' = {
  name: 'synapseDevPEDeployment'
  params: {
    childService: childService
    groupIds: ['dev']
    linkedVirtualNetworkId: hubVNet.id
    hubVnetResourceGroupName: hubVNet.rg
    location: location
    privateDnsZoneName: 'privatelink.dev.azuresynapse.net'
    privateEndpointName: '${synapseWorkspaceName}-dev-pe'
    privatelinkSubnetId: privatelinkSubnetId
    tags: tags
  }
}

module synapseSqlPrivateEndpoint 'privatelink/privateEndpoint.bicep' = {
  name: 'synapseSqlPEDeployment'
  params: {
    childService: childService
    groupIds: ['Sql']
    linkedVirtualNetworkId: hubVNet.id
    hubVnetResourceGroupName: hubVNet.rg
    location: location
    privateDnsZoneName: 'privatelink.sql.azuresynapse.net'
    privateEndpointName: '${synapseWorkspaceName}-sql-pe'
    privatelinkSubnetId: privatelinkSubnetId
    tags: tags
  }
  dependsOn: [
    synapseDevPrivateEndpoint
  ]
}

module synapseSqlOnDemandPrivateEndpoint 'privatelink/privateEndpoint.bicep' = {
  name: 'synapseSqlOnDemandPEDeployment'
  params: {
    childService: childService
    groupIds: ['Sql']
    linkedVirtualNetworkId: hubVNet.id
    hubVnetResourceGroupName: hubVNet.rg
    location: location
    privateDnsZoneName: 'privatelink.sql.azuresynapse.net'
    privateEndpointName: '${synapseWorkspaceName}-sqlondemand-pe'
    privatelinkSubnetId: privatelinkSubnetId
    tags: tags
  }
  dependsOn: [
    synapseSqlPrivateEndpoint
    synapseDevPrivateEndpoint
  ]
}
