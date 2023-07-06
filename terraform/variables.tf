# Region to create infrastructure
variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "The region to create the infrastructure"
}

# Declare the data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC CIDR block
variable "vpc_cidr" {
  default     = "10.10.0.0/20"
  description = "The CIDR block to be used by the VPC"
}


#Region
#variable "aws_region" {
#  description = "EU Frankfurt region"
#  default     = "eu-central-1"
#}

# The location from which a user can SSH to bastion hosts
variable "ssh_location" {
  type        = string
  description = "The IP address range that can be used to SSH to the Bastion hosts"
}

# specifying AZs 
variable "azs" {
  type = list
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnets_cidr" {
  type = list
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnets_cidr" {
  type = list
  default = ["10.10.3.0/24", "10.10.4.0/24"]
}

#changing variables
variable "ec2_user" {}
variable "private_key_public" {}
variable "private_key_private" {}
variable "public_key_public" {}
variable "public_key_private" {}
variable "rds_name" {}
variable "rds_username" {}
variable "rds_pw" {}
