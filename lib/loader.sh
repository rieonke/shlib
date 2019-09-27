if [ ! -z "${SHLIB_RELEASE}" ]
then
    return 0
fi

_file_get_real_path() {
    if [ ! -z $1 ] 
    then
        [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
    fi
}

function _find_deps() {
    _exec_file="$1"
    echo $(grep "\#\!" ${_exec_file} | awk 'gsub(/^#!\s+?require\s+?/,"",$0) {print $0}' | uniq )
}

function _parse_tree() {

    TREE_DIR_PREFIX=".build/tree"

    local node="$1" # io.write
    local parent="$2" # io.write/io.base

    # 1. find current node
    local lf=${node//.//}

    if [ -f "${_LIB_DIR_}/${lf}.sh" ]
    then
        lfp="${_LIB_DIR_}/${lf}.sh"
    else
        echo "lib [${node}] not found"
        exit 1
    fi

    local parent_arr
    for el in $(echo "${parent}" | awk '{ p = split($0, p_a, "/"); for (i=1;i<=p;i++) { print p_a[i] } }')
    do
        if [ "${el}" = "${node}" ]
        then
            echo "error: cycle dependencies, dependencies graph:"
            echo ""
            echo "${parent//\// -> }"
            local str_len
            let "str_len = ${#parent} - 6"
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


    local deps=()
    for dep in $(_find_deps ${lfp})
    do
        deps+=(${dep})
    done

    if [ ${#deps[@]} -gt 0 ]
    then

        for d in ${deps[@]}
        do
            if [ ${d} != ${node} ]
            then
                _parse_tree "${d}" "${parent}/${node}"
            fi
        done

    else
        local count_node=$(echo "${parent}/${node}" | awk '{ p = split($0, p_a, "/"); print p }')
        echo "${count_node} ${parent}/${node}" >> ".build/all_deps.route"
    fi

}



_LIB_DIR_=$(_file_get_real_path $(dirname ${BASH_SOURCE}))
_exec_file=$(_file_get_real_path ${_ENTRY_})

if [ ! -d .build ]
then
    mkdir .build
fi

cp ${_exec_file} .build

# get main deps
cat /dev/null > .build/main_deps.lst
grep "\#\!" ${_exec_file} | awk 'gsub(/^#!\s+?require\s+?/,"",$0) {print $0}' | uniq >> .build/main_deps.lst

# find deps module 
main_deps=()
cat /dev/null > .build/deps.code
cat /dev/null > .build/all_deps.route
for line in $(cat .build/main_deps.lst)
do
    _parse_tree ${line} "."
done


cat /dev/null > .build/all_deps.parsed
for route in $(cat .build/all_deps.route | sort -r | awk '{print $2}')
do

    if [ -z "${route}" ] || [ "${route}" = "." ]
    then
        continue
    fi

    for el in $(echo ${route} | awk '{ p = split($0, p_a, "/"); for (i=p;i>0;i--) { print p_a[i] } }')
    do

        if [ $(grep -c ${el} .build/all_deps.parsed ) -gt 0 ]
        then
            continue
        fi

        lf=${el//.//}

        if [ -f "${_LIB_DIR_}/${lf}.sh" ]
        then

            echo "${el}" >> .build/all_deps.parsed

            lfp="${_LIB_DIR_}/${lf}.sh"
            main_deps+=(${lfp})

            echo "#-------------------" >> .build/deps.code
            echo "# @start ${el} " >> .build/deps.code
            echo "#-------------------" >> .build/deps.code
            cat ${lfp} >> .build/deps.code
            echo "#-------------------" >> .build/deps.code
            echo "# @end ${el} " >> .build/deps.code
            echo "#-------------------" >> .build/deps.code

        else
            echo "lib [${line}] not found"
        fi
    done

done




dest=.build_$(date "+%Y%m%d%H%M%S").sh

echo "#!/usr/bin/env bash" > ${dest}
echo "declare -r SHLIB_RELEASE=1" >> ${dest}
cat .build/deps.code  ${_ENTRY_} >> ${dest}

if [ ! -z ${LS_COMPILE} ] && [ ${LS_COMPILE} -eq 1 ]
then
    cat ${dest}
    exit
else
    chmod +x "${dest}"
    bash -c $(_file_get_real_path "${dest}")
    ret=$?
    rm -rf ${dest}
    exit $ret
fi
