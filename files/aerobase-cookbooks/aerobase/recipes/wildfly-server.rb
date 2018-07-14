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

install_dir = node['package']['install-dir']
server_dir = node['unifiedpush']['unifiedpush-server']['dir']
server_log_dir = node['unifiedpush']['unifiedpush-server']['log_directory']
server_doc_dir = node['unifiedpush']['unifiedpush-server']['documents_directory']
server_upl_dir = node['unifiedpush']['unifiedpush-server']['uploads_directory']
server_etc_dir = "#{server_dir}/etc"

account_helper = AccountHelper.new(node)
aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

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
    group aerobase_group
    mode '0775'
    recursive true
  end
end

ruby_block 'copy_wildfly_sources' do
  block do
	FileUtils.cp_r "#{install_dir}/embedded/cookbooks/aerobase/files/default/wildfly/.", "#{server_dir}"
  end
  action :run
end

# Link logrotate gir to wildfly log dir
link "#{server_log_dir}/logs" do
  to "#{server_dir}/standalone/log"
end

