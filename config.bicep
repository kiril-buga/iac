@description('Name of the AKS cluster. Defaults to a unique hash prefixed with "petfaindr"')
param clusterName string = 'petfaindr'


@description('Azure Storage Account name')
param storageAccountName string = 'petfaindrstg'

@description('Azure CosmosDB account name')
param cosmosAccountName string = 'petfaindr-cdb'

@description('Azure Service Bus authorization rule name')
param serviceBusAuthorizationRuleName string = 'petfaindr-sb-t1/Dapr'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-08-01' existing = {
  name: clusterName
}


resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosAccountName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource serviceBusAuthorizationRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' existing = {
  name: serviceBusAuthorizationRuleName
}

module secrets 'secrets.bicep' = {
  name: 'secrets'
  params: {
    cosmosUrl: cosmosAccount.properties.documentEndpoint
    cosmosAccountKey: cosmosAccount.listKeys().primaryMasterKey
    kubeConfig: aksCluster.listClusterAdminCredential().kubeconfigs[0].value
    storageAccountName: storageAccount.name
    storageAccountKey: storageAccount.listKeys().keys[0].value
    serviceBusConnectionString: serviceBusAuthorizationRule.listKeys().primaryConnectionString
    cvapiTrainingEndpoint: 'https://petfaindrcv.cognitiveservices.azure.com/'
    cvapiTrainingKey: '60m9VHbiy2zVMKqBMY3fa4U3oPJmuvqy7ySpCfzoNeSCdtmEQGC7JQQJ99BDACfhMk5XJ3w3AAAJACOGndj4'
    cvapiPredictionEndpoint: 'https://petfaindrcv-prediction.cognitiveservices.azure.com/'
    cvapiPredictionKey: '30IoyslKptFdVWBYtUQJDHYRZPnX8daI7jS657neZZh2uwlDNJRiJQQJ99BDACfhMk5XJ3w3AAAIACOGoVt5'
    cvapiProjectId: '7aa38806-2263-4beb-8b7f-8e7038dd5941'
    cvapiPredictionResourceId: '/subscriptions/4fb31362-e279-40f6-9cfd-25d51f589653/resourceGroups/petfaindr-rg/providers/Microsoft.CognitiveServices/accounts/petfaindrcv'
  }
}
