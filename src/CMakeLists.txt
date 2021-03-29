set(SYSTEM_MPI_SOURCES system_mpi.F90)

include(UseMPI NO_POLICY_SCOPE)

add_library(system_mpi SHARED ${SYSTEM_MPI_SOURCES})
set_target_properties(system_mpi PROPERTIES PUBLIC_HEADER mpi_types.h)
if(TARGET MPI::MPI_Fortran)
  target_link_libraries(system_mpi PUBLIC MPI::MPI_Fortran)
else()
  configure_mpi_target(system_mpi)
endif()
target_include_directories(system_mpi INTERFACE
  $<INSTALL_INTERFACE:${Fortran_MODULE_DIRECTORY}>
  $<INSTALL_INTERFACE:include>)
install(TARGETS system_mpi
  EXPORT system_mpi
  LIBRARY DESTINATION lib ${CMAKE_INSTALL_LIBDIR}
  PUBLIC_HEADER DESTINATION include ${CMAKE_INSTALL_INCLUDEDIR})
