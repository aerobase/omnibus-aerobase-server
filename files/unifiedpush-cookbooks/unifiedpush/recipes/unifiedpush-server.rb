#
# Copyright:: Copyright (c) 2015
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

require 'openssl'

# Default location of install-dir is /opt/unifiedpush/. This path is set during build time.
# DO NOT change this value unless you are building your own Unifiedpush packages
install_dir = node['package']['install-dir']
ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

server_dir = node['unifiedpush']['unifiedpush-server']['dir']

directory server_dir do
  owner "root"
  group node['unifiedpush']['user']['group']
  mode "0775"
  action :nothing
end.run_action(:create)

execute 'extract_wildfly_8.2.1' do
  command "tar xzvf #{install_dir}/embedded/apps/wildfly/wildfly-8.2.1.Final.tar.gz"
  cwd "#{server_dir}"
  not_if { File.exists?(server_dir + "/README.txt") }
end
