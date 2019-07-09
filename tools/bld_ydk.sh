#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: bld_ydk.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-26 17:10:04
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-27 12:26:37
#=================================================================

bld_ydk() {
    local DEPLIB=$(realpath $(find -type f -name sw_bash_library))
    [[ -n $DEPLIB ]] && source $DEPLIB

    local dlStorePath=$(get_dlPath 2>/dev/null)
    [ -d $dlStorePath ] || mkdir -p $dlStorePath

    local dlURL='https://github.com/CiscoDevNet/ydk-gen/archive/0.8.3.tar.gz'
    case $1 in
    *git)
        dlURL='https://github.com/CiscoDevNet/ydk-gen.git'
        ;;
    esac
    (
        cd $dlStorePath
        local extractPath=sysrepo
        if [ "X${dlURL##*.}" == "Xgit" ]; then
            #for clone from .git
            # [ -d $extractPath ] && rm -rf $extractPath
            git clone $dlURL
        else
            local tarFile="$(basename $dlURL)"
            if [ ! -e "ydk-gen-$tarFile" ]; then
                [ -e $tarFile ] || wget $dlURL
                mv $tarFile ydk-gen-$tarFile
            fi
            tarFile="ydk-gen-$tarFile"

            extractPath=$(\ls -d1 ydk-gen-*[^tar.gz])
            [ -d $extractPath ] && rm -rf $extractPath
            tar zxvf $tarFile 2>/dev/null
            extractPath=$(\ls -d1 ydk-gen-*[^tar.gz])
        fi
        cd $extractPath

        pip install -r requirements.txt &&
            ./generate.py --libydk -i && ./generate.py --python --core &&
            pip3 install gen-api/python/ydk/dist/ydk*.tar.gz &&
            ./generate.py --python --bundle profiles/bundles/ietf_0_1_5.json &&
            ./generate.py --python --bundle profiles/bundles/openconfig_0_1_5.json &&
            pip3 install gen-api/python/ietf-bundle/dist/ydk*.tar.gz &&
            pip3 install gen-api/python/openconfig-bundle/dist/ydk*.tar.gz
    )
}

bld_ydk $@
