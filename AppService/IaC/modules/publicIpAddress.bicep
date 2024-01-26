param publicIPAddressesName string
param location string
param tags object
param aRecordLabel string
param domainNameLabel string

resource publicIPAddresses 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIPAddressesName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '3'
    '2'
    '1'
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: domainNameLabel
      fqdn: '${aRecordLabel}.${location}.cloudapp.azure.com'
    }
    ipTags: []
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
  }
}

output id string = publicIPAddresses.id
