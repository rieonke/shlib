ExternalProject_Add(
        libffi
        URL https://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz
        URL_HASH SHA256=d06ebb8e1d9a22d19e38d63fdb83954253f39bedc5d46232a05645685722ca37
        DOWNLOAD_NAME libffi-3.2.1.tar.gz
        DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/static/archives
#        PREFIX ${3RD_LIB_DIR}/libffi
        BUILD_ALWAYS OFF
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND CFLAGS=-fPIC ./configure --prefix=${3RD_LIB_DIR}/build --enable-shared=false --enable-static
        BUILD_COMMAND make -j $(nproc)
        INSTALL_COMMAND make install
        COMMAND cd  ${3RD_LIB_DIR}/build/lib/libffi-3.2.1/ && cp -rf include ../../ #find ${3RD_LIB_DIR}/build/lib/libffi-3.2.1/include/ -name "*.h" | xargs -0 -I{} cp {} ${3RD_LIB_DIR}/build/include
)
