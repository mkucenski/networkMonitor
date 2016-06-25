#!/bin/sh

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

LOGGER="logger -s -t `basename "$0"`"
INFOLOG="$LOGGER -p user.info"
ERRLOG="$LOGGER -p user.err"

$INFOLOG "Attempting to patch system for TCP-only pen-trap mode..."

cp "$1/usr/local/bin/netmon.sh" ./
if patch -N -r /tmp/netmon.sh.patch.rej -b .bak ./netmon.sh ./netmon.sh.diff; then
	if cp ./netmon.sh "$1/usr/local/bin/netmon.sh"; then
		rm ./netmon.sh
	else
		$ERRLOG "Error copying './netmon.sh' to '$1/usr/local/bin/netmon.sh'."
		exit 2
	fi
else
	$ERRLOG "Error patching 'netmon.sh'. No changes made to '$1/usr/local/bin/netmon.sh'."
	exit 2
fi

cp "$1/usr/local/etc/netmon.conf" ./
if patch -N -r /tmp/netmon.conf.patch.rej -b .bak ./netmon.conf ./netmon.conf.diff; then
	if cp ./netmon.conf "$1/usr/local/etc/netmon.conf"; then
		rm ./netmon.conf
	else
		$ERRLOG "Error copying './netmon.conf' to '$1/usr/local/etc/netmon.conf'."
		exit 2
	fi
else
	$ERRLOG "Error patching 'netmon.conf'. No changes made to '$1/usr/local/etc/netmon.conf'."
	exit 2
fi

cp "$1/usr/local/etc/netmon.conf.default" ./
if patch -N -r /tmp/netmon.conf.default.patch.rej -b .bak ./netmon.conf.default ./netmon.conf.default.diff; then
	if cp ./netmon.conf.default "$1/usr/local/etc/netmon.conf.default"; then
		rm ./netmon.conf.default
	else
		$ERRLOG "Error copying './netmon.conf.default' to '$1/usr/local/etc/netmon.conf.default'."
		exit 2
	fi
else
	$ERRLOG "Error patching 'netmon.conf.default'. No changes made to '$1/usr/local/etc/netmon.conf.default'."
	exit 2
fi

$INFOLOG "Successfully patched system for TCP-only pen-trap mode."
exit 0

