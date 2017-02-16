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

account_helper = AccountHelper.new(node)

unifiedpush_username = account_helper.unifiedpush_user
unifiedpush_group = account_helper.unifiedpush_group

unifiedpush_home = node['unifiedpush']['user']['home']

directory unifiedpush_home do
  recursive true
end

account "Unifiedpush user and group" do
  username unifiedpush_username
  uid node['unifiedpush']['user']['uid']
  ugid unifiedpush_group
  groupname unifiedpush_group
  gid node['unifiedpush']['user']['gid']
  shell node['unifiedpush']['user']['shell']
  home unifiedpush_home
  manage node['unifiedpush']['manage-accounts']['enable']
end

postgresql_user = account_helper.postgresgl_user
postgresql_group = account_helper.postgresgl_group

# Create postgresql user/group
account "Postgresql user and group" do
  username postgresql_user
  uid node['unifiedpush']['postgresql']['uid']
  ugid postgresql_user
  groupname postgresql_group
  gid node['unifiedpush']['postgresql']['gid']
  shell node['unifiedpush']['postgresql']['shell']
  home node['unifiedpush']['postgresql']['home']
  manage node['unifiedpush']['manage-accounts']['enable']
end
