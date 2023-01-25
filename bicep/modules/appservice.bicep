//version=0.0.1
param AppServicePlanName string
param AppServiceName string
param IsLinuxAppServicePlan bool
@description('Format: acrUrl/image:tag')
param LinuxAppServiceDockerImageUrl string = ''
param WindowsNetFrameworkVersion string = ''
param AppSettings array = []
param IpSecurityRestrictions array = []
param enableHttp20 bool = true
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location
param Tags object = resourceGroup().tags

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: AppServicePlanName
}

resource appService 'Microsoft.Web/sites@2021-03-01' = {
  name: AppServiceName
  location: Location
  tags: Tags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'web'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      linuxFxVersion: IsLinuxAppServicePlan ? 'DOCKER|${LinuxAppServiceDockerImageUrl}' : null
      netFrameworkVersion: IsLinuxAppServicePlan ? null : WindowsNetFrameworkVersion
      webSocketsEnabled: false
      use32BitWorkerProcess: false
      http20Enabled: enableHttp20
      acrUseManagedIdentityCreds: true
      managedPipelineMode: 'Integrated'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      httpLoggingEnabled: true
      detailedErrorLoggingEnabled: true
      requestTracingEnabled: true
      logsDirectorySizeLimit: 40
      ipSecurityRestrictions: IpSecurityRestrictions
      appSettings: AppSettings
    }   
  }
}

output appServiceName string = appService.name
output appServiceResId string = appService.id
