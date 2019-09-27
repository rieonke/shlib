#!/usr/bin/env bash
if [ -z "${SHLIB_RELEASE}" ]
then
    _ENTRY_="${BASH_SOURCE}"
    source ../lib/loader.sh
fi

#!require io.write
#!require io.base
#!require file
#!require file.delete
#!require string
#!require ./demo_lib.sh
#!require `pwd`/demo_lib2.sh

core::io::write

# call demo
demo_lib::hello

# call demo2
demo_lib2::hello # clean
