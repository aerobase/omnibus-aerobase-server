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

add_command 'uninstall', 'Run uninstall script', 2 do |cmd_name, props|
  # Default location of install-dir is /opt/aerobase/. This path is set during build time.
  # DO NOT change this value unless you are building your own Aerobase packages
  if !::File.exists? "#{etc_path}/aerobase.rb" then
    abort('It looks like aerobase has not been installed yet; skipping the uninstall '\
      'script.')
  end
  destructive = false
  if !props.nil? 
    if props != "destructive" 
      abort("Unknown command properties: #{props}, only destructive flag is allowed")
	else
	  destructive = true
	end
  end	
    
  conf = File.open("#{base_path}/embedded/cookbooks/uninstall.json", "w")
  conf.puts "{ \"destructive\": #{destructive} }"
  conf.close
  
  status = run_chef("#{base_path}/embedded/cookbooks/uninstall.json", "-l fatal -F null -o recipe[aerobase::uninstall]")
  File.delete("#{base_path}/embedded/cookbooks/uninstall.json")
  
  log <<EOS

Uninstall complete! If your Aerobase server is misbehaving try running

   sudo aerobase-ctl restart

before anything else. 
EOS
end
