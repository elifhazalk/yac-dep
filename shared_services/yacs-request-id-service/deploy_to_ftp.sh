#!/bin/bash

echo -e ">>> deploying to ftp server ... \n"

FTP_HOST="2.12.100.145"
FTP_PORT="21"
FTP_USER="svrn"
FTP_PASS="1234"

echo "ftp at : ${FTP_HOST}"

ROOT_DIR=${PWD}

## deploy by archive
SOURCE_DIR=${ROOT_DIR}/srv
TARGET_ARCHIVE_DIR=${ROOT_DIR}/deployable_archives

if [ ! -d ${TARGET_ARCHIVE_DIR} ];
then
    echo "target archvie dir not found, creating..."
    mkdir -p ${TARGET_ARCHIVE_DIR}
else
    echo "target archive dir found, continuing..."
fi

## Create package archive
# remove old file if exists
ARCHIVE_NAME="yacs-request-id-service.tar.gz"
if [ -f "${TARGET_ARCHIVE_DIR}/${ARCHIVE_NAME}" ]; then
    echo "old archive found, deleting..."
    echo "1234" | sudo -S rm -f ${TARGET_ARCHIVE_DIR}/${ARCHIVE_NAME}
fi
# compress
cd ${SOURCE_DIR}
tar --exclude=".*" -zcvpf "${TARGET_ARCHIVE_DIR}/${ARCHIVE_NAME}" $(ls)
cd ${ROOT_DIR}


## Deploy archives to ftp target
# example: ncftpput -R -v -u [username] -p [password] [hostname-or-ip-address] [/path/to/remote/dir] [/path/to/local/dir]
FTP_ARCHIVE_PACKAGE_TARGET="/Deploy/firefly/other_packages/"
ncftpput -v -u ${FTP_USER} -p ${FTP_PASS} -P ${FTP_PORT} ${FTP_HOST} ${FTP_ARCHIVE_PACKAGE_TARGET} "${TARGET_ARCHIVE_DIR}/${ARCHIVE_NAME}"

echo "\n >>> FIN. \n"