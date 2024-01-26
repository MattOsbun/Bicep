param name string

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' existing = {
  name: name
}

output ipAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
