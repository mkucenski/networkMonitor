#! /bin/bash

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
# This installation script is used to install required scripts and binaries
# on top of an existing installation of Debian Linux 4.0 i386
# (debian-40r1-i386-CD-1.iso).

# TODO automate adding users/groups/sudo/etc

# Custom scripts provided by this project
SCRIPTS="bondNICs.sh \
	 bridgeNICS.sh \
	 changeTime.sh \
 	 checkFootprints.sh \
	 enableNTP.sh \
	 enableMonitor.sh \
	 disableMonitor.sh \
	 disableNTP.sh \
	 startMonitor.sh \
	 stopMonitor.sh \
	 restartMonitor.sh \
 	 netmon.sh \
	 netmonwatch.sh \
	 netmonwatch-worker.sh \
	 networkTime.sh \
	 wipeData.sh \
	 usbConsole.sh \
	 buildNetUdevRules.sh"

# Precompiled binaries of
#    dcfldd-1.3.4-1.tar.gz
#    daemonlogger-1.2.1.tar.gz
#    vii-4.0.tar.gz
BIN="dcfldd \
     daemonlogger \
     vii"

# Custom Linux init.d scripts provided by this project
INITSCRIPTS="bondNICs \
	     netmon \
	     netmonwatch"

echo "Copying pre-compiled binaries into /usr/local/bin/..."
for x in $BIN; do
	cp -v bin/$x /usr/local/bin/
	chmod +x /usr/local/bin/$x
done
echo ""

echo "Copying scripts into /usr/local/bin/..."
for x in $SCRIPTS; do
	cp -v scripts/$x /usr/local/bin/
	chmod +x /usr/local/bin/$x
done
echo ""

echo "Copying configuration files to /etc/..."
cp -v etc/login_banner /etc/login_banner
echo ""

echo "Copying configuration files to /usr/local/etc/..."
cp -v etc/netmon.conf /usr/local/etc/netmon.conf.default
chmod -w /usr/local/etc/netmon.conf.default
cp -vi etc/netmon.conf /usr/local/etc/
cp -v etc/sdb.out /usr/local/etc/sdb.out.default
chmod -w /usr/local/etc/sdb.out.default
cp -v etc/sdb.out /usr/local/etc
echo ""

echo "Copying udev rules to /etc/udev/rules.d/..."
cp -v etc/udev/010_usbdevices.rules /etc/udev/rules.d/
echo ""

echo "Making /media/data/..."
mkdir -vp /media/data
echo ""

echo "Making /var/lib/netmon/..."
mkdir -vp /var/lib/netmon
echo ""

echo "Copying init scripts to /etc/init.d/..."
for x in $INITSCRIPTS; do
	cp -v init.d/$x /etc/init.d/
	chmod +x /etc/init.d/$x
done
echo ""

echo "Removing stale links from /etc/rc*.d/..."
for x in $INITSCRIPTS; do
	find /etc/rc*.d -regextype posix-egrep \
			-type l \
			-regex ".*(S|K)..$x" \
			-exec rm -v {} \
			\;
done
echo ""

echo "Patching configuration files..."
#patch -N -r /tmp/patch.rej /boot/grub/menu.lst boot/grub/menu.lst.diff
patch -N -r /tmp/patch.rej /etc/fstab etc/fstab.diff
patch -N -r /tmp/patch.rej /etc/inittab etc/inittab.diff
patch -N -r /tmp/patch.rej /etc/default/acpid etc/default/acpid.diff
patch -N -r /tmp/patch.rej /etc/modprobe.d/aliases etc/modprobe.d/aliases.diff
patch -N -r /tmp/patch.rej /etc/modprobe.d/blacklist etc/modprobe.d/blacklist.diff
patch -N -r /tmp/patch.rej /etc/ssh/sshd_config etc/ssh/sshd_config.diff
echo ""

echo "Installation complete."
