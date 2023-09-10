locals {
  data = jsondecode(file("../application.json"))
}

resource "kubernetes_namespace" "tf-namespace" {
  metadata {
    name = "terraform"
  }
}

module "deployment" {
  source = "./modules/app-deployment"

  for_each = {
    for index, app in local.data.applications :
    app.name => app
  }

  name           = each.value.name
  image          = each.value.image
  args           = each.value.args
  port           = each.value.port
  traffic_weight = each.value.traffic_weight
  replicas       = each.value.replicas

}
