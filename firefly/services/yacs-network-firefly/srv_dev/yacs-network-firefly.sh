NETWORK_NAME="SCAP@"
PASSWORD="!Qaz2wsx!"

SERVER="2.12.100.112"
PORT=2626

# NETWORK_NAME="SIM@"
# PASSWORD="!Q2w3e4r"

# SERVER="10.17.100.5"
# PORT=2626

HOTSPOT_PASSWORD="123456ex"

counter=1

get_device_name(){
    local wlan_interface=$(ip route show default | awk '/default/ {print $5}')
    local mac_address=$(cat /sys/class/net/$wlan_interface/address) 
    local DEVICE_NAME="Firefly_"${mac_address}

    echo $DEVICE_NAME
}

get_device_name_wlan0(){
    local wlan_interface="wlan0"
    local mac_address=$(cat /sys/class/net/$wlan_interface/address) 
    local DEVICE_NAME="Firefly_"${mac_address}

    echo $DEVICE_NAME
}

# if no parameter given after function call, result will only be printed
# source: https://stackoverflow.com/a/13322667/15096506
get_my_ip(){
    local _ip _myip _line _nl=$'\n'
    while IFS=$': \t' read -a _line ;do
        [ -z "${_line%inet}" ] &&
           _ip=${_line[${#_line[1]}>4?1:2]} &&
           [ "${_ip#127.0.0.1}" ] && _myip=$_ip
      done< <(LANG=C /sbin/ifconfig)
    printf ${1+-v} $1 "%s${_nl:0:$[${#1}>0?0:1]}" $_myip
}

send_mac_ip_address_to_server() {
    # Get the WLAN interface, MAC address, IP address, and current date and time
    local wlan_interface=$(ip route show default | awk '/default/ {print $5}')
    local mac_address=$(cat /sys/class/net/$wlan_interface/address)
    local ip_address=$(get_my_ip)
    local current_datetime=$(date)

    local DEVICE_NAME=$(get_device_name)

    # Send the MAC address and IP address to the server
    echo "{$DEVICE_NAME}: {$current_datetime} | MAC address: {$mac_address} | IP address: {$ip_address}" > /dev/tcp/$SERVER/$PORT
}

# if current connection is a hotspot connection, disable it first
CURRENT_NETWORK=$(nmcli connection show --active | grep wifi | awk "{print $1}" | cut -d ' ' -f 1)
if [[ $CURRENT_NETWORK =~ ^Hotspot.* ]]; then
    nmcli connection down $CURRENT_NETWORK
fi

while [ $counter -le 3 ]
do
    # check if wifi is enabled and connected to any wifi network
    if nmcli radio wifi | grep -q enabled; then
        if nmcli connection show | grep -q wifi
        then
            echo "Wi-Fi is enabled and a connection is set up."
            # check if SSID of current network is same as NETWORK_NAME
            if nmcli connection show --active | grep "^$NETWORK_NAME"; then
                echo "Device is connected to right network: $NETWORK_NAME"
                if ping -c 1 $SERVER >/dev/null; then
                    echo "Ping to $SERVER successful."
                    send_mac_ip_address_to_server
                fi
                counter=5
            else
                echo "Connected to the wrong network."
                WIFI_NETWORK=$(nmcli connection show --active | grep wifi | awk "{print $1}" | cut -d ' ' -f 1)
                echo "Device is connected to wrong network: $WIFI_NETWORK. Attempting to connect correct network: $NETWORK_NAME"
                nmcli connection down $WIFI_NETWORK

                # Connect to right network
                nmcli dev wifi rescan
                sleep 10
                # make sure to connect via wlan0 interface (instead of p2p0)
                nmcli device wifi connect "$NETWORK_NAME" password "$PASSWORD" ifname wlan0

                #Wait for the connection to be established
                echo "Waiting for connection to $NETWORK_NAME network..."
                sleep 10

                if nmcli connection show --active | grep "^$NETWORK_NAME"; then
                    echo "Device is connected to right network: $NETWORK_NAME"
                    # Try to ping server again
                    if ping -c 1 $SERVER >/dev/null; then
                        echo "Ping to $SERVER successful."
                        send_mac_ip_address_to_server
                    fi
                    counter=5
                else
                    if [ $counter -gt 2 ]
                    then
                        echo "Ping to $SERVER failed after re-try, enabling hotspot"
                        # Enable hotspot
        
                        DEVICE_NAME=$(get_device_name_wlan0)
                        HOTSPOT_NAME=$DEVICE_NAME

                        nmcli device wifi hotspot con-name "$HOTSPOT_NAME" ssid "$HOTSPOT_NAME" password "$HOTSPOT_PASSWORD"
                        nmcli con modify $HOTSPOT_NAME 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
                        nmcli con up $HOTSPOT_NAME
                        sleep 300
                    else
                        counter=$((counter+1))
                        echo "Unable to connect to wifi network. Attempting to reconnect."
                        sleep 3
                    fi
                fi
            fi
        else
            # wifi enabled but no connection exists yet, create it
            nmcli dev wifi rescan
            sleep 10
            # make sure to connect via wlan0
            nmcli device wifi connect "$NETWORK_NAME" password "$PASSWORD" ifname wlan0
            sleep 10
            # increment counter ?
        fi
    else
        nmcli radio wifi
    fi
done

exit 0
