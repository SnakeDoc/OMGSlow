#!/bin/bash
#
# OMG Slow!!!!!!
# Monitor Ping Latency
#
# description: Uninstalls OMGSlow
#
# This script has currently been tested on CentOS based systems.
#

# Initialization
PATH="/sbin:/bin:/usr/bin:/usr/sbin"
RETVAL=0

# Check that we are root
if [ "$(id -u)" != "0" ]; then

    echo "${0} must be run as root"
    exit 1

fi

echo -n "Uninstalling OMGSlow: "

if [ "$(service omgslow status)" == "0" ]; then
    echo ""
    echo "OMGSlow must be stopped first!"
    exit 1
fi

chkconfig omgslow off

rm -f /etc/init.d/omgslow
rm -f /etc/sysconfig/omgslow

cd /
rm -rf /opt/omgslow

userdel omgslow

echo "DONE"

echo ""
echo "OMGSlow has been removed from your system."
echo ""

