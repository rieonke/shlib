ExternalProject_Add(
        zlib
        URL https://www.zlib.net/zlib-1.2.11.tar.gz
        URL_HASH SHA256=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1
        DOWNLOAD_NAME zlib-1.2.11.tar.gz
        DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/static/archives
#        PREFIX ${3RD_LIB_DIR}/libffi
        BUILD_ALWAYS OFF
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ./configure --prefix=${3RD_LIB_DIR}/build --static
        BUILD_COMMAND make -j $(nproc)
        INSTALL_COMMAND make install
)
