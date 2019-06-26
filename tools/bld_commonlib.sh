#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: bld_commonlib.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-26 17:10:57
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-26 17:10:57
#=================================================================

#OS Detection
if [ -e /etc/os-release ]; then
if [ "X$(uname)" == "XLinux" ]; then
  OS_ID=$(cat /etc/os-release | awk -F'=' '/^ID=/{print $2}' | sed 's/"//g')
  OS_VERSION_ID=$(cat /etc/os-release | awk -F'=' '/^VERSION_ID=/{print $2}' |sed 's/"//g')
fi
fi

