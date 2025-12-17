1) Generate SSL cert
   mkdir -p nginx/certs
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout nginx/certs/server.key \
     -out nginx/certs/server.crt \
     -subj "/C=ID/ST=JawaTimur/L=Surabaya/O=Case5/OU=Cloud/CN=localhost"

2) Create basic auth user
   mkdir -p nginx/auth
   docker run --rm httpd:2.4-alpine htpasswd -nb admin admin123 > nginx/auth/htpasswd

3) Start
   docker compose up -d --build

4) Access
   https://localhost/insert/
   https://localhost/delete/   (Basic Auth: admin / admin123)
   https://localhost/phpmyadmin/

5) Stop
   docker compose down
