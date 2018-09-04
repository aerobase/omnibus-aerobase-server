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

require 'mixlib/shellout'

module ShellOutHelper
  def do_shell_out(cmd, user = nil, password = nil, cwd = nil)
    if OsHelper.new(node).is_windows?
      o = Mixlib::ShellOut.new(cmd, :user=>user, :password=>password, :cwd=>cwd)
    else
      o = Mixlib::ShellOut.new(cmd, :user=>user, :cwd=>cwd)
    end 
    o.run_command
    o
  rescue Errno::EACCES
    Chef::Log.info("Cannot execute #{cmd}.")
    o
  rescue Errno::ENOENT
    Chef::Log.info("#{cmd} does not exist.")
    o
  end
  def success?(cmd, user = nil, password = nil)
    o = do_shell_out(cmd, user, password)
    !o.error?
  end
  def failure?(cmd)
    o = do_shell_out(cmd)
    o.error?
  end
end

class CmdHelper
  include ShellOutHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end
  
  def success(cmd, user = nil, password = nil)
    success?(cmd, user, password)
  end
  
  def failure(cmd)
    failure?(cmd)
  end
end

class PgHelper
  include ShellOutHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def database_exists?(db_name, user = nil, password = nil)
    if OsHelper.new(node).is_windows?
      grep_cmd = "findstr"
    else
      grep_cmd = "grep -x"
    end
    psql_cmd(["-d \"postgres\"",
              "-c \"select datname from pg_database\" -A",
              "|#{grep_cmd} #{db_name}"], user, password)
  end

  def user_exists?(db_user, user = nil, password = nil)
    if OsHelper.new(node).is_windows?
      grep_cmd = "findstr"
    else
      grep_cmd = "grep -x"
    end
    psql_cmd(["-d \"postgres\"",
              "-c \"select usename from pg_user\" -A",
              "|#{grep_cmd} \"#{db_user}\""], user, password)
  end

  def psql_cmd(cmd_list, user = nil, password = nil)
    install_dir = node['package']['install-dir']
    cmd = []
    if OsHelper.new(node).not_windows?
      cmd << "#{install_dir}/embedded/bin/chpst"
      cmd << "-u #{pg_user}"
      cmd << "#{install_dir}/embedded/bin/psql"
    else
      cmd << "\"#{install_dir}/embedded/bin/psql\""
    end

    cmd << "-h #{pg_host}"
    unless user.nil?
      cmd << "-U #{user}"
    end
    cmd << "--port #{pg_port}"
    cmd << cmd_list.join(" ")
    cmd = cmd.join(" ")

    if OsHelper.new(node).is_windows?
      success?(cmd, user, password)
    else 
      # Linux based dist is executed using chpst (root user)
      success?(cmd)
    end 
  end
  
  def psql_jdbc_url(db_host, db_port, db_database)
    url = "jdbc:postgresql://#{db_host}:#{db_port}/#{db_database}"
    url
  end

  def pg_user
    node['unifiedpush']['postgresql']['username']
  end

  def pg_port
    node['unifiedpush']['postgresql']['port']
  end

  def pg_host
    node['unifiedpush']['postgresql']['server']
  end

end

class MsSQLHelper
  include ShellOutHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def database_exists?(db_name, user = nil, password = nil)
    mssql_exec(["\"SELECT name FROM master.dbo.sysdatabases WHERE name = '#{db_name}'\"", "|findstr \"#{db_name}\""])
  end

  def user_exists?(db_user, user = nil, password = nil)
    mssql_exec(["\"SELECT name FROM [sys].[server_principals] WHERE  name = '#{db_user}'\"", "|findstr \"#{db_user}\""])
  end

  def mssql_exec(cmd_list, user = nil, password = nil)
    cmd = mssql_cmd(cmd_list)	
    success?(cmd, user, password)
  end
  
  def mssql_cmd(cmd_list)
    install_dir = node['package']['install-dir']
    cmd = []
	
    cmd << "sqlcmd -b"
	
    cmd << "-S #{mssql_server}"
    if mssql_logon
      cmd << "-U #{mssql_user} -P #{mssql_password}"
    else
      cmd << "-E"
    end
    if mssql_azure_logon
      cmd << "-G"
    end

    cmd << "-Q"
    cmd << cmd_list.join(" ")
    cmd = cmd.join(" ")	
    cmd
  end 
  
  def mssql_jdbc_url(db_host, db_port, db_database, db_username, db_password)
    login = mssql_login ? "user=#{db_username};password=#{db_username};" : "integratedSecurity=true;"
      instance = mssql_instance.nil? ? "" : "\\#{mssql_instance}" 
    url = "jdbc:sqlserver://#{db_host}#{instance}:#{db_port};databaseName=#{db_database};#{login}"
    url
  end

  def mssql_logon
    node['unifiedpush']['mssql']['logon']
  end
  
  def mssql_azure_logon
    node['unifiedpush']['mssql']['azure_logon']
  end
  
  def mssql_user
    node['unifiedpush']['mssql']['username']
  end

  def mssql_password
    node['unifiedpush']['mssql']['password']
  end
  
  def mssql_port
    node['unifiedpush']['mssql']['port']
  end

  def mssql_server
    node['unifiedpush']['mssql']['server']
  end
  
  def mssql_login
    node['unifiedpush']['mssql']['logon']
  end
  
  def mssql_instance
    node['unifiedpush']['mssql']['instance']
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
