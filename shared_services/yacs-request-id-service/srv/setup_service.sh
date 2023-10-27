#!/bin/bash

echo "setting up request_user_id service"

cp ./request_info_via_mac.py /var
cp ./get_ip.sh /var
cp ./custom_env_vars_source /var
cp ./custom_env_vars.sh /etc/profile.d
cp ./yacs-request-user-id.service /etc/systemd/system
systemctl enable yacs-request-user-id.service
systemctl daemon-reload

echo "FIN."
