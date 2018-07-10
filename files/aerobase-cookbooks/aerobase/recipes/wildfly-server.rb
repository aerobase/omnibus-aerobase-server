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

require 'openssl'

server_dir = node['unifiedpush']['unifiedpush-server']['dir']
server_log_dir = node['unifiedpush']['unifiedpush-server']['log_directory']
server_doc_dir = node['unifiedpush']['unifiedpush-server']['documents_directory']
server_upl_dir = node['unifiedpush']['unifiedpush-server']['uploads_directory']
server_etc_dir = "#{server_dir}/etc"

account_helper = AccountHelper.new(node)
aerobase_user = account_helper.aerobase_user

unifiedpush_vars = node['unifiedpush']['unifiedpush-server'].to_hash
global_vars = node['unifiedpush']['global'].to_hash
all_vars = unifiedpush_vars.merge(global_vars)

# These directories do not need to be writable for unifiedpush-server
[ 
  server_dir,
  server_log_dir,
  server_doc_dir, 
  server_upl_dir,
  server_etc_dir
].each do |dir_name|
  directory dir_name do
    owner aerobase_user
    group 'root'
    mode '0775'
    recursive true
  end
end

# Always re-extract wildfly and recreate configuration.
execute 'extract_wildfly' do
  command "tar xzvf #{install_dir}/embedded/apps/wildfly/wildfly-11.0.0.Final.tar.gz --strip-components 1"
  cwd "#{server_dir}"
end

# Link logrotate gir to wildfly log dir
link "#{server_log_dir}/logs" do
  to "#{server_dir}/standalone/log"
end