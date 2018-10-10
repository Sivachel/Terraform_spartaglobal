output db_instance_id {
  description = "the db instance"
  value = "${aws_instance.raj-TF-DB.private_ip}"
}
