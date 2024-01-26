param ase object
param virtualNetworks object
param internalIpAddress string
param tags object

// Create Private DNS Zone
module privateDnsZone 'privateDnsZone.bicep' = {
  name: 'PrivateDnsZoneDeployment${uniqueString(ase.name, ase.id)}'
  params: {
    virtualNetworks: virtualNetworks
    privateDnsZoneName: '${ase.name}.appserviceenvironment.net'
    tags: tags
  }
}

resource dnsRegistration1 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${ase.name}.appserviceenvironment.net/*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: internalIpAddress
      }
    ]
  }
  dependsOn: [
    privateDnsZone
  ]
}

resource dnsRegistration2 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${ase.name}.appserviceenvironment.net/@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: internalIpAddress
      }
    ]
  }
  dependsOn: [
    privateDnsZone
  ]
}

resource dnsRegistration3 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${ase.name}.appserviceenvironment.net/*.scm'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: internalIpAddress
      }
    ]
  }
  dependsOn: [
    privateDnsZone
  ]
}
