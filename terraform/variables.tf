variable "ssh_pubkey" {
  description = "ssh public key"
  type = "string"
}

variable "ssh_key_name" {
  description = "Desired name of AWS key pair"
  default = "deployment-key"
}

variable "instance_type" {
  default = "t2.nano"
}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "rds_volume_size" {
  default = "1"
}

variable "rds_root_user" {
  default = "root"
}

variable "rds_root_password" {
    type = "string"
}
