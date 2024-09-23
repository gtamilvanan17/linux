#!/bin/bash
 
# Define the cutoff date in YYYY-MM-DD format
cutoff_date=$(date --date='180 days ago' +%F)
 
# List all users
users=$(aws iam list-users --query 'Users[].UserName' --output text)
 
for user in $users; do
    # Initialize an indicator to mark user as inactive
    inactive=1
    # List access keys for user
    keys=$(aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata[].AccessKeyId' --output text)
    for key in $keys; do
        # Get the last used details
        last_used=$(aws iam get-access-key-last-used --access-key-id "$key" --query 'AccessKeyLastUsed.LastUsedDate' --output text)
        if [[ "$last_used" > "$cutoff_date" ]]; then
            inactive=0
            break
        fi
    done
    # If user is inactive, delete them (after handling dependencies)
    if [[ $inactive -eq 1 ]]; then
        echo "User $user is inactive. Consider deleting after manual review."
        # aws iam delete-user --user-name "$user"
    fi
done
