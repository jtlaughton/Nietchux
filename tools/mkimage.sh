#!/bin/bash

# mkimage.sh - Create bootable disk image for Q800OS
# This script combines stage1, stage2, and kernel into a bootable disk image

set -e  # Exit on any error

# Configuration
STAGE1_BIN="bootloader/stage1/stage1_boot.bin"
STAGE2_BIN="bootloader/stage2/stage2_boot.bin"
KERNEL_BIN="kernel/kernel.bin"
OUTPUT_IMAGE="boot.img"

# Image size in bytes (adjust as needed)
IMAGE_SIZE=$((16 * 1024 * 1024))  # 16MB

# Memory layout (these are placeholders - adjust based on Q800 research)
STAGE1_OFFSET=0                    # Boot sector at beginning
STAGE2_OFFSET=512                  # Stage2 right after boot sector
KERNEL_OFFSET=65536               # Kernel at 64KB offset (adjust as needed)

echo "Creating Q800OS boot image..."

# Check if required binaries exist
if [ ! -f "$STAGE1_BIN" ]; then
    echo "Error: $STAGE1_BIN not found. Build stage1 first."
    exit 1
fi

if [ ! -f "$STAGE2_BIN" ]; then
    echo "Error: $STAGE2_BIN not found. Build stage2 first."
    exit 1
fi

if [ ! -f "$KERNEL_BIN" ]; then
    echo "Error: $KERNEL_BIN not found. Build kernel first."
    exit 1
fi

# Create empty image file
echo "Creating ${IMAGE_SIZE} byte disk image..."
dd if=/dev/zero of="$OUTPUT_IMAGE" bs=1 count=$IMAGE_SIZE status=none

# Check stage1 size constraint
STAGE1_SIZE=$(stat -c%s "$STAGE1_BIN")
if [ $STAGE1_SIZE -gt 512 ]; then
    echo "Error: Stage1 bootloader is ${STAGE1_SIZE} bytes (max 512)"
    exit 1
fi
echo "Stage1 size: ${STAGE1_SIZE} bytes (OK)"

# Write stage1 to boot sector
echo "Writing stage1 bootloader to boot sector..."
dd if="$STAGE1_BIN" of="$OUTPUT_IMAGE" bs=1 seek=$STAGE1_OFFSET conv=notrunc status=none

# Write stage2
STAGE2_SIZE=$(stat -c%s "$STAGE2_BIN")
echo "Writing stage2 bootloader (${STAGE2_SIZE} bytes) at offset ${STAGE2_OFFSET}..."
dd if="$STAGE2_BIN" of="$OUTPUT_IMAGE" bs=1 seek=$STAGE2_OFFSET conv=notrunc status=none

# Write kernel
KERNEL_SIZE=$(stat -c%s "$KERNEL_BIN")
echo "Writing kernel (${KERNEL_SIZE} bytes) at offset ${KERNEL_OFFSET}..."
dd if="$KERNEL_BIN" of="$OUTPUT_IMAGE" bs=1 seek=$KERNEL_OFFSET conv=notrunc status=none

# Create info file with layout
INFO_FILE="boot_layout.txt"
echo "Boot Image Layout:" > "$INFO_FILE"
echo "==================" >> "$INFO_FILE"
echo "Total image size: ${IMAGE_SIZE} bytes" >> "$INFO_FILE"
echo "" >> "$INFO_FILE"
echo "Stage1 (boot sector):" >> "$INFO_FILE"
echo "  Offset: ${STAGE1_OFFSET}" >> "$INFO_FILE"
echo "  Size: ${STAGE1_SIZE} bytes" >> "$INFO_FILE"
echo "" >> "$INFO_FILE"
echo "Stage2 bootloader:" >> "$INFO_FILE"
echo "  Offset: ${STAGE2_OFFSET}" >> "$INFO_FILE"
echo "  Size: ${STAGE2_SIZE} bytes" >> "$INFO_FILE"
echo "" >> "$INFO_FILE"
echo "Kernel:" >> "$INFO_FILE"
echo "  Offset: ${KERNEL_OFFSET}" >> "$INFO_FILE"
echo "  Size: ${KERNEL_SIZE} bytes" >> "$INFO_FILE"
echo "" >> "$INFO_FILE"
echo "Free space: $((IMAGE_SIZE - KERNEL_OFFSET - KERNEL_SIZE)) bytes" >> "$INFO_FILE"

echo "Boot image created successfully: $OUTPUT_IMAGE"
echo "Layout information saved to: $INFO_FILE"

# Optional: Show hex dump of first 512 bytes for verification
if command -v hexdump >/dev/null 2>&1; then
    echo ""
    echo "First 512 bytes of boot image (boot sector):"
    hexdump -C "$OUTPUT_IMAGE" | head -32
fi

echo ""
echo "You can now run 'make run' to test the boot image in QEMU"