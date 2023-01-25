//version=0.0.1
param AppServicePlanName string
param Hostname string
param isInitialDeployment bool = true
@description('Resources location, defaults to resource group location.')
param Location string = resourceGroup().location

resource appServicePlanObject 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: AppServicePlanName
}

resource appServiceCertificate 'Microsoft.Web/certificates@2021-03-01' = if (isInitialDeployment) {
  name: Hostname
  location: Location
  properties: {
    serverFarmId: appServicePlanObject.id
    canonicalName: Hostname
  }
}

resource existingAppServiceCertificate 'Microsoft.Web/certificates@2021-03-01' existing = if (!isInitialDeployment) {
  name: Hostname
}

output appServiceCertificateThumbprint string = appServiceCertificate.properties.thumbprint
