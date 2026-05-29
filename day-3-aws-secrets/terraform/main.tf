provider "aws" {
  region = var.region
}

# -----------------------------------
# GET AWS ACCOUNT ID
# -----------------------------------
data "aws_caller_identity" "current" {}

# -----------------------------------
# IAM ROLE FOR EC2
# -----------------------------------
resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# -----------------------------------
# ATTACH ECR READ POLICY
# -----------------------------------
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# -----------------------------------
# INSTANCE PROFILE
# -----------------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# -----------------------------------
# SECURITY GROUP
# -----------------------------------
resource "aws_security_group" "go_sg" {
  name = "go-web-sg-v4"

  ingress {
    description = "HTTP"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # Replace with your IP
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "go-web-sg-v4"
  }
}

# -----------------------------------
# EC2 INSTANCE
# -----------------------------------
resource "aws_instance" "go_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.go_sg.id
  ]

  user_data = templatefile("${path.module}/user-data.sh", {
    region     = var.region
    account_id = data.aws_caller_identity.current.account_id
    app_secret = var.app_secret
  })

  tags = {
    Name = "go-web-server-v4"
  }
}