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

account_helper = AccountHelper.new(node)
unifiedpush_user = account_helper.unifiedpush_user

server_dir = node['unifiedpush']['unifiedpush-server']['dir']
keycloak_vars = node['unifiedpush']['keycloak-server'].to_hash
global_vars = node['unifiedpush']['global'].to_hash

# Prepare ups realm json
template "#{server_dir}/standalone/configuration/keycloak-server-ups-realm.json" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "keycloak-server-ups-realm-json.erb"
  variables(keycloak_vars.merge(global_vars))
end

# Prepare upsi realm json
template "#{server_dir}/standalone/configuration/keycloak-server-upsi-realm.json" do
  owner unifiedpush_user
  group "root"
  mode 0755
  source "keycloak-server-upsi-realm-json.erb"
  variables(keycloak_vars.merge(global_vars))
end

if node['unifiedpush']['keycloak-server']['enable']
    include_recipe "unifiedpush::keycloak-embeded-wildfly-conf"
end
