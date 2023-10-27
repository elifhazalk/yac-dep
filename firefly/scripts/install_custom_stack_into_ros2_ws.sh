#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {Download Target DIR}" >&2
  exit 1
fi

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

DOWNLOAD_TARGET=$1
echo "DOWNLOAD_TARGET : $DOWNLOAD_TARGET"

## check ros2_ws env variable
ROS2_INSTALL_DIR=""
if [[ -z "${ROS2_WS}" ]]; then
  # ROS2_WS env variable not set
  echo "ROS2_WS env variable not set, exiting..."
  exit 1
else
  echo "ROS2_WS: ${ROS2_WS}"
  ROS2_INSTALL_DIR="${ROS2_WS}/install"
  echo "ROS2_INSTALL_DIR: ${ROS2_INSTALL_DIR}"
fi

echo "installing stack packages into $ROS2_INSTALL_DIR directly..."

## check target dir (slam_ros_pkg)
TARGET_DIR="${ROS2_WS}/install"
echo "TARGET_DIR : ${TARGET_DIR}"
if [ ! -d ${TARGET_DIR} ];
then
    echo "TARGET_DIR not found, creating..."
    mkdir -p ${TARGET_DIR}
else
    echo "TARGET_DIR found, continuing..."
fi

CUSTOM_STACK_ARCHIVE_NAME="ros2_custom_stack_firefly_direct_install.tar.gz"
## extract into ros2 install dir
echo "extracting -> ${CUSTOM_STACK_ARCHIVE_NAME}"
pv ${DOWNLOAD_TARGET}/${CUSTOM_STACK_ARCHIVE_NAME} | tar -xpzf - --directory ${TARGET_DIR} # to show progress
check_return_code $?

## TODO: check each folder after deploy??

exit 0

