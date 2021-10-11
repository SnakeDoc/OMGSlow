#!/bin/bash
#
# OMG Slow!!!!!!
# Monitor Ping Latency
#
# description: Installs OMGSlow
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

echo -n "Installing OMGSlow: "

# Check for program directory, and if it doesn't exist, creati it.
[ ! -d "/opt/omgslow" ] && mkdir -p /opt/omgslow/logs

# Copy files into program directory, set permissions, and setup sym link to init.d.
cp ./* /opt/omgslow && chmod 755 /opt/omgslow/* \
&& chmod 775 /opt/omgslow/logs && ln -sf /opt/omgslow/omgslow /etc/init.d/omgslow
RETVAL=$?

echo -en "\e[60G"
echo -en "["
if [ "${RETVAL}" -eq 0 ]; then

    echo -en "\e[1;92m"
    echo -en "  OK  "

else

    echo -en "\e[1;91m"
    echo -en "FAILED"

fi

echo -en "\e[0;0m"
echo -e "]"

# ------------------------------------------------------------------------

echo ""
echo "Now we'll ask some questions to populate the default config."
echo "Press [ENTER] to accept the specified default, or type your own."

echo ""
echo -n "Notification Email Address: [root@localhost] "
read ADMIN_EMAIL
[ -z "${ADMIN_EMAIL}" ] && ADMIN_EMAIL="root@localhost"

echo ""
echo -n "Site 1: [4.2.2.2] "
read SITE_1
[ -z "${SITE_1}" ] && SITE_1="4.2.2.2"

echo ""
echo -n "Site 2: [8.8.8.8] "
read SITE_2
[ -z "${SITE_2}" ] && SITE_2="8.8.8.8"

echo ""
echo -n "Site 3: [yahoo.com] "
read SITE_3
[ -z "${SITE_3}" ] && SITE_3="yahoo.com"

echo ""
echo -n "Site 4: [google.com] "
read SITE_4
[ -z "${SITE_4}" ] && SITE_4="google.com"

echo ""
echo -n "Site 5: [custom] "
read SITE_5
[ -z "${SITE_5}" ] && SITE_5=""

echo ""
echo -n "Polling Interval in Seconds: [30] "
read INTRVL
[ -z "${INTRVL}" ] && INTRVL="30"

# -----------------------------------------------------------------------

# Create default /etc/sysconfig/omgslow config file.
echo -n "Installing default sysconfig configuration file: "

# Check for default sysconfig file, if it does not exist, create it.
[ ! -f "/etc/sysconfig/omgslow" ] && cat > /etc/sysconfig/omgslow << EOF
OMGSLOW_HOME="/opt/omgslow"
OMGSLOW_USER="omgslow"
OMGSLOW_PIDFILE="/var/run/omgslow.pid"
OMGSLOW_LOGDIR="${OMGSLOW_HOME}/logs"
#####
# Edit to change notification email address
#####
ADMIN_EMAIL=${ADMIN_EMAIL}
#####
# Add sites to check
#   Max of 5 supported
#####
SITE_1=${SITE_1}
SITE_2=${SITE_2}
SITE_3=${SITE_3}
SITE_4=${SITE_4}
SITE_5=${SITE_5}
#####
# Polling Interval in Seconds
#####
INTRVL=${INTRVL}
EOF
RETVAL=$?

echo -en "\e[60G"
echo -en "["
if [ "${RETVAL}" -eq 0 ]; then

    echo -en "\e[1;92m"
    echo -en "  OK  "

else

    echo -en "\e[1;91m"
    echo -en "FAILED"

fi

echo -en "\e[0;0m"
echo -e "]"


echo -n "Creating 'omgslow' User: "

# Check is the user 'omgslow' already exists, if not, create it as a system account
[ "$(id -u omgslow > /dev/null 2>&1)" != "0" ] && useradd -s /bin/nologin -r -M omgslow
RETVAL=$?

echo -en "\e[60G"
echo -en "["
if [ "${RETVAL}" -eq 0 ]; then

    echo -en "\e[1;92m"
    echo -en "  OK  "

else

    echo -en "\e[1;91m"
    echo -en "FAILED"

fi

echo -en "\e[0;0m"
echo -e "]"

# Fix permissions on log directory.
chown -R :omgslow /opt/omgslow/logs

echo ""
echo "OMGSlow Installation Complete!"
echo ""
echo ""
sleep 1

# Print some basic instructions.
echo "Configuration is located at /etc/sysconfig/omgslow, defaults are usually OK."
echo ""
echo "############################################################################"
echo "# Your configured sites: "
echo "#     Site 1: ${SITE_1}"
echo "#     Site 2: ${SITE_2}"
echo "#     Site 3: ${SITE_3}"
echo "#     Site 4: ${SITE_4}"
echo "#     Site 5: ${SITE_5}"
echo "############################################################################"
echo ""
echo "To start program, do: 'service omgslow start'."
echo "To run at boot, do: 'chkconfig omgslow on'."
echo ""
echo "Enjoy! :)"
echo ""

