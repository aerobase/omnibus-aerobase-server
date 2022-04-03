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
dependency "public_suffix"
dependency "file-tail" 

# unifiedpush internal dependencies/components
dependency "aerobase-ctl"
dependency "aerobase-gsg-ui"
dependency "aerobase-config-template" 
dependency "aerobase-keycloak-spi"
dependency "aerobase-keycloak-addons"
dependency "mscplus"
dependency "winsw"
dependency "mssql-jdbc"
dependency "mysql-jdbc"
dependency "mariadb-jdbc"
dependency "postgresql-jdbc"

# KC server and themes must be added after cookbooks
if windows?
  dependency "keycloak-server"
end

dependency "aerobase-keycloak-theme"

# Most common updates - keep it last
dependency "aerobase-cookbooks"
