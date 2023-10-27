#!/bin/bash

STACK_NAME="yacs"

# Pull the latest draco image
docker pull 10.17.100.2:8000/yacs/draco:latest

# Update the draco service
docker service update --image 10.17.100.2:8000/yacs/draco:latest ${STACK_NAME}_draco
