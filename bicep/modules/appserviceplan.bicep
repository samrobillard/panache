//version=0.0.1
param AppServicePlanName string
param AppServicePlanSku string
param AppServicePlanCapacity int
param IsLinuxAppServicePlan bool
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
param Tags object = resourceGroup().tags

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: AppServicePlanName
  location: Location
  tags: Tags
  sku: {
    name: AppServicePlanSku
    capacity: AppServicePlanCapacity
  }
  kind: IsLinuxAppServicePlan ? 'linux' : 'windows'
  properties: {
    reserved: IsLinuxAppServicePlan
  }
}

output appServicePlanName string = appServicePlan.name
output appServicePlanResId string = appServicePlan.id
