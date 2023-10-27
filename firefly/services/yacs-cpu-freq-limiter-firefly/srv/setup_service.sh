#!/bin/bash

echo "setting up yacs-cpu-freq-limiter service..."

ROOT_DIR="$PWD"
echo "ROOT_DIR: ${ROOT_DIR}"

echo "1234" | sudo -S cp ./yacs-cpu-freq-limiter.sh /var
cd /var
echo "1234" | sudo -S chmod +x yacs-cpu-freq-limiter.sh

cd $ROOT_DIR
echo "1234" | sudo -S cp ./yacs-cpu-freq-limiter.service /etc/systemd/system
echo "1234" | sudo -S systemctl enable yacs-cpu-freq-limiter.service

echo "1234" | sudo -S systemctl daemon-reload



echo "FIN."
