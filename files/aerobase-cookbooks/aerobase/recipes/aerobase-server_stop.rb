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
cmd_helper = CmdHelper.new(node)

# Default location of install-dir is /opt/aerobase/. This path is set during build time.
# DO NOT change this value unless you are building your own Aerobase packages
install_dir = node['package']['install-dir']
server_dir = node['unifiedpush']['aerobase-server']['dir']

# Stop service first
if os_helper.is_windows?
  execute "stop aerobase-server service" do
    command "echo 'Stoping aerobase-server service ...'"
    only_if { cmd_helper.success("#{server_dir}/bin/aerobasesw.exe stop") }
  end

  ruby_block "Waiting 30 seconds for aerobase-server service to stop ..." do
    block do
      sleep 30
      only_if { cmd_helper.success("#{server_dir}/bin/aerobasesw.exe stop") }
    end
  end
end


