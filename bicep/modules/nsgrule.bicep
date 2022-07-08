param NsgName string
param NsgRuleName string
param NsgRuleProtocol string
param NsgRuleSourceAddressPrefix string
param NsgRuleSourcePortRange string
param NsgRuleDestinationAddressPrefix string
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
    sourcePortRange: NsgRuleSourcePortRange
    destinationAddressPrefix: NsgRuleDestinationAddressPrefix
    destinationPortRange: NsgRuleDestinationPortRange
    access: NsgRuleAccess
    priority: NsgRulePriority
    direction: NsgRuleDirection
  }
}

output nsgRuleName string = nsgRule.name
output nsgRuleResId string = nsgRule.id
