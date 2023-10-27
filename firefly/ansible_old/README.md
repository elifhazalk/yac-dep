First Setup General Flow:

1. create user
```
adduser svrn # brings up prompt
usermod -aG sudo svrn
```

2. create gpio group & add svrn user to it
```
addgroup gpio
usermod -aG gpio svrn
```

camera permission
```
usermod -aG video svrn
```

dialout (serial port) permission
```
usermod -aG dialout svrn
```

3. connect to wifi
```
nmcli r wifi on
nmcli dev wifi connect SCAP@ password \!Qaz2wsx\! # connect to SCAP@
apt update -y && apt upgrade -y
```

4. update device tree blob & reboot \
Clickup link for <device_tree_file>: https://app.clickup.com/36243145/v/dc/12j1p9-4580/12j1p9-15680
```
mount /dev/mmcblk0p3 /mnt
cd /mnt
mv <device_tree_file> # move device tree .dtb file here by removing or renaming old one
umount /mnt
reboot
```

5. setup gpio permissions \
Add to: `/etc/udev/rules.d/80-gpio-permission.rules` 
```
SUBSYSTEM=="gpio", KERNEL=="gpiochip1", ACTION=="add", PROGRAM="/bin/sh -c 'chmod g+rw /dev/gpiochip1 && chgrp gpio /dev/gpiochip1'"
SUBSYSTEM=="gpio", KERNEL=="gpiochip1", GROUP="gpio", MODE="0660"
```
Then, either reboot or :
```
sudo udevadm control --reload-rules && sudo service udev restart && sudo udevadm trigger
```


6. install ros ->  (in ansible) \
TODO: add to ansible -> apt install install ros-foxy-cv-bridge ros-dev-tools
```bash
# ros2 installation (from: [Ubuntu (Debian) — ROS 2 Documentation: Foxy documentation](https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html))
sudo apt update -y && sudo apt install locales -y
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

sudo apt install software-properties-common -y
sudo add-apt-repository universe

sudo apt update -y && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update -y && sudo apt upgrade -y

sudo apt install ros-foxy-ros-base python3-argcomplete ros-dev-tools ros-foxy-cv-bridge -y

# create workspace and init
mkdir -p ~/Workspace/ros2_ws/src
cd ~/Workspace/ros2_ws
colcon build
```

7. install nvm & node v8.9.0 ->  (in ansible)
```bash
# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
# source after install
exec bash
# install node
nvm install 8.9.0
```

9. setup bashrc config -> (in ansible) \
current example bashrc additions:
```
echo "bashrc -> start"
export ROS1_INSTALL_PATH=/opt/ros/noetic
export ROS2_INSTALL_PATH=/opt/ros/foxy
source /opt/ros/foxy/setup.bash
export _colcon_cd_root=/opt/ros/foxy/
source /usr/share/colcon_cd/function/colcon_cd.sh
export ROS_DOMAIN_ID=3
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
export SSL_CERT_FILE=/usr/lib/ssl/certs/ca-certificates.crt
export ROS2_WS=${HOME}/Workspace/ros2_ws
source ${ROS2_WS}/install/setup.bash
#source ${HOME}/Workspace/ros2_ws/install/setup.bash
export PATH="$PATH:/$HOME/.local/bin"
#export ROS_DISCOVERY_SERVER="127.0.0.1:11811"
#export FASTRTPS_DEFAULT_PROFILES_FILE=${HOME}/dds_config/discovery_server_configuration_file.xml
#export DISPLAY=2.12.100.112:0.0
#export DISPLAY=:0
export DEVICE_ID=1
export CONFIGS_DIR=${HOME}/Workspace/Configs
export SAVED_MAPS_DIR=${HOME}/Workspace/SavedMaps
export OUTPUTS_DIR=${HOME}/Outputs
export BLE_DEVICE_ADDRESS=f9:10:4b:e0:dc:4e
export ORCHESTRATOR_MODE=2 # server=1, edge=2
echo "bashrc -> end"
```

9. setup workspace folder structure with scripts
```
exec bash # to source ros2_ws after setting up workspace
# necessery packages
sudo apt install pv ncftp
# clone yacs-deployment
cd ~/Workspace && git clone https://github.com/sav-ddg/yacs-deployment.git
# run setup script
cd ~/Workspace/yacs-deployment/firefly/scripts
bash ./extract_and_pull_all_in_one.sh
# also install services (wifi & ntp)
```

10. ntp config
