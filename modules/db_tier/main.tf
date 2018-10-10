#DB
#Database instance
resource "aws_instance" "raj-TF-DB"{
  ami = "${var.ami_id}"
  subnet_id ="${aws_subnet.rajdb.id}"
  vpc_security_group_ids = ["${aws_security_group.rajdb.id}"]
  instance_type = "t2.micro"
  tags {
    Name = "${var.name}-TF-db"
  }
}

#Private route table for the DB
resource "aws_route_table" "rajdb" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}-dbRT"
  }
}

#Private subnet for the DB
resource "aws_subnet" "rajdb" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.4.2.0/24"
  availability_zone = "${var.region}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.name}-db-subnet"
  }
}

#Route table for the private DB
resource "aws_route_table_association" "rajdb" {
  subnet_id      = "${aws_subnet.rajdb.id}"
  route_table_id = "${aws_route_table.rajdb.id}"
}

#Security group for the DB
resource "aws_security_group" "rajdb" {
  name = "raj-db"
  description = "raj db Security Group"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = "27017"
    to_port = "27017"
    protocol = "tcp"
    security_groups = ["${var.app_sg}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-db"
  }
}

#Nacl for the DB
resource "aws_network_acl" "db" {
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "${var.app_subnet_cidr_block}"
    from_port = 27017
    to_port = 27017
  }

  #Empheral ports
  egress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "${var.app_subnet_cidr_block}"
    from_port = 1024
    to_port = 65535
  }

  ingress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "${var.app_subnet_cidr_block}"
    from_port = 1024
    to_port = 65535
  }
  subnet_ids = ["${aws_subnet.rajdb.id}"]

  tags {
    Name = "${var.name}-db-Nacl"
  }
}
