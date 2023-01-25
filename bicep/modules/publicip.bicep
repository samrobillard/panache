//version=1.1.1
param PipName string
@description('Default is Static allocation.')
@allowed([
  'Static'
  'Dynamic'
])
param AllocationMethod string = 'Static'
param PipAvailabilityZones array = []
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
param Tags object = resourceGroup().tags

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: PipName
  location: Location
  tags: Tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: PipAvailabilityZones
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: AllocationMethod
  }
}

output publicIpName string = publicIp.name
output publicIpResId string = publicIp.id
output publicIpAddress string = publicIp.properties.ipAddress
