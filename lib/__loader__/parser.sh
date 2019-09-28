function core::__loader__::find_deps() {
    local _exec_file="$1"
    echo $(grep -E "^\#\!([[:space:]]?)+require" ${_exec_file} | awk 'gsub(/^#!\s+?require\s+?/,"",$0) {print $0}' | uniq )
}

function core::__loader__::get_absolute_path() {
    local prefix="$2"

    if [[ -z ${prefix} ]]
    then
        prefix="$PWD"
    fi

    if [[ ! -z $1 ]]
    then
        [[ $1 = /* ]] && echo "$1" || echo "$prefix/${1#./}"
    fi
}

function core::__loader__::out_error() {
    echo "$@" # >& 2
}

function core::__loader__::out() {
    echo "$@" # >& 1
}

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
function core::__loader__::get_real_lib_path() {
    local target_lib="$1"
    local search_dir="$2"
    local host_script="$3"

    if [[ -z ${target_lib} ]]
    then
        core::__loader__::out_error "error: missing search lib"
    fi

    # check the given search directory valid or not
    if [[ ! -z ${search_dir} ]] && [[ ! -d  ${search_dir} ]]
    then
        core::__loader__::out_error "error: ${search_dir} does not exist or is not a directory"
        return 2
    fi

    # if libpath contains $ or `
    if [[ ${target_lib} = *"$"* ]] || [[ ${target_lib} = *"\`"* ]]
    then
        target_lib=$(eval "echo ${target_lib}")
    fi


    # if is a absolute path
    if [[ ${target_lib} = /* ]] && [[ ! -f ${target_lib} ]] # absolute path
    then
        core::__loader__::out_error "error: file ${target_lib} does not exists"
        return 1
    fi

    if [[ ${target_lib} = /* ]] && [[ -f ${target_lib} ]] # absolute path
    then
        core::__loader__::out ${target_lib}
        return 0
    fi

    # if is a relative path
    if [[ ${target_lib} = .* ]]
    then
        if [[ -z ${host_script} ]]
        then
            echo "cannot find relative lib without host script path"
            return 1
        fi

#        if [[ -d ${search_dir} ]]
#        then
#            sd=${search_dir}
#        fi

        local sd=$(dirname $(core::__loader__::get_absolute_path ${host_script}))
        if [[ -f "${sd}/${target_lib}" ]]
        then
            core::__loader__::out "${sd}/${target_lib}"
            return 0
        else
            core::__loader__::out_error "error: file ${sd}/${target_lib} does not exists"
            return 1
        fi
    fi

    # if is a named lib
    # 1. search in the loader path
    local short_lib_path="${target_lib//.//}.sh"

    if [[ -d ${search_dir} ]]
    then
        local sd=${search_dir}
        if [[ -f "${sd}/${short_lib_path}" ]]
        then
            core::__loader__::out "${sd}/${short_lib_path}"
            return 0
        fi
    fi

    core::__loader__::out_error "error: lib ${target_lib} not found"
    return 1
}

function core::__loader__::get_deps_routines() {

    local node="${1}"
    local parent="${2}"
    local entry="${3}"
    local libdir="${4}"

    # 1. find the current node real lib path
    # 2. check cycle deps
    # 3. get all the deps of current node
    # 4. if current node has no dependency, push current routine to routines_arr

    # 1. find the current node real lib path
    local path
    path=$(core::__loader__::get_real_lib_path ${node} ${libdir} ${entry})


    # 2. check cycle deps
    local parent_arr
    local _LOADER_SEPARATOR_="#"
    for el in $(echo "${parent}" | awk '{ p = split($0, p_a, "'${_LOADER_SEPARATOR_}'"); for (i=1;i<=p;i++) { print p_a[i] } }')
    do
        if [[ "${el}" = "${node}" ]]
        then
            local dep_path="${parent//#/ -> }"
            echo "error: cycle dependencies, dependencies graph:"
            echo ""
            echo "${dep_path}"
            local str_len
            let "str_len = ${#dep_path} - 6"
            printf "%6s%${str_len}s\n" "^" "|"

            cycle_line=""

            for ((i=2;i<${str_len};i++))
            do
                cycle_line+="_"
            done

            cycle_line+="/"

            printf "%6s%s\n" "|" ${cycle_line}
            echo ""

            exit 1
        fi

    done

    # 2. get all the deps of current node

    local sub_deps=()
    for line in $(core::__loader__::find_deps ${path})
    do
        sub_deps+=(${line})
    done

    # 4 if current node has no dependency, push current routine to routines_arr, else recursive
    if [[ ${#sub_deps[@]} -gt 0 ]]
    then

        for d in ${sub_deps[@]}
        do
            if [[ ${d} != ${node} ]]
            then
                core::__loader__::get_deps_routines "${d}" "${parent}${_LOADER_SEPARATOR_}${node}" "${entry}" "${libdir}" # todo entry could be current dep's path
            fi
        done

    else
        local count_node=$(echo "${parent}${_LOADER_SEPARATOR_}${node}" | awk '{ p = split($0, p_a, "'${_LOADER_SEPARATOR_}'"); print p }')
        echo "${count_node} ${parent}${_LOADER_SEPARATOR_}${node}"
    fi
}