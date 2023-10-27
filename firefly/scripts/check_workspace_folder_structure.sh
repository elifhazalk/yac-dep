#!/bin/bash

echo ">>> checking Workspace folder structure..."

function check_folder_status()
{
    TARGET_FOLDER=$1 # this should be full path

    # create if folder not exists
    if [ ! -d "${TARGET_FOLDER}" ]
    then
        echo "folder ${TARGET_FOLDER} does not exist, creating..."
        mkdir -p ${TARGET_FOLDER}
    else
        echo "folder ${TARGET_FOLDER} exists, NICE"
    fi
}

# env vars : CONFIGS_DIR, SAVED_MAPS_DIR
CONFIGS_DIR_LOCAL=$CONFIGS_DIR
MAPS_DIR=$SAVED_MAPS_DIR

## check if empty (in case env vars not set)
# config
if [ -z "${CONFIGS_DIR_LOCAL}" ]
then
    echo "${CONFIGS_DIR_LOCAL} was empty, env var may not be set, will use ~/Workspace/Configs folder as default"
    CONFIGS_DIR_LOCAL=$HOME/Workspace/Configs
fi
# maps
if [ -z "${MAPS_DIR}" ]
then
    echo "${MAPS_DIR} was empty, env var may not be set, will use ~/Workspace/SavedMaps folder as default"
    MAPS_DIR=$HOME/Workspace/SavedMaps
fi


DOWNLOADS_DIR=$HOME/Workspace/Downloads
OTHER_PACKAGES_DIR=$HOME/Workspace/other_deployed_packages
SCRIPTS_DIR=$HOME/Workspace/Scripts

if [ "$HOSTNAME" == "ros_test" ]; then
    DOWNLOADS_DIR=$HOME/mounted_volume/Workspace/Downloads
    OTHER_PACKAGES_DIR=$HOME/mounted_volume/Workspace/other_deployed_packages
    SCRIPTS_DIR=$HOME/mounted_volume/Workspace/Scripts
    CONFIGS_DIR_LOCAL=$HOME/mounted_volume/Workspace/Configs
    MAPS_DIR=$HOME/mounted_volume/Workspace/SavedMaps
fi


check_folder_status ${CONFIGS_DIR_LOCAL}
check_folder_status ${SAVED_MAPS_DIR}
check_folder_status ${DOWNLOADS_DIR}
check_folder_status ${OTHER_PACKAGES_DIR}
check_folder_status ${SCRIPTS_DIR}

exit 0