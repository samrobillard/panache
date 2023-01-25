//version=1.1.0
param AppConfigurationName string
@allowed([
  'free'
  'standard'
])
param AppConfigurationSku string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
@description('Number of days for the soft delete retention period. The default value in Azure is 7.')
param SoftDeleteRetentionInDays int
param EnablePurgeProtection bool
param Tags object = resourceGroup().tags

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: AppConfigurationName
  location: Location
  tags: Tags
  sku: {
    name: AppConfigurationSku
  }
  properties: {
    disableLocalAuth: true
    softDeleteRetentionInDays: SoftDeleteRetentionInDays
    enablePurgeProtection: EnablePurgeProtection
  }
}

output appConfigurationName string = appConfig.name
output appConfigurationResId string = appConfig.id
