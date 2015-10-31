#!/bin/bash
executable=./bin/luaw_server
if [[ ! -e $executable ]]; then
    echo "Unable to locate Luaw binary executable: $executable"
    echo "Please, execute ./prepare.sh"
    exit -1
fi
LD_LIBRARY_PATH=./lib $executable conf/server.lua
