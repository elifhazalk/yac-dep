#!/bin/bash

# TODO:
# - IMPORTANT: make folder paths into variables
# - IMPORTANT: use return codes to stop this script if any subscript fails
# - check target folders under Workspace, if they do not exist, create them -> new script
# - pull & extract Configs folder also (has both slam_node and any other node configs under it, update individual nodes from their own folder, target will be Configs/<node>)
# - TODO: new script -> send from server to device without running scripts from device


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


echo "====> all-in-one script START"

echo "===> checking folder structure..."
bash ./check_workspace_folder_structure.sh
check_return_code check_workspace_folder_structure $?

echo "===> checking for required apt packages..."
bash ./check_apt_package.sh
check_return_code check_apt_package $?

echo "===> pulling from ftp..."
bash ./pull_archives_from_ftp.sh ~/Workspace/Downloads
check_return_code pull_archives_from_ftp $?

echo "===> extracting pulled packages..."
bash ./extract_pulled_archives.sh ~/Workspace/Downloads ~/Workspace/SavedMaps
check_return_code extract_pulled_archives $?

echo "===> installing slam package into ros2_ws/install ..."
# NOTE: ros2_ws will be read from env var.
bash ./install_slam_pkg_into_ros2_ws.sh ~/Workspace/Downloads
check_return_code install_slam_pkg_into_ros2_ws $?

echo "===> copying current map folder into SavedMaps/currentMap ..."
bash ./deploy_current_map.sh ~/Workspace/SavedMaps/currentMap ~/Workspace/SavedMaps/backup_sideHelmet_hue_focus_60
check_return_code deploy_current_map $?

echo "===> deploying Configs..."
bash ./deploy_configs.sh ~/Workspace/Downloads ~/Workspace/Configs
check_return_code deploy_configs $?

echo "===> deploying vocabulary ..."
bash ./deploy_vocabulary.sh ~/Workspace/Downloads ~/Workspace/Configs/slam_node
check_return_code deploy_vocabulary $?

# echo "===> deploying ros2-custom-stack via direct installation ..."
# # NOTE: ros2_ws will be read from env var.
# bash ./install_custom_stack_into_ros2_ws.sh ~/Workspace/Downloads
# check_return_code install_custom_stack_into_ros2_ws $?

echo "===> deploy & build ros2-custom-stack ..."
# NOTE: ros2_ws will be read from env var.
bash ./install_and_build_custom_stack_via_source.sh ~/Workspace/Downloads
check_return_code install_and_build_custom_stack_via_source $?

echo "====> all-in-one script END"