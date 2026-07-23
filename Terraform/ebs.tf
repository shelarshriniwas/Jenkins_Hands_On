#############################################
# EBS Volume
#############################################

resource "aws_ebs_volume" "data" {

  availability_zone = "ap-south-1a"

  size = 20

  type = "gp3"

  encrypted = true

  tags = {
    Name = "data-volume"
  }
}

#############################################
# Attach EBS Volume to EC2
#############################################

resource "aws_volume_attachment" "data_attach" {

  device_name = "/dev/xvdf"

  volume_id = aws_ebs_volume.data.id

  instance_id = aws_instance.web.id

  force_detach = false

  stop_instance_before_detaching = true
}

#############################################
# EBS Snapshot
#############################################

resource "aws_ebs_snapshot" "data_snapshot" {

  volume_id = aws_ebs_volume.data.id

  tags = {
    Name = "data-volume-snapshot"
  }
}

#############################################
# Copy Snapshot (Optional)
#############################################

resource "aws_ebs_snapshot_copy" "copy" {

  source_snapshot_id = aws_ebs_snapshot.data_snapshot.id

  source_region = "ap-south-1"

  encrypted = true

  tags = {
    Name = "snapshot-copy"
  }
}

#############################################
# Volume from Snapshot
#############################################

resource "aws_ebs_volume" "restore" {

  availability_zone = "ap-south-1a"

  snapshot_id = aws_ebs_snapshot.data_snapshot.id

  type = "gp3"

  tags = {
    Name = "restored-volume"
  }
}

#############################################
# Outputs
#############################################

output "ebs_volume_id" {

  value = aws_ebs_volume.data.id
}

output "snapshot_id" {

  value = aws_ebs_snapshot.data_snapshot.id
}

output "restored_volume_id" {

  value = aws_ebs_volume.restore.id
}