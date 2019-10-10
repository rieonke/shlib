#!/usr/bin/env bash
wget -c https://github.com/ninja-build/ninja/archive/v1.9.0.tar.gz
tar zxf v1.9.0.tar.gz
cd ninja-1.9.0
./configure.py --bootstrap
sudo cp ./ninja /usr/bin