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


echo "====> all-in-one script START"

echo "===> checking folder structure..."
bash ./check_workspace_folder_structure.sh
check_return_code check_workspace_folder_structure $?

echo "===> checking for required apt packages..."
bash ./check_apt_package.sh
check_return_code check_apt_package $?

echo "===> pulling from ftp..."
bash ./pull_archives_from_ftp.sh ~/mounted_volume/Workspace/Downloads
check_return_code pull_archives_from_ftp $?

echo "===> extracting pulled packages..."
bash ./extract_pulled_archives.sh ~/mounted_volume/Workspace/Downloads ~/mounted_volume/Workspace/deploy ~/mounted_volume/Workspace/SavedMaps ~/mounted_volume/Workspace/other_deployed_packages/firefly_mongo
check_return_code extract_pulled_archives $?

# echo "===> installing slam package into ros2_ws/install ..."
# # NOTE: ros2_ws will be read from env var.
# bash ./install_slam_pkg_into_ros2_ws.sh ~/mounted_volume/Workspace/Downloads
# check_return_code install_slam_pkg_into_ros2_ws $?

echo "===> copying current map folder into SavedMaps/currentMap ..."
bash ./deploy_current_map.sh ~/mounted_volume/Workspace/SavedMaps/currentMap ~/mounted_volume/Workspace/SavedMaps/backup_sideHelmet_hue_focus_60
check_return_code deploy_current_map $?

echo "===> deploying Configs..."
bash ./deploy_configs.sh ~/mounted_volume/Workspace/Downloads ~/mounted_volume/Workspace/Configs
check_return_code deploy_configs $?

echo "===> deploying vocabulary ..."
bash ./deploy_vocabulary.sh ~/mounted_volume/Workspace/Downloads ~/mounted_volume/Workspace/Configs/slam_node
check_return_code deploy_vocabulary $?

# echo "===> deploy & build ros2-custom-stack ..."
# # NOTE: ros2_ws will be read from env var.
# bash ./install_and_build_custom_stack_via_source.sh ~/Workspace/Downloads
# check_return_code install_and_build_custom_stack_via_source $?

echo "====> all-in-one script END"