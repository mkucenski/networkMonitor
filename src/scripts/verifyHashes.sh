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
	HASHER="sha1sum"
	echo "`basename "$0"`: Unable to read configuration file: $CONF, using $HASHER"
fi

for FILE in "$@"; do
	HASH=`$HASHER "$FILE" | sed -r 's/^([^[:space:]]+).*/\1/'`
	if [ -e "$FILE.$HASHER" ]; then
		STOREDHASH=`cat "$FILE.$HASHER"`
		if [ "$HASH" = "$STOREDHASH" ]; then
			echo "$HASHER Verified ($FILE) = $STOREDHASH"
		else
			echo "$HASHER Mismatch ($FILE) != $STOREDHASH"
		fi
	else
		echo "$HASHER Mismatch ($FILE) Stored Hash Missing."
	fi
done

