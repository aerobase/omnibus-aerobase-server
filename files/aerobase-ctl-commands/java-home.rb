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

# Usage example:  aerobase-ctl.bat java-home"
require 'rbconfig'
@os = RbConfig::CONFIG['host_os']

add_command 'java-home', 'Add JAVA_HOME to env', 2 do |cmd_name, props|  
  # Default location of install-dir is /opt/aerobase/. This path is set during build time.
  # DO NOT change this value unless you are building your own Aerobase packages
  if !::File.exists? "#{etc_path}/aerobase.rb" then
    abort('It looks like aerobase has not been installed yet; skipping the java home '\
      'script.')
  end
  
  status = run_chef("#{base_path}/embedded/cookbooks/java-home.json", "-l fatal -F null")
  exit! status.success? ? 0 : 1
end