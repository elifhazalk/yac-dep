NETWORK_NAME="SIM@"
PASSWORD="!Q2w3e4r"

SERVER="10.17.10.2"
PORT=2626

HOTSPOT_PASSWORD="123456ex"

counter=1

send_mac_ip_address_to_server() {
  # Get the WLAN interface, MAC address, IP address, and current date and time
  local wlan_interface=$(iw dev | awk '$1=="Interface"{print $2}')
  local mac_address=$(cat /sys/class/net/$wlan_interface/address)
  local ip_address=$(ip addr show $wlan_interface | grep -Eo 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}')
  local current_datetime=$(date)

  # Send the MAC address and IP address to the server
  echo "PORTENTA: {$current_datetime} | MAC address: {$mac_address} | IP address: {$ip_address}" > /dev/tcp/$SERVER/$PORT
}

# if current connection is a hotspot connection, disable it first
CURRENT_NETWORK=$(nmcli connection show --active | grep wifi | awk "{print $1}" | cut -d ' ' -f 1)
if [[ $CURRENT_NETWORK =~ ^Hotspot.* ]]; then
    nmcli connection down $CURRENT_NETWORK
fi

while [ $counter -le 3 ]
do
    # check if wifi is enabled and connected to any wifi network
    if nmcli radio wifi | grep -q enabled && nmcli connection show | grep -q wifi; then
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
            nmcli device wifi connect "$NETWORK_NAME" password "$PASSWORD"

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
                    echo "Ping to $SERVER failed after new connection try. Enabling hotspot."
                    # TODO: Enable hotspot
                    WLAN_INTERFACE=$(iw dev | awk '$1=="Interface"{print $2}')
                    MAC_ADDRESS=$(cat /sys/class/net/$WLAN_INTERFACE/address)
    
                    HOTSPOT_NAME="Hotspot-$MAC_ADDRESS"

                    nmcli device wifi hotspot con-name "$HOTSPOT_NAME" ssid "$HOTSPOT_NAME" password "$HOTSPOT_PASSWORD"
                    sleep 300
                else
                    counter=$((counter+1))
                    echo "Unable to connect to wifi network. Attempting to reconnect."
                    sleep 3
                fi
            fi
        fi
    else
        nmcli radio wifi
    fi
done

exit 0
