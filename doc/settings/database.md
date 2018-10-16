# Database settings
## Supported Databases
PostgreSQL (default), MSSQL, MySQL, Oracle

## Connecting to external database
```
# Shutdown internal embedded database
postgresql['enable'] = false

# Point to external database 
postgresql['server'] = "YOU-IP"
postgresql['username'] = "postgres"
postgresql['password'] = "postgres"
```
Now run `sudo aerobase-ctl reconfigure`.
