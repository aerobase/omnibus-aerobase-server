# OAuth2 settings
## Load Additional Realm

Download and place your realm.json file under AEROBASE_HOME/unifiedpush-server/standalone/configuration/

In order for Aerobase to load custom realm it needs to know the PATH under which it is located, e.g.
`/opt/aerobase/unifiedpush-server/standalone/configuration/your-realm.json`. Add or edit the following line in `/etc/aerobase/aerobase.rb`:

```ruby
keycloak_server['realm_files'] = ['C:/Aerobase/Configuration/your-realm.json']
```

Run `sudo aerobase-ctl reconfigure` for the change to take effect.

## Disable Theme Caching

Download and place your theme directory under AEROBASE_HOME/unifiedpush-server/themes

Add or edit the following line in `/etc/aerobase/aerobase.rb`:

```ruby
keycloak_server['theme_cache'] = false
```

Run `sudo aerobase-ctl reconfigure` for the change to take effect.
