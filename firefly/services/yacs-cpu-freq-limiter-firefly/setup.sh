# service files should be under 'srv' folder
# setup.sh should be under yacs-cpu-freq-limiter-service folder

#!/bin/bash

echo "setting up yacs-cpu-freq-limiter service ..."

if [ -z "$1" ]; then
    VERSION="latest"
else
    VERSION="$2"
fi

echo "using version: $VERSION"

function check_archive_status()
{
    ARCHIVE_TARGET=$1

    # if archives exist at target, delete them
    if [ -f "${ARCHIVE_TARGET}" ]; then
        echo "old archive found, deleting..."
        echo "1234" | sudo -S rm -f ${ARCHIVE_TARGET}
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

function extract_archive() {
  local source_folder="$1"    # Path to the folder containing the archive
  local target_folder="$2"    # Path to the folder where the archive will be extracted
  local archive_name="$3"     # Name of the archive file

  local archive_path="$source_folder/$archive_name"

  if [ -f "$archive_path" ]; then
    tar -xzvf "$archive_path" -C "$target_folder"
  else
    echo "Archive not found: $archive_path"
  fi
}


## setup service
cd srv
./setup_service.sh

# check_return_code $?
echo "FIN (setup.sh)"