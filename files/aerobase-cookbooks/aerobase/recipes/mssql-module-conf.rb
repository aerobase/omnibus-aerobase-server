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

# Default location of install-dir is /opt/aerobase/. This path is set during build time.
# DO NOT change this value unless you are building your own Aerobase packages

os_helper = OsHelper.new(node)

db_helper = DBHelper.new(node)

install_dir = node['package']['install-dir']
server_dir = node['unifiedpush']['aerobase-server']['dir']
modules_dir = "#{server_dir}/lib/lib/main"

account_helper = AccountHelper.new(node)
aerobase_user = account_helper.aerobase_user
aerobase_group = account_helper.aerobase_group

file_seperator = "//"
if os_helper.is_windows?
  file_seperator = "///"
end

remote_file "Copy mssql driver file" do
  path "#{modules_dir}/mssql-jdbc-12.2.0.jre11.jar"
  source "file:#{file_seperator}#{install_dir}/embedded/apps/mssql/mssql-jdbc-12.2.0.jre11.jar"
  owner aerobase_user
  group aerobase_group
  mode 0755
end

# Copy MSSQL jdbc driver only if mssql is used
ruby_block 'copy_mssql_jdbc_driver' do
  block do
    FileUtils.cp_r "#{install_dir}/embedded/apps/mssql/.", "#{server_dir}/bin/mssql"
  end
  action :run
  only_if { db_helper.is_mssql? }
end

