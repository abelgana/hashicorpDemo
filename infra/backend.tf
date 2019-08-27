terraform {
    backend "s3" {
        bucket  = "terraform-backend-store-test"
        encrypt = true
        key     = "terraform.tfstate"
        region  = "eu-west-1"
    }
}
