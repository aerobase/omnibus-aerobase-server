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

# Copy mariadb JDBC driver
remote_file "Copy mariadb driver file" do
  path "#{modules_dir}/mariadb-java-client-2.4.4.jar"
  source "file:#{file_seperator}#{install_dir}/embedded/apps/mariadb/mariadb-java-client-2.4.4.jar"
  owner aerobase_user
  group aerobase_group
  mode 0755
end
