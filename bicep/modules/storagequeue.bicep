param StorageAccountName string
param QueueName string
param QueueMetadata object = {}

resource storageAccountQueueService 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' existing = {
  name: '${StorageAccountName}/default'
}

resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = {
  name: QueueName
  parent: storageAccountQueueService
  properties: {
    metadata: QueueMetadata
  }
}
