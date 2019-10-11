ExternalProject_Add(
        gettext
        URL https://ftp.gnu.org/pub/gnu/gettext/gettext-0.20.1.tar.gz
        URL_HASH SHA256=66415634c6e8c3fa8b71362879ec7575e27da43da562c798a8a2f223e6e47f5c
        DOWNLOAD_NAME gettext-0.20.1.tar.gz
        DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/static/archives
        PREFIX ${3RD_LIB_DIR}/gettext
        BUILD_ALWAYS OFF
        #BUILD_IN_SOURCE OFF
        BINARY_DIR ${3RD_LIB_DIR}/gettext/src/gettext/gettext-runtime
        CONFIGURE_COMMAND CFLAGS=-fPIC ../gettext/configure --disable-dependency-tracking  --disable-silent-rules gl_cv_func_ftello_works=yes --disable-debug  --with-included-gettext  --enable-shared=false --enable-static  --disable-java  --disable-csharp  --prefix=${3RD_LIB_DIR}/build #CXXFLAGS=-fPIC
        BUILD_COMMAND make clean && make -j $(nproc)
        INSTALL_COMMAND make install
        COMMAND mkdir -p ${3RD_LIB_DIR}/build/lib/pkgconfig && echo "prefix=${3RD_LIB_DIR}/build \\n libdir=\${prefix}/lib \\n includedir=\${prefix}/include \\n\\n Name: intl \\n Description: Gettext \\n Version: 0.20.1 \\n Libs: -L\${libdir} -lintl \\n Cflags: -I\${includedir} \\n " > ${3RD_LIB_DIR}/build/lib/pkgconfig/libintl.pc
)

