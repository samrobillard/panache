//version=1.1.0
param NsgName string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
param Tags object = resourceGroup().tags

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: NsgName
  location: Location
  tags: Tags
}

output nsgName string = nsg.name
output nsgResId string = nsg.id
