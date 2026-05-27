provider "aws" {
  region = "us-east-1"
  # Industry Standard: Default Tags ensure everything is tracked for FinOps
  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "NareshIT-Student"
      Project     = "180-Days-DevOps"
      CostCenter  = "Engineering-101"
    }
  }
}

resource "aws_s3_bucket" "finance_reports" {
  bucket = "company-finops-reports-2024"
  # Individual tags override defaults if needed
}