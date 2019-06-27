#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: bld_libssh.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-26 17:10:04
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-26 17:10:04
#=================================================================
DEP_LIB=swt_deplib.sh
source $(dirname $(realpath $0))/${DEP_LIB}

logInfo i am testing log info
logErr i am testing log err
