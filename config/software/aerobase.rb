name "aerobase"

skip_transitive_dependency_licensing true

license :project_license

if windows?
  dependency "postgresql-bin"
  dependency "nginx-bin"
else
  dependency "postgresql"
  dependency "nginx"
  dependency "logrotate"
  dependency "runit"
end

dependency "omnibus-ctl"
dependency "omnibus-ctl-nofisp"
dependency "public_suffix"

# unifiedpush internal dependencies/components
dependency "aerobase-ctl"
dependency "unifiedpush-server"
dependency "unifiedpush-admin-ui"
dependency "aerobase-gsg-ui"
dependency "aerobase-config-template" 
dependency "aerobase-cookbooks"
dependency "aerobase-keycloak-spi"
dependency "mscplus"
dependency "winsw"
dependency "mssql-jdbc"

# KC server and themes must be added after cookbooks
if windows?
  dependency "keycloak-server"
end

dependency "aerobase-keycloak-theme"
