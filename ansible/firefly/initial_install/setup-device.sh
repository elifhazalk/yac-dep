#!/bin/bash

# Create gpio group & add svrn user to it
sudo addgroup gpio
sudo usermod -a -G gpio svrn

# Camera permission
sudo usermod -a -G video svrn

# Dialout (serial port) permission
sudo usermod -a -G dialout svrn

# Permanently disable p2p0 interface
echo 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="p2p0", ENV{NM_UNMANAGED}="1"' | sudo tee /etc/udev/rules.d/00-nta1000-net.rules

# Update device tree blob & reboot
mkdir -p ~/Downloads && cd ~/Downloads
sudo wget --user=svrn --password=S%*^WZUht^RGz\!PXHC6ymF\!Da%4 "ftp://10.17.100.2/Deploy/firefly/recompiled_device_trees/4_gpio_pin_added/roc-rk3588s-pc.dtb"
sudo mount /dev/mmcblk0p3 /mnt
sudo mv /mnt/roc-rk3588s-pc.dtb /mnt/roc-rk3588s-pc.dtb.original
sudo cp ~/Downloads/roc-rk3588s-pc.dtb /mnt/roc-rk3588s-pc.dtb
sudo umount /mnt
sudo reboot
