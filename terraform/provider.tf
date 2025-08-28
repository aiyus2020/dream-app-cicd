terraform {
  backend "s3" {
    bucket       = "aiyus-dream-app-setup"
    key          = "backend/terraform.tfstate"
    region       = "us-east-1"
    profile      = "default"
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
