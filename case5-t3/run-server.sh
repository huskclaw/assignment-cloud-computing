#!/usr/bin/env bash

set -a
source ./.env
set +a

NET="case5_net"
VOL="case5_mysql_data"

docker network inspect "$NET" >/dev/null 2>&1 || docker network create "$NET"
docker volume inspect "$VOL" >/dev/null 2>&1 || docker volume create "$VOL"

docker rm -f case5_nginx case5_app_insert case5_app_delete case5_mysql case5_phpmyadmin >/dev/null 2>&1 || true

docker run -d \
  --name case5_mysql \
  --network "$NET" \
  -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
  -e MYSQL_DATABASE="$MYSQL_DATABASE" \
  -e MYSQL_USER="$MYSQL_USER" \
  -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
  -v "$VOL":/var/lib/mysql \
  -v "$(pwd)/mysql/init.sql":/docker-entrypoint-initdb.d/init.sql:ro \
  mysql:8.0

# (Optional) wait until MySQL is ready (prevents "connection refused")
# echo "Waiting for MySQL to be ready..."
# until docker exec case5_mysql mysqladmin ping -h 127.0.0.1 --silent; do
#   sleep 1
# done

docker run -d \
  --name case5_app_insert \
  --network "$NET" \
  -e DB_HOST="case5_mysql" \
  -e DB_NAME="$MYSQL_DATABASE" \
  -e DB_USER="$MYSQL_USER" \
  -e DB_PASS="$MYSQL_PASSWORD" \
  case5_app_insert:1.0

docker run -d \
  --name case5_app_delete \
  --network "$NET" \
  -e DB_HOST="case5_mysql" \
  -e DB_NAME="$MYSQL_DATABASE" \
  -e DB_USER="$MYSQL_USER" \
  -e DB_PASS="$MYSQL_PASSWORD" \
  case5_app_delete:1.0

docker run -d \
  --name case5_phpmyadmin \
  --network "$NET" \
  -e PMA_HOST="case5_mysql" \
  -e PMA_PORT="3306" \
  -e PMA_ABSOLUTE_URI="https://localhost/phpmyadmin/" \
  phpmyadmin:latest

docker run -d \
  --name case5_nginx \
  --network "$NET" \
  -p 80:80 \
  -p 443:443 \
  -v "$(pwd)/nginx/nginx.conf":/etc/nginx/nginx.conf:ro \
  -v "$(pwd)/nginx/certs":/etc/nginx/certs:ro \
  -v "$(pwd)/nginx/auth":/etc/nginx/auth:ro \
  nginx:alpine