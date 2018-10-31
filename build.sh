#!/bin/bash



cp envs/local .env
source .env

#build all within the docker-compose env
docker-compose build


