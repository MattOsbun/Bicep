using 'main.bicep'

param environmentName = 'stage'
param tags = {
  Environment: 'Non-Prod'
  Owner: 'btonkin@petermillar.com'
}
param apimPublisherEmail = 'btonkin@petermillar.com'
param apimPublisherName = 'Peter Millar'
param vnetIpRange = '10.100.80.0/20'
param subnetValues = {
  privatelink: {name: 'privatelink', iprange: '10.100.80.0/24'}
  keyvault: {name: 'keyvault', iprange: '10.100.81.0/24'}
  ase: {name: 'ase', iprange: '10.100.82.0/23'}
  buildagent: {name: 'buildagent', iprange: '10.100.84.0/24'}
}
param hubNetworkParams = {
  name: 'non-prod-use-da-vnet-01'
  rg: 'nonprod-da-dev-use-rg-1'
}
param apimSubnetIpRange = '10.100.19.0/24'
param apimARecordLabel = 'pm-esbint-stage'
