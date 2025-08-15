#!/bin/bash

# Raw Disk Image Creation Script (No Compression)
# WARNING: Requires full disk size in free space

echo "=== Raw Disk Image Creation (No Compression) ==="
echo "Source: /dev/rdisk4 (1TB SD Card)"
echo "Output: disk4_backup.img (raw, uncompressed)"
echo ""
echo "WARNING: This will create a 1TB file!"
echo "Available space: $(df -h . | tail -1 | awk '{print $4}')"
echo "Required space: ~1TB"
echo ""
echo "The process will likely FAIL due to insufficient space!"
echo ""
read -p "Continue anyway? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting raw disk image creation..."
    echo "This will be much faster but requires 1TB of free space"
    echo ""
    
    # Create raw disk image
    sudo dd if=/dev/rdisk4 of=disk4_backup.img bs=1m status=progress
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "Disk image created successfully!"
        echo "File: disk4_backup.img"
        ls -lh disk4_backup.img
    else
        echo ""
        echo "Error creating disk image (likely out of space)."
        # Clean up partial file if it exists
        if [ -f disk4_backup.img ]; then
            echo "Removing partial image file..."
            rm disk4_backup.img
        fi
    fi
else
    echo "Operation cancelled."
fi