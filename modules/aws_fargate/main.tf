resource "aws_ecr_repository" "quest-ecr" {
  name                 = "quest"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecs_cluster" "quest-cluster" {
  name = "${var.name}-${var.env}"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-${var.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"   
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.fargate_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "name": "quest",
    "image": "${var.image}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "80"
      },
      {
        "name": "HEALTHCHECK",
        "value": "/"
      },
      {
        "name": "ENABLE_LOGGING",
        "value": "false"
      },
      {
        "name": "PRODUCT",
        "value": "${var.name}"
      },
      {
        "name": "ENVIRONMENT",
        "value": "${var.env}"
      },
      {
        "name": "SECRET_WORD",
        "value": "${data.aws_secretsmanager_secret_version.secretword.secret_string}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.name}-${var.env}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}
resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${var.name}-${var.env}"
  retention_in_days = 1

}
resource "aws_ecs_service" "app" {
  name            = "quest-dev"
  cluster         = aws_ecs_cluster.quest-cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  force_new_deployment = true

  network_configuration {
    security_groups = [aws_security_group.sg_task.id]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "quest"
    container_port   = var.container_port
  }
  depends_on = [aws_alb_listener.https]
}


resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.name}-${var.env}-ecs"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# application role for the task
resource "aws_iam_role" "fargate_role" {
  name               = "${var.name}-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.fargate_role_assume_role_policy.json
}

# associate app policy
resource "aws_iam_role_policy" "fargate_policy" {
  name   = "${var.name}-${var.env}"
  role   = aws_iam_role.fargate_role.id
  policy = data.aws_iam_policy_document.fargate_policy.json
}

data "aws_iam_policy_document" "fargate_policy" {
  statement {
    actions = [
      "ecs:DescribeClusters",
    ]

    resources = [
      aws_ecs_cluster.quest-cluster.arn,
    ]
  }
}
data "aws_iam_policy_document" "fargate_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "random_id" "id" {
	byte_length = 8
}
resource "aws_secretsmanager_secret" "secretword" {
  name = "${random_id.id.hex}-function-secretword"
}
resource "aws_secretsmanager_secret_version" "secretword" {
  secret_id     = aws_secretsmanager_secret.secretword.id
  secret_string = "Please Update in Secrets Manager Console"
  lifecycle {
    ignore_changes = [
      #ignore changes to this attribute because we will manage secrets in the console
     secret_string,
    ]
  }
}
data "aws_secretsmanager_secret" "secretword" {
  arn = aws_secretsmanager_secret_version.secretword.arn
}
data "aws_secretsmanager_secret_version" "secretword" {
  secret_id = data.aws_secretsmanager_secret.secretword.id
}