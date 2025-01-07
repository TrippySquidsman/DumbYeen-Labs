#!/bin/bash

# Variables
backup_dir="/tmp/docker_backups"      # Temporary directory for backups
network_mount="/mnt/pve/container_backup"         # Path to mounted network drive

# Ensure backup directory exists
mkdir -p $backup_dir

# Back up all running containers
echo "Backing up all containers..."
for container in $(docker ps -q); do
    container_name=$(docker inspect --format='{{.Name}}' $container | cut -c2-)  # Get container name
    image_name="$(date +%Y%m%d)_${container_name}"                        # Create backup image name with date
    backup_file="${backup_dir}/${image_name}.tar"                               # Backup file path

    echo "Backing up container: $container_name (ID: $container)"
    # Commit the container to an image
    docker commit $container $image_name
    # Save the image as a compressed tar file
    docker save $image_name -o $backup_file | gzip > $image_name.tar.gz        
done

# Copy backups to the network drive with progress bar
echo "Transferring backups to network drive..."

total_files=$(find $backup_dir -type f | wc -l)
current_file=0

for file in $backup_dir/*; do
    current_file=$((current_file + 1))
    echo "Transferring file $current_file of $total_files: $(basename $file)"
    
    # Sub-progress bar for current file
    pv $file > $network_mount/$(basename $file)
done

# Clean up local backup files
echo "Cleaning up local backup files..."
rm -rf $backup_dir

echo "Backup complete!"
