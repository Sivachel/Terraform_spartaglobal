variable "vpc_id" {
  description = "the vpc for the db"
}

variable "name" {
  description = "yourname"
}

variable "region" {
  description = "your region"
}

variable "ami_id" {
  description = "the id of the ami"
}

 variable "app_sg" {
   description = "security group of the app"
 }

 variable "app_subnet_cidr_block" {
   default = "the cidr block of the app"
 }
