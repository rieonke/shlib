#!/usr/bin/env bash
if [[ -z "${1}" ]]; then
        PROJ_DIR=$(pwd)
    else
            PROJ_DIR="${1}"
fi

if [[ ! -d "${PROJ_DIR}" ]]; then
        echo "${PROJ_DIR} does not exist!" >& 2
fi

PKG_FULL=0
if [[ ! -z "${2}" ]] && [[ "${2}" = "full" ]]; then
    PKG_FULL=1
fi

ARC_NAME="shlib_bin"
if [[ ${PKG_FULL} -eq 1 ]]; then
    ARC_NAME+="_full"
fi

echo "packaging ${PROJ_DIR}"
# 1. mkdir temp
TMP_DIR=$(mktemp -d)

echo "create temp dir ${TMP_DIR}"
cp -r "${PROJ_DIR}/bin" "${TMP_DIR}/${ARC_NAME}"

echo "cleaning ..."
rm -rf "${TMP_DIR}/${ARC_NAME}/build"
rm -rf "${TMP_DIR}/${ARC_NAME}/static/build"

if [[ ${PKG_FULL} -eq 0 ]]; then
    echo "cleaning downloaded sources"
    rm -rf "${TMP_DIR}/${ARC_NAME}/static/archives/"*.*
fi

echo "packaging ... "
tar zcf ${ARC_NAME}.tar.gz -C ${TMP_DIR} ${ARC_NAME}

rm -rf "${TMP_DIR}"
