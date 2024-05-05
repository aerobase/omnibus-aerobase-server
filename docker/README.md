## Aerobase Docker usage guide

### Update properties to overrides.rb
```
vi overrides.rb
# Update `external_url` with your hostname
```
### Run docker container
```
docker-compose up -d
```
### Build localy
```
docker build -t aerobase/aerobase:latest .
```
```
docker build -t aerobase/aerobase-rootless -f Dockerfile-Rootless .
```
### Open web browser and access http(s)://aerobase.example.com/auth/admin/aerobase/console
Username: admin
Password: 123

### Stop and reset container state
```
docker-compose kill
docker-compose rm
```

### View aerobase logs
```
docker-compose logs -f
```

### Run ssh command
```
docker exec -it docker_aerobase_1 /bin/bash
```

### Start Using SSL/HTTPS
Create host directories to share SSL.
1. mkdir `$HOME/aerobase/ssl`
2. Place your certificate files under `$HOME/aerobase/ssl/$(hostname).crt/.key`
