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

server_dir = node['unifiedpush']['aerobase-server']['dir']
server_etc_dir = "#{server_dir}/etc"

account_helper = AccountHelper.new(node)
mssql_helper = MsSQLHelper.new(node)
pgsql_helper = PgHelper.new(node)

aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

aerobase_vars = node['unifiedpush']['aerobase-server'].to_hash
unifiedpush_vars = node['unifiedpush']['unifiedpush-server'].to_hash
global_vars = node['unifiedpush']['global'].to_hash
all_vars = aerobase_vars.merge(unifiedpush_vars)
all_vars = aerobase_vars.merge(global_vars)

database_host = node['unifiedpush']['aerobase-server']['db_host']
database_port = node['unifiedpush']['aerobase-server']['db_port']
database_name = node['unifiedpush']['aerobase-server']['db_database']
database_username = node['unifiedpush']['aerobase-server']['db_username']
database_adapter = node['unifiedpush']['aerobase-server']['db_adapter']

if database_adapter == "postgresql"
  jdbc_url = pgsql_helper.psql_jdbc_url(database_host, database_port, database_name)
  jdbc_hbm_dialect = "org.hibernate.dialect.PostgreSQL95Dialect"
end 

if database_adapter == "mssql"
  jdbc_url = mssql_helper.mssql_jdbc_url(database_host, database_port, database_name, database_username, database_username)
  jdbc_hbm_dialect = "org.hibernate.dialect.SQLServer2012Dialect" 
end

if os_helper.is_windows?
  cli_cmd = "jboss-cli.bat"
  standalone_file = "conf.bat"
else
  cli_cmd = "jboss-cli.sh"
  standalone_file = "conf"
end

# Prepare datasource cli config script
template "#{server_dir}/cli/unifiedpush-server-wildfly-ds.cli" do
  owner aerobase_user
  group aerobase_group
  mode 0755
  source "aerobase-server-wildfly-ds-cli.erb"
  variables(all_vars)
end

# Prepare oauth2 cli config script
template "#{server_dir}/cli/unifiedpush-server-wildfly-oauth2.cli" do
  owner aerobase_user
  group aerobase_group
  mode 0755
  source "unifiedpush-server-wildfly-oauth2-cli.erb"
  variables(all_vars)
end

template "#{server_etc_dir}/environment.properties" do
  source "unifiedpush-server-env-properties.erb"
  owner aerobase_user
  group aerobase_group
  mode "0644"
  variables(all_vars)
end

template "#{server_etc_dir}/db.properties" do
  source "unifiedpush-server-db-properties.erb"
  owner aerobase_user
  group aerobase_group
  mode "0644"
  variables(all_vars.merge({
      :jdbc_url => jdbc_url
    }
  ))
end

template "#{server_etc_dir}/hibernate.properties" do
  source "unifiedpush-server-hibernate.properties.erb"
  owner aerobase_user
  group aerobase_group
  mode "0644"
  variables(all_vars.merge({
      :jdbc_hbm_dialect => jdbc_hbm_dialect
    }
  ))
end

# Execute cli scripts
execute 'Unifiedpush datasource cli script' do
  command "#{server_dir}/bin/#{cli_cmd} --file=#{server_dir}/cli/unifiedpush-server-wildfly-ds.cli"
end

execute 'Unifiedpush oauth2 cli script' do
  command "#{server_dir}/bin/#{cli_cmd} --file=#{server_dir}/cli/unifiedpush-server-wildfly-oauth2.cli"
end

# Link apps/
link "#{server_dir}/standalone/deployments/unifiedpush-server.war" do
  to "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-server.war"
end

