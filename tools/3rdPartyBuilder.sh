#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: 3rdPartyBuilder.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-07-12 15:43:59
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-09-06 15:52:47
#=================================================================
bldThirdParties() {
    function bp_chkBuildTools() {
        local bPaks='build-essential libtool gcc g++ gdb cmake make automake autoconf curl
         git wget libssl-dev pkgconf indent libcmocka-dev libev-dev libavl-dev libpcre3-dev
         libprotobuf-c-dev protobuf-c-compiler zlib1g-dev libsqlite3-dev libpcre2-dev'
        local ePaks='crossbuild-essential-arm64 gcc-aarch64-linux-gnu g++-aarch64-linux-gnu u-boot-tools
         device-tree-compiler dh-autoreconf openssl python-pip qemu-utils libncurses5-dev python-crypto libpcap-dev'
        sudo apt install -y $bPaks
        [ -n $CROSS_COMPILE ] && sudo apt install -y $ePaks
    }
    function bp_ByCmake() {
        local OPTS_CMAKE='-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr' # -DCMAKE_INSTALL_LIBDIR=lib
        mkdir -p bltDir && (
            cd bltDir
            $CMAKE $OPTS_CMAKE .. && make
            [ ${HC_NO_INSTALL-0} -eq 1 ] || sudo make install
        ) && rm -rf bltDir
    }
    function bp_ByMake() {
        local OPTS_MAKE='--prefix=/usr'
        [ -x autogen.sh ] && bash autogen.sh
        if [ -x configure ]; then
            bash configure $OPTS_MAKE
        else
            [ -x config ] && bash config
        fi
        make
        [ ${HC_NO_INSTALL-0} -eq 1 ] || sudo make install
    }
    trap 'unset -f bp_{chkBuildTools,ByCmake,ByMake}' EXIT RETURN HUP INT
    [ ${HC_CBT-0} -eq 1 ] && [ -n "$(/usr/bin/which apt 2>/dev/null)" ] && bp_chkBuildTools

    local bldRoot=$(
        while [ "X$PWD" != "X/" ]; do
            [ -d build-root ] && echo $PWD/build-root && return || cd $PWD/..
        done
    )
    [ -z $bldRoot ] && echo -e "\n[FATAL] cannot found < build-root >, you need check !!! \n" && return

    local CMAKE=cmake kw=
    while [ $# -ge 0 ]; do
        case $1 in
        -h | --help | help) echo -e "\nUsage:\n bash ${0##./} <THIRD-PARTY-NAME> \n" && return ;;
        "" | -l | --list-tar-gz)
            if [ -n "$(/usr/bin/which tree)" ]; then
                tree --noreport --dirsfirst $(basename $bldRoot)/_*
            else
                /bin/ls --color=auto $(basename $bldRoot)/_dld*/*
            fi
            /bin/ls --color=auto -ad1 $(basename $bldRoot)/[^_]* 2>/dev/null
            return
            ;;
        *) [ "X${1:0:1}" == "X-" ] && echo -e "[FATAL] not support args [ $1 ] now, please check!!!\n" && return || kw="${kw}$1 " ;;
        esac
        shift && [ $# -eq 0 ] && break
    done

    kw=$(x=$(basename $kw) && echo ${x%-v*})
    local tgzFile=$(find $bldRoot -name "*${kw}*.tar.gz")
    [ -z $tgzFile ] && echo -e "\n[FATAL] cannot found ${kw}-XXX.tar.gz in dir <$bldRoot>, please check carefully!!!\n" && return
    rm -rf $bldRoot/*${kw}* &>/dev/null #清除已经编译过的旧目录,进行重新解压(防止多个版本同时存在)
    local srcDir=$(cd $bldRoot && tar zxvf $tgzFile &>/dev/null && realpath $(ls -ad1 *${kw}*/))
    (
        cd $srcDir
        case $kw in
        *etopeer2)
            local xd=
            for xd in cli server keystored; do
                (cd $xd && bp_ByMake)
            done
            ;;
        *) [ -f CMakeLists.txt ] && bp_ByCmake || bp_ByMake ;;
        esac
    )
    [ ${HC_FCD-0} -eq 1 ] && rm -rf $srcDir
}

case $0 in
*.sh) bldThirdParties $@ ;; #只能通过普通的 bash xxx.sh 方式来执行
*bash) unset -f bldThirdParties ;; #删除这个函数以防止通过source加载后再执行它
esac
