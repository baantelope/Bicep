

param appName string
param aspName string
@allowed([
  'v3.0'
  'v4.0'
  'v5.0'
  'v6.0'
])
param netFrameworkVersion string = 'v5.0'
@allowed([
  'dotnet'
  'dotnetcore'
])
param dotnettype string = 'dotnet'
param vNetName string = ''
param subnetName string = ''
param use32bit bool = true


resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' existing = {
  name: aspName
}



resource webApplication 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  location: resourceGroup().location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: { 
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      use32BitWorkerProcess: use32bit
      netFrameworkVersion: netFrameworkVersion
      alwaysOn: true
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: dotnettype
        }
      ]
    }
  }
}

resource aspDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'AppDiags'
  scope: webApplication
  properties: {
    workspaceId : '/subscriptions/63fe62de-6748-4a43-a950-f566a7f67665/resourcegroups/monitor-east-us2-rg/providers/microsoft.operationalinsights/workspaces/ag-monitor-la-hub-prod-east-us2'
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: true
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
      }
    ]
  }
}



//VNet Integration
resource webAppConfig 'Microsoft.Web/sites/networkConfig@2021-01-15' = if(vNetName != ''){
name: 'virtualNetwork'
parent: webApplication
properties: {
    subnetResourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${vNetName}/subnets/${subnetName}'
    swiftSupported: true
  }
}
