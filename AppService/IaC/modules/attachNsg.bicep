param subnetName string
param vnetName string
param subnetProperties object
param nsgId string

var combinedProperties = union(subnetProperties,{
  networkSecurityGroup: {
    id: nsgId
  }
})

resource modifySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnetName}/${subnetName}'
  properties: combinedProperties
}
