#!/bin/bash

echo ">>> pulling slam package from ftp server into Workspace/Downloads ..."

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {Download Target DIR}" >&2
  exit 1
fi

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

function check_archive_status()
{
    ARCHIVE_TARGET=$1

    # if archives exist at target, delete them
    if [ -f "${ARCHIVE_TARGET}" ]; then
        echo "old archive found, deleting..."
        echo "1234" | sudo -S rm -f ${ARCHIVE_TARGET}
    fi
}

function pull_from_ftp()
{
  ARCHIVE_NAME=$1
  FTP_ARCHIVE_LOCATION=$2
  DOWNLOAD_LOCATION=$3
  echo "ARCHIVE_NAME : ${ARCHIVE_NAME}"
  echo "FTP_ARCHIVE_LOCATION : ${FTP_ARCHIVE_LOCATION}"
  echo "DOWNLOAD_LOCATION : ${DOWNLOAD_LOCATION}"

  # TODO: read FTP properties from config file or DB
  FTP_HOST="2.12.100.145"
  FTP_PORT="21"
  FTP_USER="svrn"
  FTP_PASS="1234"

  echo "using ftp at : ${FTP_HOST}"

  # check if exists
  check_archive_status "${DOWNLOAD_LOCATION}/${ARCHIVE_NAME}"
  # pull from ftp
  # example: ncftpget -R -T -v -u [username] -p [password] [hostname-or-ip-address] [/path/to/local/dir] [/path/to/remote/dir]
  ncftpget -v -u ${FTP_USER} -p ${FTP_PASS} -P ${FTP_PORT} ${FTP_HOST} ${DOWNLOAD_LOCATION} ${FTP_ARCHIVE_LOCATION}

  return_code=$?
  if [ ${return_code} == 0 ];
  then
    echo "ncftpget succeeded for ${ARCHIVE_NAME}"
  else
    echo "ncftpget FAILED for ${ARCHIVE_NAME}"
    exit -1
  fi
}

echo "received argument: $1"

## deploy by archive
ARCHIVE_TARGET_DIR=$1

## =========== packages after here ===============
## saved maps
SAVED_MAPS_ARCHIVE_NAME="saved_maps.tar.gz"
FTP_SAVED_MAPS_TARGET="/Deploy/firefly/map_package/${SAVED_MAPS_ARCHIVE_NAME}"
pull_from_ftp ${SAVED_MAPS_ARCHIVE_NAME} ${FTP_SAVED_MAPS_TARGET} ${ARCHIVE_TARGET_DIR}

## slam_ros_pkg into directly -> ${ros2_ws}/install/slam_ros_pkg
SLAM_PKG_ROS2_INSTALL_ARCHIVE_NAME="slam_pkg_ros2_install.tar.gz"
FTP_SLAM_ROS2_INSTALL_TARGET="/Deploy/firefly/slam_ros2_install/${SLAM_PKG_ROS2_INSTALL_ARCHIVE_NAME}"
pull_from_ftp ${SLAM_PKG_ROS2_INSTALL_ARCHIVE_NAME} ${FTP_SLAM_ROS2_INSTALL_TARGET} ${ARCHIVE_TARGET_DIR}

# ## slam vocabulary package
# VOCABULARY_PKG_ARCHIVE_NAME="vocabulary.tar.gz"
# FTP_VOCABULARY_PKG_TARGET="/Deploy/firefly/vocabulary_package/${VOCABULARY_PKG_ARCHIVE_NAME}"
# pull_from_ftp ${VOCABULARY_PKG_ARCHIVE_NAME} ${FTP_VOCABULARY_PKG_TARGET} ${ARCHIVE_TARGET_DIR}

### config packages
## slam config
CONFIG_SLAM_ARCHIVE_NAME="slam_config.tar.gz"
FTP_CONFIG_SLAM_TARGET="/Deploy/firefly/config_packages/${CONFIG_SLAM_ARCHIVE_NAME}"
pull_from_ftp ${CONFIG_SLAM_ARCHIVE_NAME} ${FTP_CONFIG_SLAM_TARGET} ${ARCHIVE_TARGET_DIR}

echo ">>> pulling SLAM archives FIN."

exit 0