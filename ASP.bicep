@minValue(1)
@maxValue(3)
param capacity int = 1
@allowed([
  'S1'
  'P1V2'
  'P2V2'
])
param pricingTier string = 'S1'
param aspName string
param location string = resourceGroup().location
param linux bool = false


resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: aspName
  location: location
  sku: {
    name: pricingTier
    capacity: capacity
  }
  properties: {
    reserved: linux
  }
}

resource aspDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'  = {
  name: 'ASPDiags'
  scope: appServicePlan
  properties: {
    workspaceId : '/subscriptions/63fe62de-6748-4a43-a950-f566a7f67665/resourcegroups/monitor-east-us2-rg/providers/microsoft.operationalinsights/workspaces/ag-monitor-la-hub-prod-east-us2'
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output aspid string = appServicePlan.id
