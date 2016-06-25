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

FILE="/etc/udev/rules.d/010_netinterface.rules"

echo "" > /dev/stderr
echo "WARNING: Channel bonding masks one of the slave interface MAC addresses.  Channel bonding must be disabled (via /etc/init.d/bondNICs stop) prior to running this script." > /dev/stderr
echo "" > /dev/stderr

CONTINUE="no"
echo "WARNING: $FILE will be erased and rebuilt!"
echo ""
read -p "Are you sure you wish to continue? (yes/no) " CONTINUE
if [ $CONTINUE == "yes" ]; then
	HWADDRS=""
	for x in `ls /sys/class/net`; do
		HWADDRS+="`udevinfo --attribute-walk --path=/sys/class/net/$x | grep address | sed -r 's/.*\"(.+)\".*/\1/' | grep -v '00:00:00:00:00:00'` "
	done

	echo "Found the following hardware addresses:"
	for x in $HWADDRS; do
		echo "   $x"
	done

	rm "$FILE"
	for x in $HWADDRS; do
		NAME=""
		while 	[ "$NAME" != "adm0" ] && \
			[ "$NAME" != "tap0" ] && \
			[ "$NAME" != "tap1" ] && \
			[ "$NAME" != "skip" ]; do
			read -p "Enter new interface name for hardware address $x: (adm0/tap0/tap1/skip) " NAME
		done
		if [ "$NAME" != "skip" ]; then
			echo "SUBSYSTEM==\"net\", DRIVERS==\"?*\", ATTR{address}==\"$x\", NAME=\"$NAME\"" >> "$FILE"
		fi
	done
	exit 0
else
	echo "Cancelled"
fi
exit 2

