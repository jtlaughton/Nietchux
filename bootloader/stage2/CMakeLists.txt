# Stage 2 bootloader (C code)
add_executable(stage2_boot
    src/main.c
    src/disk.c
    src/memory.c
)

# Include headers
target_include_directories(stage2_boot PRIVATE
    include
    ${CMAKE_SOURCE_DIR}/bootloader/include
)

# Custom linker script for stage 2
set_target_properties(stage2_boot PROPERTIES 
    LINK_FLAGS "-T ${CMAKE_CURRENT_SOURCE_DIR}/stage2.ld"
)

# Create binary file from ELF
add_custom_command(TARGET stage2_boot POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary stage2_boot stage2_boot.bin
    COMMENT "Creating stage2 binary"
)

# For testing stage2 standalone (you'll need to create a test image)
add_custom_target(test_stage2
    COMMAND echo "Stage2 testing requires custom test image setup"
    DEPENDS stage2_boot
    COMMENT "Stage2 standalone test placeholder"
)