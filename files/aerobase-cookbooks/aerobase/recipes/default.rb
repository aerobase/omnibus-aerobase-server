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
os_helper = OsHelper.new(node)
aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group
postgresql_user = account_helper.postgresql_user
postgresql_password = account_helper.postgresql_password

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
  node.default['unifiedpush']['bootstrap']['enable'] = false
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

# Schema creation - either to embedded postgresqk or to external.
# Schama must be configured before unifiedpush-server is started.
if node['unifiedpush']['unifiedpush-server']['db_adapter'] == 'postgresql'
  include_recipe "aerobase::postgresql_initialize"
end

include_recipe "aerobase::web-server"

# Configure Services
[
  "unifiedpush-server", 
  "keycloak-server",
  "nginx"
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

include_recipe "aerobase::backup"
include_recipe "aerobase::bootstrap"