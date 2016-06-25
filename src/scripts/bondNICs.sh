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

# Read options and common commands from the configuration file
CONF="/usr/local/etc/netmon.conf"
if [ -r "$CONF" ]; then
	. "$CONF"
else
	echo "`basename "$0"`: Unable to read configuration file: $CONF"
	exit 2
fi

# A single --destroy argument indicates that the
# bonded interface should be torn down.
if [ -n "$1" ] && [ "$1" == "--destroy" ]; then

	$INFOLOG "Attempting to destroy bonded interface..."

	# Detach the slave interfaces
	if ifenslave -d bond0 $INTERFACE0 && \
	   ifenslave -d bond0 $INTERFACE1; then

		if modprobe -r bonding; then
			$INFOLOG "Unloaded bonding module"
			exit 0
		else
			$ERRLOG "Failure unloading bonding module"
			exit 2
		fi
	else
		$ERRLOG "Failure detaching slave interfaces"
	fi

# Otherwise, load the bonding module, bring up the interface
# and attach the individual send/recv interfaces.
else
	$INFOLOG "Attempting to enable channel bonding..."

	# 'ifenslave' required for operation on Linux
	if [ -n "`which ifenslave`" ]; then
		
		# Log the MAC addresses for each of this
		# system's interfaces for future
		# reference and validation that no data 
		# was introduced into the captures
		$INFOLOG "System MAC Addresses: `ifconfig -a | grep HWaddr | sed -r 's/^([^[:space:]]+).+HWaddr (.+)$/\1: \2/'`"

		# Load the bonding module into the kernel
		if modprobe bonding miimon=100; then

			# Bring up the bonding interface
			if ifconfig bond0 up -arp; then

				# Attach the slave interfaces
				if ifenslave bond0 $INTERFACE0 && \
				   ifenslave bond0 $INTERFACE1; then

					$INFOLOG "Channel bonding enabled"
					exit 0
				else
					$ERRLOG "Failure attaching slave interfaces"
				fi
			else
				$ERRLOG "Failure bringing up bond interface"
			fi
		else
			$ERRLOG "Failure loading bonding module"
		fi
	else
		$ERRLOG "Unable to find: ifenslave"
	fi
	exit 2
fi

