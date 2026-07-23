resource "aws_instance" "ec2-1" {

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  monitoring                  = true
  iam_instance_profile        = var.iam_instance_profile
  root_block_device {

    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"

  }
}