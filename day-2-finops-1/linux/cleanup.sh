#!/bin/bash
# FinOps at the OS Level: Prevent storage over-provisioning

TARGET_DIR="/tmp"
DAYS=2

echo "Searching for old archives in $TARGET_DIR..."

# Find files older than 2 days and delete them
find $TARGET_DIR -type f \( -name "*.zip" -o -name "*.gz" \) -mtime +$DAYS -exec rm -v {} \;

echo "Cleanup complete. Local storage optimized."