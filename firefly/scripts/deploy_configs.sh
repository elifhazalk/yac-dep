#!/bin/bash

echo ">>> deploying config packages to target"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 {Download Target DIR} {Configs Target DIR}" >&2
  exit 1
fi

function check_folder_status()
{
    TARGET_FOLDER=$1 # this should be full path

    # create if folder not exists
    if [ ! -d "${TARGET_FOLDER}" ]
    then
        echo "folder ${TARGET_FOLDER} does not exist, creating..."
        mkdir -p ${TARGET_FOLDER}
    fi
}

function check_source_archive()
{
    ARCHIVE_DIR=$1
    ARCHIVE_NAME=$2

    # if archives exist at target, delete them
    if [ -f "${ARCHIVE_DIR}/${ARCHIVE_NAME}" ]; then
        echo "archive '${ARCHIVE_NAME}' found in '${ARCHIVE_DIR}'"
    else
        echo "archive '${ARCHIVE_NAME}' NOT FOUND in '${ARCHIVE_DIR}'"
        exit -1
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

DOWNLOAD_TARGET=$1
CONFIGS_DEPLOY_DIR=$2

echo "DOWNLOAD_TARGET : $DOWNLOAD_TARGET"
echo "CONFIGS_DEPLOY_DIR : $CONFIGS_DEPLOY_DIR"


## slam_node config
SLAM_CONFIG_ARCHIVE_NAME="slam_config.tar.gz"
SLAM_CONFIG_DEPLOY_TARGET=${CONFIGS_DEPLOY_DIR}/slam_node
check_source_archive $DOWNLOAD_TARGET ${SLAM_CONFIG_ARCHIVE_NAME}
check_folder_status ${SLAM_CONFIG_DEPLOY_TARGET}
## gpio config
GPIO_CONFIG_ARCHIVE_NAME="gpio_config.tar.gz"
GPIO_CONFIG_DEPLOY_TARGET=${CONFIGS_DEPLOY_DIR}/gpio_node
check_source_archive $DOWNLOAD_TARGET ${GPIO_CONFIG_ARCHIVE_NAME}
check_folder_status ${GPIO_CONFIG_DEPLOY_TARGET}

# untar archive to target
if [ "$HOSTNAME" = "firefly" ]; then
    # slam config
    echo "extracting -> ${SLAM_CONFIG_ARCHIVE_NAME}"
    pv ${DOWNLOAD_TARGET}/${SLAM_CONFIG_ARCHIVE_NAME} | tar -xpzf - --directory ${SLAM_CONFIG_DEPLOY_TARGET} # to show progress
    check_return_code $?

    # gpio config
    echo "extracting -> ${GPIO_CONFIG_ARCHIVE_NAME}"
    pv ${DOWNLOAD_TARGET}/${GPIO_CONFIG_ARCHIVE_NAME} | tar -xpzf - --directory ${GPIO_CONFIG_DEPLOY_TARGET} # to show progress
    check_return_code $?
elif [ "$HOSTNAME" = "ros_test" ]; then
    # slam config
    echo "extracting -> ${SLAM_CONFIG_ARCHIVE_NAME}"
    pv ${DOWNLOAD_TARGET}/${SLAM_CONFIG_ARCHIVE_NAME} | tar -xpzf - --directory ${SLAM_CONFIG_DEPLOY_TARGET} # to show progress
    check_return_code $?

    # gpio config
    echo "extracting -> ${GPIO_CONFIG_ARCHIVE_NAME}"
    pv ${DOWNLOAD_TARGET}/${GPIO_CONFIG_ARCHIVE_NAME} | tar -xpzf - --directory ${GPIO_CONFIG_DEPLOY_TARGET} # to show progress
    check_return_code $?
else
    echo "unknown hostname, skipping extraction !"
    exit -1
fi

exit 0