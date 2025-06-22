cmake_minimum_required(VERSION 3.20)
project(dispositional_plugin LANGUAGES C CXX)

# Locate LLVM
find_package(LLVM 17 REQUIRED CONFIG)

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

# Add LLVM includes
include_directories(SYSTEM ${LLVM_INCLUDE_DIRS})
separate_arguments(LLVM_DEFINITIONS_LIST NATIVE_COMMAND ${LLVM_DEFINITIONS})
add_definitions(${LLVM_DEFINITIONS_LIST})

# Create the plugin library
add_library(DispositionalPass MODULE
    DispositionalPass.cpp
)

# Set compiler flags
target_compile_features(DispositionalPass PRIVATE cxx_std_17)
target_compile_options(DispositionalPass PRIVATE
    -fno-rtti
    -fPIC
)

# Don't link LLVM libraries for a simple plugin - just include headers
# This avoids the zstd dependency issue

# Set output properties
set_target_properties(DispositionalPass PROPERTIES
    PREFIX ""
    SUFFIX ".so"
)

if(APPLE)
    target_link_options(DispositionalPass PRIVATE 
        -undefined dynamic_lookup
    )
endif()