#!/bin/bash

# Direct Clone from 1TB SD Card to 2TB USB
# Source: /dev/disk4 (1TB SD Card)
# Target: /dev/disk5 (2TB USB)

echo "=== Direct Disk Clone: 1TB to 2TB ==="
echo ""
echo "Source: /dev/disk4 (1TB SD Card with Linux filesystem)"
echo "Target: /dev/disk5 (2TB USB - currently FAT32)"
echo ""
echo "Current target disk layout:"
diskutil list disk5
echo ""
echo "⚠️  WARNING: This operation will:"
echo "   • COMPLETELY ERASE the 2TB USB disk (/dev/disk5)"
echo "   • Copy all 1TB from the SD card to the USB"
echo "   • Take approximately 2-3 hours to complete"
echo "   • Create an exact clone (the extra 1TB will be unallocated)"
echo ""
echo "After cloning, the 2TB disk will have:"
echo "   • 1TB: Exact copy of your SD card with Linux filesystem"
echo "   • 1TB: Unallocated space (can be partitioned later)"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Step 1: Unmounting target disk..."
    diskutil unmountDisk /dev/disk5
    
    echo ""
    echo "Step 2: Starting direct clone..."
    echo "You'll be prompted for your password."
    echo "Progress will be shown in MB/s"
    echo ""
    
    # Start time
    START_TIME=$(date +%s)
    
    # Direct clone with progress
    sudo dd if=/dev/rdisk4 of=/dev/rdisk5 bs=1m status=progress
    
    # End time
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    DURATION_MIN=$((DURATION / 60))
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Clone completed successfully!"
        echo "Duration: $DURATION_MIN minutes"
        echo ""
        echo "Verifying target disk:"
        diskutil list disk5
        echo ""
        echo "The 2TB USB now contains an exact copy of your 1TB SD card."
        echo ""
        echo "Next steps:"
        echo "1. You can use the cloned disk as-is (1TB used, 1TB free)"
        echo "2. Or expand the partition to use the full 2TB using Linux tools"
    else
        echo ""
        echo "❌ Error during cloning process."
        echo "Please check:"
        echo "  - Both disks are properly connected"
        echo "  - You have sufficient permissions (sudo)"
        echo "  - The disks are not in use by other processes"
    fi
else
    echo "Operation cancelled."
fi