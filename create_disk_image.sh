#!/bin/bash

# Disk Image Creation Script
# This script creates a compressed image of /dev/rdisk4

echo "=== Disk Image Creation Script ==="
echo "Source: /dev/rdisk4 (1TB SD Card)"
echo "Output: disk4_backup.img.gz (compressed)"
echo ""
echo "WARNING: This process will:"
echo "  - Take several hours for 1TB"
echo "  - Require your sudo password"
echo "  - Create a large file (size depends on disk usage and compression)"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting disk image creation..."
    echo "You can monitor progress with the status output."
    echo "Press Ctrl+C to cancel if needed."
    echo ""
    
    # Create the disk image with progress monitoring
    sudo dd if=/dev/rdisk4 bs=1m status=progress | gzip > disk4_backup.img.gz
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "Disk image created successfully!"
        echo "File: disk4_backup.img.gz"
        ls -lh disk4_backup.img.gz
    else
        echo ""
        echo "Error creating disk image."
    fi
else
    echo "Operation cancelled."
fi