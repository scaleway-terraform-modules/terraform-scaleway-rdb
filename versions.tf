terraform {
  required_version = ">= 0.13"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.43.0"
    }
  }
}
