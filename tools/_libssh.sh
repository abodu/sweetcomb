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

bld_libssh() {
    #load dependens library to set global env
    source $(dirname $(realpath $0))/swt_deplib.sh

    local dlStorePath=$(get_dlStorePath)
    local dlURL='https://git.libssh.org/projects/libssh.git/snapshot/libssh-0.7.7.tar.gz'
    local tarFile=$(basename $dlURL)
    local extPath=${tarFile%.tar.gz}
    [ -d $dlStorePath ] || mkdir -p $dlStorePath
    (
        cd $dlStorePath 
        [ -e $tarFile ] || wget $dlURL
        tar zxvf $tarFile
        cd $extPath

        local srcPath=$PWD bltDir=bltSSH
        rm -rf $bltDir 2>/dev/null
        mkdir $bltDir
        cd $bltDir
        case $OS_ID in
        ubuntu | debian | deepin)
            CMAKE_BUILD_OPT_STR="-DZLIB_INCLUDE_DIR=/usr/include $CMAKE_BUILD_OPT_STR"
            CMAKE_BUILD_OPT_STR="-DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so $CMAKE_BUILD_OPT_STR"
            ;;
        esac

        $CMAKE $CMAKE_BUILD_OPT_STR $srcPath
        make -j${NPROG}
        echo
        read -p "Will install libssh(y[es] or n[o])?"
        case $REPLY in
        [yY] | [yY]es)
            sudo make install
            sudo ldconfig
            ;;
        esac
    )
}

bld_libssh
