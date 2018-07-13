name "aerobase"

skip_transitive_dependency_licensing true

license :project_license

# unifiedpush internal dependencies/components
dependency "aerobase-ctl"
dependency "unifiedpush-server"
dependency "unifiedpush-admin-ui"
dependency "aerobase-gsg-ui"
dependency "aerobase-config-template"
dependency "aerobase-cookbooks"

# KC server and themes must be added after cookbooks
if windows?
  dependency "keycloak-server"
end

dependency "aerobase-keycloak-theme"