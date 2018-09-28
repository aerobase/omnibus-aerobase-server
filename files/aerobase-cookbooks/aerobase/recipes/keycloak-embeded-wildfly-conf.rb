#
# Copyright:: Copyright (c) 2018, Aerobase Inc
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Default location of install-dir is /opt/aerobase/. This path is set during build time.
# DO NOT change this value unless you are building your own Unifiedpush packages

install_dir = node['package']['install-dir']
server_dir = node['unifiedpush']['unifiedpush-server']['dir']

account_helper = AccountHelper.new(node)
os_helper = OsHelper.new(node)
mssql_helper = MsSQLHelper.new(node)
pgsql_helper = PgHelper.new(node)

aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

keycloak_vars = node['unifiedpush']['keycloak-server'].to_hash

database_host = node['unifiedpush']['keycloak-server']['db_host']
database_port = node['unifiedpush']['keycloak-server']['db_port']
database_name = node['unifiedpush']['keycloak-server']['db_database']
database_username = node['unifiedpush']['keycloak-server']['db_username']
database_adapter = node['unifiedpush']['unifiedpush-server']['db_adapter']

# Always include modules since they are statically referenced from war file.
include_recipe "aerobase::postgresql-module-wildfly-conf"
include_recipe "aerobase::mssql-module-wildfly-conf"

if database_adapter == 'postgresql'
  jdbc_url = pgsql_helper.psql_jdbc_url(database_host, database_port, database_name)
  jdbc_hbm_dialect = "org.hibernate.dialect.PostgreSQL95Dialect"
  jdbc_driver_name = "postgresql"
  jdbc_driver_module_name = "org.postgresql"
  jdbc_driver_class_name = "org.postgresql.xa.PGXADataSource"
end

if database_adapter == 'mssql'
  jdbc_url = mssql_helper.mssql_jdbc_url(database_host, database_port, database_name, database_username, database_username)
  jdbc_hbm_dialect = "org.hibernate.dialect.SQLServer2012Dialect"
  jdbc_driver_name = "sqlserver"
  jdbc_driver_module_name = "com.microsoft"
  jdbc_driver_class_name = "com.microsoft.sqlserver.jdbc.SQLServerXADataSource"
end

ruby_block 'copy_keycloak_sources' do
  block do
	FileUtils.cp_r "#{install_dir}/embedded/apps/keycloak-server/keycloak-overlay/.", "#{server_dir}"
  end
  action :run
end

template "#{server_dir}/cli/keycloak-server-wildfly.cli" do
  owner aerobase_user
  group aerobase_group
  mode 0755
  source "keycloak-server-wildfly-cli.erb"
  variables(keycloak_vars.merge({
      :server_dir => "#{server_dir}",
	  :jdbc_url => jdbc_url, 
	  :jdbc_driver_name => jdbc_driver_name,
	  :jdbc_driver_module_name => jdbc_driver_module_name,
	  :jdbc_driver_class_name => jdbc_driver_class_name
    }
  ))
end

template "#{server_dir}/cli/keycloak-server-ups-realms.cli" do
  owner aerobase_user
  group aerobase_group
  mode 0755
  source "keycloak-server-ups-realms-cli.erb"
  variables({:server_dir => "#{server_dir}"})
end

if os_helper.is_windows?
  cli_cmd = "jboss-cli.bat"
else
  cli_cmd = "jboss-cli.sh"
end

execute 'KC datasource and config cli script' do
  command "#{server_dir}/bin/#{cli_cmd} --file=#{server_dir}/cli/keycloak-server-wildfly.cli"
end

execute 'KC datasource and config cli script' do
  command "#{server_dir}/bin/#{cli_cmd} --file=#{server_dir}/cli/keycloak-server-ups-realms.cli"
end
