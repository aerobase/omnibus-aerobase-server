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

# Usage example:  aerobase-ctl.bat recover master_password"

add_command 'recover', 'Add keycloak master realm admin user', 2 do |cmd_name, props|
  
  # Default location of install-dir is /opt/aerobase/. This path is set during build time.
  # DO NOT change this value unless you are building your own Aerobase packages
  if !::File.exists? "#{etc_path}/aerobase.rb" then
    abort('It looks like aerobase has not been installed yet; skipping the recover '\
      'script.')
  end
  
  if props.nil? 
    abort('Missing input password, Usage example: aerobase-ctl recover master_password')
  end
  
  conf = File.open("#{base_path}/embedded/cookbooks/add-keycloak-user.json", "w")
  conf.puts "{ \"keycloak_admin_password\": \"#{props}\",  \"keycloak_admin_user\": \"admin\", \"keycloak_admin_realm\": \"master\" }"
  conf.close
  
  # /add-keycloak-user.json run list will be overridden by -o f run_list 
  status = run_chef("#{base_path}/embedded/cookbooks/add-keycloak-user.json", "-l fatal -F null -o recipe[aerobase::add-keycloak-user]")
  File.delete("#{base_path}/embedded/cookbooks/add-keycloak-user.json")
  
  exit! status.success? ? 0 : 1  
end