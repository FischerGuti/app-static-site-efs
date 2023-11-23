# PROVIDER
terraform {

  required_version = "~> 1.6.2

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }

  backend "s3" {
    bucket         = "gsquevaidarcertodofishinho"
    key            = "terraform.tfstate"
    dynamodb_table = "tabeladodofishinho"
    region         = "us-east-1"
  }

}

provider "aws" {
  region  = "us-east-1"
}