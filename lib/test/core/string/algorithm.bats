# test for core::string::algorithm module

function setup() {
    if [[ -z ${SOURCE_IMPORTED} ]]
    then
        source ${BATS_TEST_DIRNAME}/../../libsh_test_suit.sh
        libsh_test_init ${BATS_TEST_DIRNAME}/../../../core/string/algorithm.sh
        declare -r SOURCE_IMPORTED=1
    fi
}


@test "core::string::size ascii" {
    run core::string::size abcd
    [[ "$output" = 4 ]]
}


@test "core::string::size unicode" {
    run core::string::size "中国"
    [[ "$output" = 6 ]]
}

@test "core::string::length" {
    run core::string::length abcd
    [[ "$output" = 4 ]]
}

@test "core::string::append" {
    run core::string::append a b c d
    [[ "$output" = "abcd" ]]
}

@test "core::string::prepend" {
    run core::string::prepend a b c d
    [[ "$output" == "bcda" ]]
}

@test "core::string::prepend_reverse" {
    run core::string::prepend_reverse a b c d
    [[ "$output" == dcba ]]
}


@test "core::string::index_of" {
    run core::string::index_of abcdbcd bcd
    [[ "$output" = 1 ]]
}

@test "core::string::index_of_offset" {
    run core::string::index_of_offset abcdbcd bcd 2
    [[ "$output" = 4 ]]
}

@test "core::string::substring" {
    run core::string::substring abcedfg 2 3
    [[ "$output" = "c" ]]

    run core::string::substring abcdefg 2
    [[ "$output" = "cdefg" ]]

}