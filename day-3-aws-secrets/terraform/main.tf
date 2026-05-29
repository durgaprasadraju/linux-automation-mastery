provider "aws" {
  region = var.region
}

# -----------------------------------
# AWS ACCOUNT
# -----------------------------------
data "aws_caller_identity" "current" {}

# -----------------------------------
# SECRETS MANAGER
# -----------------------------------
resource "aws_secretsmanager_secret" "app_secret" {
  name = "go-web-app-secret"
}

resource "aws_secretsmanager_secret_version" "app_secret_value" {
  secret_id = aws_secretsmanager_secret.app_secret.id

  secret_string = jsonencode({
    APP_SECRET = var.app_secret
  })
}

# -----------------------------------
# IAM ROLE
# -----------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "ec2-go-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# ECR ACCESS
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# SECRETS ACCESS
resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# INSTANCE PROFILE
resource "aws_iam_instance_profile" "profile" {
  name = "ec2-go-profile"
  role = aws_iam_role.ec2_role.name
}

# -----------------------------------
# SECURITY GROUP
# -----------------------------------
resource "aws_security_group" "go_sg" {
  name = "go-web-sg-prod"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # replace with your IP in real setup
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "go-web-sg-prod"
  }
}

# -----------------------------------
# EC2 INSTANCE
# -----------------------------------
resource "aws_instance" "go_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.profile.name

  vpc_security_group_ids = [
    aws_security_group.go_sg.id
  ]

  user_data = templatefile("${path.module}/user-data.sh", {
    region     = var.region
    account_id = data.aws_caller_identity.current.account_id
    secret_id  = aws_secretsmanager_secret.app_secret.name
  })

  tags = {
    Name = "go-web-server-prod"
  }
}