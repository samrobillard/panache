//version=0.0.1
param AppServiceName string
param Hostname string

resource appServiceObject 'Microsoft.Web/sites@2022-03-01' existing = {
  name: AppServiceName
}

resource appServiceHostNameBindings 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  name: Hostname
  parent: appServiceObject
}
