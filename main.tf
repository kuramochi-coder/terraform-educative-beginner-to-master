# provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# variables list
variable "region" {
  default = "ap-southeast-1"
}

variable "bucket_name" {
  description = "the name of the bucket you wish to create"
  default     = "my-first-bucket"
}

variable "my_tup" {
  type    = tuple([number, string, bool])
  default = [4, "hello", false]
}

variable "my_map" {
  type = map(number)
  default = {
    "alpha" = 2,
    "bravo" = 3
  }
}

variable "person" {
  type = object({ name = string, age = number })
  default = {
    age  = 19
    name = "Bob"
  }
}

variable "address" {
  type = object({ line1 = string, line2 = string, country = string, postalcode = string })
  default = {
    country    = "Europe"
    line1      = "1 the road"
    line2      = "St Ives"
    postalcode = "CB1 2GB"
  }
}

variable "person_with_address" {
  type = object({ name = string, age = number, address = object({ line1 = string, line2 = string, country = string, postalcode = string }) })
  default = {
    address = {
      country    = "Europe"
      line1      = "1 the road"
      line2      = "St Ives"
      postalcode = "CB1 2GB"
    }
    age  = 21
    name = "Jim"
  }
}

variable "nsg" {}

# locals (variables in terraform)
locals {
  first_part  = "hello"
  second_part = "${local.first_part}-there"
  bucket_name = "${local.second_part}-this-is-my-first-bucket"
  fruit       = toset(["apple", "orange", "banana"])
}

# aws provider
provider "aws" {
  region = var.region
}

# s3 buckets 
resource "aws_s3_bucket" "first_bucket" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket" "second_bucket" {
  bucket = var.bucket_name
}

# vpc config
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# security group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "my-first-security-group"
}

# security group rule for https
resource "aws_security_group_rule" "tls_in" {
  protocol          = "tcp"
  security_group_id = aws_security_group.my_security_group.id
  from_port         = 443
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# security group rule for http
resource "aws_security_group_rule" "http_in" {
  protocol          = "tcp"
  security_group_id = aws_security_group.my_security_group.id
  from_port         = 80
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# aws sqs queue to demonstrate the use of for_each contstruct to create multiple similar resources
resource "aws_sqs_queue" "queues" {
  for_each = local.fruit
  name     = "queue-${each.key}"
}

# outputs
output "bucket_name" {
  value = aws_s3_bucket.first_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.first_bucket.arn
}

output "bucket_information" {
  value = "bucket name: ${aws_s3_bucket.first_bucket.id}, bucket arn: ${aws_s3_bucket.first_bucket.arn}"
}

output "first_bucket_all" {
  value = aws_s3_bucket.first_bucket
}

output "rendered_template" {
  value = templatefile("./backends.tpl", { port = 8080, ip_addrs = ["10.0.0.1", "10.0.0.2"] })
}

output "tuple" {
  value = var.my_tup
}

output "map" {
  value = var.my_map
}

output "alpha_value" {
  value = var.my_map.alpha
}

output "person" {
  value = var.person
}

output "address" {
  value = var.address
}

output "person_with_address" {
  value = var.person_with_address
}

output "nsg" {
  value = var.nsg
}