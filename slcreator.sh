#!/usr/bin/env bash

function slcreator() {

    local proj_name="${1}"
    if [[ -e ${proj_name} ]] ; then
        echo "error: ${proj_name} exists! " >& 2
        exit
    fi

    if [[ ! -f ~/.local/bin/shlib ]]; then
        echo "Installing shlib"
        sh -c $(curl -fsSL https://raw.githubusercontent.com/rieonke/shlib/master/install.sh)
    fi

    CUR_DIR=$(pwd)

    mkdir -p "${proj_name}/bin"
    mkdir -p "${proj_name}/lib"

    cd "${proj_name}"
    # download lib file
    wget -c https://github.com/rieonke/shlib/releases/download/v0.0.1/lib.zip
    unzip lib.zip -d ./lib

    rm -rf lib.zip

    cp ./lib/loader.sh ./bin
    ln -s ~/.local/bin/shlib ./bin/shlib

    echo "[lib]
global_search_dir = ./lib

[runtime]
shell = /bin/env bash

[optimize]
minify = 1" > shlib.ini

    echo "#!/usr/bin/env bash
if [ -z \"\${SHLIB_RELEASE}\" ]; then
  _ENTRY_=\"\${BASH_SOURCE}\"
  source ./bin/loader.sh
fi

#!require core.array.print

arr=(hello world shlib!)

core::array::print_in_comma \${arr[@]}
" > main.sh

    chmod +x main.sh
    ./main.sh
    if [ $(command -v git  > /dev/null) ]; then
        git init
    fi

    echo "Project ${proj_name} has been successfully created"
}

slcreator "${@}"
