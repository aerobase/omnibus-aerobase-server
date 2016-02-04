#
# Copyright:: Copyright (c) 2015.
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

install_dir = node['package']['install-dir']
database_name = node['unifiedpush']['unifiedpush-server']['db_database']

dependent_services = []
#dependent_services << "service[unifiedpush-server]" if OmnibusHelper.should_notify?("unicorn")

execute "initialize unifiedpush-server database" do
  cwd "#{install_dir}/embedded/apps/unifiedpush/initdb/bin"
  command "./init-unifiedpush-db.sh #{database_name}"
  action :nothing
end

execute "initialize keycloak-server database" do
  # just a dummy command - TODO create keyclock tables at installation time
  command "/sbin/sysctl -e -p /etc/sysctl.conf"
  action :nothing
end
