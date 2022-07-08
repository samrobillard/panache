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
@description('Name of the resource group created by AKS')
param AksRgName string
param AksUseAzureKeyvaultSecretsProvider bool
param AksApiIpToWhitelist array
param EgressPipResId string
@description('Enable Workload Identity on cluster: https://azure.github.io/azure-workload-identity/docs/')
param EnableWorkloadIdentity bool = false

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-03-02-preview' = {
  name: AksClusterName
  location: Location
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
    disableLocalAccounts: true
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
        osDiskSizeGB: 30
        count: AksNodeCount
        vmSize: AksNodeSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones: []
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
