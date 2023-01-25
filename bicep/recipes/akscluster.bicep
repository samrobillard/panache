//version=1.2.6
param AksClusterName string
@description('Kubernetes internal DNS zone name')
param K8sDnsZoneName string
@description('Required if k8s monitoring is wanted')
param LogAnalyticResId string
param K8sVersion string
@description('Number of nodes to deploy in the pool')
param AksNodeCount int
@description('VM SKU to use in the node pool')
param AksNodeSize string
param AksNodeAvailabilityZones array = []
param AksNodeDiskSize int
param AksAutoScaling bool = false
param AksAutoScalingMaxCount int = 1
param AksAutoScalingMinCount int = 1
@description('Name of the resource group created by AKS')
param AksRgName string
param AksUseAzureKeyvaultSecretsProvider bool = false
param AksApiIpToWhitelist array
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
param AksVnetName string
param AksSubnetNsgName string
@description('Azure public IP is automatically configured for the network traffic exiting the cluster')
param EgressPipName string
param AksSubnetName string = 'aksDefault'
@description('ObjectId of the Azure AD group for the Kubernetes Cluster User Azure RBAC role')
param KubernetesClusterUserGroupObjectId string
@description('ObjectId of the Azure AD group for the Kubernetes Service RBAC Cluster Admin Azure RBAC role')
param KubernetesServiceRbacClusterAdminGroupObjectId string
param AksVnetAdressPrefixes array = [
  '10.240.0.0/16'
]
param AksSubnetAddressPrefix string = '10.240.0.0/16'
@description('Enable Workload Identity on cluster: https://azure.github.io/azure-workload-identity/docs/')
param EnableWorkloadIdentity bool = false

var contributorRoleDefId = '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

module aksNsg 'br:infra0prod0bicep0assets.azurecr.io/bicep/modules/nsg:v1' = {
  name: 'aksNsgDeploy'
  params: {
    Location: Location
    NsgName: AksSubnetNsgName
  }
}

module aksVnet 'br:infra0prod0bicep0assets.azurecr.io/bicep/modules/virtualnetwork:v1' = {
  name: 'aksVnetDeploy'
  params: {
    VnetName: AksVnetName
    Location: Location
    VnetAdressPrefixes: AksVnetAdressPrefixes
    SubnetName: AksSubnetName
    SubnetAddressPrefix: AksSubnetAddressPrefix
    NsgResId: aksNsg.outputs.nsgResId
  }
}

module egressPip 'br:infra0prod0bicep0assets.azurecr.io/bicep/modules/publicip:v1.1.1' = {
  name: 'egressPipDeploy'
  params: {
    PipName: EgressPipName
    Location: Location
    AllocationMethod: 'Static'
    PipAvailabilityZones: AksNodeAvailabilityZones
  }
}

module managedCluster 'br:infra0prod0bicep0assets.azurecr.io/bicep/modules/managedcluster:v1.1.3' = {
  name: 'managedClusterDeploy'
  params: {
    AksApiIpToWhitelist: AksApiIpToWhitelist
    AksClusterName: AksClusterName
    AksNodeCount: AksNodeCount
    AksNodeSize: AksNodeSize
    AksNodeAvailabilityZones: AksNodeAvailabilityZones
    AksNodeDiskSize: AksNodeDiskSize
    AksAutoScaling: AksAutoScaling
    AksAutoScalingMaxCount: AksAutoScalingMaxCount
    AksAutoScalingMinCount: AksAutoScalingMinCount
    AksRgName: AksRgName
    AksSubnetName: AksSubnetName
    AksVnetName: AksVnetName
    EgressPipResId: egressPip.outputs.publicIpResId
    K8sDnsZoneName: K8sDnsZoneName
    K8sVersion: K8sVersion
    LogAnalyticResId: LogAnalyticResId
    Location: Location
    AksUseAzureKeyvaultSecretsProvider: AksUseAzureKeyvaultSecretsProvider
    EnableWorkloadIdentity: EnableWorkloadIdentity
  }
}

resource egressPublicIpObject 'Microsoft.Network/publicIPAddresses@2022-01-01' existing = {
  name: EgressPipName
}

resource aksEgressPipContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(egressPublicIpObject.id, AksClusterName, contributorRoleDefId)
  scope: egressPublicIpObject
  properties: {
    roleDefinitionId: contributorRoleDefId
    principalId: managedCluster.outputs.aksIdentityPrincipalId
  }
}

module aksClusterRoleAssignments 'br:infra0prod0bicep0assets.azurecr.io/bicep/recipes/aksclusterroleassingments:v1.0.1' = {
  name: 'aksClusterRoleAssignmentsDeploy'
  params: {
    AksClusterName: managedCluster.outputs.aksClusterName
    AksIdentityPrincipalId: managedCluster.outputs.aksIdentityPrincipalId
    AksVnetName: aksVnet.outputs.virtualNetworkName
    KubernetesClusterUserGroupObjectId: KubernetesClusterUserGroupObjectId
    KubernetesServiceRbacClusterAdminGroupObjectId: KubernetesServiceRbacClusterAdminGroupObjectId
  }
}

output aksIdentityPrincipalId string = managedCluster.outputs.aksIdentityPrincipalId
output aksClusterName string = managedCluster.outputs.aksClusterName
output egressIpAddress string = egressPip.outputs.publicIpAddress
