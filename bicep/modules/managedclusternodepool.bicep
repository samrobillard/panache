//version=1.1.0
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
param ManagedClusterNodeAvailabilityZones array = []
param ManagedClusterNodeAutoScaling bool = false
param ManagedClusterNodeAutoScalingMaxCount int = 1
param ManagedClusterNodeAutoScalingMinCount int = 1

resource managedCluster 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' existing = {
  name: AksClusterName
}

resource managedClusterNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2022-03-02-preview' = {
  name: ManagedClusterNodePoolName
  parent: managedCluster
  properties: {
    availabilityZones: ManagedClusterNodeAvailabilityZones
    enableNodePublicIP: false
    vnetSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', '${AksVnetName}', '${AksSubnetName}')
    osDiskSizeGB: ManagedClusterNodeDiskSize
    count: ManagedClusterNodeCount
    vmSize: ManagedClusterNodeSize
    osType: ManagedClusterNodeOs
    type: 'VirtualMachineScaleSets'
    mode: 'User'
    maxPods: ManagedClusterMaxPods
    enableAutoScaling: ManagedClusterNodeAutoScaling
    maxCount: ManagedClusterNodeAutoScaling ? ManagedClusterNodeAutoScalingMaxCount : null
    minCount: ManagedClusterNodeAutoScaling ? ManagedClusterNodeAutoScalingMinCount : null
  }
}
