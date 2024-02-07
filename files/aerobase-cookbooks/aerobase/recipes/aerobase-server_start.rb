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

server_dir = node['unifiedpush']['aerobase-server']['dir']
service_name = "Aerobase-Application-Server"

# Stop aerobase-server first
if os_helper.is_windows?
  execute "restart aerobase-server service" do
    command "#{server_dir}/bin/aerobasesw.exe restart"
  end
  ruby_block "Waiting 30 seconds for aerobase-server service to restart ..." do
    block do
      sleep 30
    end
  end
end
