# Disk Imaging Scripts

This directory contains scripts for creating disk images from storage devices, particularly for backing up and cloning USB drives and SD cards.

## Quick Start

### Step 1: Identify Your Disk
```bash
# List all disks to find your USB/SD card
diskutil list

# Look for your device (e.g., /dev/disk4 for SD card, /dev/disk5 for USB)
# Note the disk identifier for the next steps
```

### Step 2: Choose and Run a Script

#### Option A: Maximum Compression (Slowest, Smallest File)
```bash
# Clone the repository
git clone https://github.com/randomtask2000/usbcopy.git
cd usbcopy

# Run the default compression script
./create_disk_image.sh
```

#### Option B: Fast Compression (Balanced Speed/Size)
```bash
# Navigate to the repository
cd usbcopy

# Run the fast compression script
./create_disk_image_fast.sh
```

#### Option C: Raw Image (Fastest, Largest File)
```bash
# Navigate to the repository
cd usbcopy

# Run the raw image script (requires full disk size in free space)
./create_disk_image_raw.sh
```

### Step 3: Restore to New Disk
```bash
# First, identify the target disk
diskutil list

# For compressed images:
gunzip -c disk4_backup.img.gz | sudo dd of=/dev/rdisk5 bs=1m status=progress

# For raw images:
sudo dd if=disk4_backup.img of=/dev/rdisk5 bs=1m status=progress
```

## Available Scripts

### 1. `create_disk_image.sh` - Compressed Image (Default Compression)
Creates a compressed disk image using gzip's default compression level (6).
- **Pros**: Best compression ratio, saves maximum space
- **Cons**: Slowest option (2-6 hours for 1TB)
- **Use when**: You have limited storage space and time is not critical

### 2. `create_disk_image_fast.sh` - Compressed Image (Fast Compression)
Creates a compressed disk image using gzip's fastest compression level (1).
- **Pros**: Faster than default compression, still saves significant space
- **Cons**: Larger file than maximum compression (1-3 hours for 1TB)
- **Use when**: You want a balance between speed and space savings

### 3. `create_disk_image_raw.sh` - Raw Image (No Compression)
Creates an uncompressed, bit-for-bit copy of the disk.
- **Pros**: Fastest option, exact sector-by-sector copy
- **Cons**: Requires full disk size in free space (1TB for 1TB disk)
- **Use when**: You have sufficient storage space and want maximum speed

## Command Line Examples

### Complete Workflow Example
```bash
# 1. Clone the repository
git clone https://github.com/randomtask2000/usbcopy.git
cd usbcopy

# 2. Check your current disk setup
diskutil list

# 3. Verify available space
df -h

# 4. Unmount the source disk (if mounted)
diskutil unmountDisk /dev/disk4

# 5. Create the image (choose one):
./create_disk_image_fast.sh    # Recommended for most users

# 6. After swapping the SSD, identify the new disk
diskutil list

# 7. Unmount the target disk
diskutil unmountDisk /dev/disk5

# 8. Restore the image
gunzip -c disk4_backup.img.gz | sudo dd of=/dev/rdisk5 bs=1m status=progress

# 9. Verify the restoration
diskutil list
```

### Direct Terminal Commands (Without Scripts)

#### Create Images
```bash
# Compressed image (saves space)
sudo dd if=/dev/rdisk4 bs=1m status=progress | gzip -1 > backup.img.gz

# Maximum compression (smallest file)
sudo dd if=/dev/rdisk4 bs=1m status=progress | gzip -9 > backup.img.gz

# Raw image (fastest, needs full disk space)
sudo dd if=/dev/rdisk4 of=backup.img bs=1m status=progress
```

#### Restore Images
```bash
# From compressed image
gunzip -c backup.img.gz | sudo dd of=/dev/rdisk5 bs=1m status=progress

# From raw image
sudo dd if=backup.img of=/dev/rdisk5 bs=1m status=progress
```

#### Monitor Progress (in another terminal)
```bash
# Check how much has been written
sudo killall -INFO dd

# Watch file size grow
watch -n 5 'ls -lh *.img*'

# Check disk activity
iostat -w 5
```

### Advanced Examples

#### Clone Directly Between Two Disks (No Intermediate File)
```bash
# When you have both disks connected
sudo dd if=/dev/rdisk4 of=/dev/rdisk5 bs=1m status=progress
```

#### Create Image to External Drive
```bash
# To save space on main drive
sudo dd if=/dev/rdisk4 bs=1m status=progress | gzip > /Volumes/ExternalDrive/backup.img.gz
```

#### Verify Image Integrity
```bash
# Create checksums
sudo dd if=/dev/rdisk4 bs=1m | tee backup.img | md5 > backup.md5
# Later verify
md5 backup.img
cat backup.md5
```

#### Resume Interrupted Transfer
```bash
# Check how much was copied
ls -la backup.img

# Resume from that point (example: resume at 10GB)
sudo dd if=/dev/rdisk4 of=backup.img bs=1m seek=10240 skip=10240 status=progress
```

## How the Code Works

### Core Components

#### 1. The `dd` Command
```bash
dd if=/dev/rdisk4 of=output.img bs=1m status=progress
```
- `dd`: "Data duplicator" - copies data block by block
- `if=/dev/rdisk4`: Input file (source disk)
  - `/dev/rdisk4` uses raw disk access (faster than `/dev/disk4` on macOS)
- `of=output.img`: Output file (destination image)
- `bs=1m`: Block size of 1 megabyte (optimal for macOS disk operations)
- `status=progress`: Shows real-time progress updates

#### 2. Compression Pipeline (Compressed Versions)
```bash
dd if=/dev/rdisk4 bs=1m status=progress | gzip > output.img.gz
```
- The pipe `|` sends dd's output to gzip instead of a file
- `gzip`: Compresses the data stream
  - Default level (6): Best compression
  - `-1` flag: Fastest compression, larger file
  - `-9` flag: Maximum compression, slowest
- `>`: Redirects compressed output to a file

#### 3. Why `/dev/rdisk` vs `/dev/disk`
- `/dev/disk4`: Buffered device (goes through macOS's buffer cache)
- `/dev/rdisk4`: Raw device (bypasses buffer cache)
- Raw devices are typically 2-20x faster for sequential operations like imaging

### Script Flow

1. **Display Information**: Shows source disk and output file details
2. **Check Available Space**: Warns about space requirements
3. **User Confirmation**: Requires explicit consent before proceeding
4. **Execute dd Command**: Runs with sudo for disk access permissions
5. **Progress Monitoring**: Shows bytes copied in real-time
6. **Error Handling**: Checks exit code and cleans up on failure
7. **Success Report**: Shows final file size when complete

### Restoring Images

To restore an image back to a disk:

#### Compressed Image:
```bash
gunzip -c disk4_backup.img.gz | sudo dd of=/dev/rdisk5 bs=1m status=progress
```

#### Raw Image:
```bash
sudo dd if=disk4_backup.img of=/dev/rdisk5 bs=1m status=progress
```

**WARNING**: Be absolutely certain of the destination disk number. This will completely overwrite the target disk!

## Important Notes

1. **Disk Identification**: Always verify disk numbers with `diskutil list` before operations
2. **Data Loss Risk**: These operations can destroy data if the wrong disk is specified
3. **Time Requirements**: 
   - 1TB over USB 3.0: ~2-3 hours raw, 3-6 hours compressed
   - 1TB over USB 2.0: ~8-10 hours raw, 10-15 hours compressed
4. **Space Requirements**:
   - Raw: Exactly the size of the source disk
   - Compressed: Varies based on data content (20-90% of original)
5. **Sudo Access**: Required for raw disk access on macOS

## Safety Tips

1. Always double-check disk numbers before running
2. Keep your Mac plugged in and prevent sleep during operations
3. Don't disconnect devices during operations
4. Verify the image after creation (optional):
   ```bash
   # For raw images
   sudo dd if=/dev/rdisk4 bs=1m count=1000 | md5
   dd if=disk4_backup.img bs=1m count=1000 | md5
   # Compare the checksums
   ```

## Troubleshooting

- **"Resource busy"**: Unmount the disk first: `diskutil unmountDisk /dev/disk4`
- **"Operation not permitted"**: Ensure Terminal has Full Disk Access in System Settings
- **"No space left"**: Check available space with `df -h`
- **Slow speeds**: Ensure using `/dev/rdisk` not `/dev/disk`, check USB connection type