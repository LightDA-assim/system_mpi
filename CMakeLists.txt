cmake_minimum_required(VERSION 3.10)

project(system_mpi)

enable_language(Fortran)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/modules/")

include(CMakePackageConfigHelpers)

add_subdirectory(src)

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/system_mpiConfig.cmake"
  INSTALL_DESTINATION lib/cmake/system_mpi
  )

install(FILES
          "${CMAKE_CURRENT_BINARY_DIR}/system_mpiConfig.cmake"
        DESTINATION lib/cmake/system_mpi
)
