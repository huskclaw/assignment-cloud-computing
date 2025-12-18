#!/usr/bin/env bash

docker build -t case5_app_insert:1.0 ./app-insert
docker build -t case5_app_delete:1.0 ./app-delete
docker build -t case5_nginx:1.0 ./nginx