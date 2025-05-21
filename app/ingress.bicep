@description('The kube config for the target Kubernetes cluster.')
@secure()
param kubeConfig string = 'placeholder for base64-encoded-kubeconfig' // << fixed – real value, no uniqueString()
 
@description('DNS name of the HTTP Application Routing AddOn')
param HTTPApplicationRoutingZoneName string
 
extension kubernetes with {
  kubeConfig: kubeConfig
  namespace: 'default'
}
 
resource ingress 'networking.k8s.io/Ingress@v1' = {
  metadata: {
    name: 'frontend'
  }
  spec: {
    ingressClassName: 'webapprouting.kubernetes.azure.com'  // new class
    rules: [
      {
        host: HTTPApplicationRoutingZoneName
        http: {
          paths: [
            {
              path: '/'
              pathType: 'Prefix'
              backend: {
                service: {
                  name: 'frontend'
                  port: { number: 80 }
                }
              }
            }
          ]
        }
      }
    ]
  }
}
