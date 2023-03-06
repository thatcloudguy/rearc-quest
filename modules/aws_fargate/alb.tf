resource "aws_alb" "main" {
  name            = "${var.name}-${var.env}"
  internal        = false
  subnets         = var.public_subnets
  security_groups = [aws_security_group.sg_lb.id]
}

resource "aws_alb_target_group" "main" {
  name                 = "${var.name}-${var.env}"
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 5

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = "30"
    timeout             = "10"
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.quest_cert_validate.certificate_arn
  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_security_group" "sg_lb" {
  name        = "${var.name}-${var.env}-lb"
  description = "Security group for load balancer"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "sg_task" {
  name        = "${var.name}-${var.env}-task"
  description = "Security group for ECS Task"
  vpc_id      = var.vpc_id
}

# Rules for the LB (Targets the task SG)

resource "aws_security_group_rule" "sg_lb_egress_rule" {
  description              = "Only allow load balancer SG to connect to ECS task"
  type                     = "egress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_task.id

  security_group_id = aws_security_group.sg_lb.id
}

# Rules for the TASK (Targets the LB SG)
resource "aws_security_group_rule" "sg_task_ingress_rule" {
  description              = "Only allow LB connections from container port"
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_lb.id

  security_group_id = aws_security_group.sg_task.id
}

resource "aws_security_group_rule" "sg_task_egress_rule" {
  description = "Allow outbound"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sg_task.id
}
resource "aws_security_group_rule" "ingress_lb_https" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_lb.id
}