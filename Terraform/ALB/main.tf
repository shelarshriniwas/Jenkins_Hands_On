#############################################
# Application Load Balancer
#############################################

resource "aws_lb" "alb" {

  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  enable_deletion_protection = false

  idle_timeout = 60

  enable_http2 = true

  tags = {
    Name = "web-alb"
  }
}

#############################################
# Target Group
#############################################

resource "aws_lb_target_group" "web" {

  name = "web-tg"

  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.main.id

  target_type = "instance"

  health_check {

    enabled = true

    path = "/"

    protocol = "HTTP"

    port = "traffic-port"

    interval = 30

    timeout = 5

    healthy_threshold = 3

    unhealthy_threshold = 2

    matcher = "200"

  }

  tags = {
    Name = "web-target-group"
  }
}

#############################################
# HTTP Listener
#############################################

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.web.arn

  }
}

#############################################
# HTTPS Listener
#############################################

resource "aws_lb_listener" "https" {

  load_balancer_arn = aws_lb.alb.arn

  port = 443

  protocol = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = aws_acm_certificate.web.arn

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.web.arn

  }
}

#############################################
# HTTP -> HTTPS Redirect
#############################################

resource "aws_lb_listener_rule" "redirect" {

  listener_arn = aws_lb_listener.http.arn

  priority = 1

  action {

    type = "redirect"

    redirect {

      protocol = "HTTPS"

      port = "443"

      status_code = "HTTP_301"

    }
  }

  condition {

    path_pattern {

      values = ["/*"]

    }

  }

}

#############################################
# Listener Rule
#############################################

resource "aws_lb_listener_rule" "app" {

  listener_arn = aws_lb_listener.https.arn

  priority = 100

  action {

    type = "forward"

    target_group_arn = aws_lb_target_group.web.arn

  }

  condition {

    path_pattern {

      values = ["/app/*"]

    }

  }

}

#############################################
# Outputs
#############################################

output "alb_dns_name" {

  value = aws_lb.alb.dns_name

}

output "alb_arn" {

  value = aws_lb.alb.arn

}

output "target_group_arn" {

  value = aws_lb_target_group.web.arn

}

output "http_listener_arn" {

  value = aws_lb_listener.http.arn

}

output "https_listener_arn" {

  value = aws_lb_listener.https.arn

}