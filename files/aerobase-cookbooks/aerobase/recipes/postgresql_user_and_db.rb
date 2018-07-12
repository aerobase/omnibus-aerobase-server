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

###
# Create the database, migrate it, and create the users we need, and grant them
# privileges.
###
pg_helper = PgHelper.new(node)
account_helper = AccountHelper.new(node)
os_helper = OsHelper.new(node)

postgresql_socket_dir = node['unifiedpush']['postgresql']['unix_socket_directory']
pg_port = node['unifiedpush']['postgresql']['port']
pg_user = account_helper.postgresql_user
pg_password = account_helper.postgresql_password
bin_dir = node['unifiedpush']['postgresql']['bin_dir']
database_name = node['unifiedpush']['unifiedpush-server']['db_database']
keycloak_database_name = node['unifiedpush']['keycloak-server']['db_database']
keycloak_database_username = node['unifiedpush']['keycloak-server']['db_username']

databases = []
if node['unifiedpush']['unifiedpush-server']['enable']
  databases << ['unifiedpush-server', database_name, node['unifiedpush']['postgresql']['sql_user']]
end

if node['unifiedpush']['keycloak-server']['enable']
  databases << ['unifiedpush-server', keycloak_database_name, keycloak_database_username]
end

databases.each do |unifiedpush_app, db_name, sql_user|
  execute "create user #{sql_user} for database #{db_name}" do
    command "#{bin_dir}/psql --port #{pg_port} -h #{postgresql_socket_dir} -d \"postgres\" -c \"CREATE USER #{sql_user}\""
    user pg_user
	if os_helper.is_windows?
	  password pg_password
	end
    # Added retries to give the service time to start on slower systems
    retries 20
    not_if { pg_helper.user_exists?(sql_user, pg_user, pg_password) }
  end

  execute "create #{db_name} database" do
    command "#{bin_dir}/createdb --port #{pg_port} -h #{postgresql_socket_dir} -O #{sql_user} -E UTF8 #{db_name}"
    user pg_user
    if os_helper.is_windows?
	  password pg_password
	end
    not_if { pg_helper.database_exists?(db_name, pg_user, pg_password) }
    retries 30
  end
end
