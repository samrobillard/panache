param PipName string
@description('Default is Static allocation.')
@allowed([
  'Static'
  'Dynamic'
])
param AllocationMethod string = 'Static'
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: PipName
  location: Location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: AllocationMethod
  }
}

output publicIpName string = publicIp.name
output publicIpResId string = publicIp.id
output publicIpAddress string = publicIp.properties.ipAddress
