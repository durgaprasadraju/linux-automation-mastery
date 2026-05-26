provider "aws" {
  region = "us-east-1"
}

variable "dev_users" {
  type    = list(string)
  default = ["alice", "bob", "charlie"]
}

# Create IAM Users
resource "aws_iam_user" "onboarding_users" {
  for_each = toset(var.dev_users)
  name     = each.value
}

# Create a Group
resource "aws_iam_group" "dev_group" {
  name = "Developers"
}

# Add Users to Group
resource "aws_iam_group_membership" "team" {
  name = "dev-team-membership"
  users = [for u in aws_iam_user.onboarding_users : u.name]
  group = aws_iam_group.dev_group.name
}

# Attach S3 ReadOnly Access to the Group
resource "aws_iam_group_policy_attachment" "s3_readonly" {
  group      = aws_iam_group.dev_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}