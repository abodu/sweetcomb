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
    local DEPLIB=$(realpath $(find -type f -name bld_corelib))
    [[ -n $DEPLIB ]] && source $DEPLIB
    local dlPath=$(get_dlPath 2>/dev/null)
    [[ -d $dlPath ]] && rm -rf $dlPath/*[^.tar.gz]
}

sw_clean $@
