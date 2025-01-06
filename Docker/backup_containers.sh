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
    image_name="backup_${container_name}_$(date +%Y%m%d)"                        # Create backup image name with date
    backup_file="${backup_dir}/${image_name}.tar"                               # Backup file path

    echo "Backing up container: $container_name (ID: $container)"
    docker commit $container $image_name                                        # Commit the container to an image
    docker save $image_name -o $backup_file                                     # Save the image as a tar file
done

# Copy backups to the network drive
echo "Transferring backups to network drive..."
cp -r $backup_dir/* $network_mount

# Clean up local backup files
echo "Cleaning up local backup files..."
rm -rf $backup_dir

echo "Backup complete!"
