using 'main.bicep'

param environmentName = 'local'
param tags = {}
param apimPublisherEmail = 'matt.osbun@3cloudsolutions.com'
param apimPublisherName = '3Cloud Solutions'
param intent = 'mo'
param vnetIpRange = '10.100.64.0/20'
param hubNetworkParams = {
  name: 'vnet-MattOsbun-local-eastus2-01'
  rg: 'rg-MattOsbun-local-eastus2-01'
}
param subnetValues = {
  ase: {name: 'ase', iprange: '10.100.66.0/23'}
  keyvault: {name: 'keyvault', iprange: '10.100.65.0/24'}
  privatelink: {name: 'privatelink', iprange: '10.100.64.0/24'}
  buildagent: {name: 'buildagent', iprange: '10.100.68.0/24'}
}
