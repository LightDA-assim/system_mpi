find_package(MPI REQUIRED)

function(configure_mpi_target target)
  target_compile_definitions(${target} PRIVATE ${MPI_Fortran_COMPILE_DEFINITIONS})
  target_compile_options(${target} PRIVATE ${MPI_Fortran_COMPILE_OPTIONS})
  target_include_directories(${target} PRIVATE ${MPI_Fortran_INCLUDE_DIRS})
  target_link_libraries(${target} PRIVATE ${MPI_Fortran_LINK_FLAGS})
  target_link_libraries(${target} PRIVATE ${MPI_Fortran_LIBRARIES})
endfunction()

