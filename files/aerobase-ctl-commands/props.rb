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

# Usage example:  aerobase-ctl.bat prop "aerobase_server.db_adapter=mssql;;aerobase_server.db_sslmode=111"
# Output: unifiedpush_se+rver['db_adapter']="mssql"
# Output: aerobase_server['db_sslmode']=111

def is_numeric?(s)
  begin
    Float(s)
  rescue
    false # not numeric
  else
    true # numeric
  end
end

def is_boolean?(s)
  if s == 'true' || s == 'false'
    return true
  else
    return false
  end
end

add_command 'prop', 'Update default aerobase properties', 2 do |cmd_name, props|
  
  # Default location of install-dir is /opt/aerobase/. This path is set during build time.
  # DO NOT change this value unless you are building your own Aerobase packages
  if !::File.exists? "#{etc_path}/aerobase.rb" then
    abort('It looks like aerobase has not been installed yet; skipping the update '\
      'script.')
  end
  
  if props.nil? 
    abort('Missing input properties')
  end	
  
  tokens = props.split(";;")
  if !tokens.any?
    abort("Input #{tokens} is missing required properties") 
  end	
  
  # Backup config file
  FileUtils.cp("#{etc_path}/aerobase.rb", "#{etc_path}/aerobase.rb-" + Time.now.strftime("%Y-%m-%d-%H%M%S"))
   
  conf = File.open("#{etc_path}/aerobase.rb", File::RDWR)
  lines = conf.readlines
  conf.close

  # Reopen file to clear previous content
  conf = File.open("#{etc_path}/aerobase.rb", 'w')
  
  lines.each do |line|
    match=false
	
    tokens.each { |token| 
	  prop = token.split("=")
	  
	  # For single level prop use space as equality. 
	  # nonly 'external_url' should be declared in a single level.
	  equality=" "
	  
	  # Convert token to regex expression
	  if prop[0].include? "."
	    # Case for two levels props, e.g 'aerobase_server.db_sslrootcert'
	    prop[0] = prop[0].sub(".", "\\['") + "'\\]"
		equality = " = "
	  end
	  
	  # Wrap property key as regex $
	  regex = ".*(" + prop[0] + ").*"
	  
	  # Extract regex $1
	  part = line[/#{regex}/,1]
	  
	  if prop.length < 2
		# Empty String 
		prop << ""
	  end 
	  
	  if !part.nil? && !part.empty?
	    # Evaluate boolean, numeric or array values 
		if is_boolean?(prop[1]) || is_numeric?(prop[1]) || prop[1].start_with?("[")
  	      conf.puts part + equality + prop[1]
		else
		  conf.puts part + equality + "\"" + prop[1] + "\""
		end
		match = true
	  end
	}
	if !match
	  conf.puts line
	end 
  end
  conf.close
end
