provider "aws" {
  region = var.region
}

# Get AWS Account ID
data "aws_caller_identity" "current" {}

# -----------------------------
# SECURITY GROUP
# -----------------------------
resource "aws_security_group" "go_sg" {
  name = "go-web-sg-v3"

  ingress {
    description = "HTTP"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application"

    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"

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

  tags = {
    Name = "go-web-sg-v3"
  }
}

# -----------------------------
# EC2 INSTANCE
# -----------------------------
resource "aws_instance" "go_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.go_sg.id
  ]

  user_data = templatefile("${path.module}/user-data.sh", {
    region     = var.region
    account_id = data.aws_caller_identity.current.account_id
    app_secret = var.app_secret
  })

  tags = {
    Name = "go-web-server-v3"
  }
}
