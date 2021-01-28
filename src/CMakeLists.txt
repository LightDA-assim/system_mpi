set(SYSTEM_MPI_SOURCES system_mpi.F90)

include(UseMPI)

add_library(system_mpi SHARED ${SYSTEM_MPI_SOURCES})
set_target_properties(system_mpi PROPERTIES PUBLIC_HEADER mpi_types.h)
configure_mpi_target(system_mpi)
target_include_directories(system_mpi INTERFACE
  $<INSTALL_INTERFACE:${Fortran_MODULE_DIRECTORY}>
  $<INSTALL_INTERFACE:include>)
install(TARGETS system_mpi EXPORT system_mpi)
