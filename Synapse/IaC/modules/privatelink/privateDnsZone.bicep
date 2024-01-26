param tags object
param privateDnsZoneName string
param linkedVirtualNetworkId string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' =  {
  name: privateDnsZoneName
  location: 'global'
  tags: tags
}

// Link Zone to Vnet
resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' =  {
  name: 'vnl-${privateDnsZone.name}'
  location: 'global'
  tags: tags
  parent: privateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: linkedVirtualNetworkId
    }
  }
}

output privateDnsZoneId string = privateDnsZone.id
output privateDnsZoneName string = privateDnsZone.name
