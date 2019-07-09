#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: sw_clean.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-27 13:57:50
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-27 13:57:50
#=================================================================

sw_clean() {
    local DEPLIB=$(realpath $(find -type f -name sw_bash_library))
    [[ -n $DEPLIB ]] && source $DEPLIB

    local dt=
    case $1 in
    dist* | DC | -t | --clean-total)
        for dt in $(get_build_root)/build-{scvpp,plugins,package}; do
            [ -d $dt ] && rm -rf $dt
        done 2>/dev/null
        ;;
    *)
        for dt in $(get_build_root)/build-{scvpp,plugins,package}; do
            [ -d $dt ] || continue
            (
                cd $dt
                make clean
            )
        done 2>/dev/null
        ;;
    esac
}

sw_clean $@
