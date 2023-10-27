# service files should be under 'srv' folder
# setup.sh should be under yacs_network_firefly_service folder

#!/bin/bash

echo "running deploy.sh for yacs_network_firefly_service ..."

# FTP server information
FTP_HOST="VMYACSDOC"
FTP_USER="svrn"
FTP_PASS="1234"
DIRECTORY="yacs_network_firefly_service"

if [ -z "$1" ]; then
    VERSION="latest"
else
    VERSION="$1"
fi

echo "Create folder: $DIRECTORY/$VERSION"
rm -rf $DIRECTORY
mkdir -p $DIRECTORY/$VERSION
cd $DIRECTORY/$VERSION

## pull from ftp
echo "pulling from ftp"
mkdir srv
cd srv
wget --recursive --no-directories --no-host-directories ftp://$FTP_USER:$FTP_PASS@$FTP_HOST/$DIRECTORY/$VERSION/srv/
chmod +x *.sh
cd ..

wget ftp://$FTP_USER:$FTP_PASS@$FTP_HOST/$DIRECTORY/$VERSION/setup.sh

chmod +x setup.sh
# setup.sh -> first arg: download dir, second arg: version
./setup.sh $VERSION

echo "FIN."