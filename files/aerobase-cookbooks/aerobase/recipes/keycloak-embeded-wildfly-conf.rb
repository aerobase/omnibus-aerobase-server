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
# DO NOT change this value unless you are building your own Aerobase packages

install_dir = node['package']['install-dir']
server_dir = node['unifiedpush']['aerobase-server']['dir']
server_etc_dir = "#{server_dir}/etc"
server_cli_dir = "#{server_dir}/cli"
user_cli_dir = "#{server_dir}/cli/usr"
server_mssql_dir = "#{server_dir}/bin/mssql"

account_helper = AccountHelper.new(node)
os_helper = OsHelper.new(node)
mssql_helper = MsSQLHelper.new(node)
mysql_helper = MySQLHelper.new(node)
pgsql_helper = PgHelper.new(node)

aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

keycloak_vars = node['unifiedpush']['keycloak-server'].to_hash

database_host = node['unifiedpush']['keycloak-server']['db_host']
database_port = node['unifiedpush']['keycloak-server']['db_port']
database_name = node['unifiedpush']['keycloak-server']['db_database']
database_username = node['unifiedpush']['keycloak-server']['db_username']
database_password = node['unifiedpush']['keycloak-server']['db_password']
database_adapter = node['unifiedpush']['aerobase-server']['db_adapter']

ruby_block 'copy_keycloak_sources' do
  block do
    FileUtils.cp_r "#{install_dir}/embedded/apps/keycloak-server/keycloak/.", "#{server_dir}"
  end
  action :run
end

# Additional aerobase config dirs
[
  server_etc_dir,
  server_cli_dir,
  user_cli_dir,
  server_mssql_dir
].each do |dir_name|
  directory dir_name do
    owner aerobase_user
    group aerobase_group
    mode 0775
    recursive true
  end
end

# Aggreagate all server realms
if node['unifiedpush']['keycloak-server']['realm_default_enable']
  server_realms = server_dir + "/standalone/configuration/keycloak-server-aerobase-realm.json,"
else
  server_realms = ""
end

node['unifiedpush']['keycloak-server']['realm_files'].each do |file|
  server_realms = server_realms + file + ","
end

# Always include modules since they are statically referenced from war file.
include_recipe "aerobase::postgresql-module-wildfly-conf"
include_recipe "aerobase::mssql-module-wildfly-conf"
include_recipe "aerobase::mysql-module-wildfly-conf"
include_recipe "aerobase::mariadb-module-wildfly-conf"

if database_adapter == 'postgresql'
  jdbc_url = pgsql_helper.psql_jdbc_url(database_host, database_port, database_name)
  jdbc_hbm_dialect = "org.hibernate.dialect.PostgreSQL95Dialect"
  jdbc_driver_name = "postgresql"
  jdbc_driver_module_name = "org.postgresql"
  jdbc_driver_class_name = "org.postgresql.xa.PGXADataSource"
end

if database_adapter == 'mssql'
  jdbc_url = mssql_helper.mssql_jdbc_url(database_host, database_port, database_name, database_username, database_password)
  jdbc_hbm_dialect = "org.hibernate.dialect.SQLServer2012Dialect"
  jdbc_driver_name = "sqlserver"
  jdbc_driver_module_name = "com.microsoft"
  jdbc_driver_class_name = "com.microsoft.sqlserver.jdbc.SQLServerXADataSource"
end

if mysql_helper.is_mysql_type
  jdbc_url = mysql_helper.mysql_jdbc_url(database_host, database_port, database_name)
  jdbc_hbm_dialect = mysql_helper.mysql_jdbc_hbm_dialect
  jdbc_driver_name = mysql_helper.mysql_type
  jdbc_driver_module_name = mysql_helper.mysql_jdbc_driver_module_name
  jdbc_driver_class_name = mysql_helper.mysql_jdbc_driver_class_name 
end

# install keycloak-server-wildfly-cli.erb to cli directory
# update keycloak-server-wildfly-cli.erb on KC version upgrade
# source template 'keycloak-overlay-X.X.X.Final/bin/keycloak-install-ha.cli'
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

template "#{server_dir}/cli/keycloak-server-aerobase-realms.cli" do
  owner aerobase_user
  group aerobase_group
  mode 0755
  source "keycloak-server-aerobase-realms-cli.erb"
  variables(keycloak_vars.merge({
      :server_realms => "#{server_realms}"
    }
  ))
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
  command "#{server_dir}/bin/#{cli_cmd} --file=#{server_dir}/cli/keycloak-server-aerobase-realms.cli"
end

# Additional keycloak cli files
Dir.glob("#{server_dir}/cli/usr/*.cli") do |file_name|
  execute 'KC user additional cli script #{file_name}' do
    command "#{server_dir}/bin/#{cli_cmd} --file=#{file_name}"
  end
end

# Copy spi resources
ruby_block 'copy_aerobase_keycloak_spi' do
  block do
    FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-spi/.", "#{server_dir}/standalone/deployments/"
  end
  action :run
  only_if { node['unifiedpush']['keycloak-server']['aerobase_spi'] }
end

# Copy addons resources
ruby_block 'copy_aerobase_keycloak_addons' do
  block do
    FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-addons/.", "#{server_dir}/standalone/deployments/"
  end
  action :run
  only_if { node['unifiedpush']['keycloak-server']['aerobase_addons'] }
end

# Deploy sms auth resources
ruby_block 'copy_aerobase_keycloak_sms_authenticator' do
  block do
    FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-sms-authenticator/.", "#{server_dir}/standalone/deployments/"
  end
  action :run
  only_if { node['unifiedpush']['keycloak-server']['aerobase_sms_authenticator'] }
end

# Copy spi resources
ruby_block 'copy_aerobase_keycloak_patch' do
  block do
    FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-services/.", "#{server_dir}/modules/system/layers/keycloak/org/keycloak/keycloak-services/main/"
	FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-server-spi/.", "#{server_dir}/modules/system/layers/keycloak/org/keycloak/keycloak-server-spi/main/"
	FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-ldap-federation/.", "#{server_dir}/modules/system/layers/keycloak/org/keycloak/keycloak-ldap-federation/main/"
	FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-kerberos-federation/.", "#{server_dir}/modules/system/layers/keycloak/org/keycloak/keycloak-kerberos-federation/main/"
  end
  action :run
  only_if { node['unifiedpush']['keycloak-server']['aerobase_patch'] }
end
