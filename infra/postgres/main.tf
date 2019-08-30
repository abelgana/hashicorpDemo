# Initialize Helm (and install Tiller)
provider "helm" {
  install_tiller = true

  kubernetes {
    host                   = "${var.host}"
    client_certificate     = "${base64decode(var.client_certificate)}"
    client_key             = "${base64decode(var.client_key)}"
    cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"
  }
}

data "helm_repository" "svc_cat" {
  name = "svc-cat"
  url  = "https://svc-catalog-charts.storage.googleapis.com"
}

resource "helm_release" "catalog" {
  name       = "catalog"
  repository = "${data.helm_repository.svc_cat.metadata.0.name}"
  chart      = "catalog"

  set {
    name  = "apiserver.storage.etcd.persistence.enabled"
    value = "true"
  }

  set {
    name  = "apiserver.healthcheck.enabled"
    value = "false"
  }

  set {
    name  = "controllerManager.healthcheck.enabled"
    value = "false"
  }

  set {
    name  = "apiserver.verbosity"
    value = "2"
  }

  set {
    name  = "controllerManager.verbosity"
    value = "2"
  }
}

data "helm_repository" "azure" {
  name = "azure"
  url  = "https://kubernetescharts.blob.core.windows.net/azure"
}

resource "helm_release" "osba" {
  name       = "osba"
  repository = "${data.helm_repository.azure.metadata.0.name}"
  chart      = "open-service-broker-azure"
  namespace  = "osba"

  set_sensitive {
    name  = "azure.subscriptionId"
    value = "${var.arm_subscription_id}"
  }

  set_sensitive {
    name  = "azure.tenantId"
    value = "${var.arm_tenant_id}"
  }

  set_sensitive {
    name  = "azure.clientId"
    value = "${var.arm_client_id}"
  }

  set_sensitive {
    name  = "azure.clientSecret"
    value = "${var.arm_client_secret}"
  }

  depends_on = [null_resource.delay]

}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 60"
  }

  triggers = {
    "before" = "${helm_release.catalog.id}"
  }
}

resource "null_resource" "delay2" {
  provisioner "local-exec" {
    command = "sleep 60"
  }

  depends_on = [helm_release.osba]
}

resource "helm_release" "postgres_chart" {
  name       = "postgres"
  chart      = "./postgres/postgres-chart"
  timeout    = 12000

  depends_on = [null_resource.delay2]
}
