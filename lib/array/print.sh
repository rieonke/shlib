# @description print an array in separate line
# @arg $@ the array
# @stdout array element in lines
function core::array::print() {
    core::array::print_in_format "%s\n" "${@}"
}

# @description print an array in specific format
# @arg $1 format
# @stdout array in format
function core::array::print_in_format() {
    local format="${1}"

    shift
    local arr=()
    arr+=(${@})

    printf "${format}" ${arr[@]}

}

function core::array::print_in_comma() {
    local arr=()
    arr+=(${@})

    for (( i = 0; i < ${#arr[@]}; ++i ))
    do
        if [[ ${i} -eq $((${#arr[@]}-1)) ]]
        then
            printf "%s\n" ${arr[i]}
        else
            printf "%s," ${arr[i]}
        fi
    done

}

