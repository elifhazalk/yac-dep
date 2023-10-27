#!/bin/bash

function check_return_code() # returning anything other than 0 is failure
{
    SCRIPT_THAT_RETURNED=$1
    RETURN_CODE=$2

    if [ ${RETURN_CODE} == 0 ]
    then
        echo "script '${SCRIPT_THAT_RETURNED}' finished successfully."
    else
        echo "script '${SCRIPT_THAT_RETURNED}' failed!"
        exit -1
    fi
}


echo "====> update_slam_only START"

echo "===> pulling from ftp..."
bash ./pull_slam_only.sh ~/Workspace/Downloads
check_return_code pull_slam_only $?

echo "===> extracting pulled slam related packages..."
bash ./extract_for_slam_only.sh ~/Workspace/Downloads ~/Workspace/deploy ~/Workspace/SavedMaps
check_return_code extract_for_slam_only $?

echo "===> installing slam package into ros2_ws/install ..."
# NOTE: ros2_ws will be read from env var.
bash ./install_slam_pkg_into_ros2_ws.sh ~/Workspace/Downloads
check_return_code install_slam_pkg_into_ros2_ws $?

echo "===> copying current map folder into SavedMaps/currentMap ..."
bash ./deploy_current_map.sh ~/Workspace/SavedMaps/currentMap ~/Workspace/SavedMaps/backup_firefly_onHelmet_hue80_prot_lowAngle
check_return_code deploy_current_map $?

echo "===> deploying Configs..."
bash ./deploy_configs_slam_only.sh ~/Workspace/Downloads ~/Workspace/Configs
check_return_code deploy_configs_slam_only $?

# echo "===> deploying vocabulary ..."
# bash ./deploy_vocabulary.sh ~/Workspace/Downloads ~/Workspace/Configs/slam_node
# check_return_code deploy_vocabulary $?

echo "====> update_slam_only END"