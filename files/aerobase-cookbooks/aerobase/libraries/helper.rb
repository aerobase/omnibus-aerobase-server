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

require 'mixlib/shellout'

module ShellOutHelper
  def do_shell_out(cmd, user = nil, cwd = nil)
    o = Mixlib::ShellOut.new(cmd, user: user, cwd: cwd)
    o.run_command
    o
  rescue Errno::EACCES
    Chef::Log.info("Cannot execute #{cmd}.")
    o
  rescue Errno::ENOENT
    Chef::Log.info("#{cmd} does not exist.")
    o
  end
  def success?(cmd)
    o = do_shell_out(cmd)
    o.exitstatus == 0
  end
  def failure?(cmd)
    o = do_shell_out(cmd)
    o.exitstatus != 0
  end
end

class PgHelper
  include ShellOutHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def is_running?
    omnibus_helper = OmnibusHelper.new(node)
    omnibus_helper.service_up?("postgresql")
  end

  def database_exists?(db_name)
    psql_cmd(["-d 'template1'",
              "-c 'select datname from pg_database' -A",
              "| grep -x #{db_name}"])
  end

  def user_exists?(db_user)
    psql_cmd(["-d 'template1'",
              "-c 'select usename from pg_user' -A",
              "|grep -x #{db_user}"])
  end

  def psql_cmd(cmd_list)
    install_dir = node['package']['install-dir']
    cmd = ["#{install_dir}/embedded/bin/chpst",
           "-u #{pg_user}",
           "#{install_dir}/embedded/bin/psql",
           "-h #{pg_host}",
           "--port #{pg_port}",
           cmd_list.join(" ")].join(" ")
    success?(cmd)
  end

  def pg_user
    node['unifiedpush']['postgresql']['username']
  end

  def pg_port
    node['unifiedpush']['postgresql']['port']
  end

  def pg_host
    node['unifiedpush']['postgresql']['unix_socket_directory']
  end

end

class SecretsHelper
  include ShellOutHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end
  
  def self.read_unifiedpush_secrets
    existing_secrets ||= Hash.new
	config_dir = node['package']['config-dir']
    if File.exists?("#{config_dir}/unifiedpush-secrets.json")
      existing_secrets = Chef::JSONCompat.from_json(File.read("#{config_dir}/unifiedpush-secrets.json"))
    end

    existing_secrets.each do |k, v|
      v.each do |pk, p|
        # Note: Specifiying a secret in unifiedpush.rb will take precendence over "unifiedpush-secrets.json"
        Unifiedpush[k][pk] ||= p
      end
    end
  end

  def self.write_to_unifiedpush_secrets
    secret_tokens = {
	  'unifiedpush' => {
		'secret_token' => Unifiedpush['unifiedpush']['secret_token'],
	  }
	}
	
	config_dir = node['package']['config-dir']
    if File.directory?(config_dir)
      File.open("#{config_dir}/unifiedpush-secrets.json", "w") do |f|
        f.puts(
          Chef::JSONCompat.to_json_pretty(secret_tokens)
        )
        system("chmod 0600 #{config_dir}/unifiedpush-secrets.json")
      end
    end
  end

end

module SingleQuoteHelper

  def single_quote(string)
   "'#{string}'" unless string.nil?
  end

end

class RedhatHelper

  def self.system_is_rhel7?
    platform_family == "rhel" && platform_version =~ /7\./
  end

  def self.platform_family
    case platform
    when /oracle/, /centos/, /redhat/, /scientific/, /enterpriseenterprise/, /amazon/, /xenserver/, /cloudlinux/, /ibm_powerkvm/, /parallels/
      "rhel"
    else
      "not redhat"
    end
  end

  def self.platform
    contents = read_release_file
    get_redhatish_platform(contents)
  end

  def self.platform_version
    contents = read_release_file
    get_redhatish_version(contents)
  end

  def self.read_release_file
    if File.exists?("/etc/redhat-release")
      contents = File.read("/etc/redhat-release").chomp
    else
      "not redhat"
    end
  end

  # Taken from Ohai
  # https://github.com/chef/ohai/blob/31f6415c853f3070b0399ac2eb09094eb81939d2/lib/ohai/plugins/linux/platform.rb#L23
  def self.get_redhatish_platform(contents)
    contents[/^Red Hat/i] ? "redhat" : contents[/(\w+)/i, 1].downcase
  end

  # Taken from Ohai
  # https://github.com/chef/ohai/blob/31f6415c853f3070b0399ac2eb09094eb81939d2/lib/ohai/plugins/linux/platform.rb#L27
  def self.get_redhatish_version(contents)
    contents[/Rawhide/i] ? contents[/((\d+) \(Rawhide\))/i, 1].downcase : contents[/release ([\d\.]+)/, 1]
  end
end

class OsHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end
  
  def is_windows?
	node['platform'] == 'windows'
  end
  
  def not_windows?
	node['platform'] != 'windows'
  end
end
