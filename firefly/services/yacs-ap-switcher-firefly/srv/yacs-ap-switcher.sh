#!/bin/bash
    iw dev p2p0 del
    echo 0x03 > /proc/net/rtl8821cu/wlan0/roam_flags
    wpa_cli ap_scan 1

check_connection_status() {
    # get connection via iwconfig
    iwconfig_output=$(iwconfig)
    connected_essid=$(echo "$iwconfig_output" | awk -F '"' '/ESSID/ {print $2}')
    connected_bssid=$(echo "$iwconfig_output" | awk '/Access Point/ {print $NF}')

    if [[ "$connected_essid" == "" ]]; then
        echo "Not connected"
        sleep 10
        # @TODO, reconnect maybe.
    else
        # get signal level
        signal_level=$(iwconfig | grep "Signal level" | awk '{print $4}' | awk -F'=' '{print $2}' | awk -F'/' '{print $1}')
        signal_level_int=$(echo "$signal_level" | awk '{print int($1)}')

	#set threshold
        signal_threshold=18

        echo "Connected ESSID: $connected_essid"
        echo "Connected AP BSSID: $connected_bssid"
        echo "Signal Level: $signal_level_int"

        # If signal quality lower than 40 issue a scan per 30 seconds
        if [[ "$signal_level_int" -lt "$signal_threshold" ]]; then
            echo "Signal is low, scanning and connecting"
            wpa_cli ap_scan 1
            wpa_cli scan
            sleep 10

        else
            # If we got good signal level still check 1 secs.
            sleep 1
        fi
    fi
}

# Check connection status, starting point of the app
check_connection_status

# Daemonize
while true; do
    check_connection_status
done