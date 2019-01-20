## Aerobase Docker usage guide

### HTTPS vs HTTP
In order to run using SSL / HTTPS, place your certificate files under /etc/aerobase/ssl/$(hostname).crt/.key
If only http access is required, add port 80 to docker-compose.yaml config

### Run and build docker image
Replace test.aerobase.org with your host name
```
export HOST=test.aerobase.org; docker-compose up --build -d
```
### Configure aerobase image according to your host name
```
docker-compose exec -T --privileged --index=1 aerobase /bin/bash -c "/tmp/setup.sh"
```
