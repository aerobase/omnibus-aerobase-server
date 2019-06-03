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

# Default location of install-dir is /opt/aerobase/. This path is set during build time.
# DO NOT change this value unless you are building your own Aerobase packages
install_dir = node['package']['install-dir']
config_dir = node['package']['config-dir']
runtime_dir = node['package']['runtime-dir']
logs_dir = node['package']['logs-dir']
ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

# Stop All Services
[
  "aerobase-server", 
  "nginx",
  "postgresql"
].each do |service|
  if node["unifiedpush"][service]["enable"]
    include_recipe "aerobase::#{service}_stop"
  end
end

# AEROBASE-107 - This sectiokn can be removed once 2.2.3 is no longer available
ruby_block "Update aerobase.rb attributes" do
  block do
    begin
      file_name = "#{config_dir}/aerobase.rb"
      text = File.read(file_name)
      new_contents = text.gsub(/unifiedpush_server\[/, "aerobase_server\[")
      # Write changes to the file
      File.open(file_name, "w") {|file| file.puts new_contents }
    rescue
      puts "Failed to upgrade aerobase server, unable to modify #{config_dir}/aerobase.rb"
    end
  end
end
