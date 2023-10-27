#!/bin/bash

echo "setting up ros middleware profile..."

if [ -z "$1" ]; then
    VERSION="latest"
else
    VERSION="$2"
fi

echo "using version: $VERSION"

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

function check_env_variable() {
  local variable_name="$1"

  if [[ -z "${!variable_name}" ]]; then
    echo "Error: Environment variable '$variable_name' is not set."
    exit 1
  fi
}

# returning anything other than 0 is failure
function check_return_code() 
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

## check env var & folders
check_env_variable "CONFIGS_DIR"
check_return_code $?

CONFIG_FILE="localhost_only.xml"
CONFIG_TARGET="$CONFIGS_DIR/ros_middleware_config"

check_folder_status $CONFIG_TARGET
check_return_code $?

## setup config
echo "copying config profile to '$CONFIG_TARGET'"
cp $CONFIG_FILE $CONFIG_TARGET

# check_return_code $?
echo "FIN (setup.sh)"