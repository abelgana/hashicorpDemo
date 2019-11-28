module "aks" {
  source = "./aks"

  ARM_CLIENT_ID     = var.ARM_CLIENT_ID
  ARM_CLIENT_SECRET = var.ARM_CLIENT_SECRET
}

module "postgres" {
  source = "./postgres"

  client_key             = module.aks.client_key
  client_certificate     = module.aks.client_certificate
  cluster_ca_certificate = module.aks.cluster_ca_certificate
  host                   = module.aks.host
  arm_client_id          = var.ARM_CLIENT_ID
  arm_client_secret      = var.ARM_CLIENT_SECRET
  arm_subscription_id    = var.ARM_SUBSCRIPTION_ID
  arm_tenant_id          = var.ARM_TENANT_ID
}
