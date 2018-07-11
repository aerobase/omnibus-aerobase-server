#
# Copyright:: Copyright (c) 2015
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

account_helper = AccountHelper.new(node)
aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group
os_helper = OsHelper.new(node)

# Default location of install-dir is /opt/aerobase/. This path is set during build time.
# DO NOT change this value unless you are building your own Aerobase packages
install_dir = node['package']['install-dir']
config_dir = node['package']['config-dir']
runtime_dir = node['package']['runtime-dir']
ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

# Always create default user and group.
include_recipe "aerobase::users"

directory config_dir do
  owner aerobase_user
  group aerobase_group
  mode "0775"
end

Unifiedpush[:node] = node
if File.exists?("#{config_dir}/aerobase.rb")
  Unifiedpush.from_file("#{config_dir}/aerobase.rb")
end

# Merge and cosume aerobase attributes.
node.consume_attributes(Unifiedpush.generate_config(node['fqdn']))

if File.exists?("#{runtime_dir}/bootstrapped")
  node.set['unifiedpush']['bootstrap']['enable'] = false
end

directory "#{install_dir}/embedded/etc" do
  owner aerobase_user
  group aerobase_group
  mode "0755"
  recursive true
  action :create
end

# Install our runit instance for none windows os
if os_helper.not_windows?
  include_recipe "enterprise::runit"
end

# Install java from external package
if node['unifiedpush']['java']['install_java']
  # Define java cookbook attributes.
  JavaHelper.new(node)
  include_recipe 'java'
end

# First setup datastore configuraitons (postgres, cassandra), if required. 
[
  "postgresql",
  "cassandra"
].each do |service|
  if node["unifiedpush"][service]["enable"]
    include_recipe "aerobase::#{service}"
  else
    include_recipe "aerobase::#{service}_disable"
  end
end

# NOTE: These recipes are written idempotently, but require a running
# PostgreSQL service.  They should run each time (on the appropriate
# backend machine, of course), because they also handle schema
# upgrades for new releases of AeroBase.  As a result, we can't
# just do a check against node['unifiedpush']['bootstrap']['enable'],
# which would only run them one time.
if node['unifiedpush']['postgresql']['enable']
  execute "#{install_dir}/bin/aerobase-ctl start postgresql" do
    retries 20
  end

  ruby_block "wait for postgresql to start" do
    block do
      pg_helper = PgHelper.new(node)
      connectable = false
      2.times do |i|
        # Note that we have to include the port even for a local pipe, because the port number
        # is included in the pipe default.
        if pg_helper.psql_cmd(["-d 'pg_database'", "-c 'SELECT * FROM pg_database' -t -A"])
          Chef::Log.fatal("Could not connect to database, retrying in 10 seconds.")
          sleep 10
        else
          connectable = true
          break
        end
      end

      unless connectable
        Chef::Log.fatal <<-ERR
Could not connect to the postgresql database.
Please check /var/log/unifiedpush/posgresql/current for more information.
ERR
        exit!(1)
      end
    end
  end
end

if node['unifiedpush']['unifiedpush-server']['enable'] && node['unifiedpush']['unifiedpush-server']['db_adapter'] == 'postgresql'
  include_recipe_user_db = "aerobase::postgresql_user_and_db"
  include_recipe_schema = "aerobase::postgresql_schema"
 
  # Schema creation - either to embedded postgresqk or to external.
  # Schama must be configured before unifiedpush-server is started.
  include_recipe include_recipe_user_db
  include_recipe include_recipe_schema
end 

include_recipe "aerobase::web-server"
include_recipe "aerobase::backup"

# Configure Services
[
  "bootstrap",
  "nginx",
  "unifiedpush-server", 
  "keycloak-server"
].each do |service|
  if node["unifiedpush"][service]["enable"]
    include_recipe "aerobase::#{service}"
  else
    include_recipe "aerobase::#{service}_disable"
  end
end

# logrotate only support unix like flavors
if os_helper.not_windows?
  if node["unifiedpush"]["logrotate"]["enable"]
    include_recipe "aerobase::logrotate"
  else
    include_recipe "aerobase::logrotate_disable"
  end
end 
