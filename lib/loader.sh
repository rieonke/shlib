#!/usr/bin/env bash
if [[ ! -z "${SHLIB_RELEASE}" ]]; then
  return 0
fi

if [[ -z ${_ENTRY_} ]] ; then
    echo "error: _ENTRY_ not defined !" >& 2
    exit 1
fi

_ENTRY_PATH_=${_ENTRY_} #$(_file_get_real_path ${_ENTRY_})
CUR_DIR=$(dirname ${BASH_SOURCE})


# 1. find shlib
if [[ ! -f ~/.local/bin/shlib ]]; then
    echo "error: shlib executable file not found, please install shlib first"
    exit
elif [[ ! -f ${CUR_DIR}/shlib ]]; then
    ln -s ~/.local/bin/shlib "${CUR_DIR}/shlib"
fi

CMD="${CUR_DIR}/shlib -l"

if [[ ! -z ${SHLIB_CONF} ]]; then
 CMD+=" -C ${SHLIB_CONF}"
fi

CMD+=" ${_ENTRY_PATH_}"

for f in $(eval "${CMD}")
do
    source "${f}"
done
