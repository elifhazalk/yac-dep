#!/bin/bash

echo ">>> deploying current map..."

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 {current map deploy target} {map folder full path}" >&2
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

DEPLOY_TARGET=$1
MAP_FOLDER=$2
echo "DEPLOY_TARGET : ${DEPLOY_TARGET}"
echo "MAP_FOLDER : ${MAP_FOLDER}"

# check if map folder to be copied exits
if [ ! -d "${MAP_FOLDER}" ]
then
    echo "ERROR -> map folder ${MAP_FOLDER} does not exist, exiting..."
    exit -1
fi

# copy map folder contents to target
if [ "$HOSTNAME" = "firefly" ]; then
    # slam_package
    check_folder_status ${DEPLOY_TARGET}
    cp -r ${MAP_FOLDER}/* ${DEPLOY_TARGET}
    check_return_code $?
elif [ "$HOSTNAME" = "ros_test" ]; then
    # slam_package
    check_folder_status ${DEPLOY_TARGET}
    cp -r ${MAP_FOLDER}/* ${DEPLOY_TARGET}
    check_return_code $?
else
    echo "unknown hostname, skipping extraction !"
    exit -1
fi

echo ">>> FIN ?"
exit 0