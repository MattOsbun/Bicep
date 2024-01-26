param location string
param tags object
param childService object
param privatelinkSubnetId string
param groupIds array
param privateEndpointName string
param privateDnsZoneName string
param linkedVirtualNetworkId string
param hubVnetResourceGroupName string
var nicName = 'nic-${privateEndpointName}'

// Create Private DNS Zone
module privateDnsZone 'privateDnsZone.bicep' = {
  name: 'PrivateDnsZoneDeployment${uniqueString(privateEndpointName, nicName)}'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    linkedVirtualNetworkId: linkedVirtualNetworkId
    privateDnsZoneName: privateDnsZoneName
    tags: tags
  }
}

// Create Private Endpoint
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: childService.id
          groupIds: groupIds
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: nicName
    subnet: {
      id: privatelinkSubnetId
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
} 

module networkInterface 'nicFinder.bicep' = {
  name: 'nicFinder${nicName}'
  params: {
    name: nicName
  }
  dependsOn: [
    privateDnsZoneGroup
    privateDnsZone
  ]
}

// Register Private Endpoint to DNS
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpoint
  name: 'default-privateEndpointName'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dns-reg-${childService.name}'
        properties: {
          privateDnsZoneId: privateDnsZone.outputs.privateDnsZoneId
        }
      }
    ]
  }
}

module registerDns 'registerDns.bicep' = {
  name: 'registerDns${uniqueString(childService.name,nicName)}'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    childService: childService
    privateDnsZoneName: privateDnsZoneName
    privateIPAddress: networkInterface.outputs.ipAddress
  }
  dependsOn: [
    privateDnsZoneGroup
  ]
}
