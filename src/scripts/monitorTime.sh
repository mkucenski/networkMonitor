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

sudo hwclock --show
date "+%a %d %b %Y %r %Z"

cat /proc/driver/rtc | grep rtc_time | sed -r 's/.+: (.+)$/\1/'
cat /proc/driver/rtc | grep rtc_date | sed -r 's/.+: (.+)$/\1/'
cat /proc/driver/rtc | grep batt_status | sed -r 's/.+: (.+)$/\1/'
