cmake_minimum_required(VERSION 3.10)

project(system_mpi)

enable_language(Fortran)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/modules/")

include(CMakePackageConfigHelpers)

add_subdirectory(src)

# Add all targets to the build-tree export set
export(TARGETS system_mpi
  FILE "${PROJECT_BINARY_DIR}/system_mpiTargets.cmake")

# Export the package for use from the build-tree
# (this registers the build-tree with a global CMake-registry)
export(PACKAGE system_mpi)

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/system_mpiConfig.cmake"
  INSTALL_DESTINATION lib/cmake/system_mpi
  )

install(FILES
          "${CMAKE_CURRENT_BINARY_DIR}/system_mpiConfig.cmake"
        DESTINATION lib/cmake/system_mpi
)
