#!/bin/bash

# TODO: this script is old, needs updating if it will be used. Instead of this, ansible may be used ?

exit 1

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {'init' || 'update'}" >&2
  exit 1
fi
echo ">> setting up ros2 and slam workspace"

MODE=$1
echo "MODE : ${MODE}"

SCRIPTS_DIR="/home/svrn/Workspace/Scripts"
ROS2_WS_DIR="/home/svrn/Workspace/ros2_ws"
ARCHIVE_DOWNLOAD_TARGET="/home/svrn/Workspace/Downloads"

## packages to deploy
SLAM_DEPLOY_DIR="/home/svrn/Workspace/deploy"
SAVED_MAPS_DEPLOY_DIR="/home/svrn/Workspace/SavedMaps"
FIREFLY_MONGO_DEPLOY_DIR="/home/svrn/Workspace/firefly_mongo"

function check_folder_status()
{
    TARGET_FOLDER=$1 # this should be full path

    # create if folder not exists
    if [ ! -d "${TARGET_FOLDER}" ]
    then
        echo "folder ${TARGET_FOLDER} does not exist, creating..."
        mkdir -p ${TARGET_FOLDER}
    else
        echo "folder ${TARGET_FOLDER} does exist, continuing"
    fi
}

function check_return_code() # returning anything other than 0 is failure
{
    RETURN_CODE=$1

    if [ ${RETURN_CODE} == 0 ]
    then
        echo "command succeeded"
    else
        echo "command failed."
        exit -1
    fi
}

cd ${SCRIPTS_DIR}

# pull from git
echo "> setting up ros2 workspace"

# check ROS2_WS -> TODO
check_folder_status "${ROS2_WS_DIR}/src"

cd ${ROS2_WS_DIR}/src
if [ "${MODE}" == "init" ]
then
    echo "initializing ros2-custom-stack"
    if [ -d ros2-custom-stack ]
    then
        echo "ros2-custom-stack already exits, deleting..."
        echo "1234" | sudo -S rm -rf ros2-custom-stack
    fi
    git clone https://github.com/sav-ddg/yacs-orion.git ros2-custom-stack
    cd ros2-custom-stack
    bash ./colcon_build_stack.sh
elif [ "${MODE}" == "update" ]
then
    echo "updating ros2_ws"
    cd ros2-custom-stack
    git pull
    bash ./colcon_build_stack.sh
else
    echo "unknown mode, exiting..."
    exit 1
fi

# move back to scripts DIR
echo "> moving back to Scripts DIR"
cd ${SCRIPTS_DIR}

if [ "${MODE}" == "init" ] || [ "${MODE}" == "update" ]
then
    # pull slam package from ftp
    echo "> pulling slam deploy package from ftp"
    bash ${SCRIPTS_DIR}/pull_archives_from_ftp.sh ${ARCHIVE_DOWNLOAD_TARGET}
    # untar package to deploy target (Workspace/deploy)
    echo "> un-tar slam package to Workspace/deploy"
    bash ${SCRIPTS_DIR}/extract_pulled_archives.sh ${ARCHIVE_DOWNLOAD_TARGET} ${SLAM_DEPLOY_DIR} ${SAVED_MAPS_DEPLOY_DIR} ${FIREFLY_MONGO_DEPLOY_DIR}
else
    echo "unknown mode, exiting..."
    exit 1
fi

