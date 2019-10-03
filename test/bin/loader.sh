#!/usr/bin/env bash
if [[ ! -z "${SHLIB_RELEASE}" ]]; then
  return 0
fi

_file_get_real_path() {

  local prefix="$2"

  if [[ -z ${prefix} ]]; then
    prefix="$PWD"
  fi

  if [[ ! -z $1 ]]; then
    [[ $1 == /* ]] && echo "$1" || echo "$prefix/${1#./}"
  fi
}

if [[ -z ${_ENTRY_} ]] ; then
    echo "error: _ENTRY_ not defined !" >& 2
    exit 1
fi

_ENTRY_PATH_=$(_file_get_real_path ${_ENTRY_})

for f in $(./bin/shlib -l ${_ENTRY_PATH_})
do
    source "${f}"
done
