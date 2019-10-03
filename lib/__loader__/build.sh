##!require __loader__.parser
if [[ ! -z "${SHLIB_RELEASE}" ]]; then
  source ./parser.sh
  source ../array/print.sh
fi

source ./parser.sh
source ../array/print.sh
function core::__loader__::parse_all_deps() {

  local script="${1}"


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

core::__loader__::parse_all_deps /Users/rieon/Projects/rieon/shlib/test/test.sh