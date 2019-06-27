#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: bld_sysrepo.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-26 17:10:04
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-27 12:26:37
#=================================================================

bld_sysrepo() {
    #load dependens library to set global env
    source $(dirname $(realpath $0))/sw_bash_library

    CMAKE_BUILD_OPT_STR="$CMAKE_BUILD_OPT_STR -DENABLE_BUILD_TESTS=OFF
    -DGEN_LANGUAGE_BINDINGS=OFF -DGEN_CPP_BINDINGS=ON -DGEN_LUA_BINDINGS=OFF
 	-DGEN_PYTHON_BINDINGS=OFF -DGEN_JAVA_BINDINGS=OFF -DBUILD_EXAMPLES=OFF"

    local dlStorePath=$(get_downloadPath 2>/dev/null)

    local dlURL='https://github.com/sysrepo/sysrepo/archive/v0.7.7.tar.gz'
    case $1 in
    *git)
        dlURL='https://github.com/sysrepo/sysrepo.git'
        ;;
    esac
    [ -d $dlStorePath ] || mkdir -p $dlStorePath
    (
        cd $dlStorePath
        local extractPath=sysrepo
        if [ "X${dlURL##*.}" == "Xgit" ]; then
            #for clone from .git
            # [ -d $extractPath ] && rm -rf $extractPath
            git clone $dlURL
        else
            local tarFile="$(basename $dlURL)"
            if [ ! -e "sysrepo-$tarFile" ]; then
                [ -e $tarFile ] || wget $dlURL
                mv $tarFile sysrepo-$tarFile
            fi
            tarFile="sysrepo-$tarFile"

            extractPath=$(\ls -d1 sysrepo-*[^tar.gz])
            [ -d $extractPath ] && rm -rf $extractPath
            tar zxvf $tarFile
            extractPath=$(\ls -d1 sysrepo-*[^tar.gz])
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

bld_sysrepo $@
