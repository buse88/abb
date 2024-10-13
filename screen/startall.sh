#!/bin/sh

#stty -F /dev/ttyUSB0 speed 115200 cs8 -parenb -cstopb

echo -e -n "$(/root/screen/openlcd.sh)" >/dev/nul 2>&1
echo -e -n "$(/root/screen/bps.sh)" >/dev/nul 2>&1
echo -e -n "$(/root/screen/power.sh)" >/dev/nul 2>&1
sleep 10
echo -e -n "n1.val=1\xff\xff\xff" > /dev/ttyUSB0
