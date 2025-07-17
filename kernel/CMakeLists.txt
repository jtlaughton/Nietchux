# Kernel
add_executable(kernel
    src/main.c
)

# Include headers
target_include_directories(kernel PRIVATE
    include
    ${CMAKE_SOURCE_DIR}/kernel/include
)

# Custom linker script for kernel
set_target_properties(kernel PROPERTIES 
    LINK_FLAGS "-T ${CMAKE_CURRENT_SOURCE_DIR}/kernel.ld"
)

# Create binary file from ELF
add_custom_command(TARGET kernel POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary kernel kernel.bin
    COMMENT "Creating kernel binary"
)

# Kernel standalone test target (placeholder)
add_custom_target(test_kernel
    COMMAND echo "Kernel testing requires bootloader to load it"
    DEPENDS kernel
    COMMENT "Kernel standalone test placeholder"
)