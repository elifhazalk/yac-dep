#!/bin/bash

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

echo "deploying scripts to ftp..."

FTP_HOST="2.12.100.145"
FTP_PORT="21"
FTP_USER="svrn"
FTP_PASS="1234"

echo "ftp at : ${FTP_HOST}"

ROOT_DIR=${PWD}

## deploy by archive
SOURCE_DIR=${ROOT_DIR}
TARGET_ARCHIVE_DIR=${ROOT_DIR}/deployable_archives

if [ ! -d ${TARGET_ARCHIVE_DIR} ];
then
    echo "target archvie dir not found, creating..."
    mkdir -p ${TARGET_ARCHIVE_DIR}
else
    echo "target archive dir found, continuing..."
fi

## Scripts
# remove old file if exists
SCRIPTS_ARCHIVE_NAME="deploy_scripts.tar.gz"
if [ -f "${TARGET_ARCHIVE_DIR}/${SCRIPTS_ARCHIVE_NAME}" ]; then
    echo "old archive found, deleting..."
    echo "1234" | sudo -S rm -f ${TARGET_ARCHIVE_DIR}/${SCRIPTS_ARCHIVE_NAME}
fi
# compress (absence or presence of ' and " (quotes) important)
cd ${SOURCE_DIR}
echo "compressing into -> ${SCRIPTS_ARCHIVE_NAME}"
tar --exclude=".*" -zcvpf "${TARGET_ARCHIVE_DIR}/${SCRIPTS_ARCHIVE_NAME}" $(find . -name "*.sh" -printf '%f\n')
check_return_code $?
cd ${ROOT_DIR}

## Deploy archives to ftp target
FTP_SCRIPTS_TARGET="/Deploy/firefly/deploy_scripts/"
echo "upload to ftp -> ${SCRIPTS_ARCHIVE_NAME}"
ncftpput -v -u ${FTP_USER} -p ${FTP_PASS} -P ${FTP_PORT} ${FTP_HOST} ${FTP_SCRIPTS_TARGET} "${TARGET_ARCHIVE_DIR}/${SCRIPTS_ARCHIVE_NAME}"
check_return_code $?

exit 0