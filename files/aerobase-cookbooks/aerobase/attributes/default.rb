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

###
# Set a project-name for the enterprise-chef-common cookbook
###
default['enterprise']['name'] = "unifiedpush"
default['unifiedpush']['install_path'] = "#{node['package']['install-dir']}"

####
# omnibus options
####
default['unifiedpush']['bootstrap']['enable'] = true
# Default contactpoints for symmetric cluster mode.
# Override spesific properties [server_contactpoints, seeds] unless spesified to aerobase.rb
default['unifiedpush']['global']['contactpoints'] = "127.0.0.1"
default['unifiedpush']['global']['backup_path'] = "#{node['package']['runtime-dir']}/backups"
default['unifiedpush']['global']['portal_mode'] = false
default['unifiedpush']['global']['access_port'] = 80
# Windows Services prefix
default['unifiedpush']['global']['srv_label'] = "Aerobase"
default['unifiedpush']['global']['srv_start'] = true

####
## Global user managment options
####
# The Aerobase User that services run as
default['unifiedpush']['user']['username'] = "aerobase"
default['unifiedpush']['user']['group'] = "aerobase-group"
default['unifiedpush']['user']['manage_accounts'] = true
# Used only under windows os
default['unifiedpush']['user']['password'] = "$1$8AKNexhr$XEYpJFyWMcI.c96XLKLSk/"
default['unifiedpush']['user']['uid'] = nil
default['unifiedpush']['user']['gid'] = nil
# The shell for the aerobase services user
default['unifiedpush']['user']['shell'] = "/bin/sh"
# The home directory for the aerobase services user
default['unifiedpush']['user']['home'] = "#{node['package']['runtime-dir']}"

####
# Aerobase Server app
####
default['unifiedpush']['aerobase-server']['enable'] = true
default['unifiedpush']['aerobase-server']['ha'] = false
default['unifiedpush']['aerobase-server']['dir'] = "#{node['package']['runtime-dir']}/aerobase-server"
default['unifiedpush']['aerobase-server']['log_directory'] = "#{node['package']['logs-dir']}/aerobase-server"
default['unifiedpush']['aerobase-server']['log_rotation']['file_maxbytes'] = 104857600
default['unifiedpush']['aerobase-server']['log_rotation']['num_to_keep'] = 10
default['unifiedpush']['aerobase-server']['environment'] = 'production'
default['unifiedpush']['aerobase-server']['env'] = {
  'SIDEKIQ_MEMORY_KILLER_MAX_RSS' => '1000000',
  # PATH to set on the environment
  # defaults to /opt/aerobase/embedded/bin:/bin:/usr/bin. The install-dir path is set at build time
  'PATH' => "#{node['package']['install-dir']}/bin:#{node['package']['install-dir']}/embedded/bin:/bin:/usr/bin"
}
# Delayed start service on windows
default['unifiedpush']['aerobase-server']['delayed_start'] = false
default['unifiedpush']['aerobase-server']['documents_directory'] = "#{node['package']['runtime-dir']}/aerobase-server/documents"
default['unifiedpush']['aerobase-server']['uploads_directory'] = "#{node['package']['runtime-dir']}/aerobase-server/uploads"
# Max JSON size in KB
default['unifiedpush']['aerobase-server']['documents_json_limit'] = 4
# By default server_host extracted from external_url
default['unifiedpush']['aerobase-server']['server_host'] = node['fqdn']
# Internal network bind address. If the node has a default route, this is the IPV4 address for the interface. 
default['unifiedpush']['aerobase-server']['server_address'] = '127.0.0.1'
default['unifiedpush']['aerobase-server']['server_contactpoints'] = node['fqdn']
default['unifiedpush']['aerobase-server']['server_port'] = 8080
default['unifiedpush']['aerobase-server']['server_https'] = false
default['unifiedpush']['aerobase-server']['time_zone'] = nil
default['unifiedpush']['aerobase-server']['cache_owners'] = 1
default['unifiedpush']['aerobase-server']['java_xmx'] = "1g"
default['unifiedpush']['aerobase-server']['java_opts'] = nil
# SQL Global connection params
default['unifiedpush']['aerobase-server']['db_initialize'] = true
default['unifiedpush']['aerobase-server']['db_adapter'] = "postgresql"
default['unifiedpush']['aerobase-server']['db_sslmode'] = false
default['unifiedpush']['aerobase-server']['db_jdbc_flags'] = nil

####
# Keycloak Server app
####
default['unifiedpush']['keycloak-server']['enable'] = true
# Install additional aerobase spi services
default['unifiedpush']['keycloak-server']['aerobase_spi'] = true
default['unifiedpush']['keycloak-server']['aerobase_patch'] = true
# private_themes will filter aerobase themes and realm private themes
default['unifiedpush']['keycloak-server']['private_themes'] = false
default['unifiedpush']['keycloak-server']['ha'] = false
# When keycloak-server is disabled, server_host should point to external URL.
default['unifiedpush']['keycloak-server']['server_host'] = node['fqdn']
default['unifiedpush']['keycloak-server']['server_https'] = false
default['unifiedpush']['keycloak-server']['cache_owners'] = 1
default['unifiedpush']['keycloak-server']['cache_size'] = 10000
default['unifiedpush']['keycloak-server']['theme_cache'] = true
default['unifiedpush']['keycloak-server']['start_timeout'] = "600"
# Database properties
# db_username, db_host, db_port oveeride PostgreSQL properties [sql_kc_user, listen_address, port]
default['unifiedpush']['keycloak-server']['db_database'] = "keycloak_server"
default['unifiedpush']['keycloak-server']['db_username'] = "keycloak_server"
default['unifiedpush']['keycloak-server']['db_password'] = "keycloak_server"
default['unifiedpush']['keycloak-server']['db_host'] = "localhost"
default['unifiedpush']['keycloak-server']['db_port'] = nil
default['unifiedpush']['keycloak-server']['db_pool'] = "10"
default['unifiedpush']['keycloak-server']['realm_default_enable'] = true
# Additional realm json files array. e.g ['filepath', 'filepath']
default['unifiedpush']['keycloak-server']['realm_files'] = []

###
# PostgreSQL
###
default['unifiedpush']['postgresql']['enable'] = true
default['unifiedpush']['postgresql']['ha'] = false
default['unifiedpush']['postgresql']['dir'] = "#{node['package']['runtime-dir']}/postgresql"
default['unifiedpush']['postgresql']['data_dir'] = "#{node['package']['runtime-dir']}/postgresql/data"
default['unifiedpush']['postgresql']['log_directory'] = "#{node['package']['logs-dir']}/postgresql"
default['unifiedpush']['postgresql']['log_rotation']['file_maxbytes'] = 104857600
default['unifiedpush']['postgresql']['log_rotation']['num_to_keep'] = 10
# Unix socket directory is supported only for linux.
default['unifiedpush']['postgresql']['server'] = "localhost"
default['unifiedpush']['postgresql']['username'] = "aerobase-sql"
# Used only when pointing to external database or under windows
default['unifiedpush']['postgresql']['password'] = "$1$8AKNexhr$XEYpJFyWMcI.c96XLKLSk/"
default['unifiedpush']['postgresql']['uid'] = nil
default['unifiedpush']['postgresql']['gid'] = nil
default['unifiedpush']['postgresql']['shell'] = "/bin/sh"
default['unifiedpush']['postgresql']['home'] = "#{node['package']['runtime-dir']}/postgresql"
# Delayed start service on windows
default['unifiedpush']['postgresql']['delayed_start'] = false
# Postgres User's Environment Path
# defaults to /opt/aerobase/embedded/bin:/opt/aerobase/bin/$PATH. The install-dir path is set at build time
default['unifiedpush']['postgresql']['user_path'] = "#{node['package']['install-dir']}/embedded/bin:#{node['package']['install-dir']}/bin:$PATH"
default['unifiedpush']['postgresql']['bin_dir'] = "#{node['package']['install-dir']}/embedded/bin"
default['unifiedpush']['postgresql']['sql_ups_user'] = "aerobase_server"
default['unifiedpush']['postgresql']['sql_kc_user'] = "keycloak_server"
default['unifiedpush']['postgresql']['port'] = 5432
default['unifiedpush']['postgresql']['listen_address'] = 'localhost'
default['unifiedpush']['postgresql']['max_connections'] = 200
default['unifiedpush']['postgresql']['md5_auth_cidr_addresses'] = []
default['unifiedpush']['postgresql']['trust_auth_cidr_addresses'] = ['localhost', '127.0.0.1/32','::1/128']
default['unifiedpush']['postgresql']['shmmax'] = node['kernel']['machine'] =~ /x86_64/ ? 17179869184 : 4294967295
default['unifiedpush']['postgresql']['shmall'] = node['kernel']['machine'] =~ /x86_64/ ? 4194304 : 1048575
default['unifiedpush']['postgresql']['semmsl'] = 250
default['unifiedpush']['postgresql']['semmns'] = 32000
default['unifiedpush']['postgresql']['semopm'] = 32
default['unifiedpush']['postgresql']['semmni'] = ((node['unifiedpush']['postgresql']['max_connections'].to_i / 16) + 250)

# Resolves CHEF-3889
if (node['memory']['total'].to_i / 4) > ((node['unifiedpush']['postgresql']['shmmax'].to_i / 1024) - 2097152)
  # guard against setting shared_buffers > shmmax on hosts with installed RAM > 64GB
  # use 2GB less than shmmax as the default for these large memory machines
  default['unifiedpush']['postgresql']['shared_buffers'] = "14336MB"
else
  default['unifiedpush']['postgresql']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / (1024)}MB"
end

default['unifiedpush']['postgresql']['work_mem'] = "8MB"
default['unifiedpush']['postgresql']['effective_cache_size'] = "#{(node['memory']['total'].to_i / 2) / (1024)}MB"
default['unifiedpush']['postgresql']['max_wal_size'] = "1GB"
default['unifiedpush']['postgresql']['checkpoint_timeout'] = "5min"
default['unifiedpush']['postgresql']['checkpoint_completion_target'] = 0.9
default['unifiedpush']['postgresql']['checkpoint_warning'] = "30s"

###
# MSSQL - Installation is not supported, only jdbc/odbc usage.
###
default['unifiedpush']['mssql']['server'] = "localhost"
default['unifiedpush']['mssql']['port'] = nil
default['unifiedpush']['mssql']['username'] = "sa"
default['unifiedpush']['mssql']['password'] = "sa"
default['unifiedpush']['mssql']['logon'] = true
default['unifiedpush']['mssql']['azure_logon'] = false
default['unifiedpush']['mssql']['instance'] = nil

###
# MySQL - Installation is not supported, only jdbc usage.
###
default['unifiedpush']['mysql']['server'] = "localhost"
default['unifiedpush']['mysql']['port'] = 3306
default['unifiedpush']['mysql']['username'] = "root"
default['unifiedpush']['mysql']['password'] = "password"

###
# MariaDB - Installation is not supported, only jdbc usage.
###
default['unifiedpush']['mariadb']['server'] = "localhost"
default['unifiedpush']['mariadb']['port'] = 3306
default['unifiedpush']['mariadb']['username'] = "root"
default['unifiedpush']['mariadb']['password'] = "password"

####
# Web server
####
# Username for the webserver user
default['unifiedpush']['web-server']['username'] = "aerobase-www"
default['unifiedpush']['web-server']['password'] = "$1$8AKNexhr$XEYpJFyWMcI.c96XLKLSk/"
default['unifiedpush']['web-server']['uid'] = nil
default['unifiedpush']['web-server']['gid'] = nil
default['unifiedpush']['web-server']['shell'] = "/bin/false"
default['unifiedpush']['web-server']['home'] = "#{node['package']['runtime-dir']}/nginx"
# When bundled nginx is disabled we need to add the external webserver user to the Unifiedpush webserver group
default['unifiedpush']['web-server']['external_users'] = []

####
#NGINX
####
default['unifiedpush']['nginx']['enable'] = true
default['unifiedpush']['nginx']['ha'] = false
# Delayed start service on windows
default['unifiedpush']['nginx']['delayed_start'] = false
default['unifiedpush']['nginx']['dir'] = "#{node['package']['runtime-dir']}/nginx"
default['unifiedpush']['nginx']['log_directory'] = "#{node['package']['logs-dir']}/nginx"
default['unifiedpush']['nginx']['log_rotation']['file_maxbytes'] = 104857600
default['unifiedpush']['nginx']['log_rotation']['num_to_keep'] = 10
default['unifiedpush']['nginx']['log_2xx_3xx'] = true
default['unifiedpush']['nginx']['worker_processes'] = node['cpu']['total'].to_i
default['unifiedpush']['nginx']['worker_connections'] = 10240
default['unifiedpush']['nginx']['sendfile'] = 'off'
default['unifiedpush']['nginx']['tcp_nopush'] = 'on'
default['unifiedpush']['nginx']['tcp_nodelay'] = 'on'
default['unifiedpush']['nginx']['proxy_buffer_size'] = '8k'
default['unifiedpush']['nginx']['proxy_buffers'] = '32 16k'
default['unifiedpush']['nginx']['proxy_busy_buffers_size'] = '32k'
default['unifiedpush']['nginx']['server_names_hash_bucket_size'] = "64"
default['unifiedpush']['nginx']['gzip'] = "on"
default['unifiedpush']['nginx']['gzip_http_version'] = "1.0"
default['unifiedpush']['nginx']['gzip_comp_level'] = "2"
default['unifiedpush']['nginx']['gzip_proxied'] = "any"
default['unifiedpush']['nginx']['gzip_types'] = [ "text/plain", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript", "application/json" ]
default['unifiedpush']['nginx']['keepalive_timeout'] = 65
default['unifiedpush']['nginx']['client_max_body_size'] = '250m'
default['unifiedpush']['nginx']['proxy_cache'] = false
default['unifiedpush']['nginx']['cache_max_size'] = '10g'
default['unifiedpush']['nginx']['cache_expires'] = '48h'
default['unifiedpush']['nginx']['resolver'] = nil # set nginx resolver tag e,g '8.8.8.8 8.8.4.4'
default['unifiedpush']['nginx']['software_lb'] = false
# Set google analytics access from reverse proxy
# When analytics is true, resolver must be set
default['unifiedpush']['nginx']['analytics'] = false
default['unifiedpush']['nginx']['redirect_http_to_https'] = false
default['unifiedpush']['nginx']['redirect_http_to_https_port'] = 80
default['unifiedpush']['nginx']['ssl_certificate'] = "#{node['package']['config-dir']}/ssl/#{node['fqdn']}.crt"
default['unifiedpush']['nginx']['ssl_certificate_key'] = "#{node['package']['config-dir']}/ssl/#{node['fqdn']}.key"
default['unifiedpush']['nginx']['ssl_ciphers'] = "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"
default['unifiedpush']['nginx']['ssl_prefer_server_ciphers'] = "on"
default['unifiedpush']['nginx']['ssl_protocols'] = "TLSv1 TLSv1.1 TLSv1.2" # recommended by https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html & https://cipherli.st/
default['unifiedpush']['nginx']['ssl_session_cache'] = "builtin:1000  shared:SSL:10m" # recommended in http://nginx.org/en/docs/http/ngx_http_ssl_module.html
default['unifiedpush']['nginx']['ssl_session_timeout'] = "5m" # default according to http://nginx.org/en/docs/http/ngx_http_ssl_module.html
default['unifiedpush']['nginx']['ssl_dhparam'] = nil # Path to dhparam.pem
default['unifiedpush']['nginx']['listen_addresses'] = ['*']
default['unifiedpush']['nginx']['listen_addresses_ipv6'] = ['::']
default['unifiedpush']['nginx']['listen_ipv4_only'] = false
default['unifiedpush']['nginx']['listen_port'] = nil # override only if you have a reverse proxy
default['unifiedpush']['nginx']['listen_https'] = nil # override only if your reverse proxy internally communicates over HTTP
default['unifiedpush']['nginx']['set_real_ip_from'] = nil # array type of network CIDR
default['unifiedpush']['nginx']['set_real_ip_header'] = "X-Forwarded-For"
default['unifiedpush']['nginx']['set_real_ip_recursive'] = "on"
default['unifiedpush']['nginx']['set_intr_ip_from'] = nil # array type of internal network ips ['1.2.3', '1.2.3.4']
default['unifiedpush']['nginx']['set_intr_map_name'] = 'isinternalx' # isinternalr (using realip_remote_addr) | isinternalx (using x-forwarded-for)
default['unifiedpush']['nginx']['custom_nginx_config'] = nil
default['unifiedpush']['nginx']['custom_http_config'] = nil
default['unifiedpush']['nginx']['custom_aerobase_config'] = nil

###
# Logging (svlog* attributes are used in runit log config)
# logrotate * attributes are used in logrotare-service.erb
###
default['unifiedpush']['logging']['svlogd_size'] = 200 * 1024 * 1024 # rotate after 200 MB of log data
default['unifiedpush']['logging']['svlogd_num'] = 30 # keep 30 rotated log files
default['unifiedpush']['logging']['svlogd_timeout'] = 24 * 60 * 60 # rotate after 24 hours
default['unifiedpush']['logging']['svlogd_filter'] = "gzip" # compress logs with gzip
default['unifiedpush']['logging']['svlogd_udp'] = nil # transmit log messages via UDP
default['unifiedpush']['logging']['svlogd_prefix'] = nil # custom prefix for log messages
default['unifiedpush']['logging']['udp_log_shipping_host'] = nil # remote host to ship log messages to via UDP
default['unifiedpush']['logging']['udp_log_shipping_port'] = 514 # remote host to ship log messages to via UDP
default['unifiedpush']['logging']['logrotate_frequency'] = "daily" # rotate logs daily
default['unifiedpush']['logging']['logrotate_size'] = nil # do not rotate by size by default
default['unifiedpush']['logging']['logrotate_rotate'] = 30 # keep 30 rotated logs
default['unifiedpush']['logging']['logrotate_compress'] = "compress" # see 'man logrotate'
default['unifiedpush']['logging']['logrotate_method'] = "copytruncate" # see 'man logrotate'
default['unifiedpush']['logging']['logrotate_postrotate'] = nil # no postrotate command by default

###
# Logrotate
###
default['unifiedpush']['logrotate']['enable'] = true
default['unifiedpush']['logrotate']['ha'] = false
default['unifiedpush']['logrotate']['dir'] = "#{node['package']['runtime-dir']}/logrotate"
default['unifiedpush']['logrotate']['log_directory'] = "#{node['package']['logs-dir']}/logrotate"
default['unifiedpush']['logrotate']['log_rotation']['file_maxbytes'] = 104857600
default['unifiedpush']['logrotate']['log_rotation']['num_to_keep'] = 10
default['unifiedpush']['logrotate']['services'] = %w{nginx aerobase-server}
default['unifiedpush']['logrotate']['pre_sleep'] = 600 # sleep 10 minutes before rotating after start-up
default['unifiedpush']['logrotate']['post_sleep'] = 3000 # wait 50 minutes after rotating
