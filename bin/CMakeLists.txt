cmake_minimum_required(VERSION 3.0)
project(shlib)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

FIND_PACKAGE(PkgConfig)
PKG_CHECK_MODULES(GLIB glib-2.0)

include_directories(${GLIB_INCLUDE_DIRS})
link_directories(${GLIB_LIBRARY_DIRS})
add_definitions(${GLIB_CFLAGS_OTHER})

set(common_lib src/lib/argtable3.h src/lib/argtable3.c src/lib/ini.h src/lib/ini.c)
add_executable(shlib src/main.c src/dependency_resolver.c src/dependency_resolver.h ${common_lib})

target_link_libraries(shlib glib-2.0 m)

include(CTest)
enable_testing()
add_executable(test_dependency_resolver src/dependency_resolver.c src/dependency_resolver.h src/test/test_dependency_resolver.c ${common_lib})

target_link_libraries(test_dependency_resolver glib-2.0 iconv intl)
add_test(test_dependency_resolver test_dependency_resolver)