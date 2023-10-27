#!/bin/bash

echo "setting up service..."

ROOT_DIR="$PWD"
echo "ROOT_DIR: ${ROOT_DIR}"

echo "1234" | sudo -S cp ./yacs-network-firefly.sh /var
cd /var
echo "1234" | sudo -S chmod +x yacs-network-firefly.sh

cd $ROOT_DIR
echo "1234" | sudo -S cp ./yacs-network.service /etc/systemd/system
echo "1234" | sudo -S systemctl enable yacs-network.service

echo "1234" | sudo -S systemctl daemon-reload



echo "FIN."
