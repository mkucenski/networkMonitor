#!/bin/bash

# Copyright 2009 Matthew A. Kucenski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# DESCRIPTION
# TODO

apt-get -y update
apt-get -y upgrade

apt-get -y install \
	   changetrack \
	   deborphan \
	   ifenslave \
	   inotify-tools \
	   lcdproc \
	   ngrep \
	   ntpdate \
	   openntpd \
	   openssh-server \
	   subversion \
	   sudo \
	   tcpdump \
	   tcpflow \
	   tcpreplay \
	   tshark

apt-get -y remove \
	   portmap \
	   pidentd

