output "web-lb" {
  value = "${aws_elb.web.dns_name}"
}

output "web-a" {
  value = "${aws_instance.web-a.public_ip}"
}

output "web-b" {
  value = "${aws_instance.web-b.public_ip}"
}

output "efs" {
  value = "${aws_efs_file_system.web-efs.dns_name}"
}

output "web-db" {
  value = "${aws_db_instance.web-db.address}"
}
