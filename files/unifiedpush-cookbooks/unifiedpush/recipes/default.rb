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
unifiedpush_user = account_helper.unifiedpush_user
unifiedpush_group = account_helper.unifiedpush_group


# Default location of install-dir is /opt/unifiedpush/. This path is set during build time.
# DO NOT change this value unless you are building your own Unifiedpush packages
install_dir = node['package']['install-dir']
ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

directory "/etc/unifiedpush" do
  owner "root"
  group "root"
  mode "0775"
  action :nothing
end.run_action(:create)

Unifiedpush[:node] = node
if File.exists?("/etc/unifiedpush/unifiedpush.rb")
  Unifiedpush.from_file("/etc/unifiedpush/unifiedpush.rb")
end
node.consume_attributes(Unifiedpush.generate_config(node['fqdn']))

if File.exists?("/var/opt/unifiedpush/bootstrapped")
  node.set['unifiedpush']['bootstrap']['enable'] = false
end

directory "#{install_dir}/embedded/etc" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

if node['unifiedpush']['unifiedpush-server']['enable']
  include_recipe "unifiedpush::users"
end

# Install our runit instance
include_recipe "runit"

# postgresql Configuraiton 
[
  "postgresql"
].each do |service|
  if node["unifiedpush"][service]["enable"]
    include_recipe "unifiedpush::#{service}"
  else
    include_recipe "unifiedpush::#{service}_disable"
  end
end

# Schema creation - either to embedded postgres or to external.
# Schama must be configured before unifiedpush-server is started.
include_recipe "unifiedpush::postgresql_database_setup"
include_recipe "unifiedpush::postgresql_database_schema"

include_recipe "unifiedpush::web-server"

# Prepare backup configuration files
home_dir = node['unifiedpush']['user']['home']
backup_dir = node['unifiedpush']['backup_path']

template "#{home_dir}/postgresql-backup.conf" do
  source "postgresql-backup.erb"
  owner unifiedpush_user
  mode "0664"
  variables(node['unifiedpush']['unifiedpush-server'].to_hash)
end

directory "#{backup_dir}" do
  owner unifiedpush_user
  group unifiedpush_group
  mode "0664"
  action :create
end

# Configure Services
[
  "nginx",
  "logrotate",
  "bootstrap",
  "unifiedpush-server"
].each do |service|
  if node["unifiedpush"][service]["enable"]
    include_recipe "unifiedpush::#{service}"
  else
    include_recipe "unifiedpush::#{service}_disable"
  end
end
