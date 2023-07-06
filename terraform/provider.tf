terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.60.0"
    }
  }
}

# Configuration options
  provider "aws" {
    region = "eu-central-1"
}
