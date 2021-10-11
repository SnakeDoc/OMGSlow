#!/bin/bash
#
# OMG Slow!!!!!!
# Monitor Ping Latency
#
# description: Runs OMGSlow
#
# This script has currently been tested on CentOS based systems.
#

# Initialization
PATH="/sbin:/bin:/usr/bin:/usr/sbin"
RETVAL=0

export OVERALL_AVERAGE_LATENCY="-1" # default
ARRAY_COUNTER="0"
ARRAY_MAX="100"

# We support 5 tests
ARRAY1=()
ARRAY2=()
ARRAY3=()
ARRAY4=()
ARRAY5=()

SITE_1_AVG="0"
SITE_2_AVG="0"
SITE_3_AVG="0"
SITE_4_AVG="0"
SITE_5_AVG="0"

# Get config
[ -f "/etc/sysconfig/omgslow" ] && . /etc/sysconfig/omgslow
[ -f "/etc/init.d/functions" ] && . /etc/init.d/functions

# If omgslow home variable has not been specified, use /opt/omgslow
if [ -z "${OMGSLOW_HOME}" -o ! -d "${OMGSLOW_HOME}" ]; then

    if [ ! -d "/opt/omgslow" ]; then

        # create home directory and log directory
        mkdir -p "/opt/omgslow/logs"
        OMGSLOW_HOME="/opt/omgslow"

    fi

fi

# Verify log directory exists, if it does not, create it.
[ ! -d "${OMGSLOW_HOME}/logs" ] && mkdir -p "${OMGSLOW_HOME}/logs"

# Make sure log file exits for writing
LOGFILE="${OMGSLOW_HOME}/logs/omgslow.log"
touch "${LOGFILE}"

# Trap normal SIGNAL ie. when we should shut down
trap 'exit 0' SIGINT SIGQUIT SIGTERM SIGUSR1

# ----------------------------------------------------------------

# Program functions

poll() {

    echo $(ping -c 1 "${1}" | cut -d $'\n' -f 2 | awk -F "time=" '{print $2}')

}

#####
# $1 = Site Number [1 - 5]
#####
calculate_avg() {
    
    SUM="0"

    if [ "$1" == "1" ]; then

        for i in "${ARRAY1[@]}"; do
            SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
        done

        SITE_1_AVG=$(echo "scale=2; ${SUM} / ${#ARRAY1[@]}" | bc)
        echo "Site 1 - ${SITE_1} - AVG: ${SITE_1_AVG} ms" >> "${LOGFILE}"

    fi

    if [ "$1" == "2" ]; then

        for i in "${ARRAY2[@]}"; do
            SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
        done

        SITE_2_AVG=$(echo "scale=2; ${SUM} / ${#ARRAY2[@]}" | bc)
        echo "Site 2 - ${SITE_2} - AVG: ${SITE_2_AVG} ms" >> "${LOGFILE}"

    fi

    if [ "$1" == "3" ]; then

        for i in "${ARRAY3[@]}"; do
            SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
        done

        SITE_3_AVG=$(echo "scale=2; ${SUM} / ${#ARRAY3[@]}" | bc)
        echo "Site 3 - ${SITE_3} - AVG: ${SITE_3_AVG} ms" >> "${LOGFILE}"

    fi

    if [ "$1" == "4" ]; then

        for i in "${ARRAY4[@]}"; do
            SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
        done

        SITE_4_AVG=$(echo "scale=2; ${SUM} / ${#ARRAY4[@]}" | bc)
        echo "Site 4 - ${SITE_4} - AVG: ${SITE_4_AVG} ms" >> "${LOGFILE}"

    fi

    if [ "$1" == "5" ]; then

        for i in "${ARRAY5[@]}"; do
            SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
        done

        SITE_5_AVG=$(echo "scale=2; ${SUM} / ${#ARRAY5[@]}" | bc)
        echo "Site 5 - ${SITE_5} - AVG: ${SITE_5_AVG} ms" >> "${LOGFILE}"

    fi

}

calculate_total_avg() {

    SUM="0"
    TOTAL_COUNTS=$(echo "scale=2; ${#ARRAY1[@]} + ${#ARRAY2[@]} + ${#ARRAY3[@]} + ${#ARRAY4[@]} + ${#ARRAY5[@]}" | bc)

    for i in "${ARRAY1[@]}"; do
        SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
    done

    for i in "${ARRAY2[@]}"; do
        SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
    done

    for i in "${ARRAY3[@]}"; do
        SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
    done

    for i in "${ARRAY4[@]}"; do
        SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
    done

    for i in "${ARRAY5[@]}"; do
        SUM=$(echo "scale=2; ${SUM} + ${i}" | bc)
    done

    OVERALL_AVERAGE_LATENCY=$(echo "scale=2; ${SUM} / ${TOTAL_COUNTS}" | bc)
    echo "Total Average Latency for All Sites: ${OVERALL_AVERAGE_LATENCY} ms" >> "${LOGFILE}"

}

#####
# $1 = Hostname/IP
# $2 = Last Latency
# $3 = Average Latency
#####
alert() {

    MESSAGE="Connection Issue Detected! 
 
    Host: ${1} 
    Last: ${2}
    AVG: ${3} ms
    Total AVG: ${OVERALL_AVERAGE_LATENCY} ms"

    echo "${MESSAGE}" | mail -s "Connection Issue Detected! -- $(date)" "${ADMIN_EMAIL}"

    echo "Connection Issue | Host: ${1} | Last: ${2} | AVG: ${3} | Total AVG: ${OVERALL_AVERAGE_LATENCY}" >> "${LOGFILE}"

}

# Main program loop

while [ 1 ]; do

    #####
    # Site 1
    #####
    if [ -n "${SITE_1}" ]; then
        RAW=$(poll "${SITE_1}")
        TIME=$(echo "${RAW}" | cut -d " " -f 1)
        UNITS=$(echo "${RAW}" | cut -d " " -f 2)
        if [ "${UNITS}" != "ms" ]; then # we've got a problem
            $(alert "${SITE_1}" "${RAW}" "${SITE_1_AVG}")
        fi

        ARRAY1+=("${TIME}")
        echo "Site 1 - ${SITE_1} - Latency: ${TIME} ms" >> "${LOGFILE}"
        calculate_avg "1"

        if [ $(echo "(((${TIME} - ${SITE_1_AVG})/${SITE_1_AVG})*100) > 10" | bc -l) == "1" ]; then # we've got a problem
            $(alert "${SITE_1}" "${RAW}" "${SITE_1_AVG}")
        fi
    fi

    #####
    # Site 2
    #####
    if [ -n "${SITE_2}" ]; then
        RAW=$(poll "${SITE_2}")
        TIME=$(echo "${RAW}" | cut -d " " -f 1)
        UNITS=$(echo "${RAW}" | cut -d " " -f 2)
        if [ "${UNITS}" != "ms" ]; then # we've got a problem
            $(alert "${SITE_2}" "${RAW}" "${SITE_2_AVG}")
        fi

        ARRAY2+=("${TIME}")
        echo "Site 2 - ${SITE_2} - Latency: ${TIME} ms" >> "${LOGFILE}"
        calculate_avg "2"

        if [ $(echo "(((${TIME} - ${SITE_2_AVG})/${SITE_2_AVG})*100) > 10" | bc -l) == "1" ]; then # we've got a problem
            $(alert "${SITE_2}" "${RAW}" "${SITE_2_AVG}")
        fi
    fi

    #####
    # Site 3
    #####
    if [ -n "${SITE_3}" ]; then
        RAW=$(poll "${SITE_3}")
        TIME=$(echo "${RAW}" | cut -d " " -f 1)
        UNITS=$(echo "${RAW}" | cut -d " " -f 2)
        if [ "${UNITS}" != "ms" ]; then # we've got a problem
            $(alert "${SITE_3}" "${RAW}" "${SITE_3_AVG}")
        fi

        ARRAY3+=("${TIME}")
        echo "Site 3 - ${SITE_3} - Latency: ${TIME} ms" >> "${LOGFILE}"
        calculate_avg "3"

        if [ $(echo "(((${TIME} - ${SITE_3_AVG})/${SITE_3_AVG})*100) > 10" | bc -l) == "1" ]; then # we've got a problem
            $(alert "${SITE_3}" "${RAW}" "${SITE_3_AVG}")
        fi
    fi

    #####
    # Site 4
    #####
    if [ -n "${SITE_4}" ]; then
        RAW=$(poll "${SITE_4}")
        TIME=$(echo "${RAW}" | cut -d " " -f 1)
        UNITS=$(echo "${RAW}" | cut -d " " -f 2)
        if [ "${UNITS}" != "ms" ]; then # we've got a problem
            $(alert "${SITE_4}" "${RAW}" "${SITE_4_AVG}")
        fi

        ARRAY4+=("${TIME}")
        echo "Site 4 - ${SITE_4} - Latency: ${TIME} ms" >> "${LOGFILE}"
        calculate_avg "4"

        if [ $(echo "(((${TIME} - ${SITE_4_AVG})/${SITE_4_AVG})*100) > 10" | bc -l) == "1" ]; then # we've got a problem
            $(alert "${SITE_4}" "${RAW}" "${SITE_4_AVG}")
        fi
    fi

    #####
    # Site 5
    #####
    if [ -n "${SITE_5}" ]; then
        RAW=$(poll "${SITE_5}")
        TIME=$(echo "${RAW}" | cut -d " " -f 1)
        UNITS=$(echo "${RAW}" | cut -d " " -f 2)
        if [ "${UNITS}" != "ms" ]; then # we've got a problem
            $(alert "${SITE_5}" "${RAW}" "${SITE_5_AVG}")
        fi

        ARRAY5+=("${TIME}")
        echo "Site 5 - ${SITE_5} - Latency: ${TIME} ms" >> "${LOGFILE}"
        calculate_avg "5"

        if [ $(echo "(((${TIME} - ${SITE_5_AVG})/${SITE_5_AVG})*100) > 10" | bc -l) == "1" ]; then # we've got a problem
            $(alert "${SITE_5}" "${RAW}" "${SITE_5_AVG}")
        fi
    fi

    calculate_total_avg

    # sleep for specified interval
    sleep "${INTRVL}"

done

