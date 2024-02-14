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
server_realm_dir = "#{server_dir}/data/import/"
server_mssql_dir = "#{server_dir}/bin/mssql"
server_log_dir = node['unifiedpush']['aerobase-server']['log_directory']
server_doc_dir = node['unifiedpush']['aerobase-server']['documents_directory']
server_upl_dir = node['unifiedpush']['aerobase-server']['uploads_directory']

account_helper = AccountHelper.new(node)
os_helper = OsHelper.new(node)
mssql_helper = MsSQLHelper.new(node)
mysql_helper = MySQLHelper.new(node)
pgsql_helper = PgHelper.new(node)

aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

keycloak_vars = node['unifiedpush']['keycloak-server'].to_hash
global_vars = node['unifiedpush']['global'].to_hash

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

# Additional keycloak config dirs
[
  server_realm_dir,
  server_mssql_dir,
  server_log_dir,
  server_doc_dir, 
  server_upl_dir
].each do |dir_name|
  directory dir_name do
    owner aerobase_user
    group aerobase_group
    mode 0775
    recursive true
  end
end

# Link logrotate gir to keycloak log dir
link "#{server_log_dir}/logs" do
  to "#{server_dir}/data/log"
end

# Always include modules since they are statically referenced.
include_recipe "aerobase::postgresql-module-conf"
include_recipe "aerobase::mssql-module-conf"
include_recipe "aerobase::mysql-module-conf"
include_recipe "aerobase::mariadb-module-conf"

if database_adapter == 'postgresql'
  db_adapter = "postgres"
  jdbc_url = pgsql_helper.psql_jdbc_url(database_host, database_port, database_name)
  jdbc_hbm_dialect = "org.hibernate.dialect.PostgreSQL95Dialect"
  jdbc_driver_name = "postgresql"
  jdbc_driver_module_name = "org.postgresql"
  jdbc_driver_class_name = "org.postgresql.xa.PGXADataSource"
end

if database_adapter == 'mssql'
  db_adapter = database_adapter
  jdbc_url = mssql_helper.mssql_jdbc_url(database_host, database_port, database_name, database_username, database_password)
  jdbc_hbm_dialect = "org.hibernate.dialect.SQLServer2012Dialect"
  jdbc_driver_name = "sqlserver"
  jdbc_driver_module_name = "com.microsoft"
  jdbc_driver_class_name = "com.microsoft.sqlserver.jdbc.SQLServerXADataSource"
end

if mysql_helper.is_mysql_type
  db_adapter = database_adapter
  jdbc_url = mysql_helper.mysql_jdbc_url(database_host, database_port, database_name)
  jdbc_hbm_dialect = mysql_helper.mysql_jdbc_hbm_dialect
  jdbc_driver_name = mysql_helper.mysql_type
  jdbc_driver_module_name = mysql_helper.mysql_jdbc_driver_module_name
  jdbc_driver_class_name = mysql_helper.mysql_jdbc_driver_class_name 
end


# Prepare keycloak config file
template "#{server_dir}/conf/keycloak.conf" do
  owner aerobase_user
  group aerobase_group
  mode 0755
  source "keycloak-conf.erb"
  variables(keycloak_vars.merge(global_vars).merge({
    :db_adapter => db_adapter,
    :jdbc_url => jdbc_url,
    :jdbc_driver_name => jdbc_driver_name,
    :jdbc_driver_module_name => jdbc_driver_module_name,
    :jdbc_driver_class_name => jdbc_driver_class_name
  })) 
end

if os_helper.is_windows?
  cli_cmd = "kc.bat"
else
  cli_cmd = "kc.sh"
end

execute 'KC datasource and config cli script' do
  command "#{server_dir}/bin/#{cli_cmd} build"
end

# prepare kc start command to echo and not exec
ruby_block "Prepare echo command for windows service" do
  block do
    fe = Chef::Util::FileEdit.new("#{server_dir}/bin/#{cli_cmd}")
    fe.search_file_replace('"%JAVA%" !JAVA_RUN_OPTS!',
                               'echo "%JAVA%"')
	fe.insert_line_after_match('echo "%JAVA%"',"    echo !JAVA_RUN_OPTS!")		   
    fe.write_file
  end
  only_if { os_helper.is_windows? }
end

# Echo kc start command and set output to node parameters
ruby_block "Prepare java command for windows services" do
    block do
        #tricky way to load this Chef::Mixin::ShellOut utilities
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
        command = "#{server_dir}/bin/#{cli_cmd} start --log=\"file\" --import-realm"
        command_out = shell_out(command)
        node.override['unifiedpush']['aerobase-server']['service_command'] = command_out.stdout.split(/\n/).first.chomp
		node.override['unifiedpush']['aerobase-server']['service_args'] = command_out.stdout.split(/\n/).last.chomp
    end
    only_if { os_helper.is_windows? }
end

# Copy spi resources
# ruby_block 'copy_aerobase_keycloak_spi' do
#   block do
#     FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-spi/.", "#{server_dir}/standalone/deployments/"
#   end
#   action :run
#   only_if { node['unifiedpush']['keycloak-server']['aerobase_spi'] }
# end

# Copy addons resources
# ruby_block 'copy_aerobase_keycloak_addons' do
#   block do
#     FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-addons/.", "#{server_dir}/standalone/deployments/"
#   end
#   action :run
#   only_if { node['unifiedpush']['keycloak-server']['aerobase_addons'] }
# end

# Copy spi resources
# ruby_block 'copy_aerobase_keycloak_patch' do
#   block do
#     FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-services/.", "#{server_dir}/modules/system/layers/keycloak/org/keycloak/keycloak-services/main/"
#     FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-server-spi/.", "#{server_dir}/modules/system/layers/keycloak/org/keycloak/keycloak-server-spi/main/"
#     FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-ldap-federation/.", "#{server_dir}/modules/system/layers/keycloak/org/keycloak/keycloak-ldap-federation/main/"
#     FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-kerberos-federation/.", "#{server_dir}/modules/system/layers/keycloak/org/keycloak/keycloak-kerberos-federation/main/"
#   end
#   action :run
#   only_if { node['unifiedpush']['keycloak-server']['aerobase_patch'] }
# end
