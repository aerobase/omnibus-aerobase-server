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

aerobase_username = account_helper.aerobase_user
aerobase_password = account_helper.aerobase_password
aerobase_group = account_helper.aerobase_group
aerobase_home = node['unifiedpush']['user']['home']
os_helper = OsHelper.new(node)

directory aerobase_home do
  recursive true
end
 
account "Aerobase user and group" do
    username aerobase_username
	if os_helper.is_windows?
	  password aerobase_password
	end 
    uid node['unifiedpush']['user']['uid']
    ugid aerobase_group
    groupname aerobase_group
    gid node['unifiedpush']['user']['gid']
    shell node['unifiedpush']['user']['shell']
    home aerobase_home
    manage node['unifiedpush']['manage-accounts']['enable']
end  
