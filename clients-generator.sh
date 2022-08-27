#!/bin/bash

PWD=$(pwd)
DOCKER_COMPOSE_FILE="docker-compose-dev.yaml"
echo "Current directory:" $PWD
echo "Backing up original docker-compose file"
cp $DOCKER_COMPOSE_FILE DOCKER_COMPOSE_FILE.bkp

# echo $(less $PWD/$DOCKER_COMPOSE_FILE)


sed -n '14,28p' $DOCKER_COMPOSE_FILE >> $DOCKER_COMPOSE_FILE