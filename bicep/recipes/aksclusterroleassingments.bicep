//version=1.0.1
param AksVnetName string
param AksClusterName string
param AksIdentityPrincipalId string
param KubernetesClusterUserGroupObjectId string
param KubernetesServiceRbacClusterAdminGroupObjectId string

var kubernetesClusterUserRoleDefId = '/providers/Microsoft.Authorization/roleDefinitions/4abbcc35-e782-43d8-92c5-2d3f1bd2253f'
var kubernetesServiceRbacClusterAdminDefId = '/providers/Microsoft.Authorization/roleDefinitions/b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
var networkContributorRbacRoleDefId = '/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'

resource aksClusterResource 'Microsoft.ContainerService/managedClusters@2022-03-02-preview' existing = {
  name: AksClusterName
}

resource aksVnetResource 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: AksVnetName
}

resource aksNetworkContributorRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, AksClusterName, networkContributorRbacRoleDefId)
  scope: aksVnetResource
  properties: {
    roleDefinitionId: networkContributorRbacRoleDefId
    principalId: AksIdentityPrincipalId
  }
}

resource kubernetesClusterUserRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id,KubernetesClusterUserGroupObjectId,kubernetesClusterUserRoleDefId)
  scope: aksClusterResource
  properties: {
    roleDefinitionId: kubernetesClusterUserRoleDefId
    principalId: KubernetesClusterUserGroupObjectId
  }
}

resource kubernetesServiceRbacClusterAdminRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id,KubernetesServiceRbacClusterAdminGroupObjectId,kubernetesServiceRbacClusterAdminDefId)
  scope: aksClusterResource
  properties: {
    roleDefinitionId: kubernetesServiceRbacClusterAdminDefId
    principalId: KubernetesServiceRbacClusterAdminGroupObjectId
  }
}
