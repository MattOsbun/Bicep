param tags object
param amplsName string
param lawId string
param scopedResourceName string

resource privateLinkScope 'microsoft.insights/privatelinkscopes@2021-07-01-preview' = {
  name: amplsName
  location: 'global'
  tags: tags
  properties: {
    accessModeSettings: {
      exclusions: []
      queryAccessMode: 'Open'
      ingestionAccessMode: 'Open'
    }
  }
}

resource scopedResource 'microsoft.insights/privatelinkscopes/scopedresources@2021-07-01-preview' = {
  parent: privateLinkScope
  name: scopedResourceName
  properties: {
    linkedResourceId: lawId
  }
}
