#
# Copyright (c) 2018 Doyub Kim
#
# I am making my contributions/submissions to this project solely in my personal
# capacity and am not conveying any rights to any intellectual property of any
# third parties.
#

# Target name
set(target time_perf_tests)

# Sources
file(GLOB sources
        ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
        "${CMAKE_CURRENT_SOURCE_DIR}/*.cu")

add_definitions(-DJET_USE_CUDA)
link_directories("/usr/local/lib")

# Build executable
add_executable(${target}
        ${sources})

# Project options
set_target_properties(${target}
        PROPERTIES
        ${DEFAULT_PROJECT_OPTIONS}
        )


list(APPEND CMAKE_MODULE_PATH "../cmake")
find_package(TBB)
find_package(benchmark REQUIRED)

# Link libraries
target_link_libraries(${target}
        PUBLIC
        ${DEFAULT_LINKER_OPTIONS}
        ${DEFAULT_LIBRARIES}
        gtest gtest_main gmock gmock_main Flex_Common TBB::tbb benchmark::benchmark dl)