# Copyright (c) 2018 Intel and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#  Main Dependencies:
#  netopeer2 -> libyang
#            -> libnetconf2 -> libyang
#                           -> libssh (>=0.6.4)
#
#  sysrepo   -> libyang
#            -> libredblack or libavl
#            -> libev
#            -> protobuf-c

export WS_ROOT:=$(CURDIR)
export BR:=$(WS_ROOT)/build-root
export PLATFORM?=sweetcomb
export VPP_VERSION?=release
export REBUILD_DOCKER_IMAGE?=no

##############
#OS Detection#
##############
ifneq ($(shell uname),Darwin) #usual is Linux
OS_ID        := $(shell grep '^ID=' /etc/os-release | cut -f2- -d= | sed -e 's/\"//g')
OS_VERSION_ID:= $(shell grep '^VERSION_ID=' /etc/os-release | cut -f2- -d= | sed -e 's/\"//g')
endif

ifeq ($(filter ubuntu debian,$(OS_ID)),$(OS_ID))
PKG  :=deb
CMAKE:=cmake
else ifeq ($(filter rhel centos fedora opensuse opensuse-leap opensuse-tumbleweed,$(OS_ID)),$(OS_ID))
PKG  :=rpm
CMAKE:=cmake3
endif

#####
#DEB#
#####
#Dependencies to build
BUILD_DEB     := curl build-essential autoconf automake ccache git cmake wget coreutils
#Dependencies for netopeer2
NETOPEER2_DEB := libssl-dev pkgconf
#Dependencies for checkstyle
CHECKSTYLE_DEB:= indent
#Dependencies for scvpp
SCVPP_DEB     := libcmocka-dev
#Dependencies for sysrepo (swig required for sysrepo python, lua, java)
SYSREPO_DEB   := libev-dev libavl-dev bison flex libpcre3-dev libprotobuf-c-dev protobuf-c-compiler
#Dependencies of libssh
LIBSSH_DEB    := zlib1g-dev
#Sum dependencies
DEB_DEPENDS   := ${BUILD_DEB} ${NETOPEER2_DEB} ${CHECKSTYLE_DEB} ${SCVPP_DEB} ${SYSREPO_DEB} ${LIBSSH_DEB}

#Dependencies for automatic test
DEB_TEST_DEPENDS := python3-pip python-pip libcurl4-openssl-dev libssh-dev \
libxml2-dev libxslt1-dev libtool-bin

#####
#RPM#
#####
#Dependencies to build
BUILD_RPM     := curl autoconf automake ccache cmake3 wget gcc gcc-c++ git
#Dependencies for netopeer2
NETOPEER2_RPM := openssl-devel
#Dependencies for checkstyle
CHECKSTYLE_RPM:= indent
#Dependencies for scvpp
SCVPP_RPM     := libcmocka-devel
#Dependencies for sysrepo
SYSREPO_RPM   := libev-devel bison flex pcre-devel protobuf-c-devel protobuf-c-compiler

RPM_DEPENDS   := ${BUILD_RPM} ${NETOPEER2_RPM} ${CHECKSTYLE_RPM} ${SCVPP_RPM} ${SYSREPO_RPM}

#Dependencies for automatic test
RPM_TEST_DEPENDS = python36-devel python36-pip python-pip libxml2-devel \
libxslt-devel libtool which cmake3

###############
#PHONY TARGETS#
###############
PHONY_TARGETS := help all clean distclean install test checkstyle
#deps
PHONY_TARGETS += install-dep install-dep-extra
#vpp
PHONY_TARGETS += install-vpp
#yang models
PHONY_TARGETS += install-models uninstall-models
#build parts
PHONY_TARGETS += build-scvpp build-plugins build-package
#docker
PHONY_TARGETS += docker docker-test
#clean download
PHONY_TARGETS += _clean_dl
#apps for which sweetcomb based on
PHONY_TARGETS += _libssh _libyang _libnetconf2 _sysrepo _netopeer2

.PHONY: $(PHONY_TARGETS)

help:
	@echo "Make Targets:"
	@echo " install-dep            - install software dependencies"
	@echo " install-dep-extra      - install software extra dependencies from source code"
	@echo " install-vpp            - install released vpp"
	@echo " install-models         - install YANG models"
	@echo " uninstall-models       - uninstall YANG models"
	@echo " install-test-extra     - install software extra dependencies from source code for YDK"
	@echo " build-scvpp            - build scvpp"
	@echo " test-scvpp             - unit test for scvpp"
	@echo " build-plugins          - build plugins"
	@echo " test-plugins           - integration test for sweetcomb plugins"
	@echo " build-package          - build rpm or deb package"
	@echo " docker                 - build sweetcomb in docker enviroment, with optional arguments :"
	@echo "                          VPP_VERSION=release [master|release] specifies VPP version to be used"
	@echo "                          REBUILD_DOCKER_IMAGE=no [yes|no] force rebuild docker image"
	@echo " docker-test            - run test in docker enviroment, with optional argument :"
	@echo "                          REBUILD_DOCKER_IMAGE=no [yes|no] force rebuild docker image"
	@echo " clean                  - clean all build"
	@echo " distclean              - remove all build directory"
	@echo " checkstyle             - check coding style"

install-dep:
ifeq ($(filter ubuntu debian,$(OS_ID)),$(OS_ID))

ifeq ($(OS_VERSION_ID),14.04)
	@sudo -E apt-get -y --force-yes install software-properties-common
	@sudo -E add-apt-repository ppa:openjdk-r/ppa -y
endif

	@sudo -E apt-get update
	@sudo -E apt-get $(APT_ARGS) -y install $(DEB_DEPENDS)

else ifeq ($(OS_ID),centos)

	@sudo -E yum install -y $(RPM_DEPENDS) epel-release centos-release-scl devtoolset-7
	@sudo -E yum remove -y libavl libavl-devel
	@sudo -E yum install -y http://ftp.nohats.ca/libavl/libavl-0.3.5-1.fc17.x86_64.rpm http://ftp.nohats.ca/libavl/libavl-devel-0.3.5-1.fc17.x86_64.rpm

else
	$(error "This option currently works only on Ubuntu, Debian, Centos or openSUSE systems")
endif

_libssh:
	@bash tools/bld_libssh.sh
   
_libyang:
	@bash tools/bld_libyang.sh

_libnetconf2: #_libssh _libyang
	@bash tools/bld_libnetconf2.sh

_sysrepo: #_libyang
	@bash tools/bld_sysrepo.sh

_netopeer2: #_libnetconf2
	@bash tools/bld_netopeer2.sh

_test_python:
ifeq ($(filter ubuntu debian,$(OS_ID)),$(OS_ID))
	@sudo -E apt-get $(APT_ARGS) -y install $(DEB_TEST_DEPENDS)
ifeq ($(OS_VERSION_ID), 16.04)
	# Need update libssh library, because netopeer ssh communication does not work with old library
	@echo "deb http://archive.ubuntu.com/ubuntu/ bionic main restricted" >> /etc/apt/sources.list\
	&&apt-get update && apt-get -y install libssh-4
endif
#else ifeq ($(OS_ID),centos)
# compiler return me this error and I don't know hot to fix it, yet
#  Found Doxygen: /usr/bin/doxygen (found version "1.8.5") found components:  doxygen dot
#  CMake Error: The following variables are used in this project, but they are set to NOTFOUND.
#
# 	@sudo -E yum install -y epel-release
# 	@sudo -E yum install -y $(RPM_TEST_DEPENDS)
else
	$(error "This option currently works only on Ubuntu, Debian systems")
endif
	@pip3 install pexpect pyroute2 psutil

_ydk: _test_python
	@bash tools/bld_ydk.sh

_clean_dl:
	@rm -rf $(BR)/downloads/*[^tar.gz]

install-dep-extra: _clean_dl _libssh _libyang _libnetconf2 _sysrepo _netopeer2
	@echo && echo "Done [$@]" && echo

install-vpp:
	@echo "please install vpp as vpp's guide from source if failed"
ifeq ($(PKG),deb)
	@curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | sudo bash
	@sudo -E apt-get -y install vpp libvppinfra* vpp-plugin-* vpp-dev
else ifeq ($(PKG),rpm)
#	@curl -s https://packagecloud.io/install/repositories/fdio/release/script.rpm.sh | sudo bash
ifeq ($(OS_ID),centos)
	@sudo yum -y install vpp vpp-lib vpp-plugin* vpp-devel
endif
endif

install-test-extra: _clean_dl _libssh _test_python _ydk
	@echo && echo "Done [$@]" && echo

build-scvpp:
	@mkdir -p $(BR)/build-scvpp/; cd $(BR)/build-scvpp; \
	$(CMAKE) -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX:PATH=/usr $(WS_ROOT)/src/scvpp/;\
	make install
	@# NEW INSTRUCTIONS TO BUILD-SCVPP MUST BE DECLARED ON A NEW LINE WITH '@'

test-scvpp: build-scvpp
	@cd $(BR)/build-scvpp; make test ARGS="-V"

build-plugins:
	@mkdir -p $(BR)/build-plugins/; cd $(BR)/build-plugins/; \
	$(CMAKE) -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX:PATH=/usr $(WS_ROOT)/src/plugins/; \
	make install
	@# NEW INSTRUCTIONS TO BUILD-PLUGINS MUST BE DECLARED ON A NEW LINE WITH '@'

test-plugins: install-models
	@test/run_test.py --dir ./test/

build-package:
	@mkdir -p $(BR)/build-package/; cd $(BR)/build-package/;\
	$(CMAKE) -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr \
	-DENABLE_TESTS=OFF $(WS_ROOT)/src/; make package;
	@# NEW INSTRUCTIONS TO BUILD-PACKAGE MUST BE DECLARED ON A NEW LINE WITH
	@# '@' NOT WITH ';' ELSE BUILD-PACKAGE WILL NOT RETURN THE CORRECT
	@# RETURN CODE FOR JENKINS CI
	@rm -rf $(BR)/build-package/_CPack_Packages;

install-models:
	@bash tools/sw_operate_models.sh install && echo && echo "Done [$@]" && echo

uninstall-models:
	@bash tools/sw_operate_models.sh remove && echo && echo "Done [$@]" && echo

docker:
	@scripts/docker.sh

docker-test:
	@scripts/run_test.sh

clean:
	@ if [ -d $(BR)/build-scvpp ]; then cd $(BR)/build-scvpp   && make clean; fi
	@ if [ -d $(BR)/build-plugins ]; then cd $(BR)/build-plugins && make clean; fi
	@ if [ -d $(BR)/build-package ]; then cd $(BR)/build-package && make clean; fi

distclean:
	@ if [ -d $(BR)/build-scvpp   ]; then rm -rf $(BR)/build-scvpp; fi
	@ if [ -d $(BR)/build-plugins ]; then rm -rf $(BR)/build-plugins; fi
	@ if [ -d $(BR)/build-package ]; then rm -rf $(BR)/build-package; fi
