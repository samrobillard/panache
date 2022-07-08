param StorageBlobContainerName string
param StorageAccountName string

resource storageAccountBlobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' existing = {
  name: '${StorageAccountName}/default'
}

resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: StorageBlobContainerName
  parent: storageAccountBlobService
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}
