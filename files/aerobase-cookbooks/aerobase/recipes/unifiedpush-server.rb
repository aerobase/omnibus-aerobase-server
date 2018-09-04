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

require 'openssl'

# Default location of install-dir is /opt/aerobase/. This path is set during build time.
# DO NOT change this value unless you are building your own Unifiedpush packages
install_dir = node['package']['install-dir']
ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

server_dir = node['unifiedpush']['unifiedpush-server']['dir']
server_etc_dir = "#{server_dir}/etc"

account_helper = AccountHelper.new(node)
mssql_helper = MsSQLHelper.new(node)
pgsql_helper = PgHelper.new(node)
os_helper = OsHelper.new(node)

aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group
aerobase_password = account_helper.aerobase_password

unifiedpush_vars = node['unifiedpush']['unifiedpush-server'].to_hash
global_vars = node['unifiedpush']['global'].to_hash
all_vars = unifiedpush_vars.merge(global_vars)

database_host = node['unifiedpush']['unifiedpush-server']['db_host']
database_port = node['unifiedpush']['unifiedpush-server']['db_port']
database_name = node['unifiedpush']['unifiedpush-server']['db_database']
database_username = node['unifiedpush']['unifiedpush-server']['db_username']
database_adapter = node['unifiedpush']['unifiedpush-server']['db_adapter']

# Stop windows service before we try to override files.
if os_helper.is_windows?
  execute "#{server_dir}/bin/service.bat stop /name #{global_vars['srv_label']}" do
    only_if { ::File.exist? "#{server_dir}/bin/service.bat" }
  end
  
  ruby_block "Waiting 15 seconds for #{global_vars['srv_label']} service to stop" do
    block do
      sleep 15
    end
    only_if { ::File.exist? "#{server_dir}/bin/service.bat" }
  end
end

include_recipe "aerobase::wildfly-server"
include_recipe "aerobase::unifiedpush-server-wildfly-conf"
include_recipe "aerobase::keycloak-server"

if database_adapter == "postgresql"
  jdbc_url = pgsql_helper.psql_jdbc_url(database_host, database_port, database_name)
  jdbc_hbm_dialect = "org.hibernate.dialect.PostgreSQL95Dialect"
end 

if database_adapter == "mssql"
  jdbc_url = mssql_helper.mssql_jdbc_url(database_host, database_port, database_name, database_username, database_username)
  jdbc_hbm_dialect = "org.hibernate.dialect.SQLServer2012Dialect" 
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
  variables(unifiedpush_vars.merge({
      :jdbc_url => jdbc_url
    }
  ))
end

template "#{server_etc_dir}/hibernate.properties" do
  source "unifiedpush-server-hibernate.properties.erb"
  owner aerobase_user
  group aerobase_group
  mode "0644"
  variables(unifiedpush_vars.merge({
      :jdbc_hbm_dialect => jdbc_hbm_dialect
    }
  ))
end

# create themes dir
directory "#{server_dir}/themes" do
  owner aerobase_user
  group aerobase_group
  mode "0775"
end

# Copy themes
ruby_block 'copy_aerobase_theme' do
  block do
    FileUtils.cp_r "#{install_dir}/embedded/apps/themes/.", "#{server_dir}/themes"
  end
  action :run
end

# Make sure owner is aerobase_user
directory server_dir do
  owner aerobase_user
  group aerobase_group
  mode "0775"
end

if os_helper.is_windows?
  directory server_dir do
    rights :read, aerobase_group, :applies_to_children => true
    rights :full_control, aerobase_user,  :applies_to_children => true
  end
end

if os_helper.is_windows?
  execute "#{server_dir}/bin/service.bat install /startup /config standalone-full-ha.xml" do
  end

  execute "#{server_dir}/bin/service.bat restart /name #{global_vars['srv_label']}" do
  end
else
  component_runit_service "unifiedpush-server" do
    package "unifiedpush"
  end

  execute "/opt/aerobase/bin/aerobase-ctl restart unifiedpush-server" do
    retries 20
  end
end
