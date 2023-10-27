#!/bin/bash

echo ">>> extracting pulled archives to target"

if [ "$#" -ne 2 ]; then
    # echo "Usage: $0 {Download Target DIR} {SLAM - Deploy Target DIR} {SavedMaps - Deploy Target DIR} {firefly_mongo - Deploy Target DIR}" >&2
    echo "Usage: $0 {Download Target DIR} {SavedMaps - Deploy Target DIR}" >&2
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

DOWNLOAD_TARGET=$1
# SLAM_DEPLOY_TARGET=$2
MAPS_DEPLOY_TARGET=$2
# FIREFLY_MONGO_DEPLOY_TARGET=$3
# VOCABULARY_DEPLOY_TARGET=$5

echo "DOWNLOAD_TARGET : $DOWNLOAD_TARGET"
# echo "SLAM_DEPLOY_TARGET : $SLAM_DEPLOY_TARGET"
echo "MAPS_DEPLOY_TARGET : $MAPS_DEPLOY_TARGET"
# echo "FIREFLY_MONGO_DEPLOY_TARGET : $FIREFLY_MONGO_DEPLOY_TARGET"
# echo "VOCABULARY_DEPLOY_TARGET : $VOCABULARY_DEPLOY_TARGET"

# these should be same with pull_atchives_from_ftp.sh
# TODO: read from config or .dat
# SLAM_ARCHIVE_NAME="slam_deploy.tar.gz"
SAVED_MAPS_ARCHIVE_NAME="saved_maps.tar.gz"
# FIREFLY_MONGO_ARCHIVE_NAME="firefly_mongo.tar.gz"
# VOCABULARY_ARCHIVE_NAME="vocabulary.tar.gz"

# untar archive to target TODO
if [ "$HOSTNAME" = "firefly" ]; then
    # # slam_package
    # check_folder_status ${SLAM_DEPLOY_TARGET}
    # # tar -xpzf ${DOWNLOAD_TARGET}/${SLAM_ARCHIVE_NAME} --directory ${SLAM_DEPLOY_TARGET}
    # echo "extracting -> ${SLAM_ARCHIVE_NAME}"
    # pv ${DOWNLOAD_TARGET}/${SLAM_ARCHIVE_NAME} | tar -xpzf - --directory ${SLAM_DEPLOY_TARGET} # to show progress
    # check_return_code $?

    # saved maps
    check_folder_status ${MAPS_DEPLOY_TARGET}
    echo "extracting -> ${SAVED_MAPS_ARCHIVE_NAME}"
    # tar -xpzf ${DOWNLOAD_TARGET}/${SAVED_MAPS_ARCHIVE_NAME} --directory ${MAPS_DEPLOY_TARGET}
    pv ${DOWNLOAD_TARGET}/${SAVED_MAPS_ARCHIVE_NAME} | tar -xpzf - --directory ${MAPS_DEPLOY_TARGET} # to show progress
    check_return_code $?

    # # firefly_mongo package
    # check_folder_status ${FIREFLY_MONGO_DEPLOY_TARGET}
    # echo "extracting -> ${FIREFLY_MONGO_ARCHIVE_NAME}"
    # # tar -xpzf ${DOWNLOAD_TARGET}/${SAVED_MAPS_ARCHIVE_NAME} --directory ${MAPS_DEPLOY_TARGET}
    # pv ${DOWNLOAD_TARGET}/${FIREFLY_MONGO_ARCHIVE_NAME} | tar -xpzf - --directory ${FIREFLY_MONGO_DEPLOY_TARGET} # to show progress
    # check_return_code $?

    # # vocabulary package
    # check_folder_status ${VOCABULARY_DEPLOY_TARGET}
    # pv ${DOWNLOAD_TARGET}/${VOCABULARY_ARCHIVE_NAME} | tar -xpzf - --directory ${VOCABULARY_DEPLOY_TARGET} # to show progress
elif [ "$HOSTNAME" = "ros_test" ]; then
    # saved maps
    check_folder_status ${MAPS_DEPLOY_TARGET}
    echo "extracting -> ${SAVED_MAPS_ARCHIVE_NAME}"
    # tar -xpzf ${DOWNLOAD_TARGET}/${SAVED_MAPS_ARCHIVE_NAME} --directory ${MAPS_DEPLOY_TARGET}
    pv ${DOWNLOAD_TARGET}/${SAVED_MAPS_ARCHIVE_NAME} | tar -xpzf - --directory ${MAPS_DEPLOY_TARGET} # to show progress
    check_return_code $?
else
    echo "unknown hostname, skipping extraction !"
    exit -1
fi

exit 0