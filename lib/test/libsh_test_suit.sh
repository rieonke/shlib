#!/usr/bin/env bash

function libsh_test_init() {
    local script="${1}"
    if [[ -f ${script} ]]; then
        local SHLIB_CONF=$(dirname ${BASH_SOURCE})/shlib.ini
        local _ENTRY_="${script}"
        source $(dirname ${BASH_SOURCE})/../loader.sh
        source ${_ENTRY_}
    fi
}