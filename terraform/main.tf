# Provide creds via environment variables
# export AWS_ACCESS_KEY_ID="XXX"
# export AWS_SECRET_ACCESS_KEY="YYY"
# export AWS_DEFAULT_REGION="us-west-2"

provider "aws" {}

#
# DATA
#

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#
# IAM
#

resource "aws_iam_role" "instance" {
  name               = "web-instance-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2-lb-full-access-attachment" {
    role = "${aws_iam_role.instance.name}"
    policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

#
# EC2
#

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${var.ssh_pubkey}"
}

resource "aws_security_group" "web-sg" {
  name = "web-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name                  = "web-elb"
  availability_zones    = ["${data.aws_availability_zones.available.names}"]
  security_groups       = ["${aws_security_group.web-sg.id}"]
  instances             = ["${aws_instance.web-a.id}", "${aws_instance.web-b.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/ping"
    interval            = 5
  }

  provisioner "local-exec" {
    command = "sed -i 's/^app_lb:.*$/app_lb: ${aws_elb.web.dns_name}/' ../ansible/group_vars/all/vars.yml"
  }
}

resource "aws_instance" "web-a" {
  ami                       = "${data.aws_ami.ubuntu.id}"
  instance_type             = "${var.instance_type}"
  key_name                  = "${aws_key_pair.ssh_key.id}"
  security_groups           = ["${aws_security_group.web-sg.id}"]
  iam_instance_profile      = "${aws_iam_role.instance.name}"
  availability_zone         = "${data.aws_availability_zones.available.names[0]}"
  disable_api_termination   = true

  tags {
    Name = "web-a"
  }

  connection {
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y dist-upgrade"
    ]
  }

  provisioner "local-exec" {
    command = "sed -i 's/^web-a.*$/web-a ansible_host=${aws_instance.web-a.public_ip}/' ../ansible/inventory"
  }
}

resource "aws_instance" "web-b" {
  ami                       = "${data.aws_ami.ubuntu.id}"
  instance_type             = "${var.instance_type}"
  key_name                  = "${aws_key_pair.ssh_key.id}"
  security_groups           = ["${aws_security_group.web-sg.id}"]
  iam_instance_profile      = "${aws_iam_role.instance.name}"
  availability_zone         = "${data.aws_availability_zones.available.names[1]}"
  disable_api_termination   = true

  tags {
    Name = "web-b"
  }

  connection {
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y dist-upgrade",
      "sudo apt install -y nfs-common"
    ]
  }

  provisioner "local-exec" {
    command = "sed -i 's/^web-b.*$/web-b ansible_host=${aws_instance.web-b.public_ip}/' ../ansible/inventory"
  }
}

resource "aws_efs_file_system" "web-efs" {
  creation_token = "web-efs"

  tags {
    Name = "web-efs"
  }

  provisioner "local-exec" {
    command = "sed -i 's/^app_efs:.*$/app_efs: ${aws_efs_file_system.web-efs.dns_name}/' ../ansible/group_vars/all/vars.yml"
  }
}

#
# RDS
#

resource "aws_db_security_group" "default" {
  name = "rds_sg"

  ingress {
    cidr = "10.0.0.0/16"
  }
}

resource "aws_db_instance" "web-db" {
  allocated_storage         = "${var.rds_volume_size}"
  storage_type              = "gp2"
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "${var.rds_instance_type}"
  name                      = "web-db"
  username                  = "${var.rds_root_user}"
  password                  = "${var.rds_root_password}"
  parameter_group_name      = "default.mysql5.7"
  apply_immediately         = true
  backup_retention_period   = 7
  multi_az                  = true
  deletion_protection       = true
  security_group_names      = ["${aws_db_security_group.default.id}"]

  provisioner "local-exec" {
    command = "sed -i 's/^aws_rds_host:.*$/aws_rds_host: ${aws_db_instance.web-db.address}/' ../ansible/group_vars/all/vars.yml"
  }
}
