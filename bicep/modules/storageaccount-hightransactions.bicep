//version=1.0.0
param StorageAccountName string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
param Tags object = resourceGroup().tags

var combinedTags = union(Tags, {
  AzDefenderPlanAutoEnable: 'false'
  intendedUsage: 'High transactional sync/lock'
})

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: StorageAccountName
  location: Location
  tags: combinedTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: false    
  }
}

output storageAccountName string = storageAccount.name
output storageAccountResId string = storageAccount.id
