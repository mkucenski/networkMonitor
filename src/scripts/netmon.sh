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

# Save this script's PID in /var/run
PID="/var/run/`basename "$0"`.pid"
echo "$$" > "$PID"

# Read options and common commands from the configuration file
CONF="/usr/local/etc/netmon.conf"
if [ -r "$CONF" ]; then
	. "$CONF"
else
	echo "`basename "$0"`: Unable to read configuration file: $CONF"
	exit 2
fi

function cleanup {
	# Kill all children processes, namely 'daemonlogger'
	pkill -P $$

	# Remove the PID file
	rm "$PID"

	$INFOLOG "Packet capture stopped"
	exit 0
}
trap cleanup SIGHUP SIGINT SIGTERM

$INFOLOG "Attempting to start packet capture..."
# 'daemonlogger' required
if [ -n "`which daemonlogger`" ]; then

	# Make sure that the output directory is actually
	# available before starting the capture process.
	if [ -e "$OUTPUTDIR" ]; then

		# Limit the ROLLOVERSIZE value to 2048000000 because
		# tshark stops capturing and exits if you try
		# to capture more than 2GB.
		if [ $ROLLOVERSIZE -gt 2048000000 ]; then
			$INFOLOG "ROLLOVERSIZE must be less than 2048000000"
			ROLLOVERSIZE=2048000000
		fi

		# Attempt to always keep tshark running unless told
		# to stop cleanly.
		while true; do
			# Ensure that the capture interface is available
			if ifconfig $INTERFACE > /dev/null 2>&1; then

				$INFOLOG "Starting packet capture..."
				$INFOLOG "Capturing on interface=$INTERFACE"
				$INFOLOG "Saving data to $OUTPUTDIR"
				$INFOLOG "Rollover on size=${ROLLOVERSIZE}kb"
				$INFOLOG "Rollover on time=${ROLLOVERTIME}sec"
				if [ -n "$FILTER" ]; then
					$INFOLOG "Packet filter=\"$FILTER\""
				fi

				CMD="daemonlogger -i $INTERFACE -l $OUTPUTDIR -n $OUTPUTPREFIX -s $ROLLOVERSIZE -t $ROLLOVERTIME" 

				if [ ${PENTRAP-FALSE} == "TRUE" ]; then
					# TCP only pen-trap allows the monitor to capture the entire TCP header
					# Normal pen-trap mode only allows for capturing 42 bytes as anything
					# beyond 42 bytes moves into the data portion of UDP and ICMP packets.
					if [ ${TCPONLYPENTRAP-FALSE} == "TRUE" ]; then
						$CMD -S 54 \(tcp\)${FILTER+ and \($FILTER\)} > /dev/null 2>&1 &
						$INFOLOG "PID($!)=\"$CMD -S 54 \(tcp\)${FILTER+ and \($FILTER\)}\""
					else
						$CMD -S 42 \(tcp or udp or icmp\)${FILTER+ and \($FILTER\)} > /dev/null 2>&1 &
						$INFOLOG "PID($!)=\"$CMD -S 42 \(tcp or udp or icmp\)${FILTER+ and \($FILTER\)}\""
					fi
				else
					$CMD${FILTER+ $FILTER} > /dev/null 2>&1 &
					$INFOLOG "PID($!)=\"$CMD${FILTER+ $FILTER}\""
				fi

				# Wait on the capture process executed above
				wait $!
	
				# The capture process should never exit on its own.
				# An external kill signal to this script
				# should trigger the cleanup function
				# above.  If the capture process exits and we get to
				# this point, log an error and restart
				# the process.
				$ERRLOG "Packet capture stopped unexpectedly, restarting..."
			else
				$ERRLOG "Interface unavailable: $INTERFACE"
				# Do not continuously restart if the
				# interface goes away
				break
			fi
		done
	else
		$ERRLOG "Output directory does not exist."
	fi
else
	$ERRLOG "Unable to find: daemonlogger"
fi
exit 2

