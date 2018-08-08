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
postgresql_user = account_helper.postgresql_user
postgresql_password = account_helper.postgresql_password

# NOTE: These recipes are written idempotently, but require a running
# PostgreSQL service.  They should run each time (on the appropriate
# backend machine, of course), because they also handle schema
# upgrades for new releases of AeroBase.  As a result, we can't
# just do a check against node['unifiedpush']['bootstrap']['enable'],
# which would only run them one time.
if node['unifiedpush']['unifiedpush-server']['db_adapter'] == 'postgresql'
  ruby_block "wait for postgresql to start" do
    block do
      pg_helper = PgHelper.new(node)
      connectable = false
      2.times do |i|
        # Note that we have to include the port even for a local pipe, because the port number
        # is included in the pipe default.
		
        if !pg_helper.psql_cmd(["-d \"postgres\"", "-c \"SELECT * FROM pg_database\" -t -A"], postgresql_user, postgresql_password)
          Chef::Log.fatal("Could not connect to database, retrying in 10 seconds.")
          sleep 10
        else
          connectable = true
          break
        end
      end

      unless connectable
        Chef::Log.fatal <<-ERR
Could not connect to the postgresql database.
Please check /var/log/unifiedpush/posgresql/current for more information.
ERR
        exit!(1)
      end
    end
  end
end
  
include_recipe "aerobase::postgresql_user_and_db"