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

# Set the system time to a user given
# argument. If successful, push the
# new time out to the hardware clock.

# Read options and common commands from the configuration file
CONF="/usr/local/etc/netmon.conf"
if [ -r "$CONF" ]; then
	. "$CONF"
else
	echo "`basename "$0"`: Unable to read configuration file: $CONF"
	exit 2
fi

if [ -n "$1" ]; then
	$INFOLOG "Current system time: `date`"
	$INFOLOG "Setting system time to $1..."
	if date --set="$1" > /dev/null 2>&1; then
		$INFOLOG "System time set."

		$INFOLOG "Pushing new time to hardware clock..."
		if hwclock --systohc > /dev/null 2>&1; then
			$INFOLOG "Hardware clock set"
			exit 0
		else
			$ERRLOG "Failure setting hardware clock."	
		fi
	else
		$ERRLOG "Failure setting system time."
	fi
else
	echo "You must specify the new date/time as an argument."
fi
exit 2

