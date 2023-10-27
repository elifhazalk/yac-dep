#!/bin/bash

echo "running deploy.sh for ros middleware config ..."

# FTP server information
FTP_HOST="VMYACSDOC"
FTP_USER="svrn"
FTP_PASS="1234"
DIRECTORY="yacs_ros_middleware_config"

if [ -z "$1" ]; then
    VERSION="latest"
else
    VERSION="$1"
fi

echo "Create folder: $DIRECTORY/$VERSION"
rm -rf $DIRECTORY
mkdir -p $DIRECTORY/$VERSION
cd $DIRECTORY/$VERSION

CONFIG_FILE="localhost_only.xml"

# pull from ftp
wget ftp://$FTP_USER:$FTP_PASS@$FTP_HOST/$DIRECTORY/$VERSION/setup.sh
wget ftp://$FTP_USER:$FTP_PASS@$FTP_HOST/$DIRECTORY/$VERSION/$CONFIG_FILE

chmod +x setup.sh
# setup.sh -> first arg: download dir, second arg: version
./setup.sh $VERSION

echo "FIN. (deploy.sh)"