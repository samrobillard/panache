//version=1.1.0
param SqlServerName string
@allowed([
  'Enabled'
  'Disabled'
])
param SqlPublicNetworkAccess string = 'Enabled'
@allowed([
  'Enabled'
  'Disabled'
])
param SqlRestrictOutboundNetworkAccess string = 'Enabled'
param AadSqlAdminGroupName string
param AadSqlAdminGroupObjectId string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
param ZscalerIp string
param Tags object = resourceGroup().tags

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: SqlServerName
  location: Location
  tags: Tags
  properties: {
    publicNetworkAccess: SqlPublicNetworkAccess
    restrictOutboundNetworkAccess: SqlRestrictOutboundNetworkAccess
    administrators: {
      administratorType: 'ActiveDirectory'
      login: AadSqlAdminGroupName
      sid: AadSqlAdminGroupObjectId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
  }
  resource allowZscaler 'firewallRules' = {
    name: 'allowZscaler'
    properties: {
      endIpAddress: ZscalerIp
      startIpAddress: ZscalerIp
    }
  } 
}

output sqlServerName string = sqlServer.name
output sqlServerResId string = sqlServer.id
