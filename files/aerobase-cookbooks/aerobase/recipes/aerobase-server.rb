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

require 'openssl'

# Default location of install-dir is /opt/aerobase/. This path is set during build time.
# DO NOT change this value unless you are building your own Aerobase packages
install_dir = node['package']['install-dir']
ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

server_dir = node['unifiedpush']['aerobase-server']['dir']
server_etc_dir = "#{server_dir}/etc"

account_helper = AccountHelper.new(node)
os_helper = OsHelper.new(node)

aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group
aerobase_password = account_helper.aerobase_password

unifiedpush_vars = node['unifiedpush']['aerobase-server'].to_hash
global_vars = node['unifiedpush']['global'].to_hash
all_vars = unifiedpush_vars.merge(global_vars)

# Stop windows service before we try to override files.
if os_helper.is_windows?
  include_recipe "aerobase::aerobase-server_stop"
else
  execute "/opt/aerobase/bin/aerobase-ctl stop aerobase-server" do
    retries 20
    only_if { ::File.exist? "#{server_dir}/bin/ks.sh" }
  end
end

include_recipe "aerobase::keycloak-server"

# create themes dir
directory "#{server_dir}/themes" do
  owner aerobase_user
  group aerobase_group
  mode "0775"
end

# Copy themes
ruby_block 'copy_aerobase_theme' do
  block do
    FileUtils.cp_r "#{install_dir}/embedded/apps/themes/.", "#{server_dir}/themes"
    #FileUtils.cp_r "#{install_dir}/embedded/apps/themes/aerobase/admin/resources/img/logo.png", "#{server_dir}/themes/keycloak/admin/resources/img/keyclok-logo.png"
    #FileUtils.cp_r "#{install_dir}/embedded/apps/themes/aerobase/admin/resources/img/favicon.ico", "#{server_dir}/themes/keycloak/admin/resources/img/favicon.ico"
  end
  action :run
end

# Make sure owner is aerobase_user
directory server_dir do
  owner aerobase_user
  group aerobase_group
  recursive true
  mode "0775"
end

if os_helper.is_windows?
  directory server_dir do
    if aerobase_group
      rights :read, aerobase_group, :applies_to_children => true
    end
    rights :full_control, aerobase_user,  :applies_to_children => true
  end
else
  execute "chown-server_dir" do
    command "chown -R #{aerobase_user}:#{aerobase_group} #{server_dir}"
    action :run
  end
end

if os_helper.is_windows?
  include_recipe "aerobase::aerobase-server-win-service"
else
  component_runit_service "aerobase-server" do
    package "unifiedpush"
    retry_delay 1
    retries 3
  end

  execute "/opt/aerobase/bin/aerobase-ctl restart aerobase-server" do
    retries 20
  end
end
