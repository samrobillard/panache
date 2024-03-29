//version=1.2.0
param KeyVaultName string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
@description('Number of days for the soft delete retention period.')
param SoftDeleteRetentionInDays int = 30
@description('[OPTIONAL]Enable purge protection.')
param EnablePurgeProtection bool = false
@description('[OPTIONAL]Send diagnostic logs to Log Analytics Workspace is Id is provided.')
param LogAnalyticResId string
param Tags object = resourceGroup().tags

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: KeyVaultName
  location: Location
  tags: Tags
  properties: {
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    enablePurgeProtection: EnablePurgeProtection ? EnablePurgeProtection : null
    softDeleteRetentionInDays: SoftDeleteRetentionInDays
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

resource keyVaultAuditLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(LogAnalyticResId)) {
  name: 'Send audit events to Log Analytics'
  scope: keyVault
  properties: {
    workspaceId: LogAnalyticResId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

output keyVaultName string = keyVault.name
output keyVaultResId string = keyVault.id
