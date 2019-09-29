#!/usr/bin/env bash
if [ ! -z "${SHLIB_RELEASE}" ]; then
  return 0
fi

if [[ -z "${_LOADER_SEPARATOR_}" ]]; then
  declare -r _LOADER_SEPARATOR_="#"
fi

_file_get_real_path() {

  local prefix="$2"

  if [ -z ${prefix} ]; then
    prefix="$PWD"
  fi

  if [ ! -z $1 ]; then
    [[ $1 == /* ]] && echo "$1" || echo "$prefix/${1#./}"
  fi
}

function _find_deps() {
  _exec_file="$1"
  echo $(grep -E "^\#\!([[:space:]]?)+require" ${_exec_file} | awk 'gsub(/^#!\s+?require\s+?/,"",$0) {print $0}' | uniq)
}

function _loader::out_error() {
  echo "$@" # >& 2
}

function _loader::out() {
  echo "$@" # >& 1
}

#
# @description get the real path of a required lib
# - named lib: util.date.parser
# - relative path lib: ../lib/demo_lib.sh
# - absolute path lib: /opt/shell/lib/demo_lib.sh
# - computed path contains $ or `
# it can search the lib in default lib path (where the loader.sh lies) and given lib path
#
# @arg $1 the lib name or path
# @arg $2 the lib search path
#
# @exitcode 0 success and echo the absolute path
# @exitcode 1 lib not found
# @exitcode 2 the the given search lib path does not exists
#
# @stdout the absolute path
# @stderr the error message
#
function _loader::get_real_lib_path() {
  local target_lib="$1"
  local search_dir="$2"

  if [[ -z ${target_lib} ]]; then
    _loader::out_error "error: missing search lib"
  fi

  # check the given search directory valid or not
  if [[ ! -z ${search_dir} ]] && [[ ! -d ${search_dir} ]]; then
    _loader::out_error "error: ${search_dir} does not exist or is not a directory"
    return 2
  fi

  # if libpath contains $ or `
  if [[ ${target_lib} == *"$"* ]] || [[ ${target_lib} == *"\`"* ]]; then
    target_lib=$(eval "echo ${target_lib}")
  fi

  # if is a absolute path
  if [[ ${target_lib} == /* ]] && [[ ! -f ${target_lib} ]]; then # absolute path
    _loader::out_error "error: file ${target_lib} does not exists"
    return 1
  fi

  if [[ ${target_lib} == /* ]] && [[ -f ${target_lib} ]]; then # absolute path
    _loader::out ${target_lib}
    return 0
  fi

  # if is a relative path
  if [[ ${target_lib} == .* ]]; then

    local sd=${_ENTRY_PATH_}
    if [[ -d ${search_dir} ]]; then
      sd=${search_dir}
    fi

    if [[ -f "${sd}/${target_lib}" ]]; then
      _loader::out "${sd}/${target_lib}"
      return 0
    else
      _loader::out_error "error: file ${sd}/${target_lib} does not exists"
      return 1
    fi
  fi

  # if is a named lib
  # 1. search in the loader path
  local short_lib_path="${target_lib//.//}.sh"

  if [[ -d ${search_dir} ]]; then
    local sd=${search_dir}
    if [[ -f "${sd}/${short_lib_path}" ]]; then
      _loader::out "${sd}/${short_lib_path}"
      return 0
    fi
  fi

  local sd=${_LIB_DIR_}
  if [[ -f "${sd}/${short_lib_path}" ]]; then
    _loader::out "${sd}/${short_lib_path}"
    return 0
  fi

  _loader::out_error "error: lib ${target_lib} not found"
  return 1
}

function _parse_tree() {

  local node="$1"   # io.write
  local parent="$2" # io.write/io.base
  local search_path="$3"

  # 1. find current node
  local lfp=$(_loader::get_real_lib_path ${node} ${search_path})
  if [[ ! -f ${lfp} ]]; then
    _loader::out_error ${lfp}
    exit 1
  fi

  local parent_arr
  for el in $(echo "${parent}" | awk '{ p = split($0, p_a, "'${_LOADER_SEPARATOR_}'"); for (i=1;i<=p;i++) { print p_a[i] } }'); do
    if [[ "${el}" == "${node}" ]]; then
      local dep_path="${parent//#/ -> }"
      echo "error: cycle dependencies, dependencies graph:"
      echo ""
      echo "${dep_path}"
      local str_len
      let "str_len = ${#dep_path} - 6"
      printf "%6s%${str_len}s\n" "^" "|"

      cycle_line=""

      for ((i = 2; i < ${str_len}; i++)); do
        cycle_line+="_"
      done

      cycle_line+="/"

      printf "%6s%s\n" "|" ${cycle_line}
      echo ""

      exit 1
    fi

  done

  local deps=()
  for dep in $(_find_deps ${lfp}); do
    deps+=(${dep})
  done

  if [ ${#deps[@]} -gt 0 ]; then

    for d in ${deps[@]}; do
      if [ ${d} != ${node} ]; then
        _parse_tree "${d}" "${parent}${_LOADER_SEPARATOR_}${node}"
      fi
    done

  else
    local count_node=$(echo "${parent}${_LOADER_SEPARATOR_}${node}" | awk '{ p = split($0, p_a, "'${_LOADER_SEPARATOR_}'"); print p }')
    echo "${count_node} ${parent}${_LOADER_SEPARATOR_}${node}" >>".build/all_deps.route"
  fi

}

_LIB_DIR_=$(_file_get_real_path $(dirname ${BASH_SOURCE}))
_exec_file=$(_file_get_real_path ${_ENTRY_})
_ENTRY_PATH_=$(dirname ${_exec_file})

if [ ! -d .build ]; then
  mkdir .build
fi

cp ${_exec_file} .build

# get main deps
cat /dev/null >.build/main_deps.lst
_find_deps ${_exec_file} >>.build/main_deps.lst

# find deps module
main_deps=()
cat /dev/null >.build/deps.code
cat /dev/null >.build/all_deps.route
for line in $(cat .build/main_deps.lst); do
  _parse_tree ${line} "."
done

cat /dev/null >.build/all_deps.parsed
for route in $(cat .build/all_deps.route | sort -r | awk '{print $2}'); do

  if [ -z "${route}" ] || [ "${route}" = "." ]; then
    continue
  fi

  for el in $(echo ${route} | awk '{ p = split($0, p_a, "'${_LOADER_SEPARATOR_}'"); for (i=p;i>0;i--) { print p_a[i] } }'); do

    if [ $(grep -c ${el} .build/all_deps.parsed) -gt 0 ]; then
      continue
    fi

    lfp=$(_loader::get_real_lib_path ${el})

    if [[ -f "${lfp}" ]]; then

      echo "${el}" >>.build/all_deps.parsed

      main_deps+=(${lfp})

      if [[ -z ${LS_COMPILE} ]] || [[ ${LS_COMPILE} -eq 1 ]]; then
        echo "#-------------------" >>.build/deps.code
        echo "# @start ${el} " >>.build/deps.code
        echo "#-------------------" >>.build/deps.code
      fi

      cat ${lfp} >>.build/deps.code

      if [[ -z ${LS_COMPILE} ]] || [[ ${LS_COMPILE} -eq 1 ]]; then
        echo "#-------------------" >>.build/deps.code
        echo "# @end ${el} " >>.build/deps.code
        echo "#-------------------" >>.build/deps.code
      fi

    else
      _loader::out_error "lib [${el}] not found"
      exit 1
    fi
  done

done

dest=.build_$(date "+%Y%m%d%H%M%S").sh

echo "#!/usr/bin/env bash" >${dest}
echo "declare -r SHLIB_RELEASE=1" >>${dest}
cat .build/deps.code ${_ENTRY_} >>${dest}

if [ ! -z ${LS_COMPILE} ] && [ ${LS_COMPILE} -ge 1 ]; then
  if [ ${LS_COMPILE} -eq 2 ]; then
    cat ${dest} | grep -vE "\#\!([[:space:]]?)+require" | grep -E "^[[:blank:]]*[^[:blank:]#;]"
  else
    cat ${dest}
  fi
  rm -rf ${dest}
  exit
else
  chmod +x "${dest}"
  bash -c $(_file_get_real_path "${dest}")
  ret=$?
  rm -rf ${dest}
  exit $ret
fi
