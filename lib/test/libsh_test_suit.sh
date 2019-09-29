#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../__loader__/parser.sh

function libsh_test_init() {
  local script="${1}"
  local sourced_arr=()
  for routine in $(core::__loader__::get_deps_routines ${script} . ${script} .. | sort -r | awk '{print $2}'); do
    for el in $(echo ${routine} | awk '{ p = split($0, p_a, "#"); for (i=p;i>0;i--) { print p_a[i] } }'); do
      if [[ ${el} == "." ]]; then
        continue
      fi

      #            if [[ ${el} == ${script} ]]
      #            then
      #                continue
      #            fi

      if [[ $(__array_contains ${el} "${sourced_arr[@]}") -ge 0 ]]; then
        continue
      fi

      local lfp
      lfp=$(core::__loader__::get_real_lib_path ${el} $(dirname ${BASH_SOURCE})/.. ${script}) # ${node} ${libdir} ${entry})

      if [[ -f "${lfp}" ]]; then
        sourced_arr+=("${el}")
        echo "sourcing ${lfp}"
        source ${lfp}
      else
        echo "lib [${el}] not found"
        exit 1
      fi
    done
  done
}

function __array_contains() {
  local find="${1}"
  shift

  local arr=()
  arr+=(${@})

  #    for item in ${arr[@]}
  for ((i = 0; i < ${#arr[@]}; ++i)); do
    local item="${arr[i]}"
    if [[ "${item}" == "${find}" ]]; then
      echo ${i}
      return 0
    fi
  done

  echo -1
  return 0
}
