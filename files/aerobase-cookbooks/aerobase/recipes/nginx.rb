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

os_helper = OsHelper.new(node)
account_helper = AccountHelper.new(node)
omnibus_helper = OmnibusHelper.new(node)
domain_helper = DomainHelper.new(node)

install_dir = node['package']['install-dir']
nginx_dir = node['unifiedpush']['nginx']['dir']
nginx_conf_dir = File.join(nginx_dir, "conf")
nginx_confd_dir = File.join(nginx_dir, "conf.d")
nginx_html_dir = File.join(nginx_dir, "www/html")
nginx_ups_html_dir = File.join(nginx_html_dir, "unifiedpush-server")
nginx_gsg_html_dir = File.join(nginx_html_dir, "getting-started")
nginx_log_dir = node['unifiedpush']['nginx']['log_directory']

# These directories do not need to be writable for unifiedpush-server
[
  nginx_dir,
  nginx_conf_dir,
  nginx_confd_dir,
  nginx_html_dir,
  nginx_ups_html_dir,
  nginx_gsg_html_dir,
  nginx_log_dir,
].each do |dir_name|
  directory dir_name do
    owner account_helper.web_server_user
    group account_helper.web_server_group
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
nginx_aerobase_js = File.join(nginx_html_dir, "aerobase.js")

unifiedpush_server_http_conf = File.join(nginx_conf_dir, "aerobase-http.conf")
unifiedpush_locations_http_conf = File.join(nginx_conf_dir, "aerobase-locations.import")
unifiedpush_locations_http_sub_module_conf = File.join(nginx_conf_dir, "aerobase-locations-http-sub-module.import")
unifiedpush_subdomains_http_conf = File.join(nginx_conf_dir, "aerobase-subdomains.conf")

# If the service is enabled, check if we are using internal nginx
nginx_server_enabled = node['unifiedpush']['nginx']['enable']
unifiedpush_server_enabled = node['unifiedpush']['unifiedpush-server']['enable']
keycloak_server_enabled = node['unifiedpush']['keycloak-server']['enable']
portal_mode = node['unifiedpush']['global']['portal_mode']

# Include the config file for unifiedpush-server in nginx.conf later
nginx_vars = node['unifiedpush']['nginx'].to_hash.merge({
               :unifiedpush_http_config => unifiedpush_server_enabled || keycloak_server_enabled ? unifiedpush_server_http_conf : nil,
			   :unifiedpush_subdomains_http_conf => unifiedpush_server_enabled || keycloak_server_enabled ? unifiedpush_subdomains_http_conf : nil,
               :unifiedpush_http_configd => nginx_confd_dir,
	           :fqdn => node['unifiedpush']['unifiedpush-server']['server_host'],
      	       :html_dir => nginx_html_dir,
               :portal_mode => portal_mode
             })

if nginx_vars['listen_https'].nil?
  nginx_vars['https'] = node['unifiedpush']['unifiedpush-server']['server_https']
else
  nginx_vars['https'] = nginx_vars['server_https']
end

template unifiedpush_server_http_conf do
  source "nginx-unifiedpush-http.conf.erb"
  owner account_helper.web_server_user
  group account_helper.web_server_group
  mode "0644"
  variables nginx_vars
  action nginx_server_enabled ? :create : :delete
end

template unifiedpush_locations_http_conf do
  source "nginx-locations-http.conf.erb"
  owner account_helper.web_server_user
  group account_helper.web_server_group  
  mode "0644"
  variables nginx_vars
  action nginx_server_enabled ? :create : :delete
end

# Install nginx protection to serving apps outside of portal iframe.
# This case is relevant when returning from external actions e.g registration.
template unifiedpush_locations_http_sub_module_conf do
  source "nginx-locations-http-sub-module.conf.erb"
  owner account_helper.web_server_user
  group account_helper.web_server_group
  mode "0644"
  variables nginx_vars
  action nginx_server_enabled ? :create : :delete
  only_if { portal_mode }
end

template unifiedpush_subdomains_http_conf do
  source "nginx-subdomains-http.conf.erb"
  owner account_helper.web_server_user
  group account_helper.web_server_group
  mode "0644"
  variables nginx_vars
  action nginx_server_enabled ? :create : :delete
end

template nginx_config do
  source "nginx.conf.erb"
  owner account_helper.web_server_user
  group account_helper.web_server_group
  mode "0644"
  variables nginx_vars
  action nginx_server_enabled ? :create : :delete
end

template nginx_aerobase_js do
  source "nginx-aerobase.js.erb"
  owner account_helper.web_server_user
  group account_helper.web_server_group
  mode "0644"
  variables nginx_vars
end

# Extract aerobae static contect to html directory
ruby_block 'copy_ups_html_sources' do
  block do
    FileUtils.mkdir_p "#{nginx_ups_html_dir}"
	FileUtils.cp_r "#{install_dir}/embedded/apps/unifiedpush-admin-ui/.", "#{nginx_ups_html_dir}"
  end
  action :run
  only_if { unifiedpush_server_enabled }
end

ruby_block 'copy_gsg_html_sources' do
  block do
    FileUtils.mkdir_p "#{nginx_ups_html_dir}"
	FileUtils.cp_r "#{install_dir}/embedded/apps/aerobase-gsg-ui/.", "#{nginx_gsg_html_dir}"
  end
  action :run
  only_if { unifiedpush_server_enabled }
end

# Make sure owner is web_server_user
directory "#{nginx_ups_html_dir}" do
  owner account_helper.web_server_user
  group account_helper.web_server_group
  mode "0775"
  action :create
end

if os_helper.not_windows?
  component_runit_service "nginx" do
    package "unifiedpush"
  end

  execute "/opt/unifiedpush/bin/unifiedpush-ctl restart nginx" do
    retries 20
  end
end
