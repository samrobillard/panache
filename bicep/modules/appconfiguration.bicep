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

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: AppConfigurationName
  location: Location
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
