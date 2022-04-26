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

###
# Create the database, migrate it, and create the users we need, and grant them
# privileges.
###
mysql_helper = MySQLHelper.new(node)

keycloak_database_name = node['unifiedpush']['keycloak-server']['db_database']
keycloak_database_username = node['unifiedpush']['keycloak-server']['db_username']
keycloak_database_password = node['unifiedpush']['keycloak-server']['db_password']

databases = []
if node['unifiedpush']['keycloak-server']['enable']
  databases << ['aerobase-server', keycloak_database_name, keycloak_database_username, keycloak_database_password]
end

grant_cmd = "ALL"
if mysql_helper.selective_privileges
  grant_cmd = "SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER"
end 

databases.each do |unifiedpush_app, db_name, sql_user, sql_pass|
  execute "create #{db_name} database" do
    command "#{mysql_helper.mysql_cmd(["CREATE DATABASE IF NOT EXISTS #{db_name} CHARACTER SET utf8 COLLATE utf8_unicode_ci;"])}"

    not_if { mysql_helper.database_exists?(db_name) }
    retries 5
  end

  execute "create user #{sql_user}@localhost for database #{db_name}" do
    command "#{mysql_helper.mysql_cmd(["CREATE USER IF NOT EXISTS '#{sql_user}'@'localhost' IDENTIFIED BY '#{sql_pass}';"])}"
    # Added retries to give the service time to start on slower systems
    retries 3
  end

  execute "create user #{sql_user}@% for database #{db_name}" do
    command "#{mysql_helper.mysql_cmd(["CREATE USER IF NOT EXISTS '#{sql_user}'@'%' IDENTIFIED BY '#{sql_pass}';"])}"
    # Added retries to give the service time to start on slower systems
    retries 3
  end

  execute "grant all to user '#{sql_user}'@'localhost' for database #{db_name}" do
    command "#{mysql_helper.mysql_cmd(["GRANT #{grant_cmd} ON #{db_name}.* TO '#{sql_user}'@'localhost';"])}"
    # Added retries to give the service time to start on slower systems
    retries 3
  end


  execute "grant all to user '#{sql_user}'@'%' for database #{db_name}" do
    command "#{mysql_helper.mysql_cmd(["GRANT #{grant_cmd} ON #{db_name}.* TO '#{sql_user}'@'%';"])}"
    # Added retries to give the service time to start on slower systems
    retries 3
  end
end

