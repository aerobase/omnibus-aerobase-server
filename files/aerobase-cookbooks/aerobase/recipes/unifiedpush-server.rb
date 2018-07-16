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

# Default location of install-dir is /opt/unifiedpush/. This path is set during build time.
# DO NOT change this value unless you are building your own Unifiedpush packages
install_dir = node['package']['install-dir']
ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

server_dir = node['unifiedpush']['unifiedpush-server']['dir']
server_log_dir = node['unifiedpush']['unifiedpush-server']['log_directory']
server_etc_dir = "#{server_dir}/etc"

account_helper = AccountHelper.new(node)
aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group
aerobase_password = account_helper.aerobase_password
os_helper = OsHelper.new(node)

unifiedpush_vars = node['unifiedpush']['unifiedpush-server'].to_hash
global_vars = node['unifiedpush']['global'].to_hash
all_vars = unifiedpush_vars.merge(global_vars)

include_recipe "aerobase::wildfly-server"
include_recipe "aerobase::unifiedpush-server-wildfly-conf"

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
  variables(all_vars)
end

# create themes dir
directory "#{server_dir}/themes" do
  owner aerobase_user
  group aerobase_group
  mode "0775"
end

# Copy themes
ruby_block 'copy_wildfly_sources' do
  block do
	FileUtils.cp_r "#{install_dir}/embedded/cookbooks/aerobase/files/default/themes/.", "#{server_dir}/themes"
  end
  action :run
end

# Make sure owner is aerobase_user
directory server_dir do
  owner aerobase_user
  group aerobase_group
  mode "0775"
  action :nothing
end.run_action(:create)

directory server_dir do
  rights :read, aerobase_group, :applies_to_children => true
  rights :full_control, aerobase_user,  :applies_to_children => true
  only_if { os_helper.is_windows? }
end

if os_helper.is_windows?
  execute "#{server_dir}/bin/service.bat install /startup /config standalone-full-ha.xml" do
    user aerobase_user
	password aerobase_password
  end

  execute "#{server_dir}/bin/service.bat restart /name Aerobase" do
    user aerobase_user
	password aerobase_password
  end
else
  component_runit_service "unifiedpush-server" do
    package "unifiedpush"
  end

  execute "/opt/unifiedpush/bin/aerobase-ctl restart unifiedpush-server" do
    retries 20
  end
end

