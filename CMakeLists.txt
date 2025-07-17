cmake_minimum_required(VERSION 3.16)
project(NIETZSCHUX ASM C)

# Enable assembly language
enable_language(ASM)

# Override linker script (will be set per target)
# Remove the global linker flag since each component needs its own script
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")

# Include directories
include_directories(
        ${CMAKE_SOURCE_DIR}/bootloader/include
        ${CMAKE_SOURCE_DIR}/kernel/include
)

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