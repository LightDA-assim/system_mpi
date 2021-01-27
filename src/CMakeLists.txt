set(SYSTEM_MPI_SOURCES system_mpi.F90)

include(UseMPI)

add_library(system_mpi SHARED ${SYSTEM_MPI_SOURCES})
set_target_properties(system_mpi PROPERTIES PUBLIC_HEADER "mpi_types.h")
configure_mpi_target(system_mpi)
target_include_directories(system_mpi PUBLIC
  ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
install(TARGETS system_mpi)
