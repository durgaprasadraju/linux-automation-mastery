#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Input: A file containing a list of usernames
USER_LIST=$1

if [[ -z "$USER_LIST" ]]; then
    echo "Usage: ./create_users.sh <user_list_file>"
    exit 1
fi

while IFS= read -r username; do
    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists, skipping..."
    else
        # Create user with a home directory and bash shell
        useradd -m -s /bin/bash "$username"
        
        # Set directory permissions (Least Privilege)
        chmod 700 /home/"$username"
        chown "$username":"$username" /home/"$username"
        
        echo "User $username created successfully with restricted home directory."
    fi
done < "$USER_LIST"


