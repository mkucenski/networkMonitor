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

# Check for access to nist.gov time
# servers and update the time 
# accordingly. If successful, push the
# new time out to the hardware clock.

# Read options and common commands from the configuration file
CONF="/usr/local/etc/netmon.conf"
if [ -r "$CONF" ]; then
	. "$CONF"
else
	echo "`basename "$0"`: Unable to read configuration file: $CONF"
	exit 2
fi

$INFOLOG "Current system time: `date`"
for server in 	time-a.nist.gov \
		time-b.nist.gov \
		time.nist.gov \
		time-nw.nist.gov; do

	$INFOLOG "Updating system time from: $server..."
	if ntpdate -q $server > /dev/null 2>&1; then
		$INFOLOG "System time updated successfully."

		$INFOLOG "Pushing new time to hardware clock..."
		if hwclock --systohc > /dev/null 2>&1; then
			$INFOLOG "Hardware clock set"
			exit 0
		else
			$ERRLOG "Failure setting hardware clock."	
		fi

		break;
	else
		$ERRLOG "Failure updating system time."
	fi
done
exit 2

