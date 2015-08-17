#
# Cookbook Name:: runit
# Recipe:: systemd
#
# Copyright 2015.
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

directory '/usr/lib/systemd/system' do
  recursive true
end

cookbook_file "/usr/lib/systemd/system/unifiedpush-runsvdir.service" do
  mode "0644"
  source "unifiedpush-runsvdir.service"
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  notifies :run, 'execute[systemctl enable unifiedpush-runsvdir]', :immediately
  notifies :run, 'execute[systemctl start unifiedpush-runsvdir]', :immediately
end

# Remove old symlink
file "/etc/systemd/system/default.target.wants/unifiedpush-runsvdir.service" do
  action :delete
end

execute "systemctl daemon-reload" do
  action :nothing
end

execute "systemctl enable unifiedpush-runsvdir" do
  action :nothing
end

execute "systemctl start unifiedpush-runsvdir" do
  action :nothing
end
