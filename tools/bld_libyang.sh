#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: bld_libyang.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-26 17:10:04
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-27 10:51:48
#=================================================================

bld_libyang() {
    #load dependens library to set global env
    source $(dirname $(realpath $0))/sw_bash_library

    CMAKE_BUILD_OPT_STR="$CMAKE_BUILD_OPT_STR -DGEN_LANGUAGE_BINDINGS=OFF -DGEN_CPP_BINDINGS=ON \
        -DGEN_PYTHON_BINDINGS=OFF -DBUILD_EXAMPLES=OFF -DENABLE_BUILD_TESTS=OFF"

    local dlStorePath=$(get_dlPath 2>/dev/null)
    local dlURL='https://github.com/CESNET/libyang/archive/v0.16-r3.tar.gz'

    [ -d $dlStorePath ] || mkdir -p $dlStorePath
    (
        cd $dlStorePath
        local tarFile="$(basename $dlURL)"
        if [ ! -e "libyang-$tarFile" ]; then
            [ -e $tarFile ] || wget $dlURL
            mv $tarFile libyang-$tarFile
        fi

        local extractPath=$(\ls -d1 libyang-*[^tar.gz])
        [ -d $extractPath ] && rm -rf $extractPath
        tarFile="libyang-$tarFile"
        tar zxvf $tarFile
        extractPath=$(\ls -d1 libyang-*[^tar.gz])
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

bld_libyang
