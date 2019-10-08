ExternalProject_Add(
        gettext
        URL https://mirrors.tuna.tsinghua.edu.cn/gnu/gettext/gettext-0.20.1.tar.gz
        URL_HASH SHA256=66415634c6e8c3fa8b71362879ec7575e27da43da562c798a8a2f223e6e47f5c
        DOWNLOAD_NAME gettext-0.20.1.tar.gz
        DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/static/archives
        PREFIX ${3RD_LIB_DIR}/gettext
        BUILD_ALWAYS OFF
        BUILD_IN_SOURCE OFF
        CONFIGURE_COMMAND ../gettext/configure --enable-shared=false --disable-dependency-tracking  --disable-silent-rules  --disable-debug  --with-included-gettext  gl_cv_func_ftello_works=yes  --enable-shared=false  --with-included-glib  --with-included-libcroco  --with-included-libunistring  --disable-java  --disable-csharp  --without-git  --without-cvs  --without-xz --prefix=${3RD_LIB_DIR}/build
        BUILD_COMMAND make -j 4
        INSTALL_COMMAND make install
        COMMAND mkdir -p ${3RD_LIB_DIR}/build/lib/pkgconfig && echo "prefix=${3RD_LIB_DIR}/build \\n libdir=\${prefix}/lib \\n includedir=\${prefix}/include \\n\\n Name: intl \\n Description: Gettext \\n Version: 0.20.1 \\n Libs: -L\${libdir} -lintl \\n Cflags: -I\${includedir} \\n " > ${3RD_LIB_DIR}/build/lib/pkgconfig/libintl.pc
)

