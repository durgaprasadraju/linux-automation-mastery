provider "aws" {
  region = "us-east-1"
}

# 1. Fetch the secret from AWS Secrets Manager
data "aws_secretsmanager_secret" "my_app_secret" {
  name = "prod/ecommerce/api_key"
}

data "aws_secretsmanager_secret_version" "current_secret" {
  secret_id = data.aws_secretsmanager_secret.my_app_secret.id
}

# 2. Extract the exact value (Assuming it's stored as plain text or JSON)
locals {
  secret_value = data.aws_secretsmanager_secret_version.current_secret.secret_string
}

# 3. Create the EC2 Instance
resource "aws_instance" "go_web_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS
  instance_type = "t2.micro"

  # INJECT THE SECRET AS AN ENVIRONMENT VARIABLE VIA USER DATA
  user_data = <<-EOF
              #!/bin/bash
              # Export the secret to the OS
              export APP_SECRET='${local.secret_value}'
              
              # Download/Install Go (simplified for demo)
              apt-get update && apt-get install -y golang-go
              
              # Create a simple run script
              echo 'export APP_SECRET="${local.secret_value}"' >> /etc/environment
              
              # Run the app (Assuming GitHub Actions uploaded the compiled binary here)
              # ./go-app &
              EOF

  tags = {
    Name = "Golang-Secure-Server"
  }
}