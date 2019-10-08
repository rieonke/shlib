cmake_minimum_required(VERSION 3.0)
project(shlib)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

option(BUILD_STATIC "Build static shlib" OFF)

find_package(PkgConfig)
pkg_check_modules(GLIB glib-2.0)

if (${GLIB_FOUND})
    message("-- Glib found")
else()
    message("-- No Glib found, set build static on")
    set(BUILD_STATIC ON)
endif ()


set(COMMON_LINK_LIBS "glib-2.0")

if (${BUILD_STATIC})
    set(3RD_BUILD_TYPE ${CMAKE_BUILD_TYPE})
    set(3RD_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/static/build/${CMAKE_SYSTEM_NAME}/${3RD_BUILD_TYPE})

    include(ExternalProject)

    include(static/ExternalProjectGettext.cmake)
    include(static/ExternalProjectGlib.cmake)
    include(static/ExternalProjectLibffi.cmake)

    include_directories(${3RD_LIB_DIR}/build/lib/glib-2.0/include)
    include_directories(${3RD_LIB_DIR}/build/include/glib-2.0)
    include_directories(${3RD_LIB_DIR}/build/include)

    link_directories(${3RD_LIB_DIR}/build/lib)

    set(ENV{PKG_CONFIG_PATH} "${3RD_LIB_DIR}/build/lib/pkgconfig")
    #set(ENV{PKG_CONFIG_PATH} "${3RD_LIB_DIR}/build/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")

    SET(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
    SET(BUILD_SHARED_LIBS OFF)
    #SET(CMAKE_EXE_LINKER_FLAGS "-static")
    list(APPEND COMMON_LINK_LIBS "intl")
endif ()

include_directories(${GLIB_INCLUDE_DIRS})
link_directories(${GLIB_LIBRARY_DIRS})
add_definitions(${GLIB_CFLAGS_OTHER})

set(common_lib src/lib/argtable3.h src/lib/argtable3.c src/lib/ini.h src/lib/ini.c src/util.h src/util.c)
add_executable(shlib src/main.c src/dependency_resolver.c src/dependency_resolver.h ${common_lib})
add_dependencies(shlib glib)

list(APPEND COMMON_LINK_LIBS "m")

if (APPLE)
    find_library(COCOA_LIB Cocoa)
    list(APPEND COMMON_LINK_LIBS ${COCOA_LIB})
    list(APPEND COMMON_LINK_LIBS "iconv")
elseif (UNIX AND NOT APPLE)
    list(APPEND COMMON_LINK_LIBS "pthread")
endif ()

message("-- Link libs: ${COMMON_LINK_LIBS}")
target_link_libraries(shlib ${COMMON_LINK_LIBS})

#include(CTest)
enable_testing()
set(test_common_files src/dependency_resolver.c src/dependency_resolver.h ${common_lib})
add_executable(test_dependency_resolver_relative ${test_common_files} src/test/test_dependency_resolver_relative.c)
add_executable(test_dependency_resolver_absolute ${test_common_files} src/test/test_dependency_resolver_absolute.c)
add_executable(test_dependency_resolver_named ${test_common_files} src/test/test_dependency_resolver_named.c)

target_link_libraries(test_dependency_resolver_relative ${COMMON_LINK_LIBS})
target_link_libraries(test_dependency_resolver_absolute ${COMMON_LINK_LIBS})
target_link_libraries(test_dependency_resolver_named ${COMMON_LINK_LIBS})

add_test(test_dependency_resolver_relative test_dependency_resolver_relative)
add_test(test_dependency_resolver_absolute test_dependency_resolver_absolute)
add_test(test_dependency_resolver_named test_dependency_resolver_named)

