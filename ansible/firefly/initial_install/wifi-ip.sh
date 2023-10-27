#!/bin/bash
echo "!Q2w3e4r" | adb shell nmcli -a d wifi connect SIM@
echo "!Q2w3e4r" | adb shell ifconfig | grep 10.17