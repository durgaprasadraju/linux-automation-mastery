# FinOps Automation Project – Terraform, Python & Bash

## Overview

This project demonstrates practical FinOps (Financial Operations) concepts used in modern cloud environments.

The goal is to:
- Improve cloud cost visibility
- Eliminate resource waste
- Enforce tagging compliance
- Automate operational cleanup tasks

The project is divided into three phases:

| Phase | Technology | Objective |
|---|---|---|
| Inform | Terraform | Enforce mandatory cloud tags |
| Optimize | Python + Boto3 | Detect unused EBS volumes |
| Operate | Bash Script | Cleanup old compressed log/archive files |

---

# 1. Terraform – Enforcing Tagging Compliance

## FinOps Objective

In cloud environments, resources without tags become **unallocated spending**.

Finance teams cannot determine:
- Which team owns the resource
- Which environment generated the cost
- Which project or department should be billed

This leads to:
- Cost visibility problems
- Budgeting issues
- Cloud waste
- Governance failures

---

## Industry Skill

### Mandatory Cloud Resource Tagging

This is a critical DevOps + FinOps practice.

Common mandatory tags include:

| Tag | Purpose |
|---|---|
| Owner | Resource owner/team |
| Environment | dev/stage/prod |
| CostCenter | Billing department |
| Project | Associated project |
| ManagedBy | Automation tool |

---

# Terraform Default Tags

Terraform AWS provider supports `default_tags`.

This ensures every resource automatically receives standard tags.

---

## Terraform Code

### providers.tf

```hcl
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Owner       = "DevOpsTeam"
      Environment = "Production"
      CostCenter  = "Finance"
      ManagedBy   = "Terraform"
    }
  }
}
```

---

## Example Resource

### ec2.tf

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"

  tags = {
    Name = "finops-web-server"
  }
}
```

---

## Result

Terraform automatically merges:
- Resource tags
- Default provider tags

Final tags:

| Key | Value |
|---|---|
| Name | finops-web-server |
| Owner | DevOpsTeam |
| Environment | Production |
| CostCenter | Finance |
| ManagedBy | Terraform |

---

## Terraform Commands

### Initialize Terraform

```bash
terraform init
```

### Validate Configuration

```bash
terraform validate
```

### View Execution Plan

```bash
terraform plan
```

### Apply Infrastructure

```bash
terraform apply
```

---

## Benefits

### Financial Visibility
Finance teams can identify:
- Team spending
- Department spending
- Production vs Development costs

### Governance
Ensures organizational compliance.

### Cost Allocation
Supports:
- Chargeback
- Showback
- Budget reporting

### Automation
Removes manual tagging errors.

---

# 2. Python Boto3 – Identifying Unused EBS Volumes

## FinOps Objective

Unused EBS volumes continue generating charges even when detached.

These are:
- Invisible costs
- Common cloud waste
- Difficult to detect manually

---

## Industry Skill

### Automated Waste Detection

Cloud engineers regularly automate:
- Unused resource detection
- Idle infrastructure reports
- Cost optimization recommendations

---

# Solution Architecture

The script:
1. Connects to AWS EC2
2. Retrieves all EBS volumes
3. Filters unattached volumes
4. Prints waste report

---

# Python Script

## File: `unused_ebs_report.py`

```python
import boto3

def find_unused_volumes():
    ec2 = boto3.client('ec2')

    response = ec2.describe_volumes(
        Filters=[
            {
                'Name': 'status',
                'Values': ['available']
            }
        ]
    )

    volumes = response['Volumes']

    if not volumes:
        print("No unused EBS volumes found.")
        return

    print("\nUnused EBS Volumes Report")
    print("-" * 50)

    for volume in volumes:
        volume_id = volume['VolumeId']
        size = volume['Size']
        az = volume['AvailabilityZone']

        print(f"Volume ID : {volume_id}")
        print(f"Size      : {size} GB")
        print(f"Zone      : {az}")
        print("-" * 50)

if __name__ == "__main__":
    find_unused_volumes()
```

---

# Prerequisites

Install Boto3:

```bash
pip install boto3
```

Configure AWS credentials:

```bash
aws configure
```

---

# Run Script

```bash
python3 unused_ebs_report.py
```

---

# Example Output

```text
Unused EBS Volumes Report
--------------------------------------------------
Volume ID : vol-0a123456789
Size      : 50 GB
Zone      : us-west-2a
--------------------------------------------------
```

---

# Cost Optimization Impact

### Why This Matters

Unused EBS volumes:
- Continue billing per GB
- Accumulate over time
- Commonly forgotten after EC2 termination

---

## FinOps Benefits

| Benefit | Description |
|---|---|
| Waste Reduction | Removes unnecessary storage costs |
| Visibility | Identifies orphaned resources |
| Automation | Eliminates manual audits |
| Governance | Improves cloud hygiene |

---

# Future Improvements

Possible enhancements:
- Export CSV report
- Send Slack alerts
- Email notification
- Auto-delete unused volumes
- Generate cost estimates

---

# 3. Bash Script – Local Resource Cleanup

## FinOps Objective

Servers often run out of disk space because of:
- Old compressed logs
- Backup archives
- Temporary files

This leads to:
- Downtime
- Disk-full incidents
- Increased storage costs

---

## Industry Skill

### Operational Cleanup Automation

Linux administrators automate:
- Log rotation
- Temporary file cleanup
- Archive deletion
- Disk space management

---

# Cleanup Requirements

Delete:
- `.zip`
- `.tar.gz`

From:
- `/tmp`
- `/var/log`

Older than:
- 48 hours

---

# Bash Script

## File: `cleanup_old_archives.sh`

```bash
#!/bin/bash

echo "Starting cleanup process..."

find /tmp /var/log \
-type f \
\( -name "*.zip" -o -name "*.tar.gz" \) \
-mmin +2880 \
-print \
-delete

echo "Cleanup completed."
```

---

# Explanation

| Command | Purpose |
|---|---|
| find | Search files |
| -type f | Only files |
| -name | Match file extensions |
| -mmin +2880 | Older than 2880 minutes (48 hrs) |
| -print | Display deleted files |
| -delete | Remove files |

---

# Make Script Executable

```bash
chmod +x cleanup_old_archives.sh
```

---

# Run Script

```bash
./cleanup_old_archives.sh
```

---

# Example Output

```text
Starting cleanup process...

/tmp/backup_old.zip
/var/log/archive.tar.gz

Cleanup completed.
```

---

# Automating with Cron

Run every day at midnight:

```bash
crontab -e
```

Add:

```cron
0 0 * * * /home/ec2-user/cleanup_old_archives.sh
```

---

# FinOps Operational Benefits

| Benefit | Description |
|---|---|
| Disk Optimization | Frees unnecessary storage |
| Stability | Prevents disk-full outages |
| Automation | Reduces manual maintenance |
| Cost Savings | Minimizes storage expansion |

---

# Project Summary

| Component | Technology | FinOps Phase |
|---|---|---|
| Tag Enforcement | Terraform | Inform |
| Waste Detection | Python + Boto3 | Optimize |
| Cleanup Automation | Bash | Operate |

---

# Real-World Industry Relevance

This project demonstrates practical cloud engineering skills used by:
- DevOps Engineers
- Cloud Engineers
- SRE Teams
- FinOps Teams
- Platform Engineers

Key industry concepts covered:
- Infrastructure as Code (IaC)
- Cloud Governance
- Resource Optimization
- Cost Visibility
- Operational Automation

---

# Recommended Enhancements

Future improvements could include:
- AWS Config compliance rules
- CloudWatch monitoring
- Lambda automation
- Slack notifications
- Cost Explorer integration
- Terraform modules
- CI/CD integration
- Automated reporting dashboards

---

# Technologies Used

- Terraform
- AWS
- Python
- Boto3
- Bash
- Linux
- FinOps Practices

---

# Author

Prasad Nadimpalli

Backend Developer transitioning into DevOps and Cloud Engineering with hands-on experience in:
- AWS
- Terraform
- Docker
- Kubernetes
- Python Automation
- CI/CD Pipelines
- Linux Administration

---