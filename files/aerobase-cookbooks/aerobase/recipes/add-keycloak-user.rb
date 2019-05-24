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
install_dir = node['package']['install-dir']
server_dir = node['unifiedpush']['aerobase-server']['dir']

os_helper = OsHelper.new(node)
cmd_helper = CmdHelper.new(node)

password = node['keycloak_admin_password']
user = node['keycloak_admin_user']
realm = node['keycloak_admin_realm']

file_name = "add-user-keycloak.sh"

if os_helper.is_windows?
  file_name = "add-user-keycloak.bat"
end

execute "#{server_dir}/bin/#{file_name} -r #{realm} -u #{user} -p #{password}" do
end