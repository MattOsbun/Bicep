
param privateDnsZoneName string
param childService object
param privateIPAddress string

resource dnsRegistration 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${privateDnsZoneName}/${childService.name}'
  properties: {
    ttl: 10
    aRecords: [
      {
        ipv4Address: privateIPAddress
      }
    ]
  }
}
