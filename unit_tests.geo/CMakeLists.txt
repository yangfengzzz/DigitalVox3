CMAKE_MINIMUM_REQUIRED(VERSION 3.14)

# Target name
set(target unit_tests)

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


# Link libraries
target_link_libraries(${target}
        PUBLIC
        ${DEFAULT_LINKER_OPTIONS}
        ${DEFAULT_LIBRARIES}
        gtest gtest_main gmock gmock_main Flex_Common TBB::tbb dl)
