#!/bin/bash

echo "setting up service..."

ROOT_DIR="$PWD"
echo "ROOT_DIR: ${ROOT_DIR}"

cp ./yacs-ap-switcher.sh /var
cd /var
chmod +x yacs-ap-switcher.sh

cd $ROOT_DIR
cp ./yacs-ap-switcher.service /etc/systemd/system
systemctl enable yacs-ap-switcher.service
systemctl daemon-reload

echo "FIN."
