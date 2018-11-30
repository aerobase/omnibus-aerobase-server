# Aerobase common installation problems

## Start up problems
### Slow server startup after first aerobase-ctl reconfigure (Windows Only)
This issue reported as 'Windows Defender' is blocking port access.

### Server failed to start with the following error:
```
Property assignment of initial_hosts in TCPPING with original property value YOUR-HOST[7600], and converted to null could not be assigned
```

**Resolution:**
Your server host name is does't resolve to any local network address.
Either set `external_url "HOST"` to a resolvable address or set `server_contactpoints="LOCAL NETWORK IP"`
