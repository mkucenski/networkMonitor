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

function log-on-error {
	if [ -n "$1" ]; then
		$ERRLOG "$1"
	fi
}

function secure {
	# $1 = $OUTPUTDIR
	# $2 = $FILE

	$INFOLOG "Changing file ownership on $2..."
	log-on-error "`chown $DATAUSER:$DATAGROUP "$1/$2" > /dev/stdout 2>&1`"

	$INFOLOG "Changing file permissions on $2..."
	log-on-error "`chmod ug=r,o= "$1/$2" > /dev/stdout 2>&1`"
}

function hash {
	# $1 = $OUTPUTDIR
	# $2 = $FILE

	HASH=`$HASHER "$1/$2" | \
	      sed -r 's/^([^[:space:]]+).*/\1/' | \
	      tee "$1/$2".$HASHER`
	secure "$1" "$2.$HASHER"
	$INFOLOG "$2 $HASHER=$HASH"
}

function rename {
	# $1 = $OUTPUTDIR
	# $2 = $FILE

	# This function works as expected, but it
	# brings up several issues that are more
	# trouble than this is worth. 
	# 1) Debian 'mv' does not have a -n option
	#    to fail on overwriting an existing
	#    file.  If things were to get out of
	#    sync, renaming could overwrite an
	#    existing file and I would never know
	#    about it.
	# 2) Any errors at this step have to be
	#    carefully monitored as they could 
	#    have repercussions in future
	#    manipulations. At the very least I 
	#    need to modify this function to only
	#    change $FILE if the move is sucessful
	# If better naming conventions are required
	# on the captured files, I suggest
	# implementing the changes into dumpcap or
	# daemonlogger ***AND*** contributing the 
	# changes back to the maintainers for peer
	# review and wider testing/usage.
	# Contributing back also saves us from
	# having to maintain a separate source tree
	# and dealing with the headache of importing
	# bug fixes/upgrades in the main tree.
	#
	# NOTE: daemonlogger already has a slightly
	#	better system for naming files. It
	#	uses <prefix>.<seconds-since-epoch>
	#	with no other incremental numbering.

	return

	#LAST=`cat /var/lib/netmon/capture-count`
	#CURR=`expr $LAST + 1 | tee /var/lib/netmon/capture-count`
	#FILE=`echo "$2" | sed -r "s/^(.*)_.+_(.*)$/\1_netmon${CURR}_\2/"`

	#$INFOLOG "Renaming $2 to $FILE..."
	#log-on-error "`mv -n "$1/$2" "$1/$FILE" > /dev/stdout 2>&1`"
}

function compress {
	# Setting this script to gzip pcap files after completion
	# puts too much load on the monitor and affects its ability
	# to capture network traffic. Any compression (automatic
	# or manual) needs to be carefully considered to avoid
	# dropping packets.
	return
}

# 'inotifywait' waits for files that were opened for writing
# to be closed and executes the loop for each of those files.
inotifywait -e close_write --format %f -m -q "$OUTPUTDIR" | \
while read FILE; do

	# Verify that the supposed file still exists
	if [ -e "$OUTPUTDIR/$FILE" ]; then

		# Since I'm writing a hash file to the same
		# directory, I have to ignore those file events
		EXT=`echo "$FILE" | sed -r 's/.*\.([^\.]+)$/\1/'`
		if [ $EXT != "$HASHER" ]; then

			# Change ownership and write permissions
			secure "$OUTPUTDIR" "$FILE"

			if [ ${HASHER-none} != "none" ]; then
				# Save a hash of the captured data
				hash "$OUTPUTDIR" "$FILE"
			fi
		fi
	fi
done
