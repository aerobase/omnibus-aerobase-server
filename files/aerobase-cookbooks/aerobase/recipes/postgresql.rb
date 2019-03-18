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

account_helper = AccountHelper.new(node)
omnibus_helper = OmnibusHelper.new(node)
os_helper = OsHelper.new(node)

install_dir = node['package']['install-dir']

postgresql_dir = node['unifiedpush']['postgresql']['dir']
postgresql_data_dir = node['unifiedpush']['postgresql']['data_dir']
postgresql_data_dir_symlink = File.join(postgresql_dir, "data")
postgresql_log_dir = node['unifiedpush']['postgresql']['log_directory']
postgresql_delayed_start = node['unifiedpush']['postgresql']['delayed_start']
postgresql_user = account_helper.postgresql_user
postgresql_password = account_helper.postgresql_password
postgresql_group = account_helper.postgresql_group

service_label = node['unifiedpush']['global']['srv_label']
service_name = "Aerobase-PostgreSQL-Server"

account "Postgresql user and group" do
  username postgresql_user
  if os_helper.is_windows?
	password postgresql_password
  end 
  uid node['unifiedpush']['postgresql']['uid']
  ugid postgresql_group
  groupname postgresql_group
  group_members postgresql_user
  gid node['unifiedpush']['postgresql']['gid']
  shell node['unifiedpush']['postgresql']['shell']
  home node['unifiedpush']['postgresql']['home']
  manage node['unifiedpush']['manage-accounts']['enable']
end

directory postgresql_dir do
  owner postgresql_user
  mode "0755"
  recursive true
end

[
  postgresql_data_dir,
  postgresql_log_dir
].each do |dir|
  directory dir do
    owner postgresql_user
    mode "0700"
    recursive true
  end
end

link postgresql_data_dir_symlink do
  to postgresql_data_dir
  not_if { postgresql_data_dir == postgresql_data_dir_symlink }
end

file File.join(node['unifiedpush']['postgresql']['home'], ".profile") do
  owner postgresql_user
  mode "0600"
  content <<-EOH
PATH=#{node['unifiedpush']['postgresql']['user_path']}
EOH
end

if os_helper.not_windows?
  sysctl "kernel.shmmax" do
    value node['unifiedpush']['postgresql']['shmmax']
  end

  sysctl "kernel.shmall" do
    value node['unifiedpush']['postgresql']['shmall']
  end

  sem = "#{node['unifiedpush']['postgresql']['semmsl']} "
  sem += "#{node['unifiedpush']['postgresql']['semmns']} "
  sem += "#{node['unifiedpush']['postgresql']['semopm']} "
  sem += "#{node['unifiedpush']['postgresql']['semmni']}"
  sysctl "kernel.sem" do
    value sem
  end
end
  
execute "#{install_dir}/embedded/bin/initdb -D #{postgresql_data_dir} -E UTF8" do
  not_if { File.exists?(File.join(postgresql_data_dir, "PG_VERSION")) }
  user postgresql_user
  if os_helper.is_windows?
    password postgresql_password
  end
end

postgresql_config = File.join(postgresql_data_dir, "postgresql.conf")

if os_helper.is_windows? 
  encoding = "English_United States.1252" 
  shared_memory = "windows"
else
  encoding = "en_US.UTF-8"
  shared_memory = "posix"
end

template postgresql_config do
  source "postgresql.conf.erb"
  owner postgresql_user
  mode "0644"
  variables(node['unifiedpush']['postgresql'].to_hash.merge({
    :encoding => encoding, 
	:shared_memory =>  shared_memory
  }))
end

pg_hba_config = File.join(postgresql_data_dir, "pg_hba.conf")

template pg_hba_config do
  source "pg_hba.conf.erb"
  owner postgresql_user
  mode "0644"
  variables(node['unifiedpush']['postgresql'].to_hash)
end

template File.join(postgresql_data_dir, "pg_ident.conf") do
  owner postgresql_user
  mode "0644"
  variables(node['unifiedpush']['postgresql'].to_hash)
end

if os_helper.is_windows?
  service "#{service_name}" do
    action :stop
  end
  
  windows_service "#{service_name}" do
    action :create
    binary_path_name "\"#{install_dir}/embedded/bin/pg_ctl.exe\" runservice -N \"#{service_name}\" -D \"#{postgresql_data_dir}\" -w"
    startup_type :automatic
	delayed_start postgresql_delayed_start
	display_name "#{service_label} PostgreSQL" 
    description "#{service_label} PostgreSQL (Powered by Aerobase)"
  end

  service "#{service_name}" do
    action :restart
  end
else
  component_runit_service "postgresql" do
    package "unifiedpush"
    control ['t']
  end

  execute "#{install_dir}/bin/aerobase-ctl restart postgresql" do
    retries 20
  end
end