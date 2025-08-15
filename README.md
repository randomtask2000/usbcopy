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

### Image Creation Scripts

#### 1. `create_disk_image.sh` - Compressed Image (Default Compression)
Creates a compressed disk image using gzip's default compression level (6).
- **Pros**: Best compression ratio, saves maximum space
- **Cons**: Slowest option (2-6 hours for 1TB)
- **Use when**: You have limited storage space and time is not critical

**How to run:**
```bash
./create_disk_image.sh
```

**What it asks:**
```
Continue? (y/n): y
Password: [your sudo password]
```

#### 2. `create_disk_image_fast.sh` - Compressed Image (Fast Compression)
Creates a compressed disk image using gzip's fastest compression level (1).
- **Pros**: Faster than default compression, still saves significant space
- **Cons**: Larger file than maximum compression (1-3 hours for 1TB)
- **Use when**: You want a balance between speed and space savings

**How to run:**
```bash
./create_disk_image_fast.sh
```

**What it asks:**
```
Continue? (y/n): y
Password: [your sudo password]
```

#### 3. `create_disk_image_raw.sh` - Raw Image (No Compression)
Creates an uncompressed, bit-for-bit copy of the disk.
- **Pros**: Fastest option, exact sector-by-sector copy
- **Cons**: Requires full disk size in free space (1TB for 1TB disk)
- **Use when**: You have sufficient storage space and want maximum speed

**How to run:**
```bash
./create_disk_image_raw.sh
```

**What it asks:**
```
Continue anyway? (y/n): y
Password: [your sudo password]
```

### Restore and Clone Scripts

#### 4. `direct_clone_to_2tb.sh` - Direct Clone to 2TB USB
Directly clones from 1TB SD card to 2TB USB without creating an intermediate image file.
- **Pros**: Fastest method (2-3 hours), no storage space needed
- **Cons**: Both disks must be connected simultaneously
- **Use when**: You have both source and target disks connected

**How to run:**
```bash
./direct_clone_to_2tb.sh
```

**What it asks:**
```
Continue? (y/n): y
Password: [your sudo password]
```

**Sample output:**
```
=== Direct Disk Clone: 1TB to 2TB ===

Source: /dev/disk4 (1TB SD Card with Linux filesystem)
Target: /dev/disk5 (2TB USB - currently FAT32)

⚠️  WARNING: This operation will:
   • COMPLETELY ERASE the 2TB USB disk (/dev/disk5)
   • Copy all 1TB from the SD card to the USB
   • Take approximately 2-3 hours to complete

Continue? (y/n): y

Step 1: Unmounting target disk...
Step 2: Starting direct clone...
953869+0 records in
953869+0 records out
1000204886016 bytes transferred in 7234.123456 secs (138234567 bytes/sec)

✅ Clone completed successfully!
Duration: 120 minutes
```

#### 5. `restore_or_clone.sh` - Interactive Restore/Clone Tool
Provides an interactive menu to either restore from an existing image or clone directly between disks.
- **Pros**: Flexible, detects existing image files, provides multiple options
- **Cons**: Requires user interaction to choose options
- **Use when**: You want to choose between different restore methods

**How to run:**
```bash
./restore_or_clone.sh
```

**What it asks:**
```
Choose an option:
  1) Direct clone from /dev/disk4 to /dev/disk5 (fastest, no intermediate storage)
  2) Restore from existing image file [only shown if image exists]
  q) Quit

Enter your choice: 1

Are you absolutely sure? Type 'yes' to continue: yes
Password: [your sudo password]
```

**Sample interaction for direct clone:**
```bash
$ ./restore_or_clone.sh

=== USB Disk Restore/Clone Tool ===

Current disk configuration:
  Source: /dev/disk4 (1TB SD Card)
  Target: /dev/disk5 (2TB USB)

Found compressed image: disk4_backup.img.gz (423GB)

Choose an option:
  1) Direct clone from /dev/disk4 to /dev/disk5 (fastest, no intermediate storage)
  2) Restore from existing image file
  q) Quit

Enter your choice: 1

DIRECT DISK CLONE
=================
WARNING: This will COMPLETELY ERASE /dev/disk5!

Are you absolutely sure? Type 'yes' to continue: yes

Unmounting target disk...
Starting direct disk clone...
[Progress bar shows here]

Disk clone completed successfully!
```

**Sample interaction for image restore:**
```bash
$ ./restore_or_clone.sh

Choose an option:
  2) Restore from existing image file

Enter your choice: 2

RESTORE FROM IMAGE
==================
Using compressed image: disk4_backup.img.gz

WARNING: This will COMPLETELY ERASE /dev/disk5!

Are you absolutely sure? Type 'yes' to continue: yes

Starting image restoration...
[Progress bar shows here]

Image restoration completed successfully!
```

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