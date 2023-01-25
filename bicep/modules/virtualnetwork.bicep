//version=1.1.0
param VnetName string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
param VnetAdressPrefixes array
param SubnetName string
param SubnetAddressPrefix string
param NsgResId string
param Tags object = resourceGroup().tags

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: VnetName
  location: Location
  tags: Tags
  properties: {
    addressSpace: {
      addressPrefixes: VnetAdressPrefixes
    }
    subnets: [
      {
        name: SubnetName
        properties: {
          addressPrefix: SubnetAddressPrefix
          networkSecurityGroup: empty(NsgResId)? {} : {
            id: NsgResId
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output virtualNetworkName string = virtualNetwork.name
output virtualNetworkResId string = virtualNetwork.id
