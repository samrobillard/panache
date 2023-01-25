//version=1.1.3
param AksClusterName string
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
param AksSubnetName string
param AksVnetName string
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
@description('Name of the resource group created by AKS')
param AksRgName string
param AksUseAzureKeyvaultSecretsProvider bool = false
param AksAutoScaling bool = false
param AksAutoScalingMaxCount int = 1
param AksAutoScalingMinCount int = 1
param AksApiIpToWhitelist array
param EgressPipResId string
@description('Enable Workload Identity on cluster: https://azure.github.io/azure-workload-identity/docs/')
param EnableWorkloadIdentity bool = false
param Tags object = resourceGroup().tags

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: AksClusterName
  location: Location
  tags: Tags
  sku: {
    name: 'Basic'
    tier: 'Paid'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: K8sVersion
    enableRBAC: true
    disableLocalAccounts: false
    dnsPrefix: K8sDnsZoneName
    nodeResourceGroup: AksRgName
    podIdentityProfile: {
      enabled: false
    }
    agentPoolProfiles: [
      {
        name: 'defaultpool'
        enableNodePublicIP: false
        vnetSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', '${AksVnetName}', '${AksSubnetName}')
        osDiskSizeGB: AksNodeDiskSize
        count: AksNodeCount
        vmSize: AksNodeSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        enableAutoScaling: AksAutoScaling
        availabilityZones: AksNodeAvailabilityZones
        maxCount: AksAutoScaling ? AksAutoScalingMaxCount : null
        minCount: AksAutoScaling ? AksAutoScalingMinCount : null
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      serviceCidr: '10.241.0.0/16'
      dnsServiceIP: '10.241.0.10'
      dockerBridgeCidr: '172.17.0.1/16'
      loadBalancerProfile: {
        outboundIPs: {
          publicIPs: [
            {
              id: EgressPipResId
            }
          ]
        }
      }
    }
    
    oidcIssuerProfile : {
      enabled: EnableWorkloadIdentity
    }

    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    apiServerAccessProfile: {
      authorizedIPRanges: AksApiIpToWhitelist
      enablePrivateCluster: false
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: false
      }
      azurepolicy: {
        enabled: true
      }
      omsagent: empty(LogAnalyticResId) ? {
        enabled: false
      } : {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: LogAnalyticResId
        } 
      }
      azureKeyvaultSecretsProvider: {
        enabled: AksUseAzureKeyvaultSecretsProvider
      }
    }
  }
}

output aksIdentityPrincipalId string = aksCluster.identity.principalId
output aksClusterName string = aksCluster.name
output aksClusterResId string = aksCluster.id
