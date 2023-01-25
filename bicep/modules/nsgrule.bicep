//version=1.1.0
param NsgName string
param NsgRuleName string
param NsgRuleProtocol string
param NsgRuleSourceAddressPrefix string
param NsgRuleSourceAddressPrefixes array = []
param NsgRuleSourcePortRange string
param NsgRuleDestinationAddressPrefix string
param NsgRuleDestinationAddressPrefixes array = []
param NsgRuleDestinationPortRange string
@allowed([
  'Allow'
  'Deny'
])
param NsgRuleAccess string
param NsgRulePriority int
@allowed([
  'Inbound'
  'Outbound'
])
param NsgRuleDirection string


resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' existing = {
  name: NsgName
}

resource nsgRule 'Microsoft.Network/networkSecurityGroups/securityRules@2021-08-01' = {
  name: NsgRuleName
  parent: nsg
  properties: {
    protocol: NsgRuleProtocol
    sourceAddressPrefix: NsgRuleSourceAddressPrefix
    sourceAddressPrefixes: NsgRuleSourceAddressPrefixes
    sourcePortRange: NsgRuleSourcePortRange
    destinationAddressPrefix: NsgRuleDestinationAddressPrefix
    destinationAddressPrefixes: NsgRuleDestinationAddressPrefixes
    destinationPortRange: NsgRuleDestinationPortRange
    access: NsgRuleAccess
    priority: NsgRulePriority
    direction: NsgRuleDirection
  }
}

output nsgRuleName string = nsgRule.name
output nsgRuleResId string = nsgRule.id
