#!require __loader__.parser
if [[ ! -z "${SHLIB_RELEASE}" ]]; then
  source ./parser.sh
fi

function core::__loader__::parse_all_deps() {

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
