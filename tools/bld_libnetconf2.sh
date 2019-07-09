#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: bld_libnetconf2.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-26 17:10:04
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-27 11:40:36
#=================================================================

bld_libnetconf2() {
    local DEPLIB=$(realpath $(find -type f -name sw_bash_library))
    [[ -n $DEPLIB ]] && source $DEPLIB

    CMAKE_BUILD_OPTS="$CMAKE_BUILD_OPTS -DENABLE_BUILD_TESTS=OFF"

    local dlStorePath=$(get_dlPath 2>/dev/null)

    local dlURL='https://github.com/CESNET/libnetconf2/archive/v0.12-r1.tar.gz'
    case $1 in
    *git)
        dlURL='https://github.com/CESNET/libnetconf2.git'
        ;;
    esac
    [ -d $dlStorePath ] || mkdir -p $dlStorePath
    (
        cd $dlStorePath
        local extractPath=
        if [ "X${dlURL##*.}" == "Xgit" ]; then
            #for clone from .git
            git clone $dlURL
            extractPath=libnetconf2
        else
            # "https://github.com/CESNET/libnetconf2/archive/v0.12-r1.tar.gz"
            local tarFile="$(basename $dlURL)"
            if [ ! -e "libnetconf2-$tarFile" ]; then
                [ -e $tarFile ] || wget $dlURL
                mv $tarFile libnetconf2-$tarFile
            fi

            extractPath=$(\ls -d1 libnetconf2-*[^tar.gz])
            [ -d $extractPath ] && rm -rf $extractPath
            tarFile="libnetconf2-$tarFile"
            tar zxvf $tarFile
            extractPath=$(\ls -d1 libnetconf2-*[^tar.gz])
        fi
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

bld_libnetconf2 $@
