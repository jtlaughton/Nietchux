cmake_minimum_required(VERSION 3.16)
project(Q800OS ASM C)

# Cross-compilation setup
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR m68k)

# Toolchain
set(CMAKE_C_COMPILER m68k-linux-gnu-gcc)
set(CMAKE_ASM_COMPILER m68k-linux-gnu-gcc)
set(CMAKE_LINKER m68k-linux-gnu-ld)
set(CMAKE_OBJCOPY m68k-linux-gnu-objcopy)

# Bare metal flags
set(CMAKE_C_FLAGS "-m68040 -nostdlib -nostartfiles -ffreestanding -fno-builtin -Wall -Os")
set(CMAKE_ASM_FLAGS "-m68040 -nostdlib -nostartfiles")
set(CMAKE_EXE_LINKER_FLAGS "-m68040 -nostdlib -T ${CMAKE_SOURCE_DIR}/boot.ld")

# Disable standard libraries
set(CMAKE_C_STANDARD_LIBRARIES "")
set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES "")

enable_language(ASM)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/bootloader/include
    ${CMAKE_SOURCE_DIR}/kernel/include
)

# Add subdirectories
add_subdirectory(bootloader)
add_subdirectory(kernel)

# Boot image creation using your shell script
add_custom_target(boot_image
    COMMAND ${CMAKE_SOURCE_DIR}/tools/mkimage.sh
    DEPENDS stage1_boot stage2_boot kernel
    COMMENT "Creating boot image with all components"
)

# Custom targets for QEMU
add_custom_target(run
    COMMAND qemu-system-m68k -M q800 -cpu m68040 -m 128 
            -drive file=boot.img,format=raw,if=scsi 
            -serial stdio -display none -no-reboot
    DEPENDS boot_image
)

add_custom_target(debug
    COMMAND qemu-system-m68k -M q800 -cpu m68040 -m 128 
            -drive file=boot.img,format=raw,if=scsi 
            -serial stdio -display none -no-reboot -s -S
    DEPENDS boot_image
)