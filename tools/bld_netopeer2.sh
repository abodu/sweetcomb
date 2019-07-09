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
    local DEPLIB=$(realpath $(find -type f -name sw_bash_library))
    [[ -n $DEPLIB ]] && source $DEPLIB

    CMAKE_BUILD_OPTS="$CMAKE_BUILD_OPTS -DENABLE_BUILD_TESTS=OFF"

    local dlStorePath=$(get_dlPath 2>/dev/null)

    local dlURL='https://github.com/CESNET/Netopeer2/archive/v0.7-r1.tar.gz'
    case $1 in
    *git)
        dlURL='https://github.com/CESNET/Netopeer2.git'
        ;;
    esac
    [ -d $dlStorePath ] || mkdir -p $dlStorePath
    (
        cd $dlStorePath
        local extractPath=
        if [ "X${dlURL##*.}" == "Xgit" ]; then
            #for clone from .git
            git clone $dlURL
            extractPath=Netopeer2
        else
            local tarFile="$(basename $dlURL)"
            if [ ! -e "Netopeer2-$tarFile" ]; then
                [ -e $tarFile ] || wget $dlURL
                mv $tarFile Netopeer2-$tarFile
            fi

            extractPath=$(\ls -d1 Netopeer2-*[^tar.gz])
            [ -d $extractPath ] && rm -rf $extractPath
            tarFile="Netopeer2-$tarFile"
            tar zxvf $tarFile
            extractPath=$(\ls -d1 Netopeer2-*[^tar.gz])
        fi
        cd $extractPath
        _bldNp2() {
            echo "Netopeer2:$(basename $1)"
            (
                cd $1
                local srcPath=$PWD
                rm -rf bltDir 2>/dev/null
                mkdir bltDir && cd bltDir
                $CMAKE $CMAKE_BUILD_OPTS $srcPath
                make -j${CPU_NUMBERS}
                sudo make install
                sudo ldconfig
            )
        }
        load sd=
        for sd in keystored server cli; do
            [ -d $sd ] && _bldNp2 $sd
        done
    )
}

bld_netopeer2 $@
