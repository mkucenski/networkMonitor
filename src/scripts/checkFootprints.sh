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

echo "" > /dev/stderr
echo "WARNING: Channel bonding masks one of the slave interface MAC addresses.  Channel bonding must be disabled (via /etc/init.d/bondNICs stop) prior to running this script." > /dev/stderr
echo "" > /dev/stderr

MACADDRS=`ifconfig -a | \
		grep HWaddr | \
		sed -r 's/.+HWaddr ([^[:space:]]+).*/\1/' | \
		sed -e :a -e '\$!N; s/\n/|/; ta'`

for file in "$@"; do
	echo "$file"
	tcpdump -n -e -tttt -r "$file" 2> /dev/null | egrep -i "($MACADDRS)"
done

