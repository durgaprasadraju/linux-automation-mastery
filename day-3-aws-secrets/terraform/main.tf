provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

# Create ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name = "go-web-app"
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "go-web-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for EC2
resource "aws_iam_role_policy" "ec2_policy" {
  name = "go-web-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = "*"
      }
    ]
  })
}

# Attach IAM Role to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "go-web-profile"
  role = aws_iam_role.ec2_role.name
}

# Security Group
resource "aws_security_group" "go_sg" {
  name = "go-web-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "go_server" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.go_sg.id]

  user_data = templatefile("${path.module}/user-data.sh", {
    region     = var.region
    account_id = data.aws_caller_identity.current.account_id
  })

  tags = {
    Name = "go-web-server"
  }
}
