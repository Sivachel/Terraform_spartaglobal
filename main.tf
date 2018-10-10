#setting the provider in this case AWS
provider "aws" {
  region ="eu-west-1"
}

# 1 - terraform
# Creating a VPC
resource "aws_vpc" "raj" {
  cidr_block = "10.4.0.0/16"
  tags {
    Name = "${var.name}-vpc"
  }
}

#Creating a internet gateway for the VPC
resource "aws_internet_gateway" "raj" {
  vpc_id = "${aws_vpc.raj.id}"

  tags {
    Name = "${var.name}-IG"
  }
}

#Module for the App
module "app" {
  source = "./modules/app_tier"
  vpc_id = "${aws_vpc.raj.id}"
  name = "${var.name}"
  region = "${var.region}"
  user_data = "${data.template_file.app_init.rendered}"
  ami_id = "${var.app_ami_id}"
  ig_id = "${aws_internet_gateway.raj.id}"
}

#Module for the DB
module "db" {
  source = "./modules/db_tier"
  vpc_id = "${aws_vpc.raj.id}"
  name = "${var.name}"
  region = "${var.region}"
  ami_id = "${var.db_ami_id}"
  app_sg = "${module.app.security_group_id}"
  app_subnet_cidr_block = "${module.app.subnet_cidr_block}"
}

resource "aws_lb" "lb" {
  name               = "raj-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${module.app.subnet_app_id}"]
  enable_deletion_protection = false

  tags {
    Name = "raj_app_lb"
  }
}

#Creating a launch configuration
resource "aws_launch_configuration" "rajapp" {
  name = "raj-tf-launch_configuration"
  image_id = "${var.app_ami_id}"
  instance_type = "t2.micro"
  security_groups = ["${module.app.security_group_id}"]
  user_data = "${data.template_file.app_init.rendered}"
}

#Creating the Autoscaling group
resource "aws_autoscaling_group" "rajapp" {
  name = "rajapp-tf-asg"
  max_size = 2
  min_size = 0
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 2
  force_delete = true
  launch_configuration = "${aws_launch_configuration.rajapp.name}"
  vpc_zone_identifier = ["${module.app.subnet_app_id}"]
  target_group_arns = ["${aws_lb_target_group.rajapp.id}"]
}

resource "aws_lb_target_group" "rajapp" {
  name     = "${var.name}-target-group"
  port     = "80"
  protocol = "TCP"
  vpc_id   = "${aws_vpc.raj.id}"
}

resource "aws_lb_listener" "rajapp" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.rajapp.arn}"
  }
}

resource "aws_route53_record" "rajapp" {
  zone_id = "Z3CCIZELFLJ3SC"
  name    = "rajapp"
  type    = "A"

  alias {
    name                   = "${aws_lb.lb.dns_name}"
    zone_id                = "${aws_lb.lb.zone_id}"
    evaluate_target_health = true
  }
}

#Inline scripts for the App and DB
data "template_file" "app_init" {
  template = "${file("./scripts/app/setup.sh.tpl")}"
  vars {
    db_host="mongodb://${module.db.db_instance_id}:27017/posts"
  }
}
