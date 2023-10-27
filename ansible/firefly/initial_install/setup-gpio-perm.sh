
# Setup gpio permissions
echo 'SUBSYSTEM=="gpio", KERNEL=="gpiochip1", ACTION=="add", PROGRAM="/bin/sh -c '\''chmod g+rw /dev/gpiochip1 && chgrp gpio /dev/gpiochip1'\''"' | sudo tee /etc/udev/rules.d/80-gpio-permission.rules
sudo udevadm control --reload-rules
sudo service udev restart
sudo udevadm trigger

# Set Bluetooth permission
sudo setcap cap_net_raw+eip $(eval readlink -f `which node`)

# Network Setup (replace with the actual network setup command)
nmcli dev wifi connect SIM@ password \!Q2w3e4r ifname wlan0
