cmake_minimum_required(VERSION 3.0)
project(shlib_static_lib)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

set(3RD_BUILD_TYPE ${CMAKE_BUILD_TYPE})
set(3RD_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/build/${CMAKE_SYSTEM_NAME}/${3RD_BUILD_TYPE})


include(ExternalProject)

include(ExternalProjectGettext.cmake)
include(ExternalProjectGlib.cmake)
