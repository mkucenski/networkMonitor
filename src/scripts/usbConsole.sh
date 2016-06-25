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

# Keep getty running for dynamically
# connected usb-serial devices.  This
# script is meant to be called from a
# udev rule when usb-serial devices are
# connected.
#
# $1 (or $2 if using --daemon or --stop)
# should indicate the /dev device name
# (e.g. ttyUSB0)

LOGGER="logger -s -t `basename "$0"`"
INFOLOG="$LOGGER -p user.info"
ERRLOG="$LOGGER -p user.err"

if [ "$1" == "--daemon" ]; then
	DEV="$2"

	# Exit if this script is already running for the specified device
	PID=`pgrep -f "$0 $DEV"`
	if [ -n "$PID" ]; then
		$INFOLOG "getty is already running for: /dev/$DEV..."
		exit 2
	else
		$INFOLOG "Daemonizing getty for /dev/$DEV..."
		"$0" "$DEV" &
		exit 0
	fi
elif [ "$1" == "--stop" ]; then
	DEV="$2"

	$INFOLOG "Stopping getty for: /dev/$DEV..."
	PID=`pgrep -f \"$0 $DEV\"`
	if [ -n "$PID" ]; then
		kill `cat "$PID"`
	fi
	exit 0
else
	DEV="$1"

	function cleanup {
		$INFOLOG "Cleanup and exit getty for: /dev/$DEV"

		# Kill all children processes, namely 'getty'
		pkill -P $$
	
		exit 0
	}
	trap cleanup SIGHUP SIGINT SIGTERM

	# Attempt to always keep getty running unless told
	# to stop cleanly.
	$INFOLOG "Starting getty for: /dev/$DEV..."
	while true; do
		if [ -e "/dev/$DEV" ]; then
			/sbin/getty -L $DEV 115200 vt100 &

			#Wait on the getty process executed above
			wait $!
		else
			cleanup
		fi
		$INFOLOG "Restarting getty for: /dev/$DEV..."
	done
fi

