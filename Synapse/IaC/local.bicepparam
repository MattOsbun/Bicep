using 'main.bicep'

param location = 'eastus2'
param environmentName = 'local'
param tags = {}
param intent = 'mdpmo'
param ordinal = '01'
param hubNetworkParams = {
  name: 'vnet-MattOsbun-local-eastus2-01'
  rg: 'rg-mo-local-eastus2-01'
}
param spokeResources = {
  rgname: 'rg-mo-local-eastus2-01'
  vnetName: 'vnet-mo-local-eastus2-01'
  privatelinkSubnetName: 'privatelink'
}
