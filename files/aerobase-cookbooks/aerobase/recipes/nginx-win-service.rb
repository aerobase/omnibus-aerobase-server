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

web_server_user = account_helper.web_server_user
web_server_group = account_helper.web_server_group

install_dir = node['package']['install-dir']
nginx_dir = node['unifiedpush']['nginx']['dir']
nginx_html_dir = File.join(nginx_dir, "www/html")

global_vars = node['unifiedpush']['global'].to_hash
nginx_vars = node['unifiedpush']['nginx'].to_hash.merge({
               :nginx_dir => nginx_dir,
             })
all_vars = nginx_vars.merge(global_vars)

# Stop service first
execute "stop nginx service" do
  command "echo 'Stoping nginx service ...'"
  only_if { cmd_helper.success("#{nginx_dir}/aerobasesw.exe stop") }
end

ruby_block "Waiting 5 seconds for nginx service to stop ..." do
  block do
    sleep 5
  end
end
			 
directory nginx_dir do
  if web_server_group
    rights :full_control, web_server_group, :applies_to_children => true
  end
  rights :full_control, web_server_user,  :applies_to_children => true
end

# Nginx start failed without temp dir.
directory "#{nginx_dir}/temp" do
  owner web_server_user
  group web_server_group
  mode '0750'
end

ruby_block 'copy_nginx_index_html' do
  block do
    FileUtils.cp_r "#{install_dir}/embedded/html/.", "#{nginx_html_dir}"
  end
  action :run
end

execute "uninstall nginx service" do
  command "#{nginx_dir}/aerobasesw.exe uninstall"
  only_if { ::File.exist? "#{nginx_dir}/aerobasesw.exe" }
end

ruby_block 'copy_nginx_winsw' do
  block do
    FileUtils.cp "#{install_dir}/embedded/apps/winsw/aerobasesw.exe", "#{nginx_dir}"
  end
  action :run
end

template "#{nginx_dir}/aerobasesw.xml" do
  source "nginx-winsw-config.erb"
  owner web_server_user
  group web_server_group
  mode "0644"
  variables all_vars
end

ruby_block 'copy_nginx_exe' do
  block do
    FileUtils.cp "#{install_dir}/embedded/sbin/nginx.exe", "#{nginx_dir}"
  end
  action :run
end

execute "install nginx service" do
  command "#{nginx_dir}/aerobasesw.exe install"
end

execute "restart nginx service" do
  command "#{nginx_dir}/aerobasesw.exe restart"
end