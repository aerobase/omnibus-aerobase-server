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

os_helper = OsHelper.new(node)
account_helper = AccountHelper.new(node)
omnibus_helper = OmnibusHelper.new(node)

web_server_user = account_helper.web_server_user
web_server_group = account_helper.web_server_group

config_dir = node['package']['config-dir']
install_dir = node['package']['install-dir']
nginx_dir = node['unifiedpush']['nginx']['dir']
nginx_conf_dir = File.join(nginx_dir, "conf")
nginx_confd_dir = File.join(nginx_dir, "conf.d")
nginx_html_dir = File.join(nginx_dir, "www/html")
nginx_cache_dir = File.join(nginx_dir, "cache")
nginx_gsg_html_dir = File.join(nginx_html_dir, "getting-started")
nginx_log_dir = node['unifiedpush']['nginx']['log_directory']
nginx_ssl_dir = File.join(config_dir, "ssl")

# These directories do not need to be writable for aerobase-group
[
  nginx_dir,
  nginx_conf_dir,
  nginx_confd_dir,
  nginx_html_dir,
  nginx_cache_dir,
  nginx_gsg_html_dir,
  nginx_log_dir,
  nginx_ssl_dir,
].each do |dir_name|
  directory dir_name do
    owner web_server_user
    group web_server_group
    mode '0750'
    recursive true
  end
end

link File.join(nginx_dir, "logs") do
  to nginx_log_dir
end

# Link logrotate dir to self.
# A workarround to ensure logrotate always exists at log_directory/logs
link "#{nginx_log_dir}/logs" do
  to nginx_log_dir
end

nginx_config = File.join(nginx_conf_dir, "nginx.conf")

aerobase_http_conf = File.join(nginx_conf_dir, "aerobase-http.conf")
aerobase_cache_conf = File.join(nginx_conf_dir, "aerobase-proxy-cache.conf")
aerobase_locations_import = File.join(nginx_conf_dir, "aerobase-locations.import")
aerobase_sub_module_import = File.join(nginx_conf_dir, "aerobase-sub-module.import")
nginx_aerobase_js = File.join(nginx_html_dir, "aerobase.js")

# If the service is enabled, check if we are using internal nginx
nginx_server_enabled = node['unifiedpush']['nginx']['enable']
aerobase_server_enabled = node['unifiedpush']['aerobase-server']['enable']
aerobase_server_contactpoints = node['unifiedpush']['aerobase-server']['server_contactpoints']
aerobase_server_port = node['unifiedpush']['aerobase-server']['server_port']
aerobase_server_fqdn = node['unifiedpush']['aerobase-server']['server_host']
keycloak_server_enabled = node['unifiedpush']['keycloak-server']['enable']
portal_mode = node['unifiedpush']['global']['portal_mode']
top_domain = node['unifiedpush']['global']['top_domain']

# Include the config file for aerobase-server in nginx.conf later
nginx_vars = node['unifiedpush']['nginx'].to_hash.merge({
		:aerobase_http_conf => aerobase_server_enabled || keycloak_server_enabled ? aerobase_http_conf : nil,
		:aerobase_http_configd => nginx_confd_dir,
		:aerobase_cache_conf => aerobase_cache_conf,
    :server_contactpoints => aerobase_server_contactpoints,
		:fqdn => aerobase_server_fqdn,
		:aerobase_server_port => aerobase_server_port,
		:html_dir => "www/html",
		:cache_dir => "cache",
		:portal_mode => portal_mode,
		:top_domain => top_domain,
		:windows => os_helper.is_windows?
	 })

if nginx_vars['listen_https'].nil?
  nginx_vars['https'] = node['unifiedpush']['aerobase-server']['server_https']
else
  nginx_vars['https'] = nginx_vars['server_https']
end

template aerobase_http_conf do
  source "nginx-aerobase-http.conf.erb"
  owner web_server_user
  group web_server_group
  mode "0644"
  variables nginx_vars
  action nginx_server_enabled ? :create : :delete
end

template aerobase_cache_conf do
  source "nginx-aerobase-proxy-cache.conf.erb"
  owner web_server_user
  group web_server_group
  mode "0644"
  variables nginx_vars
  action nginx_server_enabled ? :create : :delete
end

template aerobase_locations_import do
  source "nginx-aerobase-locations.import.erb"
  owner web_server_user
  group web_server_group  
  mode "0644"
  variables nginx_vars
  action nginx_server_enabled ? :create : :delete
end

template nginx_config do
  source "nginx.conf.erb"
  owner web_server_user
  group web_server_group
  mode "0644"
  variables nginx_vars
  action nginx_server_enabled ? :create : :delete
end

ruby_block 'copy_mime_sources' do
  block do
	FileUtils.cp "#{install_dir}/embedded/conf/mime.types", "#{nginx_conf_dir}"
  end
  action :run
  only_if { aerobase_server_enabled }
end

if os_helper.is_windows?
  include_recipe "aerobase::nginx-win-service"
else
  component_runit_service "nginx" do
    package "unifiedpush"
  end

  execute "/opt/aerobase/bin/aerobase-ctl restart nginx" do
    retries 20
  end
end
