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
	# Kill 'inotifywait' child of the sub process
	# This will stop 'inotifywait' if it is waiting,
	# but allow other sub processes (hash, secure, etc)
	# to complete.  Fixes a bug where stopping the
	# services caused empty hash files as the worker
	# process of this script was forced to quit before
	# completing the hash.
	$INFOLOG "Killing inotifywait child under PID:${SUBPROCESSID}..."
	pkill -P $SUBPROCESSPID inotifywait

	# Wait for sub process to complete before exiting.
	# This keeps the shutdown scripts from thinking
	# that we are really done when a hash process
	# may still be running.
	$INFOLOG "Waiting for child PID:${SUBPROCESSID}..."
	wait $SUBPROCESSID
	$INFLOG "Finished waiting, child completed."

	# Remove the PID file
	rm "$PID"

	$INFOLOG "Capture watcher stopped"
	exit 0
}
trap cleanup SIGHUP SIGINT SIGTERM

$INFOLOG "Attempting to start capture watcher..."
# 'inotifywait' from 'inotify-tools' required
if [ -n "`which inotifywait`" ]; then

	# Make sure that the output directory is actually available
	# before starting the watcher
	if [ -e "$OUTPUTDIR" ]; then

		# Attempt to always keep the sub process running
		# unless told to stop cleanly.
		while true; do

			$INFOLOG "Watching $OUTPUTDIR..."
			`dirname "$0"`/netmonwatch-worker.sh &
			SUBPROCESSPID=$!

			# Wait on the sub process created above
			wait $!

			# The sub process should never exit on its own.  An
			# external kill signal to this script should trigger
			# the cleanup function above.  If the sub process 
			# exits and we get to this point, log an error and
			# restart the sub process.
			$ERRLOG "Capture watcher stopped unexpectedly, restarting..."
		done
	else
		$ERRLOG "Directory to watch does not exist."
	fi
else
	$ERRLOG "Unable to find: inotifywait"
fi
exit 2
