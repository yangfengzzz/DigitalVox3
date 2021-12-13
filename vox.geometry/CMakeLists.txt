cmake_minimum_required(VERSION 3.16)

# Target name
set(target Flex_Common)

find_package(glog)

file(GLOB sources
        ${headers}
        ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/surfaces/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/implicit_surfaces/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/query_engines/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/colliders/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/fields/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/grids/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/point_searchers/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/point_generators/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/particle_emitter/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/fdm_solvers/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/particle_system_solvers/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/levelset_solvers/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/points_to_implicits/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/*.cu)

add_definitions(-DJET_USE_CUDA)
include_directories("/usr/local/cuda/include")
add_library(${target}
        ${sources})

set_target_properties(
        ${target}
        PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)

target_link_libraries(${target}
        PUBLIC
        ${DEFAULT_LINKER_OPTIONS}
        glog::glog
        )