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
        exit 1
    fi
}

function does_folder_exist(){
    DIR=$1

    if [ ! -d ${DIR} ];
    then
        echo "'$DIR' not found !"
        return 1
    else
        echo "'$DIR' found, continuing..."
        return 0
    fi
}

DOWNLOAD_TARGET=$1
echo "DOWNLOAD_TARGET : $DOWNLOAD_TARGET"

## check ros2_ws env variable
ROS2_SRC_DIR=""
if [[ -z "${ROS2_WS}" ]]; then
  # ROS2_WS env variable not set
  echo "ROS2_WS env variable not set, exiting..."
  exit 1
else
  echo "ROS2_WS: ${ROS2_WS}"
  ROS2_SRC_DIR="${ROS2_WS}/src"
  echo "ROS2_SRC_DIR: ${ROS2_SRC_DIR}"
fi

echo "installing stack packages into $ROS2_SRC_DIR"

CUSTOM_STACK_ARCHIVE_NAME="ros2_custom_stack_firefly_source.tar.gz"
## extract into ros2 install dir
echo "extracting -> ${CUSTOM_STACK_ARCHIVE_NAME}"
pv ${DOWNLOAD_TARGET}/${CUSTOM_STACK_ARCHIVE_NAME} | tar -xpzf - --directory ${ROS2_SRC_DIR} # to show progress
check_return_code $?

## check if folder exists where it should be
TARGET_DIR=$ROS2_SRC_DIR/ros2-custom-stack
echo "TARGET_DIR : ${TARGET_DIR}"
does_folder_exist $TARGET_DIR
check_return_code $?


## build deps
echo "building serial_communicator deps"
cd $TARGET_DIR/serial_communicator
bash ./initial_setup.sh
check_return_code $?


## build stack
echo "building stack packages"
cd $TARGET_DIR
bash ./colcon_build_stack.sh
check_return_code $?

exit 0

