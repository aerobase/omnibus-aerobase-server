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

cmd_helper = CmdHelper.new(node)
os_helper = OsHelper.new(node)
account_helper = AccountHelper.new(node)

aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

install_dir = node['package']['install-dir']
server_dir = node['unifiedpush']['aerobase-server']['dir']
service_start = node['unifiedpush']['global']['srv_start']

global_vars = node['unifiedpush']['global'].to_hash
unifiedpush_vars = node['unifiedpush']['aerobase-server'].to_hash
unifiedpush_vars = node['unifiedpush']['aerobase-server'].to_hash.merge({
               :service_start => service_start,
               :server_dir => server_dir,
             })
all_vars = unifiedpush_vars.merge(global_vars)

# Stop service first
execute "stop aerobase-server service" do
  command "echo 'Stoping aerobase-server service ...'"
  only_if { cmd_helper.success("#{server_dir}/bin/aerobasesw.exe stop") }
end

ruby_block "Waiting 30 seconds for aerobase-server service to stop ..." do
  block do
    sleep 30
  end
end
			 
directory "#{server_dir}" do
  if aerobase_group
    rights :full_control, aerobase_group, :applies_to_children => true
  end
  rights :full_control, aerobase_user,  :applies_to_children => true
end

# Nginx start failed without temp dir.
directory "#{server_dir}/temp" do
  owner aerobase_user
  group aerobase_group
  mode '0750'
end

execute "uninstall aerobase-server service" do
  command "#{server_dir}/bin/aerobasesw.exe uninstall"
  only_if { ::File.exist? "#{server_dir}/bin/aerobasesw.exe" }
end

ruby_block 'copy_aerobase_server_winsw' do
  block do
    FileUtils.cp "#{install_dir}/embedded/apps/winsw/aerobasesw.exe", "#{server_dir}/bin"
  end
  action :run
end

template "#{server_dir}/bin/aerobasesw.xml" do
  source "aerobase-server-winsw-config.erb"
  owner aerobase_user
  group aerobase_group
  mode "0644"
  variables all_vars
end

execute "install aerobase-server service" do
  command "#{server_dir}/bin/aerobasesw.exe install"
end

if service_start
  include_recipe "aerobase::aerobase-server_start"
end
