#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copyright (c) 2020, 2023 Enrico Sorichetti
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file BOOST_LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
message( STATUS "CMake version  '${CMAKE_VERSION}'" )
message( STATUS "Processing     '${CMAKE_CURRENT_LIST_FILE}'" )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if( CMAKE_VERSION VERSION_LESS  3.26 )
  message( FATAL_ERROR "
 CMake '3.26' or higher is required,
 You are running '${CMAKE_VERSION}'" )
endif()
cmake_minimum_required( VERSION ${CMAKE_VERSION} )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if( NOT DEFINED ENV{CMTK} )
  message( FATAL_ERROR "
 unable to locate the cmToolKit directory" )
endif()

set( CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR} )
list( APPEND CMAKE_MODULE_PATH "$ENV{CMTK}/cmake/Modules" )

set( TEMPL_SOURCE_PATH ${CMAKE_SOURCE_DIR} )
list( APPEND TEMPL_SOURCE_PATH $ENV{CMTK}/cmake/Templates )

include( vDump )
include( vDrop )
include( vSnap )
set( VSNAP 1 )
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# deprecate 'in-source' builds ( source directory/subdirectories )
# if You accidentally try an 'in-source' build
# You will have to manually clean up the leftovers :
# file 'CMakeCache.txt' and directory 'CMakeFiles'

set( CMAKE_DISABLE_IN_SOURCE_BUILD ON )
set( CMAKE_DISABLE_SOURCE_CHANGES  ON )

get_filename_component( _s "${CMAKE_SOURCE_DIR}" REALPATH )
string( TOLOWER "${_s}" _s )

get_filename_component( _b "${CMAKE_BINARY_DIR}" REALPATH )
string( TOLOWER "${_b}" _b )

if( ( "${_b}" STREQUAL "${_s}" ) OR
    ( "${_b}" MATCHES  "${_s}/" ) )
  message( FATAL_ERROR "
 binary directory '${CMAKE_BINARY_DIR}'
 source directory '${CMAKE_SOURCE_DIR}'
 builds that modify the source directory/subdirectories are not allowed,
 remove file 'CMakeCache.txt' and directory 'CMakeFiles' " )
endif( )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set( SYSTEM_NAME "${CMAKE_HOST_SYSTEM_NAME}" )
string( TOUPPER "${SYSTEM_NAME}" SYSTEM_NAME_UC  )
set( "${SYSTEM_NAME_UC}" 1 )
add_compile_definitions(
  ${SYSTEM_NAME_UC}
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# try to provide compatibility down to High Sierra
if( APPLE AND BUILD_UNIVERSAL_BINARIES )
  set( CMAKE_OSX_DEPLOYMENT_TARGET 10.13.6 CACHE STRING  "" FORCE)
endif()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set( PROJECT hercules )
set( VERSION  5 )
set( RELEASE  1 )
set( MODLEVL  0 )
# let's set the revision/BLDLEVL to 0 for now
# will deal later with that for different SCMs ( subverion/git )
set( BLDLEVL  0 )
set( VERSION_TRIPLET "${VERSION}.${RELEASE}.${MODLEVL}" )

project( ${PROJECT}
  VERSION ${VERSION_TRIPLET}
  LANGUAGES C CXX )
set( VERSION_STRING "${VERSION_TRIPLET}" )
set( VERSION_STRING "${VERSION_STRING}-${CMAKE_SYSTEM_PROCESSOR}" )

#
if( APPLE AND BUILD_UNIVERSAL_BINARIES )
  set( CMAKE_OSX_ARCHITECTURES arm64 x86_64 )
  set( VERSION_STRING "${VERSION_STRING}-universal" )
endif()

string( TIMESTAMP BUILD_DATE  %Y/%m/%d )
string( TIMESTAMP BUILD_TIME  %H:%M:%S )
string( TIMESTAMP BUILD_TIMESTAMP %Y/%m/%d-%H:%M:%S )
string( TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_LC )
if( "${CMAKE_BUILD_TYPE_LC}" STREQUAL "release" )
  set( VERSION_STRING "${VERSION_STRING}-Release" )
  # set( VERSION_STRING "${VERSION_STRING}-${BUILD_TIMESTAMP}" )
else()
  include( rcsInfo)
  set( VERSION_STRING "${VERSION_STRING}-${RCS_WC_REVISION_STRING}" )
endif()

add_compile_definitions(
  VERSION="${VERSION}"
  VERSION_STRING="${VERSION_STRING}" )

message( STATUS "Building ${PROJECT} ${VERSION_STRING}" )

# bits
math( EXPR HOST_ARCH "8 * ${CMAKE_SIZEOF_VOID_P}" OUTPUT_FORMAT DECIMAL)
if( NOT ( HOST_ARCH MATCHES 64 ) )
  message( SEND_ERROR "
 unsupported Architecture '${HOST_ARCH}-bits'" )
endif()
message( STATUS "Building ${PROJECT} ${VERSION_STRING} '${HOST_ARCH}-bits'" )

# endian-ness
if( NOT ( CMAKE_C_BYTE_ORDER STREQUAL "LITTLE_ENDIAN" ) )
  message( SEND_ERROR "
 unsupported Endian-ness '${CMAKE_C_BYTE_ORDER}'" )
endif()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# cleanup the CMAKE_SYSTEM_PREFIX_PATH
if( APPLE )
  list(REMOVE_DUPLICATES CMAKE_SYSTEM_PREFIX_PATH )
  set( XPATHS /opt/homebrew /usr/X11R6 /usr/pkg /opt /sw /opt/local )
  foreach( xpath ${XPATHS} )
    list( REMOVE_ITEM CMAKE_SYSTEM_PREFIX_PATH ${xpath} )
  endforeach()
endif()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   setup the proper install paths according to the GNU standards,
include( installDirectories )

set( CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${INST_BIN_DIR}" )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${INST_LIB_DIR}" )
set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${INST_LIB_DIR}" )

set( INST_MOD_DIR ${INST_LIB_DIR}/${PROJECT} )
add_compile_definitions(
  MODULESDIR="${CMAKE_INSTALL_PREFIX}/${INST_MOD_DIR}"
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# rpath handling
set( WITH_RPATH 1 )
if( WITH_RPATH )
  set( CMAKE_SKIP_BUILD_RPATH  FALSE )
  set( CMAKE_BUILD_WITH_INSTALL_RPATH TRUE )
  set( CMAKE_INSTALL_RPATH "@executable_path/../${INST_LIB_DIR}" )
  set( CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE )
endif()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set( CMAKE_C_STANDARD 99 )
set( CMAKE_C_STANDARD_REQUIRED YES )
set( CMAKE_CXX_STANDARD 11 )
set( CMAKE_CXX_STANDARD_REQUIRED YES )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set( CMAKE_POSITION_INDEPENDENT_CODE ON )
set( CMAKE_EXPORT_COMPILE_COMMANDS  ON )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
option( WITH_IPO      ""  OFF)
option( WITH_CCACHE   ""  ON )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if( WITH_IPO )
  include( CheckIPOSupported )
  check_ipo_supported( RESULT HAVE_IPO_SUPPORT )
  if ( HAVE_IPO_SUPPORT )
    message( STATUS "IPO is Supported and Enabled" )
  endif()
endif()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if( WITH_CCACHE )
  include( ccache )
endif()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# find out as early as possible about missing requirements/optionals
include( pkgConfig )

# required
pkg_config( required
  crypto decnumber softfloat telnet
)

# optional
pkg_config(
  oorexx
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
find_library( LIBZ z)
find_library( LIBBZ2 bz2 )

if( 0 )
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
include( CheckLibraryExists )

check_library_exists( z   zlibVersion       "" HAVE_ZLIB )
if( NOT HAVE_ZLIB  )
  message( SEND_ERROR "
 'libz' not available" )
endif()
set( LIBZ   "z" )

# bzip2
check_library_exists( bz2 BZ2_bzlibVersion  "" HAVE_BZLIB )
if( NOT HAVE_BZLIB )
  message( SEND_ERROR "
 'libbz2' not available" )
endif()
set( LIBBZ2 "bz2" )

endif()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# compile_definitions
include( ${PROJECT}_DEFS OPTIONAL )
include( ${PROJECT}_DIAG OPTIONAL )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set( extpkgs_INCLUDEDIR
  ${crypto_INCLUDEDIR}
  ${decnumber_INCLUDEDIR}
  ${softfloat_INCLUDEDIR}
  ${telnet_INCLUDEDIR}
)
list( REMOVE_DUPLICATES extpkgs_INCLUDEDIR )
vsnap( extpkgs_INCLUDEDIR )

include_directories(
  ${CMAKE_BINARY_DIR}
  ${CMAKE_SOURCE_DIR}
  ${CMAKE_SOURCE_DIR}/src
  ${CMAKE_SOURCE_DIR}/src/include

  ${oorexx_INCLUDEDIR}
  ${extpkgs_INCLUDEDIR}
)

set( extpkgs_LIBDIR
  ${crypto_LIBDIR}
  ${decnumber_LIBDIR}
  ${softfloat_LIBDIR}
  ${telnet_LIBDIR}
)
list( REMOVE_DUPLICATES extpkgs_LIBDIR )
vsnap( extpkgs_LIBDIR )

link_directories(
  ${extpkgs_LIBDIR}
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# sources/headers
include( ${PROJECT}_SRCS )
include( ${PROJECT}_HDRS OPTIONAL )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   the libraries/modules
include( buildLibraries )

set( LIBRARIES hercs hercu hercd herct herc )
foreach( library ${LIBRARIES} )
  build_objects( ${library} )
  build_shared_library( ${library} )
endforeach()

set( MODULES hdteq dyngui dyncrypt
  hdt1052c  hdt1403   hdt3505 hdt3525 hdt3270 hdt3420
  hdt2703   hdttcpnje hdt3705 hdt3088 hdtqeth hdtzfcp hdtptp
)
foreach( module ${MODULES} )
  build_objects( ${module} )
  build_module( ${module} )
endforeach()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# the executables

add_executable( hercules
  src/bootstrap.c
)
target_link_libraries( hercules
  hercs hercu herc
)
install( TARGETS hercules
  RUNTIME DESTINATION ${INST_BIN_DIR}
)

add_executable( hercifc
  src/hercifc.c
)
target_link_libraries( hercifc
  hercu
)
install( TARGETS hercifc
  RUNTIME DESTINATION ${INST_BIN_DIR}
)

if( WITH_RPATH )
add_custom_command(
  TARGET hercifc POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} install_name_tool -delete_rpath "@executable_path/../lib" hercifc
  DEPENDS hercifc
)
endif()

add_executable( hercutun
  src/hercutun.c
)
target_link_libraries( hercutun
)
install( TARGETS hercutun
  RUNTIME DESTINATION ${INST_BIN_DIR}
)

if( WITH_RPATH )
add_custom_command(
  TARGET hercutun POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} install_name_tool -delete_rpath "@executable_path/../lib" hercutun
  DEPENDS hercutun
)
endif()
add_executable( herclin
  src/herclin.c
)
target_link_libraries( herclin
  hercs herc
)
install( TARGETS herclin
  RUNTIME DESTINATION ${INST_BIN_DIR}
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set( DASD_UTILITIES
  cckdcdsk64  cckdcdsk
  cckdcomp64  cckdcomp
  cckddiag64  cckddiag
  cckdswap64  cckdswap
  convto64
  dasdconv64  dasdconv
  dasdcopy64  dasdcopy
  dasdinit64  dasdinit
  dasdload64  dasdload
  dasdls
  dasdpdsu
  dasdseq
)

# macro to create and install symbolic links
macro(create_bin_symlink target symlink )
  add_custom_command(
    TARGET ${target}
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} ln -sf ${target} ${symlink}
    DEPENDS ${target}
  )
  install(FILES ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${symlink}
    DESTINATION ${INST_BIN_DIR}
  )
endmacro(create_bin_symlink)

set( dasdcopy_SYMLINKS
  cckd2ckd
  cfba2fba
  ckd2cckd
  fba2cfba
)

set( dasdcopy64_SYMLINKS
  cckd642ckd
  cfba642fba
  ckd2cckd64
  fba2cfba64
)

foreach( program ${DASD_UTILITIES} )
  add_executable( ${program}
    src/${program}.c
  )
  target_link_libraries( ${program}
    hercs hercu herc hercd
  )
  install( TARGETS ${program}
    RUNTIME DESTINATION ${INST_BIN_DIR}
  )

  if( ${program}_SYMLINKS )
    foreach( symlink  ${${program}_SYMLINKS} )
      create_bin_symlink( ${program} ${symlink} )
    endforeach()
  endif()


endforeach()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set( TAPE_UTILITIES
  hetinit
  hetget
  hetmap
  hetupd
  maketape
  tapecopy
  tapemap
  tapesplt
)
foreach( program ${TAPE_UTILITIES} )
  add_executable( ${program}
    src/${program}.c
  )
  target_link_libraries( ${program}
    hercs hercu herc herct
  )
  install( TARGETS ${program}
    RUNTIME DESTINATION ${INST_BIN_DIR}
  )
endforeach()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set( MISC_UTILITIES
  tfprint
  tfswap
  txt2card
)
foreach( program ${MISC_UTILITIES} )
  add_executable( ${program}
    src/${program}.c
  )
  target_link_libraries( ${program}
    hercs hercu herc herct
  )
  install( TARGETS ${program}
    RUNTIME DESTINATION ${INST_BIN_DIR}
  )
endforeach()


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# misc files

# NOTICES
install( DIRECTORY share/NOTICES
  DESTINATION ${INST_DATADIR}
)

# the man pages
install( DIRECTORY share/man
  DESTINATION ${INST_DATADIR}
)

# the html pages
install( DIRECTORY share/html
  DESTINATION ${INST_DATADIR}
)

# the testsuite
install( DIRECTORY share/testsuite
  DESTINATION ${INST_DATADIR}
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# macro to install plain files
macro( install_F argv dest)
  install( FILES ${CMAKE_SOURCE_DIR}/${argv}
    DESTINATION ${dest}
    PERMISSIONS OWNER_READ OWNER_WRITE
                GROUP_READ
                WORLD_READ )
endmacro( install_F )

# install some samples
install_F( herclogo.txt "${INST_DATADIR}" )
install_F( hercules.cnf "${INST_DATADIR}" )
install_F( hercules.cnf.rexx "${INST_DATADIR}" )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# macro to install files as executables
macro( install_X argv )
  install( FILES ${CMAKE_SOURCE_DIR}/${argv}
    DESTINATION ${INST_BIN_DIR}
    PERMISSIONS OWNER_EXECUTE OWNER_READ OWNER_WRITE
                GROUP_EXECUTE GROUP_READ
                WORLD_EXECUTE WORLD_READ )
endmacro( install_X )

# install the runtestsuite.sh script into  the INST_BIN_DIR
install_X( share/testsuite/runtestsuite.sh )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# the support files
foreach( X
  portable-startup.sh
  path.remove path.append path.here )
  install_X( support/bin/${X} )
endforeach()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# the configuration files
include( configureTemplates )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if( 0 )
  configure_templates( config.h isohdrs.h )
  if( HAVE_CONFIG_H )
    add_compile_definitions( HAVE_CONFIG_H )
  endif()
  if( HAVE_ISOHDRS_H )
    add_compile_definitions( HAVE_ISOHDRS_H )
  endif()
else()
  configure_template( config.h.preconf config.h)
  if( HAVE_CONFIG_H )
    add_compile_definitions( HAVE_CONFIG_H )
  endif()
endif( 0 )

configure_templates( cmake_uninstall.cmake )
if( HAVE_CMAKE_UNINSTALL_CMAKE )
  add_custom_target( uninstall
    COMMAND ${CMAKE_COMMAND}
      -P ${CMAKE_BINARY_DIR}/cmake_uninstall.cmake )
endif()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
add_custom_target( portable
  COMMAND bash ${CMAKE_SOURCE_DIR}/support/bin/portable-build.bash
    --makeself ${CMAKE_SOURCE_DIR}/support/bin/makeself.sh
    --project  ${PROJECT}
    --prefix   ${CMAKE_INSTALL_PREFIX}
    --triplet  ${VERSION_TRIPLET}
    --version  ${VERSION_STRING}
  )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
add_custom_target( check
  COMMAND bash ${CMAKE_SOURCE_DIR}/share/testsuite/runtestsuite.sh
    --herc     ${CMAKE_BINARY_DIR}/${INST_BIN_DIR}/hercules
    --bindir   ${CMAKE_BINARY_DIR}/${INST_BIN_DIR}
    --libdir   ${CMAKE_BINARY_DIR}/${INST_LIB_DIR}
    --moddir   ${CMAKE_BINARY_DIR}/${INST_MOD_DIR}
    --tstdir   ${CMAKE_SOURCE_DIR}/${INST_DATADIR}/testsuite
    --conf     ${CMAKE_SOURCE_DIR}/${INST_DATADIR}/testsuite/testsuite.conf
    --platform ${CMAKE_SYSTEM_NAME}
    --ptrsize  ${CMAKE_SIZEOF_VOID_P}
  )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
include( configurationReport OPTIONAL )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
vdump( "main" "exit" )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# this must be the last statement in this file.
# include( CPack )
