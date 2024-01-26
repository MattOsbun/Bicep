param tags object
param privateDnsZoneName string
param virtualNetworks object

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' =  {
  name: privateDnsZoneName
  location: 'global'
  tags: tags
}

// Link Zone to Vnet
resource virtualNetworkLinkHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' =  {
  name: 'vnl-${virtualNetworks.hub.name}'
  location: 'global'
  tags: tags
  parent: privateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworks.hub.Id
    }
  }
}
// Link Zone to Vnet
resource virtualNetworkLinkSpoke 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' =  {
  name: 'vnl-${virtualNetworks.spoke.name}'
  location: 'global'
  tags: tags
  parent: privateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworks.spoke.Id
    }
  }
}

output privateDnsZoneId string = privateDnsZone.id
output privateDnsZoneName string = privateDnsZone.name
