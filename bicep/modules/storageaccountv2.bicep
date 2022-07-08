param StorageAccountName string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
@allowed([
  'Cool'
  'Hot'
])
@description('Default value is Hot')
param StorageAccountAccessTier string = 'Hot'
param StorageAccountBlobPublicAccess bool = false
param StorageAccountBlobCorsRules array = []
@description('Allow permanent delete on the blob retention policy. Default is false.')
param StorageAccountBlobRetentionPolicyAllowPermanentDelete bool = false
@description('Allow permanent delete on the blob retention policy. Default is 30.')
param StorageAccountBlobRetentionPolicyDays int = 30
@description('Enable retention policy on Blob. Default is true.')
param StorageAccountBlobRetentionPolicyEnable bool = true
@description('Allow permanent delete on the container retention policy. Default is false.')
param StorageAccountContainerRetentionPolicyAllowPermanentDelete bool = false
@description('Allow permanent delete on the container retention policy. Default is 30.')
param StorageAccountContainerRetentionPolicyDays int = 30
@description('Enable retention policy on containers. Default is true.')
param StorageAccountContainerRetentionPolicyEnable bool = true
param StorageAccountQueueCorsRules array = []
param StorageAccountTableCorsRules array = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: StorageAccountName
  location: Location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    accessTier: StorageAccountAccessTier
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: StorageAccountBlobPublicAccess
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        queue: {
          enabled: true
        }
        table: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
    }
  }
  resource blobServices 'blobServices' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: StorageAccountBlobCorsRules
      }
      deleteRetentionPolicy: {
        allowPermanentDelete: StorageAccountBlobRetentionPolicyAllowPermanentDelete
        days: StorageAccountBlobRetentionPolicyDays
        enabled: StorageAccountBlobRetentionPolicyEnable
      }
      containerDeleteRetentionPolicy: {
        allowPermanentDelete: StorageAccountContainerRetentionPolicyAllowPermanentDelete
        days: StorageAccountContainerRetentionPolicyDays
        enabled: StorageAccountContainerRetentionPolicyEnable
      }
    }              
  }
  resource queueServices 'queueServices' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: StorageAccountQueueCorsRules
      }
    }
  }
  resource tableServices 'tableServices' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: StorageAccountTableCorsRules
      }
    }
  }
}

output storageAccountName string = storageAccount.name
output storageAccountResId string = storageAccount.id
