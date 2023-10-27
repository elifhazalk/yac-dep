#!/bin/bash

STACK_NAME="yacs"

# Pull the latest bodypix image
docker pull 10.17.100.2:8000/yacs/bodypix:latest

# Update the bodypix service
docker service update --image 10.17.100.2:8000/yacs/bodypix:latest ${STACK_NAME}_bodypix
