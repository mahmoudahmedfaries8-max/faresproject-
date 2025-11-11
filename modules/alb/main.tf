resource "aws_lb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [var.public_sg_id]
}

resource "aws_lb_target_group" "public_tg" {
  name     = "public-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  # health check defaults are fine; adjust if your backend listens on different port
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    path                = "/"
    matcher             = "200"
    port                = "80"
    protocol            = "HTTP"
  }
}

# Register public instances (public-proxy) as targets
resource "aws_lb_target_group_attachment" "public_instances" {
  count            = length(var.public_instances)
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = var.public_instances[count.index]
  port             = 80
}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}

