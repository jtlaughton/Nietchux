# Stage 1 bootloader (pure assembly, 512 bytes max)
add_executable(stage1_boot boot.s)

# Ensure it's treated as assembly
set_target_properties(stage1_boot PROPERTIES LINKER_LANGUAGE ASM)

# Custom linker script for stage 1 (boot sector)
set_target_properties(stage1_boot PROPERTIES 
    LINK_FLAGS "-T ${CMAKE_CURRENT_SOURCE_DIR}/stage1.ld"
)

# Create binary file from ELF
add_custom_command(TARGET stage1_boot POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary stage1_boot stage1_boot.bin
    COMMENT "Creating stage1 binary"
)

# Check size constraint (512 bytes max)
add_custom_command(TARGET stage1_boot POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Checking stage1 size..."
    COMMAND test `stat -c%s stage1_boot.bin` -le 512 || (echo "ERROR: Stage1 too large (>512 bytes)" && false)
    COMMENT "Verifying stage1 size constraint"
)

# Standalone stage1 test target
add_custom_target(test_stage1
    COMMAND qemu-system-m68k -M q800 -cpu m68040 -m 128 
            -drive file=stage1_boot.bin,format=raw,if=scsi 
            -serial stdio -display none -no-reboot
    DEPENDS stage1_boot
    COMMENT "Testing stage1 bootloader only"
)