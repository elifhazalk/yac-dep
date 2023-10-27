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

FTP_HOST="VMYACSDOC"
FTP_PORT="21"
FTP_USER="svrn"
FTP_PASS="$FTP_PASS_DEV"

echo "ftp at : ${FTP_HOST}"

ROOT_DIR=${PWD}

## deploy by archive
SOURCE_DIR=${ROOT_DIR}/srv_dev
STAGING_AREA=${ROOT_DIR}/staging_area

## iterate through array and move to staging area
check_folder_status $STAGING_AREA

cd $ROOT_DIR

## copy to staging area
cp -v -r $SOURCE_DIR/* $STAGING_AREA
# get commit id / hash
COMMIT_HASH=$(git rev-parse --verify HEAD)
COMMIT_ID=${COMMIT_HASH::7}
echo "COMMIT_HASH: $COMMIT_HASH"
echo "COMMIT_ID: $COMMIT_ID"
cd $ROOT_DIR

## update 'archive' folder
FTP_PACKAGE_TARGET="/yacs_network_firefly_service"
# create folder if not exiting
echo "Sending files to FTP server"
ncftp -u ${FTP_USER} -p ${FTP_PASS} -P ${FTP_PORT} ${FTP_HOST} <<EOF
mkdir $FTP_PACKAGE_TARGET
cd $FTP_PACKAGE_TARGET
put deploy.sh
mkdir $COMMIT_ID
cd $COMMIT_ID
mkdir srv
cd srv
put $STAGING_AREA/*
cd ..
put setup.sh
cd ..
mkdir latest
cd latest
mkdir srv
cd srv
put $STAGING_AREA/*
cd ..
put setup.sh
quit
EOF

echo "\n >>> FIN. \n"