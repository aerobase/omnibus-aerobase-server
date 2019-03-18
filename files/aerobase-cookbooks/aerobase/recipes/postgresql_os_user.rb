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
os_helper = OsHelper.new(node)

postgresql_user = account_helper.postgresql_user
postgresql_group = account_helper.postgresql_group
postgresql_password = account_helper.postgresql_password

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
