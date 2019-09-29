#!require array.print

# @description get bytes actually taken by the string
# @arg $1 the string
# @stdout the bytes count taken by the string
function core::string::size() {
  local str="$1"

  if [[ -z ${str} ]]; then
    echo -1
  fi

  local tmp_lang=$LANG tmp_lc=$LC_ALL
  local -A counter info
  LANG=C LC_ALL=C

  echo ${#str}

  LANG=${tmp_lang} LC_ALL=${tmp_lc}
}

# @description get the characters count of given string
# @arg $1 the string
# @stdout the characters count of given string
function core::string::length() {
  local str="$1"
  if [[ -z ${str} ]]; then
    echo -1
  fi
  echo ${#str}
}

# @description append any count of string to a string
# @arg $1 the string to operate
# @arg $@ will append to the $1
# @stdout the new string
function core::string::append() {
  if [[ ${#@} -le 0 ]]; then
    echo ""
    return 1
  fi

  if [[ ${#@} -eq 1 ]]; then
    echo $1
    return 0
  fi

  local new_str=""

  while [[ ${#@} -gt 0 ]]; do
    new_str+=${1}
    shift
  done

  echo ${new_str}
}

# @description prepend any count of string to string
# @arg $1 the string to operate
# @arg $@ strings...
# @stdout the new string
function core::string::prepend() {
  if [[ ${#@} -le 0 ]]; then
    echo ""
    return 1
  fi

  if [[ ${#@} -eq 1 ]]; then
    echo $1
    return 0
  fi

  local new_str="$1"
  shift

  local to_prepend=""

  while [[ ${#@} -gt 0 ]]; do
    to_prepend+=${1}
    shift
  done

  echo "${to_prepend}${new_str}"
}

# @description prepend any count of string to string
# @arg $1 the string to operate
# @arg $@ strings...
# @stdout the new string
function core::string::prepend_reverse() {
  if [[ ${#@} -le 0 ]]; then
    echo ""
    return 1
  fi

  if [[ ${#@} -eq 1 ]]; then
    echo $1
    return 0
  fi

  local new_str="$1"
  shift

  local to_prepend=""

  while [[ ${#@} -gt 0 ]]; do
    to_prepend="${1}${to_prepend}"
    shift
  done

  echo "${to_prepend}${new_str}"
}

# @description get index within this string of the first occurrence of string
# @arg $1 the string
# @arg $2 string to find
# @stdout -1 not found
# @stdout >=0 the index
function core::string::index_of() {
  core::string::index_of_offset ${1} ${2} 0
}

# @description get index within this string of the first occurrence of string from offset
# @arg $1 the string
# @arg $2 string to find
# @arg $3 start offset
# @stdout -1 not found
# @stdout >=0 the index
function core::string::index_of_offset() {

  local str="$1"
  local find="$2"
  local offset=$3

  if [[ -z ${str} ]] || [[ -z ${find} ]]; then
    echo -1
    return 0
  fi

  local str_len=${#str}
  local find_len=${#find}

  if [[ ${str_len} -eq 0 ]] || [[ ${find_len} -eq 0 ]]; then
    echo -1
    return 0
  fi

  # if find is longer than str
  if [[ $((${#find_len} + ${offset})) -gt ${str_len} ]]; then
    echo -1
    return 0
  fi

  for ((i = offset; i < ${str_len}; ++i)); do
    # find first char
    local find_first=${i}
    while [[ ${find_first} -lt ${str_len} ]] && [[ ${str:${find_first}:1} != ${find:0:1} ]]; do
      let "find_first ++ "
    done

    # find the rest
    local j=0
    local k=${find_first}
    while [[ ${j} < ${find_len} && ${str:${k}:1} == ${find:${j}:1} ]]; do
      let "j ++"
      let "k ++ "
    done

    if [[ ${j} -eq $((${find_len})) ]]; then
      echo $((${find_first}))
      return 0
    fi
  done

  echo -1
  return 0

}

# @description substring
# @arg $1 string
# @arg $2 start_position (start from 0)
# @arg $3 end_position , default string_length - 1 (start from 0)
# @stdout new string
function core::string::substring() {
  local str="${1}"
  local start="${2}"
  local end="${3}"

  if [[ -z ${end} ]]; then
    end=${#str}
  fi

  local len
  let len="end - start"

  echo ${str:${start}:${len}}
}

# @description split string
# @arg $1 string to split
# @arg $2 delimiter
# @stdout the array
function core::string::split() {

  local str="$1"
  local delimiter="$2"

  if [[ -z ${str} ]] || [[ -z ${delimiter} ]]; then
    echo ""
    return 1
  fi

  local str_len=${#str}
  local del_len=${#delimiter}
  # if delimiter is longer than str, echo str
  if [[ ${del_len} -ge ${str_len} ]]; then
    echo "${str}"
    return 0
  fi

  # 1. find the next position of delimiter ( index_of from offset 0 )
  # 2. substring from 0 -> last_occurrence
  # 3. find the next position of delimiter ( index_of from offset last_occurrence + delimiter_len )
  # 4. substring from (last_occurrence + delimiter_len) -> next_occurrence
  # 5. goto step 3

  local str_arr=()

  local next_occurrence
  next_occurrence=$(core::string::index_of ${str} ${delimiter})

  # if delimiter not found
  if [[ ${next_occurrence} -lt 0 ]]; then
    echo ${str}
    return 0
  fi

  # substring
  str_arr+=($(core::string::substring ${str} 0 ${next_occurrence}))

  local idx_offset
  let idx_offset="next_occurrence + del_len"
  while [[ ${next_occurrence} -ge 0 && ${idx_offset} -lt $((${str_len})) ]]; do
    # find next occurrence
    next_occurrence=$(core::string::index_of_offset ${str} ${delimiter} ${idx_offset})

    if [[ ${next_occurrence} -lt 0 ]]; then
      str_arr+=($(core::string::substring ${str} ${idx_offset}))
      core::array::print ${str_arr[@]}
      return 0
    else
      str_arr+=($(core::string::substring ${str} ${idx_offset} ${next_occurrence}))
    fi

    let idx_offset="next_occurrence + del_len"
  done

  core::array::print ${str_arr[@]}
  return 0

}
