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

# Wipe the data drive (/dev/sdb).  Then,
# re-paritition and reformat the drive
# for use by the capture processes.

# Read options and common commands from the configuration file
CONF="/usr/local/etc/netmon.conf"
if [ -r "$CONF" ]; then
	. "$CONF"
else
	echo "`basename "$0"`: Unable to read configuration file: $CONF"
	exit 2
fi

echo "" > /dev/stderr
echo "Before continuing, be sure that netmon and netmonwatch are stopped and /media/data is not mounted." > /dev/stderr
echo "" > /dev/stderr

DISK=""
DATALABEL="/media/data"
if [ $# -eq 1 ]; then
	DISK="$1"
else
	# Loop through sd* and hd* drives looking for existing label "/media/data"
	# If found, wipe and repartition the existing data drive.
	for PART in `ls /dev/sd?? /dev/hd?? 2>/dev/null`; do
		LABEL=`e2label $PART 2>/dev/null`
		if [ "${LABEL-NULL}" == "$DATALABEL" ]; then
			DISK=${PART%?}
			break;
		fi
	done
	
	if [ -z "$DISK" ]; then
		# If unable to find and existing data drive, the drive must be specified
		# on the command line of this script.
		echo "" > /dev/stderr
		echo "Unable to find existing partition with \"$DATALABEL\" label." > /dev/stderr
		echo "You must specify the data drive on the command line (e.g. $0 /dev/sdb)" > /dev/stderr
		echo "" > /dev/stderr
		exit 2
	fi
fi

if [ -n "$DISK" ]; then
	CONTINUE="no"
	echo "WARNING: All data on $DISK will be erased!"
	echo ""
	read -p "Are you sure you wish to continue? (yes/no) " CONTINUE
	if [ $CONTINUE == "yes" ]; then

		$INFOLOG "Wiping $DISK..."
		dcfldd if=/dev/zero of=$DISK bs=65536

		$INFOLOG "Partitioning $DISK..."
		if sfdisk -uS $DISK < /usr/local/etc/sdb.out; then
	
			$INFOLOG "Formatting $DISK..."
			if mkfs -t ext3 -L "$DATALABEL" ${DISK}1; then
				$INFOLOG "Successfully wiped, partitioned, and formatted $DISK."
				exit 0
			else
				$ERRLOG "Failure formatting $DISK."
			fi
		else
			$ERRLOG "Failure partitioning $DISK."
		fi
	else
		echo "Cancelled"
	fi
else
	echo "Invalid disk.  Try specifying the data drive directly (e.g. $0 /dev/sdb)" > /dev/stderr
fi

exit 2

