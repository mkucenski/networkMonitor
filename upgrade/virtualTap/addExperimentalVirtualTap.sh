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

$INFOLOG "Attempting to patch system for UNVALIDATED virtual tap mode..."

NAME="bridgeNICs"
if ! cp ./$NAME "$1/etc/init.d/$NAME"; then
	$ERRLOG "Error copying './$NAME' to '$1/etc/init.d/$NAME'."
fi

NAME="bridgeNICs.sh"
if ! cp ./$NAME "$1/usr/local/bin/$NAME"; then
	$ERRLOG "Error copying './$NAME' to '$1/usr/local/bin/$NAME'."
fi

NAME="disableMonitor.sh"
cp "$1/usr/local/bin/$NAME" ./
if patch -N -r /tmp/$NAME.patch.rej -b .bak ./$NAME ./$NAME.diff; then
	if cp ./$NAME "$1/usr/local/bin/$NAME"; then
		rm ./$NAME
	else
		$ERRLOG "Error copying './$NAME' to '$1/usr/local/bin/$NAME'."
	fi
else
	$ERRLOG "Error patching '$NAME'. No changes made to '$1/usr/local/bin/$NAME'."
fi

NAME="enableMonitor.sh"
cp "$1/usr/local/bin/$NAME" ./
if patch -N -r /tmp/$NAME.patch.rej -b .bak ./$NAME ./$NAME.diff; then
	if cp ./$NAME "$1/usr/local/bin/$NAME"; then
		rm ./$NAME
	else
		$ERRLOG "Error copying './$NAME' to '$1/usr/local/bin/$NAME'."
	fi
else
	$ERRLOG "Error patching '$NAME'. No changes made to '$1/usr/local/bin/$NAME'."
fi

NAME="startMonitor.sh"
cp "$1/usr/local/bin/$NAME" ./
if patch -N -r /tmp/$NAME.patch.rej -b .bak ./$NAME ./$NAME.diff; then
	if cp ./$NAME "$1/usr/local/bin/$NAME"; then
		rm ./$NAME
	else
		$ERRLOG "Error copying './$NAME' to '$1/usr/local/bin/$NAME'."
	fi
else
	$ERRLOG "Error patching '$NAME'. No changes made to '$1/usr/local/bin/$NAME'."
fi

NAME="stopMonitor.sh"
cp "$1/usr/local/bin/$NAME" ./
if patch -N -r /tmp/$NAME.patch.rej -b .bak ./$NAME ./$NAME.diff; then
	if cp ./$NAME "$1/usr/local/bin/$NAME"; then
		rm ./$NAME
	else
		$ERRLOG "Error copying './$NAME' to '$1/usr/local/bin/$NAME'."
	fi
else
	$ERRLOG "Error patching '$NAME'. No changes made to '$1/usr/local/bin/$NAME'."
fi

NAME="netmon.sh"
cp "$1/usr/local/bin/$NAME" ./
if patch -N -r /tmp/$NAME.patch.rej -b .bak ./$NAME ./$NAME.diff; then
	if cp ./$NAME "$1/usr/local/bin/$NAME"; then
		rm ./$NAME
	else
		$ERRLOG "Error copying './$NAME' to '$1/usr/local/bin/$NAME'."
	fi
else
	$ERRLOG "Error patching '$NAME'. No changes made to '$1/usr/local/bin/$NAME'."
fi

NAME="netmon.conf"
cp "$1/usr/local/etc/$NAME" ./
if patch -N -r /tmp/$NAME.patch.rej -b .bak ./$NAME ./$NAME.diff; then
	if cp ./$NAME "$1/usr/local/etc/$NAME" && cp ./$NAME "$1/usr/local/etc/$NAME.default"; then
		rm ./$NAME
	else
		$ERRLOG "Error copying './$NAME' to '$1/usr/local/etc/$NAME' or '$1/usr/local/etc/$NAME.default'."
	fi
else
	$ERRLOG "Error patching '$NAME'. No changes made to '$1/usr/local/etc/$NAME' or '$1/usr/local/etc/$NAME.default'."
fi

$INFOLOG "Successfully patched system for UNVALIDATED virtual tap mode."
$INFOLOG "NOTE: You must also install the 'bridge-utils' package."

