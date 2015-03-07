#!/bin/bash
aprilann_path=$1 # first argument is APRIL-ANN path
luaw_path=$2     # second argument is Luaw path

check_arg()
{
    name=$1
    pos=$2
    path=$3
    if [[ -z $path || ! -e $path ]]; then
        echo "Needs $name path as $pos argument"
        exit -1
    fi
}

check_and_copy_file()
{
    src=$1
    file=$2
    dst=$3
    error_msg=$4
    if [[ ! -e $dst/$file ]]; then
        if [[ ! -e $src/$file ]]; then
            echo $error_msg
            exit -1
        fi
        cp $src/$file $dst
    fi
}

check_arg "APRIL-ANN" "first" "$aprilann_path"
check_arg "Luaw" "second" "$luaw_path"

check_and_copy_file $aprilann_path/lib aprilann.so lib/ "Unable to locate APRIL-ANN dynamic library: $aprilann_so"
check_and_copy_file $luaw_path/src luaw_server bin/ "Unable to locate Luaw executable: $luaw_server"

echo "Ok"
