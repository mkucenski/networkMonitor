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

EXEC=brctl

# A single --destroy argument indicates that the
# bridge interface should be torn down.
if [ -n "$1" ] && [ "$1" == "--destroy" ]; then

	$INFOLOG "Attempting to destroy bridge interface..."

	# Detach the slave interfaces
	if $EXEC delif bridge0 $INTERFACE0 && \
	   $EXEC delif bridge0 $INTERFACE1; then

		$INFOLOG "Successfully detached slave interfaces"
	else
		$ERRLOG "Failure detaching slave interfaces"
	fi

	# Unload the bridge module
	if modprobe -r bridge; then
		$INFOLOG "Unloaded bridge module"
		exit 0
	else
		$ERRLOG "Failure unloading bridge module"
		exit 2
	fi

# Otherwise, load the bridge module, bring up the interface
# and attach the individual send/recv interfaces.
else
	$INFOLOG "Attempting to enable bridging..."

	if [ -n "`which $EXEC`" ]; then
	
		# Log the MAC addresses for each of this
		# system's interfaces for future
		# reference and validation that no data 
		# was introduced into the captures
		$INFOLOG "System MAC Addresses: `ifconfig -a | grep HWaddr | sed -r 's/^([^[:space:]]+).+HWaddr (.+)$/\1: \2/'`"

		# Load the bridge module into the kernel
		if modprobe bridge; then

			# Create the bridge interface
			if $EXEC addbr bridge0; then

				# Add the send/recv interfaces to the bridge
				if $EXEC addif bridge0 $INTERFACE0 && \
				   $EXEC addif bridge0 $INTERFACE1; then

					# Bring up all of the interfaces
					if ifconfig bridge0 up -arp && \
					   ifconfig $INTERFACE0 up -arp && \
						ifconfig $INTERFACE1 up -arp; then

						$INFOLOG "Bridging enabled"
						exit 0
					else
						$ERRLOG "Error bringing up bridge interfaces"
					fi
				else
					$ERRLOG "Failure attaching interfaces to bridge"
				fi
			else
				$ERRLOG "Failure creating bridge interface"
			fi
		else
			$ERRLOG "Failure loading bridge module"
		fi
	else
		$ERRLOG "Unable to find: $EXEC"
	fi
	exit 2
fi

