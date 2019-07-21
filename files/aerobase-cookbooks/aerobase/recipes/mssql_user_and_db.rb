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
mssql_helper = MsSQLHelper.new(node)

unifiedpush_database_name = node['unifiedpush']['aerobase-server']['db_database']
unifiedpush_database_username = node['unifiedpush']['aerobase-server']['db_username']
keycloak_database_name = node['unifiedpush']['keycloak-server']['db_database']
keycloak_database_username = node['unifiedpush']['keycloak-server']['db_username']

databases = []
if node['unifiedpush']['unifiedpush-server']['enable']
  databases << ['aerobase-server', 
				unifiedpush_database_name, 
				unifiedpush_database_username
			   ]
end

if node['unifiedpush']['keycloak-server']['enable']
  databases << ['aerobase-server', 
			    keycloak_database_name, 
				keycloak_database_username
			   ]
end

databases.each do |unifiedpush_app, db_name, sql_user|
  execute "create #{db_name} database" do
    command "#{mssql_helper.mssql_cmd(["\"CREATE DATABASE [#{db_name}] CONTAINMENT = NONE;\""])}"    

    not_if { mssql_helper.database_exists?(db_name) }
    retries 5
  end
  
  execute "create login #{sql_user} for database #{db_name}" do
    command "#{mssql_helper.mssql_cmd(["\"CREATE LOGIN [#{sql_user}] WITH PASSWORD=N'#{sql_user}', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF\""])}"    
    # Added retries to give the service time to start on slower systems
    retries 5
    not_if { mssql_helper.login_exists?(sql_user) }
  end
  
  execute "add roles to login #{sql_user} for database #{db_name}" do
    command "#{mssql_helper.mssql_cmd(["\"USE [#{db_name}]; ALTER SERVER ROLE [setupadmin] ADD MEMBER #{sql_user}; ALTER SERVER ROLE [processadmin] ADD MEMBER #{sql_user};\""])}"    
    # Added retries to give the service time to start on slower systems
    retries 5
    not_if { mssql_helper.user_exists?(sql_user, db_name) }
  end
 
  execute "add database user #{sql_user} for database #{db_name}" do
    command "#{mssql_helper.mssql_cmd(["\"USE [#{db_name}]; CREATE USER [#{sql_user}] FOR LOGIN [#{sql_user}]\""])}"    
    # Added retries to give the service time to start on slower systems
    retries 5
    not_if { mssql_helper.user_exists?(sql_user, db_name) }
  end 

  execute "add database role db_owner for user #{sql_user}" do
    command "#{mssql_helper.mssql_cmd(["\"USE [#{db_name}]; ALTER ROLE [db_owner] ADD MEMBER #{sql_user};\""])}"    
    # Added retries to give the service time to start on slower systems
    retries 5
  end
end
