param location string
param tags object
param aseSubnetId string
param serviceMask string
param virtualNetworks object

var aseName = replace(serviceMask,'$Service','ase')

resource aseEnvironment 'Microsoft.Web/hostingEnvironments@2022-09-01' = {
  name: aseName
  location: location
  tags: tags
  kind: 'ASEV3'
  properties: {
    virtualNetwork: {
      id: aseSubnetId
    }
    internalLoadBalancingMode: 'Web, Publishing'
    multiSize: 'Standard_D2d_v4'
    ipsslAddressCount: 0
    frontEndScaleFactor: 15
    upgradePreference: 'None'
    dedicatedHostCount: 0
    zoneRedundant: false
  }
}

var inboundIpAddress = aseEnvironment.properties.networkingConfiguration.internalInboundIpAddresses[0]

module asePrivatelink 'asePrivatelink.bicep' = {
  name: 'registerAsePrivatelinkDeployment'
  scope: resourceGroup(virtualNetworks.hub.rg)
  params: {
    ase: {
      id: aseEnvironment.id
      name: aseEnvironment.name
    }
    virtualNetworks: virtualNetworks
    internalIpAddress: inboundIpAddress
    tags: {
    }
  }
}

output id string = aseEnvironment.id
output name string = aseEnvironment.name
output networking string = aseEnvironment.properties.networkingConfiguration.internalInboundIpAddresses[0]
