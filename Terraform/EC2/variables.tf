variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "root_volume_size" {
  type = string
}