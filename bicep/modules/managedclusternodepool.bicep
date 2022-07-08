param AksClusterName string
param AksVnetName string
param AksSubnetName string = 'aksDefault'
@description('Windows node pool name must be maximum 6 characters and Linux node pool name must be maximum 12 characters.')
param ManagedClusterNodePoolName string
param ManagedClusterNodeCount int
param ManagedClusterNodeSize string
@allowed([
  'Windows'
  'Linux'
])
param ManagedClusterNodeOs string = 'Linux'
param ManagedClusterMaxPods int = 110
param ManagedClusterNodeDiskSize int = 30

resource managedCluster 'Microsoft.ContainerService/managedClusters@2022-03-02-preview' existing = {
  name: AksClusterName
}

resource managedClusterNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2022-03-02-preview' = {
  name: ManagedClusterNodePoolName
  parent: managedCluster
  properties: {
    enableNodePublicIP: false
    vnetSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', '${AksVnetName}', '${AksSubnetName}')
    osDiskSizeGB: ManagedClusterNodeDiskSize
    count: ManagedClusterNodeCount
    vmSize: ManagedClusterNodeSize
    osType: ManagedClusterNodeOs
    type: 'VirtualMachineScaleSets'
    mode: 'User'
    maxPods: ManagedClusterMaxPods
    availabilityZones: []
  }
}
