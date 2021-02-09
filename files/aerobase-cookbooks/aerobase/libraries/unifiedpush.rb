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

# The unifiedpush module in this file is used to parse /etc/aerobase/aerobase.rb.
#
# Warning to the reader:
# Because the Ruby DSL in /etc/aerobase/aerobase.rb does not accept hyphens (_) in
# section names, this module translates names like 'aerobase_server' to the
# correct 'aerobase-server' in the `generate_hash` method. This module is the only
# place in the cookbook where we write 'aerobase_server'.

require 'mixlib/config'
require 'chef/mash'
require 'chef/json_compat'
require 'chef/mixin/deep_merge'
require 'securerandom'
require 'uri'
require 'public_suffix'

module Unifiedpush
  extend(Mixlib::Config)

  bootstrap Mash.new
  global Mash.new
  user Mash.new
  postgresql Mash.new
  mssql Mash.new
  mysql Mash.new
  mariadb Mash.new
  unifiedpush_server Mash.new
  aerobase_server Mash.new
  keycloak_server Mash.new
  web_server Mash.new
  nginx Mash.new
  logging Mash.new
  logrotate Mash.new
  node nil
  external_url nil

  class << self

    # guards against creating secrets on non-bootstrap node
    def generate_hex(chars)
      SecureRandom.hex(chars)
    end

    def generate_secrets(node_name)
      secret_helper = SecretsHelper.new(node)
	  secret_helper.read_unifiedpush_secrets

      # Note: If you add another secret to generate here make sure it gets written to disk in SecretsHelper.write_to_unifiedpush_secrets
      Unifiedpush['aerobase_server']['secret_token'] ||= generate_hex(64)

      # Note: Besides the section below, unifiedpush-secrets.json will also change
      # in CiHelper in libraries/helper.rb
      secret_helper.write_to_unifiedpush_secrets
    end

    def parse_external_url
      return unless external_url

      uri = URI(external_url.to_s)

      unless uri.host
        raise "Aerobase external URL must include a schema and FQDN, e.g. http://aerobase.example.com/"
      end

      info("Installing according to external_url -> " + uri.host)
	  
      Unifiedpush['global']['fqdn'] = external_url.to_s
      Unifiedpush['global']['top_domain'] = DomainHelper.new(node).parse_domain(uri.host)
      
      # access_port is derived from external url 
      Unifiedpush['global']['access_port'] = uri.port

      config_dir = node['package']['config-dir']

      case uri.scheme
      when "http"
        server_https = false
      when "https"
        server_https = true
        Unifiedpush['nginx']['ssl_certificate'] ||= "#{config_dir}/ssl/#{uri.host}.crt"
        Unifiedpush['nginx']['ssl_certificate_key'] ||= "#{config_dir}/ssl/#{uri.host}.key"
      else
        raise "Unsupported external URL scheme: #{uri.scheme}"
      end

      [
        # %w{aerobase_server server_host} corresponds to
        # Unifiedpush['aerobase_server']['server_host'], etc.
        [%w{aerobase_server server_host}, %W{#{uri.host}}],
        [%w{aerobase_server server_https}, [server_https]]
      ].each do |left, right|
        if Unifiedpush[left.first][left.last].nil?
          # Only If the user does not explicitly sets a value for e.g.
          Unifiedpush[left.first][left.last] = right.first
        end
      end

      Unifiedpush['aerobase_server']['webapp_host'] = Unifiedpush['global']['top_domain']

      unless ["", "/"].include?(uri.path)
        raise "Unsupported external URL path: #{uri.path}"
      end
    end

    def parse_database_settings
      # If the user wants to run the internal Postgres service using an alternative
      # DB username, host or port, then those settings should also be applied to
      # unifiedpush.
	  
      # Use either mssql mysql or postgresql props
      db_adapter =  Unifiedpush['aerobase_server']['db_adapter']
      if db_adapter.nil?
        # Use default if no override was specified
        db_adapter =  node['unifiedpush']['aerobase-server']['db_adapter']
      end
      [
        # %w{keycloak_server db_username} corresponds to
        # Unifiedpush['keycloak_server']['db_username'], etc.
        [%w{keycloak_server db_username}, %W{#{db_adapter} sql_kc_user}],
        [%w{keycloak_server db_host}, %W{#{db_adapter} server}],
        [%w{keycloak_server db_port}, %W{#{db_adapter} port}]
      ].each do |left, right|
        if ! Unifiedpush[left.first][left.last].nil?
          # If the user explicitly sets a value for e.g.
          # unifiedpush['db_port'] in unifiedpush.rb then we should never override
          # that.
          next
        end
		
        better_value_from_unifiedpush_rb = Unifiedpush[right.first][right.last]
        default_from_attributes = node['unifiedpush'][right.first.gsub('_', '-')][right.last]
        Unifiedpush[left.first][left.last] = better_value_from_unifiedpush_rb || default_from_attributes
      end
    end

    def parse_contactpoints_settings
      # If the user wants to run the in symetric cluster mode,
      # then those settings should also be applied to  aerobase-server.
      [
        # %w{aerobase_server server_contactpoints} corresponds to
        # Unifiedpush['aerobase_server']['server_contactpoints'], etc.
        [%w{aerobase_server server_contactpoints}, %w{global contactpoints}],
      ].each do |left, right|
        if ! Unifiedpush[left.first][left.last].nil?
          # If the user explicitly sets a value for e.g.
          # unifiedpush['db_port'] in unifiedpush.rb then we should never override
          # that.
          next
        end

        better_value_from_unifiedpush_rb = Unifiedpush[right.first][right.last]
        default_from_attributes = node['unifiedpush'][right.first.gsub('_', '-')][right.last]
        Unifiedpush[left.first][left.last] = better_value_from_unifiedpush_rb || default_from_attributes
      end
    end

    def parse_nginx_listen_address
      return unless nginx['listen_address']

      # The user specified a custom NGINX listen address with the legacy
      # listen_address option. We have to convert it to the new
      # listen_addresses setting.
      nginx['listen_addresses'] = [nginx['listen_address']]
    end

    def parse_nginx_listen_ports
      [
        [%w{nginx listen_port}, %w{global access_port}]
      ].each do |left, right|
        if !Unifiedpush[left.first][left.last].nil?
          next
        end

        default_set_access_port = node['unifiedpush'][right.first.gsub('_', '-')][right.last]
        user_set_access_port = Unifiedpush[right.first][right.last]

        Unifiedpush[left.first][left.last] = user_set_access_port || default_set_access_port
      end
    end

    def generate_hash
      results = { "unifiedpush" => {} }
      [
        "bootstrap",
        "global",
        "user",
	"unifiedpush_server",
        "aerobase_server",
        "keycloak_server",
        "web_server",
        "nginx",
        "logging",
        "logrotate",
        "postgresql",
        "mssql",
        "mysql",
        "mariadb",
        "external_url"
      ].each do |key|
        rkey = key.gsub('_', '-')
        results['unifiedpush'][rkey] = Unifiedpush[key]
      end

      results
    end

    def generate_config(node_name)
      # generate_secrets(node_name)
      parse_external_url
      parse_database_settings
      parse_contactpoints_settings
      parse_nginx_listen_address
      parse_nginx_listen_ports
      # The last step is to convert underscores to hyphens in top-level keys
      generate_hash
    end
  end
end

class DomainHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def parse_domain(domain)
    return PublicSuffix.domain(domain, ignore_private: true)
  end
end
