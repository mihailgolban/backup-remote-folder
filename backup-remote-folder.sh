#!/bin/bash

# Load environment variables from .env file
dotenv_file=".env"

if [ -f "$dotenv_file" ]; then
  source "$dotenv_file"
else
  echo "Error: .env file not found."
  exit 1
fi

# Check if the required environment variables are set
if [ -z "$remote_username" ] || [ -z "$remote_server" ] || [ -z "$remote_folder" ]; then
  echo "Error: Please set remote_username, remote_server, and remote_folder in the .env file."
  exit 1
fi

# Create a timestamp for the archive filename
timestamp=$(date +%Y%m%d%H%M%S)

# SSH into the remote server, archive the folder, and download it
ssh "${remote_username}@${remote_server}" << EOF
  # Navigate to the folder you want to archive (replace with the actual path)
  cd "${remote_folder}"

  # Archive the folder using tar (replace with desired archive format if needed)
  tar -czf "${timestamp}_archive.tar.gz" .

  # Exit the SSH session
  exit
EOF

# Download the archived folder to the local destination
scp "${remote_username}@${remote_server}:${remote_folder}/${timestamp}_archive.tar.gz" "${local_destination}"

# Optional: Clean up the remote server by deleting the archived folder
ssh "${remote_username}@${remote_server}" "rm -f ${remote_folder}/${timestamp}_archive.tar.gz"

echo "Archive downloaded to ${local_destination}/${timestamp}_archive.tar.gz"
