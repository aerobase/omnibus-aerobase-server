## Aerobase Docker usage guide
Create host directories to share SSL and Themes with docker.
1. mkdir /etc/aerobase/ssl
2. mkdir /var/opt/aerobase/unifiedpush-server/themes

### HTTPS vs HTTP
In order to run using SSL / HTTPS, place your certificate files under /etc/aerobase/ssl/$(hostname).crt/.key
If only http access is required, add port 80 to docker-compose.yaml config

### Update your hostname and protocl (http/https) to overrides.rb
```
vi overrides.rb
```
### Run docker build
```
docker-compose up --build -d
```
### Configure aerobase and start server
```
docker-compose exec -T --privileged --index=1 aerobase /bin/bash -c "aerobase-ctl reconfigure --accept-license"
```
### Update your hosts file according to selected $HOST
```
echo $(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" dockercompose_aerobase_1) test.aerobase.org >> /etc/hosts
```
### Open chrome and browse http(s)://test.aerobase.org/auth/admin/aerobase/console
Username: admin
Password: 123

### Stop and reset container state
```
docker-compose kill
docker-compose rm
```
