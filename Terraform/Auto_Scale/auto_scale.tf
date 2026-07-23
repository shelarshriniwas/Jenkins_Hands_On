resource "aws_autoscaling_group" "web_asg" {
  
  name = var.autoscale_grp_name

  desired_capacity = 2
  min_size = 1
  max_size =4

  vpc_zone_identifier = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {

    id      = aws_launch_template.web.id
    version = "$Latest"

  }

  target_group_arns = [
    aws_lb_target_group.web.arn
  ]

  termination_policies = [
    "OldestInstance"
  ]

  default_cooldown = 300

  force_delete = true

  wait_for_capacity_timeout = "10m"

  enabled_metrics = [

    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"

  ]

  instance_refresh {

    strategy = "Rolling"

    preferences {

      min_healthy_percentage = 50

      instance_warmup = 300

    }

}

#resource "aws_autoscaling_policy" "scale_out" {

  #name = "scale-out-policy"

  #autoscaling_group_name = aws_autoscaling_group.web_asg.name

  #adjustment_type = "ChangeInCapacity"

  #scaling_adjustment = 1

 # cooldown = 300

#}


# resource "aws_autoscaling_policy" "scale_in" {

  #name = "scale-in-policy"

  #autoscaling_group_name = aws_autoscaling_group.web_asg.name

  #adjustment_type = "ChangeInCapacity"

  #scaling_adjustment = -1

 # cooldown = 300

} 