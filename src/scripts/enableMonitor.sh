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

NETMON_S="21"
NETMONWATCH_S="20"
BONDNICS_S="20"

NETMON_K="19"
NETMONWATCH_K="20"
BONDNICS_K="20"

disableMonitor.sh

echo "Linking init scripts in /etc/rc*.d/..."
for level in 0 1 6; do
	ln -sv ../init.d/netmon /etc/rc${level}.d/K${NETMON_K}netmon
	ln -sv ../init.d/netmonwatch /etc/rc${level}.d/K${NETMONWATCH_K}netmonwatch
	if [ ${PASSTHRU-FALSE} == "TRUE" ]; then
		ln -sv ../init.d/bridgeNICs /etc/rc${level}.d/K${BONDNICS_K}bridgeNICs
	else
		ln -sv ../init.d/bondNICs /etc/rc${level}.d/K${BONDNICS_K}bondNICs
	fi
done
for level in 2 3 4 5; do
	ln -sv ../init.d/netmon /etc/rc${level}.d/S${NETMON_S}netmon
	ln -sv ../init.d/netmonwatch /etc/rc${level}.d/S${NETMONWATCH_S}netmonwatch
	if [ ${PASSTHRU-FALSE} == "TRUE" ]; then
		ln -sv ../init.d/bridgeNICs /etc/rc${level}.d/S${BONDNICS_S}bridgeNICs
	else
		ln -sv ../init.d/bondNICs /etc/rc${level}.d/S${BONDNICS_S}bondNICs
	fi
done

