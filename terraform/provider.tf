terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.34.0"
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
  region = "us-east-1"
}