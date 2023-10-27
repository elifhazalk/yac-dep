#!/bin/bash
echo -e ">>> deploying to ftp server ... \n"

function check_folder_status()
{
    TARGET_FOLDER=$1 # this should be full path

    # create if folder not exists
    if [ ! -d "${TARGET_FOLDER}" ]
    then
        echo "folder ${TARGET_FOLDER} does nor exist, creating..."
        mkdir -p ${TARGET_FOLDER}
    fi
}

function check_archive_status()
{
    ARCHIVE_TARGET=$1

    # if archives exist at target, delete them
    if [ -f "${ARCHIVE_TARGET}" ]; then
        echo "old archive found, deleting..."
        echo "1234" | sudo -S rm -f ${ARCHIVE_TARGET}
    fi
}

FTP_HOST="31.141.245.47"
FTP_PORT="21"
FTP_USER="svrn"
FTP_PASS="$FTP_PASS_PROD"

echo "ftp at : ${FTP_HOST}"

ROOT_DIR=${PWD}

# get commit id / hash
COMMIT_HASH=$(git rev-parse --verify HEAD)
COMMIT_ID=${COMMIT_HASH::7}
echo "COMMIT_HASH: $COMMIT_HASH"
echo "COMMIT_ID: $COMMIT_ID"
cd $ROOT_DIR

CONFIG_FILE="localhost_only.xml"

## update 'archive' folder
FTP_PACKAGE_TARGET="/yacs_ros_middleware_config"
# create folder if not exiting
echo "Sending files to FTP server"
ncftp -u ${FTP_USER} -p ${FTP_PASS} -P ${FTP_PORT} ${FTP_HOST} <<EOF
mkdir $FTP_PACKAGE_TARGET
cd $FTP_PACKAGE_TARGET
put deploy.sh
mkdir $COMMIT_ID
cd $COMMIT_ID
put $CONFIG_FILE
put setup.sh
cd ..
mkdir latest
cd latest
put $CONFIG_FILE
put setup.sh
quit
EOF

echo "\n >>> FIN. \n"