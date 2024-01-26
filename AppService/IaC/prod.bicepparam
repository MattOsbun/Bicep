using 'main.bicep'

param environmentName = 'prod'
param tags = {
  Environment: 'Non-Prod'
  Owner: 'btonkin@petermillar.com'
}
param apimPublisherEmail = 'btonkin@petermillar.com'
param apimPublisherName = 'Peter Millar'
param vnetIpRange = '10.100.96.0/20'
param subnetValues = {
  privatelink: {name: 'privatelink', iprange: '10.100.96.0/24'}
  keyvault: {name: 'keyvault', iprange: '10.100.97.0/24'}
  ase: {name: 'ase', iprange: '10.100.98.0/23'}
  buildagent: {name: 'buildagent', iprange: '10.100.100.0/24'}
}
param hubNetworkParams = {

}
