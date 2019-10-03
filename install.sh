#!/usr/bin/env bash

CURDIR=$(pwd)

# 1. download bin src
wget -c https://github.com/rieonke/shlib/archive/shlib_bin_0.0.1.tar.gz
tar xf shlib_bin_0.0.1.tar.gz

# 2. build
mkdir -p shlib_bin/build
cd shlib_bin/build
cmake ..
make shlib

# 3. install
if [ ! -d ~/.local/bin ]; then
    mkdir -p ~/.local/bin
fi

cp ./shlib ~/.local/bin

cd "${CURDIR}"

echo "Shlib has been successfully installed "
