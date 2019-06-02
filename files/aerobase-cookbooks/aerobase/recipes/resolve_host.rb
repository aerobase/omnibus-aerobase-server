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

require "resolv"
require "socket"

hostname = node['fqdn']
hostname_resolved = false
ruby_block "Resolving hostname address" do
  block do
    begin
      address = Resolv.getaddress(hostname)
      hostname_resolved = true
    rescue
      puts address
    end
  end
end

hostname "Set hostname entry to #{hostname} - 127.0.0.1" do
  hostname  "#{hostname}"
  ipaddress "#{node['ipaddress']}"
  windows_reboot false
  compile_time false
  only_if { !hostname_resolved }
end
