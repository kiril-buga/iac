@description('Existing ACR name')
param registryName string = 'petfaindracr2'    // << updated to new registry name for Subscription JH Azure for Students

@description('Existing AKS cluster name')
param clusterName string = 'petfaindr-aks'    // << fixed – real name, no uniqueString()

@description('Tag of container images to deploy')
param containerTag string = '1.0'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: registryName
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-08-01' existing = {
  name: clusterName
}

// derive full login server for image references
var containerRegistryLoginServer = containerRegistry.properties.loginServer

module ingress 'app/ingress.bicep' = {
  name: 'ingress'
  params: {
    kubeConfig: aksCluster.listClusterAdminCredential().kubeconfigs[0].value
  }
}

// deploy backend and frontend
module backend 'app/backend.bicep' = {
  name: 'backend'
  params: {
    kubeConfig: aksCluster.listClusterAdminCredential().kubeconfigs[0].value
    containerRegistry: containerRegistryLoginServer
    containerTag: containerTag
  }
}

module frontend 'app/frontend.bicep' = {
  name: 'frontend'
  params: {
    kubeConfig: aksCluster.listClusterAdminCredential().kubeconfigs[0].value
    containerRegistry: containerRegistryLoginServer
    containerTag: containerTag
  }
}
