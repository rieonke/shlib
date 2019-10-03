#!/usr/bin/env bash
if [ -z "${SHLIB_RELEASE}" ]; then
  _ENTRY_="${BASH_SOURCE}"
  source ./bin/loader.sh
fi

#!require core.array.print

arr=(hello world shlib)
#arr+=(abc)
#arr+=(def)
#arr+=(ghi)

core::array::print_in_comma ${arr[@]}
