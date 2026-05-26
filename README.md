# 🐧 Linux Automation Mastery: SysAdmin to Cloud

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS%20S3-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Linux](https://img.shields.io/badge/OS-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Status](https://img.shields.io/badge/Status-Active%20Learning-blue?style=for-the-badge)

## 📌 Project Overview
This repository is a comprehensive collection of automation scripts designed to handle critical **Linux System Administration** tasks and integrate them with **AWS Cloud Services**. 

The goal of this project is to move away from manual "point-and-click" administration toward **Infrastructure-as-Code (IaC)** and **Automated Workflows**. It covers the first phase of my 180-day DevOps transformation.

---

## 🛠️ Core Features

### 1. User Lifecycle Automation
*   **Onboarding:** Scripts to create users, assign home directories, and set default shells.
*   **Access Control:** Automated assignment of users to specific groups (Sudoers, Developers, Read-Only).
*   **Audit:** Scripts to identify inactive users and manage offboarding/account locking.

### 2. Security & Permission Hardening
*   **Least Privilege Enforcement:** Automated `chmod` and `chown` logic to ensure sensitive files are only accessible to authorized service accounts.
*   **Permission Audit:** A scanner that detects "World-Writable" (777) files and logs them for security review.
*   **Ownership Management:** Recursively fixes ownership issues in shared application directories.

### 3. Cloud Storage Integration (AWS S3)
*   **Log Archiver:** Automatically finds local logs (`.log`), compresses them into `tar.gz`, and moves them to an S3 bucket.
*   **S3 Sync Utility:** A "Dropbox-like" experience for Linux, where local configuration folders are synced with S3 for disaster recovery.
*   **IAM Policy Testing:** Scripts to verify if the Linux environment has the correct permissions to interact with S3 buckets.

---

## 📂 Repository Structure

```text
.
├── auth-and-users/
│   ├── create_users.sh       # Batch user creation with secure passwords
│   └── manage_groups.sh      # Group assignment and permission logic
├── security-hardening/
│   ├── audit_permissions.sh  # Scans for insecure file permissions
│   └── secure_configs.sh     # Hardens SSH and system config files
├── cloud-integration/
│   ├── s3_backup.sh          # Compresses and uploads data to AWS S3
│   └── s3_sync_config.sh     # Syncs local app configs to cloud
└── logs/                     # Local directory for script execution logs
