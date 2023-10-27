#!/bin/bash

sudo tee /etc/systemd/timesyncd.conf > /dev/null << EOL
# the system.conf.d/ subdirectory. The latter is generally recommended.
# Defaults can be restored by simply deleting this file and all drop-ins.
#
# See timesyncd.conf(5) for details.

[Time]
NTP=2.12.100.145  #ntp server
#FallbackNTP=time1.google.com time2.google.com time3.google.com time4.google.com time.cloudflare.com
#RootDistanceMaxSec=5
#PollIntervalMinSec=32
#PollIntervalMaxSec=2048
EOL
sudo systemctl restart systemd-timesyncd

