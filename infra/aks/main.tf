# Specify azure provider
provider "azurerm" {
  version = "=1.28.0"
}

# Create Azure resource group.
resource "azurerm_resource_group" "hashicorp_demo" {
  name     = "${var.prefix}-aks-hashicorp-demo"
  location = "${var.region}"
}

resource "azurerm_kubernetes_cluster" "hashicorp_demo" {
  name                = "${var.prefix}-aks-hashicorp-demo"
  location            = "${azurerm_resource_group.hashicorp_demo.location}"
  resource_group_name = "${azurerm_resource_group.hashicorp_demo.name}"
  dns_prefix          = "${var.prefix}-hashicorp-demo"

  addon_profile {
    http_application_routing {
      enabled = "true"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.ARM_CLIENT_ID}"
    client_secret = "${var.ARM_CLIENT_SECRET}"
  }

  tags = {
    Environment = "${var.prefix}"
  }
}
