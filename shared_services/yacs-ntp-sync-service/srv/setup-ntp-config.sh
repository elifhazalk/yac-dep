#!/bin/bash

TIMESYNC_CONF="/etc/systemd/timesyncd.conf"
NTP_CONF_STRING="NTP=VMYACSDOC"
NTP_MATCH_CASE="NTP="

# Extract the arguments
file_name=$TIMESYNC_CONF
string_to_find=$NTP_MATCH_CASE
replacement_string=$NTP_CONF_STRING

function setup_timezone(){
    # setup timezone
    HOST_NAME=$(hostname)
    if [[ $HOST_NAME == *"portenta"* ]]; then
        echo "device is a portenta, skip setting up timezone..."
    elif [[ $HOST_NAME == *"firefly"* ]]; then
        echo "device is firefly, setting up timezone..."
        timedatectl set-timezone Europe/Istanbul
    fi
}

function make_backup(){
    # make backup
    cp $TIMESYNC_CONF $TIMESYNC_CONF.bak
}


function setup_custom_ntp(){
    # Check if the file exists
    if [ ! -f "$file_name" ]; then
        echo "Error: File '$file_name' does not exist."
        exit 1
    fi

    # Remove lines with matching string if they are not already commented
    grep -q "$string_to_find" "$file_name" && \
    sed -i "/^$string_to_find/ { /^#/! d; }" "$file_name"

    # Remove duplicate lines matching the replacement string (commented or not)
    awk '!seen[$0]++' "$file_name" > "$file_name.tmp"
    mv "$file_name.tmp" "$file_name"

    # Append the replacement string
    echo "$replacement_string" >> "$file_name"

    echo "Successfully edited file '$file_name'."
}


## backup old file
make_backup
## perform setup
setup_custom_ntp
setup_timezone
## force re-sync
systemctl restart systemd-timesyncd.service

# TODO: check results at each step?
exit 0