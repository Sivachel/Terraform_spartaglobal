#App
#Application instance
resource "aws_instance" "raj-TF-app"{
  ami = "${var.ami_id}"
  subnet_id ="${aws_subnet.rajapp.id}"
  vpc_security_group_ids = ["${aws_security_group.rajapp.id}"]
  instance_type = "t2.micro"
  user_data = "${var.user_data}"
  tags {
    Name = "${var.name}-TF-app"
  }
}

#Public subnet for the App
resource "aws_subnet" "rajapp" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.4.1.0/24"
  availability_zone = "${var.region}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.name}-app-subnet"
  }
}

# Public route table for the app
resource "aws_route_table" "rajapp" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.ig_id}"
  }

  tags {
    Name = "${var.name}-appRT"
  }
}

#Route table for the public app
resource "aws_route_table_association" "rajapp" {
  subnet_id      = "${aws_subnet.rajapp.id}"
  route_table_id = "${aws_route_table.rajapp.id}"
}

#Security group for the App
resource "aws_security_group" "rajapp" {
  name = "raj-app"
  description = "raj App Security Group"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-app"
  }
}

#Nacl for the app
resource "aws_network_acl" "app" {
  vpc_id = "${var.vpc_id}"

  egress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  #Empheral ports
  egress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  ingress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }
  subnet_ids = ["${aws_subnet.rajapp.id}"]

  tags {
    Name = "${var.name}-App-Nacl"
  }
}
