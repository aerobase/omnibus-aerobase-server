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

install_dir = node['package']['install-dir']

account_helper = AccountHelper.new(node)
os_helper = OsHelper.new(node)
mssql_helper = MsSQLHelper.new(node)
mysql_helper = MySQLHelper.new(node)
pgsql_helper = PgHelper.new(node)

aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

database_host = node['unifiedpush']['aerobase-server']['db_host']
database_port = node['unifiedpush']['aerobase-server']['db_port']
database_name = node['unifiedpush']['aerobase-server']['db_database']
database_username = node['unifiedpush']['aerobase-server']['db_username']
database_password = node['unifiedpush']['aerobase-server']['db_password']
database_adapter = node['unifiedpush']['aerobase-server']['db_adapter']


unifiedpush_vars = node['unifiedpush']['aerobase-server'].to_hash

if os_helper.is_windows?
  tmp_dir = "Temp"
  command = "init-unifiedpush-db.bat /#{install_dir}/#{tmp_dir} > #{install_dir}/#{tmp_dir}/initdb.log"
else
  tmp_dir = "tmp"
  command = "./init-unifiedpush-db.sh --config-path=#{install_dir}/#{tmp_dir}"
end 

if database_adapter == "postgresql"
  jdbc_url = pgsql_helper.psql_jdbc_url(database_host, database_port, database_name)
  jdbc_hbm_dialect = "org.hibernate.dialect.PostgreSQL95Dialect"
end  

if database_adapter == "mssql"
  jdbc_url = mssql_helper.mssql_jdbc_url(database_host, database_port, database_name, database_username, database_password)
  jdbc_hbm_dialect = "org.hibernate.dialect.SQLServer2012Dialect" 
end

if mysql_helper.is_mysql_type
  jdbc_url = mysql_helper.mysql_jdbc_url(database_host, database_port, database_name)
  jdbc_hbm_dialect = mysql_helper.mysql_jdbc_hbm_dialect
end

directory "#{install_dir}/#{tmp_dir}" do
  owner aerobase_user
  group aerobase_group
  mode "0755"
  recursive true
  action :create
end

template "#{install_dir}/#{tmp_dir}/db.properties" do
  source "unifiedpush-server-db-properties.erb"
  owner aerobase_user
  group aerobase_group
  mode "0644"
  variables(unifiedpush_vars.merge({
      :jdbc_url => jdbc_url
    }
  ))
end

template "#{install_dir}/#{tmp_dir}/hibernate.properties" do
  source "unifiedpush-server-hibernate.properties.erb"
  owner aerobase_user
  group aerobase_group
  mode "0644"
  variables(unifiedpush_vars.merge({
      :jdbc_hbm_dialect => jdbc_hbm_dialect
    }
  ))
end

execute "initialize unifiedpush-server database" do
  cwd "#{install_dir}/embedded/apps/unifiedpush-server/initdb/bin"
  command "#{command}"
end
