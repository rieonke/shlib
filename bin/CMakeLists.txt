cmake_minimum_required(VERSION 3.0)
project(shlib)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

FIND_PACKAGE(PkgConfig)
PKG_CHECK_MODULES(GLIB glib-2.0)

include_directories(${GLIB_INCLUDE_DIRS})
link_directories(${GLIB_LIBRARY_DIRS})
add_definitions(${GLIB_CFLAGS_OTHER})

set(common_lib src/lib/argtable3.h src/lib/argtable3.c src/lib/ini.h src/lib/ini.c src/util.h src/util.c)
add_executable(shlib src/main.c src/dependency_resolver.c src/dependency_resolver.h ${common_lib})

target_link_libraries(shlib glib-2.0 m)

include(CTest)
enable_testing()
set(test_common_files src/dependency_resolver.c src/dependency_resolver.h ${common_lib})
add_executable(test_dependency_resolver_relative ${test_common_files} src/test/test_dependency_resolver_relative.c)
add_executable(test_dependency_resolver_absolute ${test_common_files} src/test/test_dependency_resolver_absolute.c)
add_executable(test_dependency_resolver_named ${test_common_files} src/test/test_dependency_resolver_named.c)

target_link_libraries(test_dependency_resolver_relative glib-2.0 m)
target_link_libraries(test_dependency_resolver_absolute glib-2.0 m)
target_link_libraries(test_dependency_resolver_named glib-2.0 m)

add_test(test_dependency_resolver_relative test_dependency_resolver_relative)
add_test(test_dependency_resolver_absolute test_dependency_resolver_absolute)
add_test(test_dependency_resolver_named test_dependency_resolver_named)

