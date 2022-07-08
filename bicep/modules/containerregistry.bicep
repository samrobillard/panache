param ContainerRegistryName string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
@description('Defaults to the Basic SKU.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param ContainerRegistrySku string = 'Basic'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: ContainerRegistryName
  location: Location
  sku: {
    name: ContainerRegistrySku
  }
  properties: {
    adminUserEnabled: false
  }
}

output containerRegistryName string = containerRegistry.name
output containerRegistryResId string = containerRegistry.id
