#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: bld_libssh.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-26 17:10:04
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-27 10:51:31
#=================================================================

bld_libssh() {
    local DEPLIB=$(realpath $(find -type f -name bld_corelib))
    [[ -n $DEPLIB ]] && source $DEPLIB

    case $OS_ID in
    ubuntu | debian | deepin)
        CMAKE_BUILD_OPTS="-DZLIB_INCLUDE_DIR=/usr/include $CMAKE_BUILD_OPTS"
        CMAKE_BUILD_OPTS="-DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so $CMAKE_BUILD_OPTS"
        ;;
    esac

    local dlStorePath=$(get_dlPath 2>/dev/null)
    local dlURL='https://git.libssh.org/projects/libssh.git/snapshot/libssh-0.7.7.tar.gz'

    [ -d $dlStorePath ] || mkdir -p $dlStorePath
    (
        cd $dlStorePath
        local tarFile=$(basename $dlURL)
        [ -e $tarFile ] || wget $dlURL

        local extractPath=$(\ls -d1 libssh-*[^tar.gz])
        [ -d $extractPath ] && rm -rf $extractPath
        tar zxvf $tarFile
        extractPath=$(\ls -d1 libssh-*[^tar.gz])
        cd $extractPath

        rm -rf bltDir 2>/dev/null
        local srcPath=$PWD
        mkdir bltDir && cd bltDir
        $CMAKE $CMAKE_BUILD_OPTS $srcPath
        make -j${CPU_NUMBERS}
        # echo
        # read -p "Do you want to install libssh (y[es] or n[o])?"
        # case $REPLY in
        # [yY] | [yY]es)
        sudo make install
        sudo ldconfig
        #     ;;
        # esac
    )
}

bld_libssh
