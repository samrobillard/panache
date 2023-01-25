var Hostname = 'infra.gsoftinfra.com'

module appServicePlan 'br:infra0prod0bicep0assets.azurecr.io/bicep/modules/appserviceplan:v0.0.1' = {
  name: 'appServicePlanDeploy'
  params: {
    AppServicePlanCapacity: 1
    AppServicePlanName: 'sam3-test-asp'
    AppServicePlanSku: 'B1'
    IsLinuxAppServicePlan: true
  }
}

module appService 'br:infra0prod0bicep0assets.azurecr.io/bicep/modules/appservice:v0.0.1' = {
  name: 'appServiceDeploy'
  params: {
    AppServiceName: 'sam3-test-app'
    LinuxAppServiceDockerImageUrl: 'hello-world:latest'
    AppServicePlanName: appServicePlan.outputs.appServicePlanName
    IsLinuxAppServicePlan: true
  }
}

module appServiceCertificate '../modules/appservicecertificate.bicep' = {
  name: 'appServiceCertificateDeploy'
  params: {
    AppServicePlanName: appServicePlan.outputs.appServicePlanName
    Hostname: Hostname
  }
}

module appServiceHostNameBinding 'br:infra0prod0bicep0assets.azurecr.io/bicep/modules/appservicecustomdns:v0.0.1' = {
  name: 'appServiceHostNameBindingDeploy'
  params: {
    AppServiceName: appService.outputs.appServiceName
    Hostname: Hostname
  }
}

module appServiceSniEnabled '../modules/appserviceenablesni.bicep' = {
  name: 'appServiceSniEnabledDeploy'
  dependsOn: [
    appServiceCertificate
  ]
  params: {
    AppServiceName: appService.outputs.appServiceName
    CertificateThumbprint: appServiceCertificate.outputs.appServiceCertificateThumbprint
    Hostname: Hostname
  }
}
