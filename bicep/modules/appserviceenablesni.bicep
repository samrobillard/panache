//version=0.0.1
param AppServiceName string
param Hostname string
param CertificateThumbprint string

resource webAppCustomHostEnable 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
  name: '${AppServiceName}/${Hostname}'
  properties: {
    sslState: 'SniEnabled'
    thumbprint: CertificateThumbprint
  }
}
