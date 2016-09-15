#
# Copyright:: Copyright (c) 2015.
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

account_helper = AccountHelper.new(node)

nginx_dir = node['unifiedpush']['nginx']['dir']
nginx_conf_dir = File.join(nginx_dir, "conf")
nginx_confd_dir = File.join(nginx_dir, "conf.d")
nginx_log_dir = node['unifiedpush']['nginx']['log_directory']

# These directories do not need to be writable for unifiedpush-server
[
  nginx_dir,
  nginx_conf_dir,
  nginx_confd_dir,
  nginx_log_dir,
].each do |dir_name|
  directory dir_name do
    owner account_helper.web_server_user
    group 'root'
    mode '0750'
    recursive true
  end
end

link File.join(nginx_dir, "logs") do
  to nginx_log_dir
end

nginx_config = File.join(nginx_conf_dir, "nginx.conf")

unifiedpush_server_http_conf = File.join(nginx_conf_dir, "unifiedpush-http.conf")

# If the service is enabled, check if we are using internal nginx
unifiedpush_server_enabled = node['unifiedpush']['nginx']['enable']

# Include the config file for unifiedpush-server in nginx.conf later
nginx_vars = node['unifiedpush']['nginx'].to_hash.merge({
               :unifiedpush_http_config => unifiedpush_server_enabled ? unifiedpush_server_http_conf : nil
             })

if nginx_vars['listen_https'].nil?
  nginx_vars['https'] = node['unifiedpush']['unifiedpush-server']['server_https']
else
  nginx_vars['https'] = nginx_vars['server_https']
end

template unifiedpush_server_http_conf do
  source "nginx-unifiedpush-http.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(nginx_vars.merge(
    {
      :fqdn => node['unifiedpush']['unifiedpush-server']['server_host']
    }
  ))
  notifies :restart, 'service[nginx]' if OmnibusHelper.should_notify?("nginx")
  action unifiedpush_server_enabled ? :create : :delete
end

template nginx_config do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables nginx_vars
  notifies :restart, 'service[nginx]' if OmnibusHelper.should_notify?("nginx")
end

runit_service "nginx" do
  down node['unifiedpush']['nginx']['ha']
  options({
    :log_directory => nginx_log_dir
  }.merge(params))
  log_options node['unifiedpush']['logging'].to_hash.merge(node['unifiedpush']['nginx'].to_hash)
end

if node['unifiedpush']['bootstrap']['enable']
  execute "/opt/unifiedpush/bin/unifiedpush-ctl start nginx" do
    retries 20
  end
end
