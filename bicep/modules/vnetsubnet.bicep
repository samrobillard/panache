//version=1.0.0
param SubnetName string
param VnetName string
param SubnetAddressPrefix string
@description('[OPTIONAL] Attach existing NSG to the subnet.')
param NsgResId string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: VnetName
}

resource vnetSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  name: SubnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: SubnetAddressPrefix
    networkSecurityGroup: empty(NsgResId)? {} : {
      id: NsgResId
    }
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

output vnetSubnetName string = vnetSubnet.name
output vnetSubnetResId string = vnetSubnet.id
