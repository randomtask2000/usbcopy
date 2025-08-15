#!/bin/bash

# Disk Restore/Clone Script
# This script can either restore from an image file or clone directly between disks

echo "=== USB Disk Restore/Clone Tool ==="
echo ""
echo "Current disk configuration:"
echo "  Source: /dev/disk4 (1TB SD Card)"
echo "  Target: /dev/disk5 (2TB USB)"
echo ""

# Check if image files exist
IMAGE_EXISTS=false
if [ -f "disk4_backup.img.gz" ]; then
    echo "Found compressed image: disk4_backup.img.gz ($(ls -lh disk4_backup.img.gz | awk '{print $5}'))"
    IMAGE_EXISTS=true
elif [ -f "disk4_backup.img" ]; then
    echo "Found raw image: disk4_backup.img ($(ls -lh disk4_backup.img | awk '{print $5}'))"
    IMAGE_EXISTS=true
else
    echo "No existing image files found."
fi

echo ""
echo "Choose an option:"
echo "  1) Direct clone from /dev/disk4 to /dev/disk5 (fastest, no intermediate storage)"
if [ "$IMAGE_EXISTS" = true ]; then
    echo "  2) Restore from existing image file"
fi
echo "  q) Quit"
echo ""
read -p "Enter your choice: " -n 1 -r
echo ""

case $REPLY in
    1)
        echo ""
        echo "DIRECT DISK CLONE"
        echo "================="
        echo "This will clone directly from /dev/disk4 (1TB) to /dev/disk5 (2TB)"
        echo ""
        echo "WARNING: This will COMPLETELY ERASE /dev/disk5!"
        echo "The target disk will be an exact copy of the source (1TB used, 1TB unused on the 2TB disk)"
        echo ""
        read -p "Are you absolutely sure? Type 'yes' to continue: " confirm
        
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo "Unmounting target disk..."
            diskutil unmountDisk /dev/disk5
            
            echo "Starting direct disk clone..."
            echo "This will take approximately 2-3 hours for 1TB over USB 3.0"
            echo ""
            
            # Direct disk-to-disk clone
            sudo dd if=/dev/rdisk4 of=/dev/rdisk5 bs=1m status=progress
            
            if [ $? -eq 0 ]; then
                echo ""
                echo "Disk clone completed successfully!"
                echo "The 2TB disk now contains an exact copy of the 1TB source."
                echo ""
                echo "Note: Only 1TB is used. To expand the partition to use the full 2TB,"
                echo "you'll need to use disk partitioning tools on the target system."
            else
                echo ""
                echo "Error during disk clone."
            fi
        else
            echo "Operation cancelled."
        fi
        ;;
        
    2)
        if [ "$IMAGE_EXISTS" = true ]; then
            echo ""
            echo "RESTORE FROM IMAGE"
            echo "=================="
            
            # Determine which image file to use
            if [ -f "disk4_backup.img.gz" ]; then
                IMAGE_FILE="disk4_backup.img.gz"
                echo "Using compressed image: $IMAGE_FILE"
                RESTORE_CMD="gunzip -c $IMAGE_FILE | sudo dd of=/dev/rdisk5 bs=1m status=progress"
            else
                IMAGE_FILE="disk4_backup.img"
                echo "Using raw image: $IMAGE_FILE"
                RESTORE_CMD="sudo dd if=$IMAGE_FILE of=/dev/rdisk5 bs=1m status=progress"
            fi
            
            echo ""
            echo "WARNING: This will COMPLETELY ERASE /dev/disk5!"
            echo ""
            read -p "Are you absolutely sure? Type 'yes' to continue: " confirm
            
            if [ "$confirm" = "yes" ]; then
                echo ""
                echo "Unmounting target disk..."
                diskutil unmountDisk /dev/disk5
                
                echo "Starting image restoration..."
                echo "This will take approximately 2-4 hours depending on compression"
                echo ""
                
                # Execute the appropriate restore command
                eval $RESTORE_CMD
                
                if [ $? -eq 0 ]; then
                    echo ""
                    echo "Image restoration completed successfully!"
                    echo "The 2TB disk now contains the restored 1TB image."
                else
                    echo ""
                    echo "Error during image restoration."
                fi
            else
                echo "Operation cancelled."
            fi
        else
            echo "Invalid option."
        fi
        ;;
        
    q|Q)
        echo "Operation cancelled."
        exit 0
        ;;
        
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

echo ""
echo "Listing final disk configuration:"
diskutil list disk4 disk5