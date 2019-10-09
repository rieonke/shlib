#!/usr/bin/env bash
if [[ -z "${1}" ]]; then
        PROJ_DIR=$(pwd)
    else
            PROJ_DIR="${1}"
fi

if [[ ! -d "${PROJ_DIR}" ]]; then
        echo "${PROJ_DIR} does not exist!" >& 2
fi

package_src.sh "${PROJ_DIR}" full

