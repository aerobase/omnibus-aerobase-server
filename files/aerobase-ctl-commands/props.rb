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
  
  # example=".*(unifiedpush_server\\['db_sslrootcert'\\]).*"

  File.readlines('C:/Aerobase/Configuration/aerobase.rb').each do |line|
    match = false
    tokens.each { |token| 
	  prop = token.split("=")
	  if !prop.any? || prop.length < 2
        abort("Property #{token} requires left hand and right hand elements!")
      end	
	  # Convert token to regex expression
	  regex = ".*(" + prop[0].sub(".", "['") + "']).*"
	  regex = regex.sub("[", "\\[").sub("]", "\\]")
	  part = line[/#{regex}/,1]
	  
	  if part
	    # Evaluate boolean or numeric values 
		if is_boolean?(prop[1]) || is_numeric?(prop[1])
  	      puts part + "=" + prop[1]
		else
		  puts part + "=\"" + prop[1] + "\""
		end
		match = true
	  end
	}
	if !match
	  puts line
	end 
  end
end

