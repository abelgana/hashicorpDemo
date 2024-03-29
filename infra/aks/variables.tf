variable "prefix" {
  description = "The prefic is used to identify the cluster. Default is Dev."
  default = "Dev"
}

variable "region" {
  description = "Azure region to deploy to."
  default = "East US 2"
}

variable "ARM_CLIENT_SECRET"{
    description = "Service principle used to for aks cluster"
}
variable "ARM_CLIENT_ID"{
    description = "Service principle used to for aks cluster"
}
