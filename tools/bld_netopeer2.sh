#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: bld_netopeer2.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-26 17:10:04
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-27 12:26:09
#=================================================================

bld_netopeer2() {
    #load dependens library to set global env
    source $(dirname $(realpath $0))/sw_bash_library

    CMAKE_BUILD_OPT_STR="$CMAKE_BUILD_OPT_STR -DENABLE_BUILD_TESTS=OFF"

    local dlStorePath=$(get_downloadPath 2>/dev/null)

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
            tarFile="libnetconf2-$tarFile"
            tar zxvf $tarFile

            extractPath=$(\ls -d1 libnetconf2-*[^tar.gz])
        fi
        cd $extractPath

        rm -rf bltDir 2>/dev/null
        local srcPath=$PWD
        mkdir bltDir && cd bltDir
        $CMAKE $CMAKE_BUILD_OPT_STR $srcPath
        make -j${NPROG}
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

bld_netopeer2 $@

