# Bootloader components
add_subdirectory(stage1)
add_subdirectory(stage2)

# Create a combined bootloader target (for future use)
add_custom_target(bootloader
    DEPENDS stage1_boot stage2_boot
    COMMENT "Building complete bootloader"
)