variable "vpc_id" {
  description = "the vpc for the app"
}

variable "name" {
  description = "yourname"
}

variable "region" {
  description = "your region"
}

variable "user_data" {
  description = "the user data"
}

variable "ami_id" {
  description = "the id of the ami"
}

variable "ig_id" {
  description = "internet gateway to attach route table to internet"
}
