## Aerobase Docker usage guide

### Update your hostname and protocol (http/https) to overrides.rb
```
vi overrides.rb
```
### Run docker container
```
docker-compose up -d
```
### Build localy
```
docker build -t aerobase/aerobase:latest .
```
### Open chrome and browse http(s)://test.aerobase.org/auth/admin/aerobase/console
Username: admin
Password: 123

### Stop and reset container state
```
docker-compose kill
docker-compose rm
```
### Start Using SSL/HTTPS
Create host directories to share SSL.
1. mkdir $HOME/aerobase/ssl

### HTTPS vs HTTP
In order to run using SSL / HTTPS, place your certificate files under $HOME/aerobase/ssl/$(hostname).crt/.key
If only http access is required, add port 80 to docker-compose.yaml config

