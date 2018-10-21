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

## Connecting to MSSQL database
```
# Shutdown internal embedded database
postgresql['enable'] = false

# Point to MSSQL host and port (Optional, default 1433)
mssql['server'] = "localhost"
mssql['port'] = 1433
```

### Connecting using Windows Logon
```
mssql['logon'] = false
```

> If both port and instance are specified, port will be preferred.
