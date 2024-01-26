param sqlServerName string
param location string
param tags object

@secure()
param privateEndpointConnections_mdp_eastus2_syn_01_mdp_eastus2_syn_01_sqlsvr01_pe_0c26052b_20de_46b7_845e_f90845211ed3_description string

@secure()
param vulnerabilityAssessments_Default_storageContainerPath string
param servers_mdp_eastus2_sqlsvr_01_name string = 'mdp-eastus2-sqlsvr-01'
param privateEndpoints_mdp_eastus2_syn_01_mdp_eastus2_syn_01_sqlsvr01_pe_externalid string = '/subscriptions/10e72cf9-8092-4625-8e0a-a1c4e164affa/resourceGroups/vnet-10e72cf9-eastus2-54-rg/providers/Microsoft.Network/privateEndpoints/mdp-eastus2-syn-01.mdp-eastus2-syn-01-sqlsvr01-pe'

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
    userAssignedIdentities: {}
  }
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      tenantId: tenant().tenantId
      azureADOnlyAuthentication: true
      login: 'sbabczak@3cloudsolutions.com'
      sid: 'b40f9b39-db48-41cf-af32-f635a3a901dd'
    }
  }
}

resource servers_mdp_eastus2_sqlsvr_01_name_resource 'Microsoft.Sql/servers@2023-02-01-preview' = {
  name: servers_mdp_eastus2_sqlsvr_01_name
  location: 'eastus2'
  kind: 'v12.0'
  properties: {
    administratorLogin: 'sqladmin'
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      tenantId: tenant().tenantId
      azureADOnlyAuthentication: true
    }
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource Microsoft_Sql_servers_azureADOnlyAuthentications_servers_mdp_eastus2_sqlsvr_01_name_Default 'Microsoft.Sql/servers/azureADOnlyAuthentications@2023-02-01-preview' = {
  parent: servers_mdp_eastus2_sqlsvr_01_name_resource
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: true
  }
}

resource servers_mdp_eastus2_sqlsvr_01_name_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2023-02-01-preview' = {
  parent: servers_mdp_eastus2_sqlsvr_01_name_resource
  name: 'AllowAllWindowsAzureIps'
}

resource servers_mdp_eastus2_sqlsvr_01_name_ClientIp_2023_11_7_13_14_55 'Microsoft.Sql/servers/firewallRules@2023-02-01-preview' = {
  parent: servers_mdp_eastus2_sqlsvr_01_name_resource
  name: 'ClientIp-2023-11-7_13-14-55'
}

resource servers_mdp_eastus2_sqlsvr_01_name_ServiceManaged 'Microsoft.Sql/servers/keys@2023-02-01-preview' = {
  parent: servers_mdp_eastus2_sqlsvr_01_name_resource
  name: 'ServiceManaged'
  kind: 'servicemanaged'
  properties: {
    serverKeyType: 'ServiceManaged'
  }
}

resource servers_mdp_eastus2_sqlsvr_01_name_mdp_eastus2_syn_01_mdp_eastus2_syn_01_sqlsvr01_pe_0c26052b_20de_46b7_845e_f90845211ed3 'Microsoft.Sql/servers/privateEndpointConnections@2023-02-01-preview' = {
  parent: servers_mdp_eastus2_sqlsvr_01_name_resource
  name: 'mdp-eastus2-syn-01.mdp-eastus2-syn-01-sqlsvr01-pe-0c26052b-20de-46b7-845e-f90845211ed3'
  properties: {
    privateEndpoint: {
      id: privateEndpoints_mdp_eastus2_syn_01_mdp_eastus2_syn_01_sqlsvr01_pe_externalid
    }
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: privateEndpointConnections_mdp_eastus2_syn_01_mdp_eastus2_syn_01_sqlsvr01_pe_0c26052b_20de_46b7_845e_f90845211ed3_description
    }
  }
}
