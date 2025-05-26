cmake_minimum_required(VERSION 3.20)
project(dispositional_plugin LANGUAGES C CXX)    #  <- C added


# Locate LLVM (installed via apt llvm-17-dev inside Docker)
find_package(LLVM 17 REQUIRED CONFIG)

message(STATUS "Found LLVM in: ${LLVM_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(AddLLVM)

# Make LLVM headers visible
include_directories(SYSTEM ${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

add_library(DispositionalPass MODULE
    DispositionalPass.cpp
)

set_target_properties(DispositionalPass PROPERTIES
    COMPILE_FLAGS "-fno-rtti"
)

llvm_map_components_to_libnames(REQ all)
target_link_libraries(DispositionalPass PRIVATE ${REQ})
        
# helper macros

add_library(DispositionalPlugin MODULE
    DispositionalPass.cpp
)

set_target_properties(DispositionalPlugin PROPERTIES
    COMPILE_FLAGS "-fno-rtti"
)

llvm_map_components_to_libnames(REQ all)
target_link_libraries(DispositionalPlugin PRIVATE ${REQ})