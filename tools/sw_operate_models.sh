#!/usr/bin/env bash
#=================================================================
# CPSTR: Copyright (c) 2019 By Abodu, All Rights Reserved.
# FNAME: sw_operate_models.sh
# AUTHR: abodu,abodu@qq.com
# CREAT: 2019-06-27 15:05:34
# ENCOD: UTF-8 Without BOM
# VERNO: 0.0.1
# LUPTS: 2019-06-27 15:05:34
#=================================================================
sw_operate_models() {

   install() {
      local DEPLIB=$(realpath $(find -type f -name bld_corelib))
      [[ -n $DEPLIB ]] && source $DEPLIB
      
      _inf_ins() {
         local x=
         for x in $@; do
            sysrepoctl ${INS_ARGS} --install --yang=$x
         done
      }
      local yang_models_dir=$(get_ws_root)/src/plugins/yang
      (
         cd ${yang_models_dir}/ietf
         local IETF_MODELS="iana-if-type@2017-01-19.yang ietf-interfaces@2018-02-20.yang
            ietf-ip@2014-06-16.yang ietf-nat@2017-11-16.yang"
         _inf_ins ${IETF_MODELS}
         sysrepoctl -e if-mib -m ietf-interfaces 2>/dev/null
      )
      (
         cd ${yang_models_dir}/openconfig
         local OC_MODELS="openconfig-local-routing@2017-05-15.yang 
            openconfig-interfaces@2018-08-07.yang openconfig-if-ip@2018-01-05.yang
            openconfig-acl@2018-11-21.yang"
         INS_ARGS='-S' _inf_ins ${OC_MODELS}
      )
   }

   uninstall() {
      # _inf_unins() {
      #    local x=
      #    for x in $@; do
      #       sysrepoctl -u -m $x
      #    done
      # }

      # _inf_unins iana-if-typ ietf-{nat,ip,interfaces} \
      #    openconfig-{acl,if-ip,local-routing,if-aggregate,interfaces,vlan-types}
      {
         sysrepoctl -u -m ietf-ip
         sysrepoctl -u -m openconfig-acl
         sysrepoctl -u -m openconfig-if-ip
         sysrepoctl -u -m openconfig-local-routing
         sysrepoctl -u -m openconfig-if-aggregate
         sysrepoctl -u -m openconfig-interfaces
         sysrepoctl -u -m ietf-nat
         sysrepoctl -u -m iana-if-type
         sysrepoctl -u -m ietf-interfaces
         sysrepoctl -u -m openconfig-vlan-types
      } >/dev/null
   }

   local OPER=$1 && shift
   {
      case $OPER in
      install | --install | -I)
         install $@
         ;;
      uninstall | rm | remove | -U)
         uninstall $@
         ;;
      esac
   } >/dev/null
}

sw_operate_models $@
