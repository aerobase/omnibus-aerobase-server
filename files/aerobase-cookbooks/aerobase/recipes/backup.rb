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
## Required for find_executable
require 'mkmf'

# Get OS user/group
account_helper = AccountHelper.new(node)
aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

# Prepare backup configuration files
install_dir = node['package']['install-dir']
home_dir = node['unifiedpush']['user']['home']
backup_dir = node['unifiedpush']['global']['backup_path']

directory "#{backup_dir}" do
  owner aerobase_user
  group aerobase_group
  mode "0774"
  action :create
end

template "#{home_dir}/postgresql-backup.conf" do
  source "postgresql-backup.erb"
  owner aerobase_user
  mode "0664"
  variables(node['unifiedpush']['unifiedpush-server'].to_hash)
  not_if { !node['unifiedpush']['postgresql']['enable'] }
end

cron 'postgresql-nightly-backup' do
  minute "0"
  hour "3"
  user "root"
  command "sh -x #{install_dir}/embedded/cookbooks/unifiedpush/libraries/pg_backup_rotated.sh -c #{home_dir}/postgresql-backup.conf > /tmp/postgresql-backup.log 2>&1"
  not_if { !node['unifiedpush']['postgresql']['enable'] }
  only_if { find_executable 'crontab' }
end
