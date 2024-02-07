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

install_dir = node['package']['install-dir']
postgresql_data_dir = node['unifiedpush']['postgresql']['data_dir']
postgresql_delayed_start = node['unifiedpush']['postgresql']['delayed_start']

service_label = node['unifiedpush']['global']['srv_label']
win_service_name = "Aerobase-PostgreSQL-Server"

if os_helper.is_windows?
  include_recipe "aerobase::postgresql_stop"
  
  windows_service "#{win_service_name}" do
    action :create
    binary_path_name "\"#{install_dir}/embedded/bin/pg_ctl.exe\" runservice -N \"#{win_service_name}\" -D \"#{postgresql_data_dir}\" -w"
    startup_type :automatic
    delayed_start postgresql_delayed_start
    display_name "#{service_label} PostgreSQL" 
    description "#{service_label} PostgreSQL (Powered by Aerobase)"
  end

  service "#{win_service_name}" do
    action :restart
  end
end