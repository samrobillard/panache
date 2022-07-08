param NsgName string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: NsgName
  location: Location
}

output nsgName string = nsg.name
output nsgResId string = nsg.id
