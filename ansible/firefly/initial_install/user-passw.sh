#!/bin/bash
sudo useradd -m -d /home/svrn -s /bin/bash -c 'SVRN User' svrn
sudo usermod -a -G sudo svrn
echo -e "1234\n1234" | passwd svrn
#groupmod -g 1001 svrn
sudo mv svrn /etc/sudoers.d/
sudo reboot