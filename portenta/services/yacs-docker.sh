#!/bin/bash

echo "Running docker-compose..."
/usr/bin/docker-compose -f "/home/fio/yacs_lynx/docker-compose.yml" up -d --build --force-recreate

/usr/bin/docker system prune -f