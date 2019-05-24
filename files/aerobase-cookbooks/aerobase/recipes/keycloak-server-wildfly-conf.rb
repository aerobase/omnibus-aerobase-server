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
aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

server_dir = node['unifiedpush']['aerobase-server']['dir']
keycloak_vars = node['unifiedpush']['keycloak-server'].to_hash
global_vars = node['unifiedpush']['global'].to_hash

# Prepare ups realm json
template "#{server_dir}/standalone/configuration/keycloak-server-aerobase-realm.json" do
  owner aerobase_user
  group aerobase_group
  mode 0755
  source "keycloak-server-aerobase-realm-json.erb"
  variables(keycloak_vars.merge(global_vars))
end

include_recipe "aerobase::keycloak-embeded-wildfly-conf"
