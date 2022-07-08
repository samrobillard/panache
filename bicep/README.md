# Introduction 
This project is the place for GSoft's Bicep enterprise building blocks

## Resource type naming
When creating a module, please provide via a @description() decorator the naming for that resource type.

i.e.: 'Your description **\n\n**Naming rules: [Rules]'
``` bicep
@description('Name of the AKS cluster\n\nNaming rules: Alphanumerics, underscores, periods, and hyphens.\nStart with alphanumeric. End alphanumeric or underscore.')
```

MS link for naming restrictions: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
