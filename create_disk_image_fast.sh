#!/bin/bash

# Fast Disk Image Creation Script with gzip (level 1 - fastest compression)
# This balances speed and space savings

echo "=== Fast Compressed Disk Image Creation ==="
echo "Source: /dev/rdisk4 (1TB SD Card)"
echo "Output: disk4_backup.img.gz (fast compression)"
echo ""
echo "Using gzip -1 for fastest compression while still saving space"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting disk image creation..."
    echo "This will be faster than default compression but create a larger file"
    echo ""
    
    # Create disk image with fastest compression level
    sudo dd if=/dev/rdisk4 bs=1m status=progress | gzip -1 > disk4_backup.img.gz
    
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