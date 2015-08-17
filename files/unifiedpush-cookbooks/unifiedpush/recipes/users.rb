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

unifiedpush_username = node['unifiedpush']['user']['username']
unifiedpush_group = node['unifiedpush']['user']['group']
unifiedpush_home = node['unifiedpush']['user']['home']

directory unifiedpush_home do
  recursive true
end

# Create the group for the unifiedpush user
group unifiedpush_group do
  gid node['unifiedpush']['user']['gid']
  system true
end

# Create the unifiedpush user
user unifiedpush_username do
  shell node['unifiedpush']['user']['shell']
  home unifiedpush_home
  uid node['unifiedpush']['user']['uid']
  gid unifiedpush_group
  system true
end
