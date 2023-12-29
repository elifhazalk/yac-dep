#!/bin/bash

docker compose pull
docker compose -f promtail-compose.yaml up -d