if(${CMAKE_VERSION} VERSION_LESS 3.9)
  # Workaround for trailing whitespace error in linker flags for older CMake
  cmake_policy(SET CMP0004 OLD)
endif()

find_package(MPI REQUIRED)

if(MPIEXEC AND NOT MPIEXEC_EXECUTABLE)
  set(MPIEXEC_EXECUTABLE ${MPIEXEC})
endif()

if(MPI_Fortran_HAVE_F90_MODULE)
  add_definitions(-DHAVE_MPI_F90_MODULE)
endif()

if(MPI_Fortran_HAVE_F08_MODULE)
  add_definitions(-DHAVE_MPI_F08_MODULE)
endif()

function(configure_mpi_target target mode)

  target_compile_definitions(${target} ${mode} ${MPI_Fortran_COMPILE_DEFINITIONS})
  target_compile_options(${target} ${mode} ${MPI_Fortran_COMPILE_OPTIONS})
  target_include_directories(${target} ${mode} ${MPI_Fortran_INCLUDE_DIRS})
  target_include_directories(${target} ${mode} ${MPI_Fortran_INCLUDE_PATH})
  target_link_libraries(${target} ${mode} ${MPI_Fortran_LINK_FLAGS})
  target_link_libraries(${target} ${mode} ${MPI_Fortran_LIBRARIES})
endfunction()

