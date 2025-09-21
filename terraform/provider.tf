terraform {
  backend "s3" {
    bucket       = "aiyus-dream-app-setup"
    key          = "backend/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = false
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
