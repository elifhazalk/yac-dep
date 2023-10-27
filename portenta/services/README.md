## YACS Network Service

This is a service that runs on portenta devices and establishes connection to the YACS IOT wifi network. It also enables hot-spot mode if the device cannot connect to the network after 3 attempts with name `Hotspot-{MACADDRESSS}` and password `123456ex`.

You can find wifi network SSID and password in the `yacs-network.sh` file. The defaults values are hardcoded and should be treated as portenta device would have no wifi connection profile.

### Installation

`yacs-network.sh` file should be copied to `/var` directory on the device. Then it should be made executable by running `chmod +x /yacs-network.sh` or `chmod 777 /yacs-network.sh`.

`yacs-network.service` file should be copied to `/etc/systemd/system` directory on the device. 
Then it should be enabled by running `systemctl enable yacs-network.service`.

If `yacs-network.sh` gets any changes, service daemon should be reloaded by running `systemctl daemon-reload` and service should be enabled by running `systemctl enable yacs-network.service` again.
