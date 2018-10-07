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

cmd_helper = CmdHelper.new(node)

nginx_dir = node['unifiedpush']['nginx']['dir']

# Stop service first
execute "stop nginx service" do
  command "echo 'Stoping nginx service ...'"
  only_if { cmd_helper.success("#{nginx_dir}/aerobasesw.exe stop") }
end

ruby_block "Waiting 5 seconds for nginx service to stop ..." do
  block do
    sleep 5
  end
end

execute "uninstall nginx service" do
  command "#{nginx_dir}/aerobasesw.exe uninstall"
  only_if { ::File.exist? "#{nginx_dir}/aerobasesw.exe" }
end