param location string
param tags object
param vnetIpRange string
param subnetValues object
param vnetName string
param aseNsgName string

resource nsgAse 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: aseNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowVnetToAse'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: subnetValues.ase.iprange
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: [
            '80'
            '443'
          ]
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowLoadBalancerToAse'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: subnetValues.ase.iprange
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: [
            '80'
            '443'
          ]
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowApimToAse'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: subnetValues.ase.iprange
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: [
            '80'
            '443'
          ]
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetIpRange
    ]}
    enableDdosProtection: false
    subnets: [
      {
        name: subnetValues.privatelink.name
        properties: {
          addressPrefixes: [
            subnetValues.privatelink.iprange
          ]
          //Scrictly speaking unnecessary, as these are the defaults, but private endpoints require these settings so I want to be explicit
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnetValues.keyvault.name
        properties: {
          addressPrefixes: [
            subnetValues.keyvault.iprange
          ]
          //Scrictly speaking unnecessary, as these are the defaults, but private endpoints require these settings so I want to be explicit
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnetValues.ase.name
        properties: {
          addressPrefix: subnetValues.ase.iprange
          networkSecurityGroup: {
            id: nsgAse.id
          }
          delegations: [
            {
                name: '${vnetName}${subnetValues.ase.name}delegation'
                properties: {
                    serviceName: 'Microsoft.Web/hostingEnvironments'
                }
                type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: subnetValues.buildagent.name
        properties: {
          addressPrefixes: [
            subnetValues.buildagent.iprange
          ]
          //Scrictly speaking unnecessary, as these are the defaults, but private endpoints require these settings so I want to be explicit
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource privateLinkSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: 'privatelink'
  parent: virtualNetwork
}

resource keyVaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: 'keyvault'
  parent: virtualNetwork
}

resource aseSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: 'ase'
  parent: virtualNetwork
}

resource buildAgentSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: 'buildagent'
  parent: virtualNetwork
}

output id string = virtualNetwork.id
output name string = virtualNetwork.name
output privateLinkSubnetID string = privateLinkSubnet.id
output keyVaultSubnetID string = keyVaultSubnet.id
output aseSubnetId string = aseSubnet.id
output buildAgentSubnetId string = buildAgentSubnet.id
