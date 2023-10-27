#!/bin/bash

echo "setting up ntp-sync service"

cp ./setup-ntp-config.sh /var
cp ./script_runner.py /var
cp ./yacs-ntp-sync.service /etc/systemd/system
systemctl enable yacs-ntp-sync.service
systemctl daemon-reload

echo "FIN."
