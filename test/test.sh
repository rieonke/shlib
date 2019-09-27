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

core::io::write
