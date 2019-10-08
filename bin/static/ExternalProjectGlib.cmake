ExternalProject_Add(
        glib
        URL https://github.com/GNOME/glib/archive/2.60.7.tar.gz
        URL_HASH SHA256=805a8ee41d431aa619470ffe68781c08ac07e96c90ef2c40ed2f59f0632a960b
        DOWNLOAD_NAME glib-2.60.7.tar.gz
        DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/static/archives
        PREFIX ${3RD_LIB_DIR}/glib
        BUILD_ALWAYS OFF
        BUILD_IN_SOURCE 1
        PATCH_COMMAND patch -p0 --forward ${3RD_LIB_DIR}/glib/src/glib/meson.build < ${CMAKE_CURRENT_SOURCE_DIR}/static/glib_meson_build.patch || true
        CONFIGURE_COMMAND PKG_CONFIG_PATH=${3RD_LIB_DIR}/build/lib/pkgconfig meson  --default-library=static -Dinternal_pcre=true -Dman=false --prefix=${3RD_LIB_DIR}/build --libdir=lib --includedir=include _build
        BUILD_COMMAND ninja -C _build
        INSTALL_COMMAND ninja -C _build install
)

add_dependencies(glib gettext libffi)