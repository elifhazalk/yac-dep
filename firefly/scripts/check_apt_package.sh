#!/bin/bash

echo ">>> checking if required apt packages existing..."

function check_apt_package()
{
    PACKAGE_NAME=$1

    echo ">> checking for '${PACKAGE_NAME}'"

    if [ $(dpkg-query -W -f='${Status}' ${PACKAGE_NAME} 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo "package '${PACKAGE_NAME}' not found, installing..."
        if apt install ${PACKAGE_NAME}; # may need sudo here
        then
            echo "apt install succeeded."
        else
            echo "apt install failed."
            exit -1
        fi
    else
        echo "package '${PACKAGE_NAME}' is found, NICE"
    fi
}

# pv command
PV_PACKAGE="pv"
check_apt_package ${PV_PACKAGE}

# ncftp (ncftpput/ncftpget) command
NCFTP_PACKAGE="ncftp"
check_apt_package ${NCFTP_PACKAGE}

exit 0
