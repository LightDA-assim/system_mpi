cmake_minimum_required(VERSION 3.0.2)

project(system_mpi)

enable_language(Fortran)

# Prevent older CMake versions from setting include directories with -isystem,
# which prevents gfortran from finding Fortran module files
set(CMAKE_NO_SYSTEM_FROM_IMPORTED ON)

find_package(MPI REQUIRED)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/modules/")

if(DEFINED CMAKE_Fortran_COMPILER_VERSION)
  set(Fortran_MODULE_DIRECTORY include/fortran_modules/${CMAKE_Fortran_COMPILER_ID}/${CMAKE_Fortran_COMPILER_VERSION})
else()
  set(Fortran_MODULE_DIRECTORY include/fortran_modules/${CMAKE_Fortran_COMPILER_ID})
endif()

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${Fortran_MODULE_DIRECTORY})

include(CMakePackageConfigHelpers)

function(list_transform_prepend var prefix)
    set(temp "")
    foreach(f ${${var}})
        list(APPEND temp "${prefix}${f}")
    endforeach()
    set(${var} "${temp}" PARENT_SCOPE)
endfunction()

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
          "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/UseMPI.cmake"
        DESTINATION lib/cmake/system_mpi
)

install(DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/ DESTINATION ${Fortran_MODULE_DIRECTORY})

install(EXPORT system_mpi
  FILE system_mpiTargets.cmake
  DESTINATION lib/cmake/system_mpi
)

# -------------------
# Build documentation
# -------------------

set ( SKIP_DOC_GEN FALSE CACHE BOOL
  "Disable building the API documentation with FORD" )
if ( NOT SKIP_DOC_GEN )
  find_program(FORD ford)

  find_package(PythonInterp)

  set(MARKDOWN_SUPPORTED_PYTHON
      NOT PYTHON_VERSION_STRING VERSION_LESS 3.5)

  if(NOT SKIP_DOC_GEN AND NOT MARKDOWN_SUPPORTED_PYTHON)
    message(WARNING "Python version ${PYTHON_VERSION_STRING} is not supported by Python-Markdown, not attempting to build documentation.")
  endif()

  if(FORD AND NOT MARKDOWN_SUPPORTED_PYTHON)

    set(DOC_ROOT "${PROJECT_BINARY_DIR}/doc")
    set(DOC_DIR "${DOC_ROOT}/system_mpi")
    set(PROJ_DIR "${PROJECT_SOURCE_DIR}")
    set(FORD_PROJECT_FILE "${CMAKE_CURRENT_BINARY_DIR}/system_mpi.md")
    set(MACRO_FLAG "")
    string(REPLACE ";" "\ninclude:" FORD_PROJECT_INCLUDES "${MPI_Fortran_INCLUDE_DIRS};${PROJ_DIR}/src")

    configure_file(system_mpi.md.in system_mpi.md)

    # Pick the preprocessor to use based on the Fortran compiler
    if ( "${CMAKE_Fortran_COMPILER_ID}" MATCHES "Intel" )
      set ( FPP "fpp\n" )
    else ()
      set ( FPP "gfortran -E\n" ) # default to gfortran -E for gfortran and unsupported compilers
    endif ()
    file ( WRITE "${PROJECT_BINARY_DIR}/.PREPROCESSOR" "${FPP}" )

    # Dynamically generate the FORD outputs list
    message ( STATUS "Dynamically computing FORD output information..." )
    if ( NOT (DEFINED FORD_OUTPUTS_CACHED) )
      message ( STATUS "Running FORD to dynamically compute documentation outputs, this could take a while..." )
      execute_process ( COMMAND ${CMAKE_COMMAND} -E remove_directory ${DOC_DIR}
	COMMAND ${CMAKE_COMMAND} -E make_directory ${DOC_DIR}
	COMMAND "${FORD}" --debug -q ${MACRO_FLAG} -d "${PROJ_DIR}" -o "${DOC_DIR}" -p "${PAGE_DIR}" "${FORD_PROJECT_FILE}" OUTPUT_QUIET )
    else ()
      message ( STATUS "Re-using cached FORD outputs, rather than regenerating them" )
    endif()

    # Compile a list of FORD output files
    file ( GLOB_RECURSE FORD_OUTPUTS
      "${DOC_DIR}/*.*" )
    file ( GLOB_RECURSE FORD_CLEAN_OUTPUTS
      "${DOC_DIR}/*.*" )

    # Cache FORD outputs
    if ( (DEFINED FORD_OUTPUTS) AND ( NOT ( "${FORD_OUTPUTS}" STREQUAL "" ) ) )
      message ( STATUS "Caching FORD outputs" )
      set ( FORD_OUTPUTS_CACHED "${FORD_OUTPUTS}"
	CACHE STRING "variable containing FORD outputs to prevent rebuilding FORD docs" FORCE )
    endif ()
    message ( STATUS "Done dynamically computing FORD outputs." )

    foreach ( DOC_SRC_FILE ${PROJECT_BINARY_DIR}/system_mpi.md src/system_mpi.F90)
      list ( APPEND FORD_DEPENDS "${DOC_SRC_FILE}" )
    endforeach ()

    # Re-build FORD output if needed
    add_custom_command ( OUTPUT ${FORD_OUTPUTS_CACHED}
      COMMAND "${FORD}" --debug ${MACRO_FLAG} -d "${PROJ_DIR}" -o "${DOC_DIR}" "${FORD_PROJECT_FILE}"
      MAIN_DEPENDENCY "${FORD_PROJECT_FILE}"
      DEPENDS ${FORD_DEPENDS}
      COMMENT "Building HTML documentation for ${PROJECT_NAME} using FORD" )

    add_custom_target ( documentation ALL
      DEPENDS ${FORD_OUTPUTS_CACHED} )

    # Install documentation
    set ( INSTALL_API_DOCUMENTATION TRUE
      CACHE BOOL "Install FORD generated documentation?" )
    if ( INSTALL_API_DOCUMENTATION )
      install ( DIRECTORY "${DOC_ROOT}/" DESTINATION share/doc )
    else ()

      # FORD Not found
      message ( WARNING
	"FORD not found. Please set the CMake cache variable FORD to point to the installed FORD executable, and reconfigure or disable building the documentation. FORD can be installed from PYPI with `sudo pip install FORD` or from <https://github.com/cmacmackin/ford> If you do not wish to install FORD and build the JSON-Fortran documentation, then please set the CMake cache variable SKIP_DOC_GEN to TRUE." )

    endif ()
  endif ()

endif()

find_program(FPRETTIFY_EXECUTABLE NAMES "fprettify" DOC "Path to fprettify")

if(NOT FPRETTIFY_EXECUTABLE)
  message(STATUS "fprettify not found.")
else()
  set(DO_FPRETTIFY "${FPRETTIFY_EXECUTABLE}" "--diff" "-i" "2" "-l" "81")

  set(ALL_SOURCES src/system_mpi.F90 src/mpi_types.h)

  list_transform_prepend(ALL_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/)

  add_custom_target(
    fprettify
    COMMAND ${DO_FPRETTIFY}
    ${ALL_SOURCES}
    )

endif()
